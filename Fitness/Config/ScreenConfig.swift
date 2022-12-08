import Foundation
import UIKit

public class ScreenConfig {

    public static let screenWidth = UIScreen.main.bounds.width
    public static let screenHeight = UIScreen.main.bounds.height

    public static let itemCardWidth: Double = screenWidth - (4 * itemSpacing)
    public static let titleWidth: Double = screenWidth - smallItemSpacing
    public static let cardWidth: Double = screenWidth - (2 * itemSpacing)

    public static let smallSpacing: Double = 16.0
    public static let mediumSpacing: Double = 24.0
    public static let largeSpacing: Double = 32.0

    public static let itemSpacing: Double = 8.0
    public static let smallItemSpacing: Double = itemSpacing / 2

    public static let cornerRadius: Double = 8.0

    public init() {

    }

    public func calculateWidthForEachItem(_ maxItems: Int) -> Double {
        (ScreenConfig.itemCardWidth / Double(maxItems) - ScreenConfig.itemSpacing)
    }

    public func calculateWidthForEachItem(containerWidth: Double, _ maxItems: Int) -> Double {
        (containerWidth / Double(maxItems) - ScreenConfig.itemSpacing)
    }
}