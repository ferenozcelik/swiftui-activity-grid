import SwiftUI

/// A showcase page. Made to fit one iPhone screen; scrolls on smaller ones.
struct ShowcasePage<Content: View>: View {
    let title: String
    let caption: String
    @ViewBuilder let content: Content

    init(_ title: String, caption: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.caption = caption
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(caption)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                content
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .frame(maxWidth: 600, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

/// One example: a short name, the code that makes it, then the view.
struct Specimen<Content: View>: View {
    let name: String?
    let code: String
    @ViewBuilder let content: Content

    init(_ name: String? = nil, code: String, @ViewBuilder content: () -> Content) {
        self.name = name
        self.code = code
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                if let name {
                    Text(name).font(.footnote.weight(.semibold))
                }
                CodeLabel(code)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A small line of code.
struct CodeLabel: View {
    let code: String

    init(_ code: String) {
        self.code = code
    }

    var body: some View {
        Text(code)
            .font(.caption2.monospaced())
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// A block of code on a tinted background.
struct CodeBox: View {
    let code: String
    var font: Font = .caption.monospaced()

    init(_ code: String, font: Font = .caption.monospaced()) {
        self.code = code
        self.font = font
    }

    var body: some View {
        Text(code)
            .font(font)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

/// A small gray heading inside a page.
struct GroupHeading: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}
