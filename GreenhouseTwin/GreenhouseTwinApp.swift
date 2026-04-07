import SwiftUI

@main
struct GreenhouseTwinApp: App {
    @State private var appModel = AppModel()
    @State private var immersionStyle: any ImmersionStyle = .progressive

    var body: some Scene {
        WindowGroup {
            ContentView(appModel: appModel)
        }
        .defaultSize(width: 620, height: 540)

        ImmersiveSpace(id: AppModel.immersiveSpaceID) {
            GreenhouseSpatialOverview(viewModel: appModel.experienceViewModel)
                .onAppear {
                    appModel.markImmersiveOpen()
                }
                .onDisappear {
                    appModel.markImmersiveClosed()
                }
        }
        .immersionStyle(selection: $immersionStyle, in: .progressive)
    }
}
