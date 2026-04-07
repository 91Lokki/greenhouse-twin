import SwiftUI

struct PlantDataPanel: View {
    let model: PlantDataPanelModel

    var body: some View {
        FloatingPanelSurface(
            title: model.name,
            subtitle: "\(model.speciesName) in \(model.zoneName)",
            width: 320
        ) {
            VStack(alignment: .leading, spacing: 12) {
                metricRow("Stage", model.stage)
                metricRow("Health", model.health)
                metricRow("Biomass", model.biomass)
                metricRow("Growth", model.growthRate)

                Divider()

                HStack {
                    Text(model.isPinned ? "Pinned panel" : "Focus panel")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(model.isPinned ? .green : .secondary)
                    Spacer()
                    Text(model.isPinned ? "Tap plant to unpin" : "Tap plant to pin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
