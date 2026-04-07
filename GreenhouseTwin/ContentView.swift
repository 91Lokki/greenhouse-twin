import SwiftUI

struct ContentView: View {
    let appModel: AppModel

    var body: some View {
        MainControlWindowView(appModel: appModel)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(appModel: AppModel())
}
