//
//  CircularVisualizerView.swift
//  waveform
//
//  Created by shimizu on 2025/04/08.
//

import SwiftUI

struct CircularVisualizerView: View {
    @ObservedObject var audioManager = AudioManager.shared

    let barCount = 64

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius: CGFloat = min(size.width, size.height) / 4

            for i in 0..<barCount {
                let angle = 2 * .pi * CGFloat(i) / CGFloat(barCount)

                let amp = CGFloat(min(audioManager.amplitudes[i] * 500, 100))
                let barLength = 30 + amp

                let start = CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )

                let end = CGPoint(
                    x: center.x + cos(angle) * (radius + barLength),
                    y: center.y + sin(angle) * (radius + barLength)
                )

                var path = Path()
                path.move(to: start)
                path.addLine(to: end)

                let hue = CGFloat(i) / CGFloat(barCount)
                let color = Color(hue: Double(hue), saturation: 1.0, brightness: 1.0)
                context.stroke(path, with: .color(color), lineWidth: 2)
            }
        }
        .background(Color.clear)
        .ignoresSafeArea()
    }
}
