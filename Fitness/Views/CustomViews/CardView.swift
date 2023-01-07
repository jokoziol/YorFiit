import SwiftUI

public struct CardView<Content>: View where Content: View {

    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack {

            HStack {
                Spacer()

                VStack {
                    content()
                }

                Spacer()
            }
                    .background(Color(UIColor.secondarySystemBackground))
        }
                .cornerRadius(ScreenConfig.cornerRadius).padding(6.0)
    }
}