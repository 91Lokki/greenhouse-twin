import SwiftUI

struct TrendLineView: View {
    let values: [Double]
    var strokeColor: Color = .green

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.05))

                midline(in: geometry.size)
                    .stroke(Color.white.opacity(0.09), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

                if values.count > 1 {
                    trendArea(in: geometry.size)
                        .fill(
                            LinearGradient(
                                colors: [strokeColor.opacity(0.26), strokeColor.opacity(0.03)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    trendPath(in: geometry.size)
                        .stroke(strokeColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                } else {
                    Capsule()
                        .fill(strokeColor.opacity(0.7))
                        .frame(width: max(20, geometry.size.width * 0.16), height: 3)
                }
            }
        }
    }

    private var bounds: ClosedRange<Double> {
        let minimum = values.min() ?? 0
        let maximum = values.max() ?? 0

        guard minimum != maximum else {
            let padding = max(abs(minimum) * 0.2, 0.05)
            return (minimum - padding)...(maximum + padding)
        }

        let padding = max((maximum - minimum) * 0.12, 0.02)
        return (minimum - padding)...(maximum + padding)
    }

    private func midline(in size: CGSize) -> Path {
        let plotRect = CGRect(x: 14, y: 10, width: size.width - 28, height: size.height - 20)

        return Path { path in
            path.move(to: CGPoint(x: plotRect.minX, y: plotRect.midY))
            path.addLine(to: CGPoint(x: plotRect.maxX, y: plotRect.midY))
        }
    }

    private func trendPath(in size: CGSize) -> Path {
        let plotRect = CGRect(x: 14, y: 10, width: size.width - 28, height: size.height - 20)
        let points = normalizedPoints(in: plotRect)

        return Path { path in
            guard let first = points.first else {
                return
            }

            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
    }

    private func trendArea(in size: CGSize) -> Path {
        let plotRect = CGRect(x: 14, y: 10, width: size.width - 28, height: size.height - 20)
        let points = normalizedPoints(in: plotRect)

        return Path { path in
            guard let first = points.first, let last = points.last else {
                return
            }

            path.move(to: CGPoint(x: first.x, y: plotRect.maxY))
            path.addLine(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.addLine(to: CGPoint(x: last.x, y: plotRect.maxY))
            path.closeSubpath()
        }
    }

    private func normalizedPoints(in rect: CGRect) -> [CGPoint] {
        guard !values.isEmpty else {
            return []
        }

        let lower = bounds.lowerBound
        let span = max(bounds.upperBound - lower, 0.0001)
        let denominator = max(values.count - 1, 1)

        return values.enumerated().map { index, value in
            let x = rect.minX + (rect.width * CGFloat(index) / CGFloat(denominator))
            let normalized = (value - lower) / span
            let y = rect.maxY - (rect.height * CGFloat(normalized))
            return CGPoint(x: x, y: y)
        }
    }
}
