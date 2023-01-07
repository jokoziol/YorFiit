import SwiftUI
import CoreLocation

public struct MapViewGroup: View {
    
    private let horizontalItemWidth: Double
    
    private let columns = [GridItem(alignment: .center), GridItem(alignment: .center), GridItem(alignment: .center)]
    
    private var workoutCoordinates = [CLLocationCoordinate2D]()
    
    private var itemTitle, itemOneText, itemTwoText, itemThreeText: String
    
    private var showView: Bool
    
    public init(title: String,
                itemOneText: String,
                itemTwoText: String,
                itemThreeText: String,
                workoutCoordinates: [CLLocationCoordinate2D],
                _ showView: Bool) {
        
        itemTitle = title
        self.itemOneText = itemOneText == "--" ? "" : itemOneText
        self.itemTwoText = itemTwoText == "--" ? "" : itemTwoText
        self.itemThreeText = itemThreeText == "--" ? "" : itemThreeText
        
        self.workoutCoordinates = workoutCoordinates
        
        self.showView = showView
        
        horizontalItemWidth = ScreenConfig().calculateWidthForEachItem(3)
    }
    
    public var body: some View {
        CardView {
            HStack {
                Spacer().frame(width: ScreenConfig.itemSpacing, height: nil, alignment: .leading)
                
                Text(itemTitle)
                    .frame(alignment: .leading)
                    .padding(EdgeInsets(top: ScreenConfig.itemSpacing, leading: 0.0, bottom: ScreenConfig.smallItemSpacing, trailing: 0.0))
                    .font(Font.title2.bold())
                
                Spacer().frame(width: ScreenConfig.itemSpacing, height: nil, alignment: .trailing)
            }
            
            LazyVGrid(columns: self.columns){
                Text(itemOneText)
                    .font(.body)
                    .lineLimit(1)
                
                Text(itemTwoText)
                    .font(.body)
                    .lineLimit(1)
                
                Text(itemThreeText)
                    .font(.body)
                    .lineLimit(1)
            }
            
            if showView && workoutCoordinates.count >= 2 {
                MapView(workoutCoordinates).frame(width: ScreenConfig.itemCardWidth, height: ScreenConfig.itemCardWidth, alignment: .center)
            }
            
            Spacer().frame(width: nil, height: ScreenConfig.itemSpacing, alignment: .trailing)
        }
    }
}
