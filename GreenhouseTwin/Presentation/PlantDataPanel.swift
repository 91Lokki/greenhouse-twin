import SwiftUI

struct PlantDataPanel: View {
    let model: PlantDataPanelModel

    private let metrics = [
        ("Stage", \PlantDataPanelModel.stage),
        ("Health", \PlantDataPanelModel.health),
        ("Biomass", \PlantDataPanelModel.biomass),
        ("Growth", \PlantDataPanelModel.growthRate)
    ]

    var body: some View {
        FloatingPanelSurface(
            title: model.name,
            subtitle: "\(model.speciesName) in \(model.zoneName)",
            width: 420,
            contentSpacing: 18
        ) {
            VStack(alignment: .leading, spacing: 16) {
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(metrics, id: \.0) { title, keyPath in
                        metricCard(title, model[keyPath: keyPath])
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Growth Trend")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Last \(model.growthTrend.count) steps")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    TrendLineView(
                        values: model.growthTrend,
                        strokeColor: model.isDead ? .red : trendColor
                    )
                    .frame(height: 86)
                }

                Divider()

                HStack {
                    Text(model.isPinned ? "Pinned panel" : "Focus panel")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(model.isDead ? .red : (model.isPinned ? .green : .secondary))
                    Spacer()
                    Text(panelInstruction)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }

    private func metricCard(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var panelInstruction: String {
        if model.isDead {
            return "Plant no longer responds to environment"
        }
        return model.isPinned ? "Tap plant to unpin" : "Tap plant to pin"
    }

    private var trendColor: Color {
        guard let latest = model.growthTrend.last else {
            return .green
        }

        return latest >= 0 ? .green : .orange
    }
}
