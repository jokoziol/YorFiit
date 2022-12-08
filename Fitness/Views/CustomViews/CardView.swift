import SwiftUI

public struct CardView<Content>: View where Content: View {

    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack {
            VStack {
                content()
            }
                    .background(Color(UIColor.secondarySystemBackground))
        }
                .cornerRadius(ScreenConfig.cornerRadius)
                .frame(width: ScreenConfig.cardWidth, alignment: .center)
    }
}