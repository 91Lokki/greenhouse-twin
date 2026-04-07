import SwiftUI

struct FloatingPanelSurface<Content: View>: View {
    var title: String?
    var subtitle: String?
    var width: CGFloat?

    private let content: Content

    init(
        title: String? = nil,
        subtitle: String? = nil,
        width: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.width = width
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 6) {
                    if let title {
                        Text(title)
                            .font(.headline)
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            content
        }
        .frame(width: width, alignment: .leading)
        .padding(20)
        .glassBackgroundEffect(in: .rect(cornerRadius: 28))
    }
}
