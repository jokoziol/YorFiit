import WidgetKit
import SwiftUI

@main
struct WorkoutLiveTrackerBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            WorkoutLiveTrackerLiveActivity()
        }
    }
}
