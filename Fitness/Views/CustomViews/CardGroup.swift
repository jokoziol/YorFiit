import SwiftUI

public struct CardGroup: View {

    private var itemTitle: String
    private var itemText: String

    public init(title: String, text: String) {
        itemTitle = title
        itemText = text
    }

    public var body: some View {

        CardView {
            HStack {
                Spacer().frame(width: ScreenConfig.itemSpacing, height: nil, alignment: .leading)

                Text(itemTitle)
                        .frame(width: ScreenConfig.itemCardWidth, height: nil, alignment: .leading)
                        .padding(EdgeInsets(top: ScreenConfig.itemSpacing, leading: 0.0, bottom: ScreenConfig.itemSpacing, trailing: 0.0))
                        .font(Font.title2.bold())

                Spacer().frame(width: ScreenConfig.itemSpacing, height: nil, alignment: .trailing)
            }

            HStack {
                Spacer().frame(width: ScreenConfig.itemSpacing, height: nil, alignment: .leading)

                Text(itemText)
                        .frame(width: ScreenConfig.itemCardWidth, height: nil, alignment: .leading)
                        .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: ScreenConfig.itemSpacing, trailing: 0.0))
                        .font(.body)

                Spacer().frame(width: ScreenConfig.itemSpacing, height: nil, alignment: .trailing)
            }
        }
    }
}