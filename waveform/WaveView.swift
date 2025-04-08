//
//  WaveView.swift
//  waveform
//
//  Created by shimizu on 2025/04/08.
//

import SwiftUI

struct WaveView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let path = wavePath(width: size.width, height: size.height, phase: phase)
                context.stroke(path, with: .color(.cyan), lineWidth: 2)
            }
        }
        .background(Color.clear)
        .onAppear {
            // タイマーで定期的に更新してみる（アニメーションが反映されないとき用）
            Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                phase += 0.1
            }
        }
    }

    func wavePath(width: CGFloat, height: CGFloat, phase: CGFloat) -> Path {
        var path = Path()
        let midY = height / 2
        let amplitude: CGFloat = 40
        let frequency: CGFloat = 2

        path.move(to: CGPoint(x: 0, y: midY))
        for x in stride(from: 0, through: width, by: 1) {
            let angle = frequency * (x / width) * 2 * .pi + phase
            let y = sin(angle) * amplitude + midY
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}
