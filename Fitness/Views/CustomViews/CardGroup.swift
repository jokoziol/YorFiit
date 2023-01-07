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
                //Spacer().frame(width: ScreenConfig.itemSpacing, height: nil, alignment: .leading)

                GeometryReader { proxy in
                    Text(itemTitle)
                            .frame(width: proxy.size.width, alignment: .leading)
                            .padding(EdgeInsets(top: ScreenConfig.itemSpacing, leading: 0.0, bottom: 0.0, trailing: 0.0))
                            .font(.caption)
                }

                //Spacer().frame(width: ScreenConfig.itemSpacing, height: nil, alignment: .trailing)
            }

            Spacer().frame(height: ScreenConfig.itemSpacing * 2)

            HStack {
                Text(itemText)
                        .frame(alignment: .leading)
                        .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: ScreenConfig.itemSpacing, trailing: 0.0))
                        .font(.title)
            }
        }
    }
}