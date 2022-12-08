import Foundation
import ActivityKit

struct WorkoutLiveTrackerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var startDate: Date

        var distanceString: String?
        var paceString: String?
        var caloriesString: String?
    }

    // Fixed non-changing properties about your activity go here!

    var name: String
}
