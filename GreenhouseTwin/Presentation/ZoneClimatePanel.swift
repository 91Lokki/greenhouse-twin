import SwiftUI

struct ZoneClimatePanel: View {
    let model: ZoneClimatePanelModel

    var body: some View {
        FloatingPanelSurface(
            title: model.name,
            subtitle: model.detail,
            width: 410,
            contentSpacing: 18
        ) {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(model.indicators) { indicator in
                    metricSection(indicator)
                }

                Divider()

                Text(model.driftSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func metricSection(_ indicator: ZoneMetricGaugeModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(indicator.title)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(indicator.valueText)
                    .monospacedDigit()
            }
            .font(.title3)

            TargetRangeGauge(indicator: indicator)
                .frame(height: 16)
        }
    }
}

private struct TargetRangeGauge: View {
    let indicator: ZoneMetricGaugeModel

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let markerX = markerPosition(in: width)
            let overshootWidth = max(18, min(width * 0.45, width * (0.12 + (indicator.deviationRatio * 0.24))))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))

                Capsule()
                    .fill(Color.green.opacity(0.22))

                if indicator.deviationDirection == .belowTarget {
                    Capsule()
                        .fill(statusColor)
                        .frame(width: overshootWidth)
                }

                if indicator.deviationDirection == .aboveTarget {
                    HStack {
                        Spacer(minLength: 0)
                        Capsule()
                            .fill(statusColor)
                            .frame(width: overshootWidth)
                    }
                }

                Circle()
                    .fill(indicator.deviationDirection == .withinTarget ? Color.green : statusColor)
                    .frame(width: 16, height: 16)
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.9), lineWidth: 2)
                    }
                    .position(x: markerX, y: geometry.size.height / 2.0)
            }
        }
    }

    private var statusColor: Color {
        indicator.deviationRatio > 0.45 ? .red : .orange
    }

    private func markerPosition(in width: CGFloat) -> CGFloat {
        let clamped = min(max(indicator.positionRatio, 0.0), 1.0)
        return min(max(width * clamped, 8), width - 8)
    }
}
