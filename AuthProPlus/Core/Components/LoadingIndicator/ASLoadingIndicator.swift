//
//  ASLoadingIndicator.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/7/26.
//

import SwiftUI

/// A custom circular loading indicator with a subtly varying rotation rate,
/// similar to modern iOS spinners.
///
/// The indicator renders a stroked circular arc whose sweep length grows and
/// shrinks while the whole shape rotates. The rotation speed is modulated over
/// time to avoid a perfectly constant spin, giving it a more organic feel.
struct ASLoadingIndicator: View {
    /// The diameter of the spinner in points.
    let size: CGFloat
    /// The stroke width of the spinner.
    let lineWidth: CGFloat
    /// The color of the spinner.
    let color: Color

    init(size: CGFloat = 24, lineWidth: CGFloat = 4, color: Color = .primary) {
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let angle = rotationAngle(time: t)
            let sweep = sweepFraction(time: t)

            Circle()
                .trim(from: 0, to: sweep)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(angle))
                .accessibilityLabel("Loading")
                .accessibilityAddTraits(.isImage)
        }
    }
}

private extension ASLoadingIndicator {
    // Produces a rotation angle (in degrees) with a varying rate over time.
    func rotationAngle(time t: TimeInterval) -> Double {
        // Base rotation: full turn every 1.2 seconds
        let basePeriod: Double = 1.2
        let base = (t / basePeriod) * 360.0

        // Modulate speed with a sine wave to create subtle accelerations/decelerations
        let modulationPeriod: Double = 2.0
        let amplitude: Double = 90.0 // degrees of modulation
        let variable = amplitude * sin((2 * .pi / modulationPeriod) * t)

        // Keep angle within 0...360 for numerical stability
        return (base + variable).truncatingRemainder(dividingBy: 360.0)
    }

    // Oscillates the arc length between ~20% and ~60% of the circle.
    func sweepFraction(time t: TimeInterval) -> CGFloat {
        let minSweep: Double = 0.20
        let maxSweep: Double = 0.60
        let sweepPeriod: Double = 1.0
        let normalized = (sin((2 * .pi / sweepPeriod) * t) + 1) / 2 // 0...1
        return CGFloat(minSweep + (maxSweep - minSweep) * normalized)
    }
}

#Preview {
    VStack(spacing: 24) {
        ASLoadingIndicator()
        ASLoadingIndicator(size: 48, lineWidth: 6, color: .primaryBlue)
    }
    .padding()
}
