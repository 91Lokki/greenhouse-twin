import SwiftUI

struct MainControlWindowView: View {
    let appModel: AppModel

    @Environment(\.dismissImmersiveSpace)
    private var dismissImmersiveSpace

    @Environment(\.openImmersiveSpace)
    private var openImmersiveSpace

    private var viewModel: GreenhouseExperienceViewModel {
        appModel.experienceViewModel
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                header
                immersivePanel

                GlobalControlPanel(
                    model: viewModel.globalControlModel,
                    density: .window,
                    onTogglePlayback: viewModel.togglePlayback,
                    onStep: viewModel.step,
                    onReset: viewModel.reset
                )
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.study.title)
                .font(.largeTitle.weight(.bold))
                .fontWeight(.semibold)
            Text(viewModel.greenhouse.description)
                .font(.title3)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("Window controls stay available while the immersive greenhouse is open.")
                .font(.callout)
                .foregroundStyle(.tertiary)
        }
    }

    private var immersivePanel: some View {
        FloatingPanelSurface(
            title: "Immersive Greenhouse",
            subtitle: "Open the shared spatial scene and inspect plant or zone data in place.",
            contentSpacing: 18
        ) {
            VStack(alignment: .leading, spacing: 14) {
                Button(immersiveButtonTitle) {
                    Task {
                        await toggleImmersiveSpace()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(appModel.immersivePhase == .opening)
                .controlSize(.large)

                Text(appModel.immersivePhase.statusText)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }
        }
    }

    private var immersiveButtonTitle: String {
        switch appModel.immersivePhase {
        case .closed, .error:
            return "Enter Greenhouse"
        case .opening:
            return "Entering..."
        case .open:
            return "Exit Greenhouse"
        }
    }

    private var statusColor: Color {
        switch appModel.immersivePhase {
        case .error:
            return .red
        case .opening:
            return .orange
        case .open:
            return .green
        case .closed:
            return .secondary
        }
    }

    @MainActor
    private func toggleImmersiveSpace() async {
        switch appModel.immersivePhase {
        case .closed, .error:
            appModel.markImmersiveOpening()

            let result = await openImmersiveSpace(id: AppModel.immersiveSpaceID)

            switch result {
            case .opened:
                appModel.markImmersiveOpen()
            case .userCancelled:
                appModel.markImmersiveClosed()
            case .error:
                appModel.markImmersiveError("Unable to enter the immersive greenhouse.")
            @unknown default:
                appModel.markImmersiveError("The immersive state returned an unknown result.")
            }
        case .opening:
            return
        case .open:
            await dismissImmersiveSpace()
            appModel.markImmersiveClosed()
        }
    }
}

#Preview(windowStyle: .automatic) {
    MainControlWindowView(appModel: AppModel())
}
