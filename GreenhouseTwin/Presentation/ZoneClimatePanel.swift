import SwiftUI

struct ZoneClimatePanel: View {
    let model: ZoneClimatePanelModel

    var body: some View {
        FloatingPanelSurface(
            title: model.name,
            subtitle: model.detail,
            width: 320
        ) {
            VStack(alignment: .leading, spacing: 12) {
                metricRow("Temperature", model.temperature)
                metricRow("Humidity", model.humidity)
                metricRow("Light", model.light)
                metricRow("Substrate", model.moisture)

                Divider()

                Text(model.driftSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func metricRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .monospacedDigit()
        }
        .font(.body)
    }
}
