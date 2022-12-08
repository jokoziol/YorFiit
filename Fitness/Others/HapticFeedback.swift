import Foundation
import UIKit

enum Vibration {

    case error
    case success

    public func vibrate() {

        switch self {

        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)

        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)

        }
    }
}