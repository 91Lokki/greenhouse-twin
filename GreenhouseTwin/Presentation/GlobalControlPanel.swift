import SwiftUI

struct GlobalControlPanel: View {
    enum Density {
        case window
        case spatial
    }

    let model: GlobalControlPanelModel
    var density: Density = .window
    var onTogglePlayback: () -> Void
    var onStep: () -> Void
    var onReset: () -> Void

    var body: some View {
        FloatingPanelSurface(
            title: density == .window ? "Simulation Controls" : "Global Controls",
            subtitle: density == .window ? model.scenarioName : "In-space stepping for the current greenhouse state.",
            width: density == .spatial ? 470 : nil,
            contentSpacing: density == .spatial ? 20 : 18
        ) {
            VStack(alignment: .leading, spacing: density == .spatial ? 18 : 16) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Simulated Time")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(model.timestamp)
                            .font(density == .window ? .title2.weight(.semibold) : .title3.weight(.semibold))
                            .monospacedDigit()
                    }

                    Spacer()

                    Text(model.isRunning ? "Running" : "Paused")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(model.isRunning ? Color.green.opacity(0.22) : Color.secondary.opacity(0.18))
                        .clipShape(Capsule())
                }

                HStack(spacing: 12) {
                    MetricBadge(title: "Health", value: model.averageHealth, emphasis: density)
                    MetricBadge(title: "Alerts", value: model.alertCount, emphasis: density)
                    MetricBadge(title: "Biomass", value: model.biomassProxy, emphasis: density)
                }

                HStack(spacing: 12) {
                    Button(model.isRunning ? "Pause" : "Play") {
                        onTogglePlayback()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(density == .window ? .large : .regular)

                    Button("Step") {
                        onStep()
                    }
                    .buttonStyle(.bordered)
                    .disabled(model.isRunning)
                    .controlSize(density == .window ? .large : .regular)

                    Button("Reset") {
                        onReset()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(density == .window ? .large : .regular)
                }

                Text(model.statusLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct MetricBadge: View {
    var title: String
    var value: String
    var emphasis: GlobalControlPanel.Density

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(emphasis == .window ? .title3.weight(.semibold) : .headline)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
