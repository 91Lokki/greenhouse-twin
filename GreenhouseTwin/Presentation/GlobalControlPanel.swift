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
            width: density == .spatial ? 380 : nil
        ) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Simulated Time")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(model.timestamp)
                            .font(density == .window ? .title3.weight(.semibold) : .headline)
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

                HStack(spacing: 10) {
                    MetricBadge(title: "Health", value: model.averageHealth)
                    MetricBadge(title: "Alerts", value: model.alertCount)
                    MetricBadge(title: "Biomass", value: model.biomassProxy)
                }

                HStack(spacing: 12) {
                    Button(model.isRunning ? "Pause" : "Play") {
                        onTogglePlayback()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Step") {
                        onStep()
                    }
                    .buttonStyle(.bordered)
                    .disabled(model.isRunning)

                    Button("Reset") {
                        onReset()
                    }
                    .buttonStyle(.bordered)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
