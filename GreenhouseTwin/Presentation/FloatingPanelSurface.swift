import SwiftUI

struct FloatingPanelSurface<Content: View>: View {
    var title: String?
    var subtitle: String?
    var width: CGFloat?
    var contentSpacing: CGFloat = 18

    private let content: Content

    init(
        title: String? = nil,
        subtitle: String? = nil,
        width: CGFloat? = nil,
        contentSpacing: CGFloat = 18,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.width = width
        self.contentSpacing = contentSpacing
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: contentSpacing) {
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 8) {
                    if let title {
                        Text(title)
                            .font(.title3.weight(.semibold))
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            content
        }
        .frame(width: width, alignment: .leading)
        .padding(24)
        .glassBackgroundEffect(in: .rect(cornerRadius: 30))
    }
}
