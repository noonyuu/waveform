//
//  AudioManager.swift
//  waveform
//
//  Created by shimizu on 2025/04/09.
//

import AVFoundation
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var engine = AVAudioEngine()
    private var isCapturing = false
    
    // 振幅
    @Published var amplitudes: [Float] = Array(repeating: 0.0, count: 64)
    
    private init() {
        requestMicrophoneAccess()
    }
    
    private func requestMicrophoneAccess() {
        // macOSでのマイク権限リクエスト
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("マイク許可取得: 開始します")
                    self.start()
                }
            } else {
                print("マイク権限が拒否されました")
            }
        }
    }
    
    func start() {
        if isCapturing {
            print("既に録音中です")
            return
        }

        if engine.isRunning {
            engine.stop()
        }
        engine = AVAudioEngine()

        let inputNode = engine.inputNode
        let bus = 0
        let bufferSize: AVAudioFrameCount = 1024

        // 明示的にモノラルフォーマットに変換
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                   sampleRate: 48000,
                                   channels: 1,
                                   interleaved: false)!

        inputNode.removeTap(onBus: bus) // 念のためtapクリア
        inputNode.installTap(onBus: bus, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
            print("installTap: buffer.frameLength = \(buffer.frameLength)")

            guard let self = self,
                  let channelData = buffer.floatChannelData?[0] else {
                return
            }

            var newAmplitudes: [Float] = []
            let frameCount = Int(buffer.frameLength)
            let samplesPerBar = max(1, frameCount / 64)

            for i in 0..<64 {
                let start = i * samplesPerBar
                let end = min((i + 1) * samplesPerBar, frameCount)
                var sum: Float = 0
                for j in start..<end {
                    let sample = channelData[j]
                    sum += sample * sample
                }
                let rms = sqrt(sum / Float(max(1, end - start)))
                newAmplitudes.append(rms)
            }

            DispatchQueue.main.async {
                self.amplitudes = newAmplitudes
                if !newAmplitudes.allSatisfy({ $0 == 0 }) {
                    print("音声信号検出: \(newAmplitudes[0])")
                }
            }
        }

        do {
            try engine.start()
            isCapturing = true
            print("オーディオエンジン開始成功")
        } catch {
            print("オーディオエンジン開始失敗: \(error)")
        }
    }
    
    func stop() {
        if engine.isRunning {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
            isCapturing = false
            print("オーディオエンジン停止")
        }
    }
    
    deinit {
        stop()
    }
}
