import Foundation
import ActivityKit

@available(iOS 16.1, *)
class LiveActivityHelper {

    private static weak var workoutActivity: Activity<WorkoutLiveTrackerAttributes>? = nil
    private static var workoutStartDate: Date = Date()

    public static func startWorkoutActivity(_ workoutName: String) {

        workoutStartDate = Date()

        let attributes: WorkoutLiveTrackerAttributes = WorkoutLiveTrackerAttributes(name: workoutName)
        let state: WorkoutLiveTrackerAttributes.ContentState = WorkoutLiveTrackerAttributes.ContentState(startDate: workoutStartDate)

        do {
            workoutActivity = try Activity<WorkoutLiveTrackerAttributes>.request(attributes: attributes, contentState: state, pushType: nil)
        } catch {
            return
        }
    }

    public static func updateWorkoutActivity(distanceString: String?, paceString: String?, caloriesString: String?) {
        let status: WorkoutLiveTrackerAttributes.ContentState = WorkoutLiveTrackerAttributes.ContentState(startDate: workoutStartDate,
                distanceString: distanceString,
                paceString: paceString,
                caloriesString: caloriesString)

        Task {
            await workoutActivity?.update(using: status)
        }
    }

    public static func stopWorkoutActivity() {
        let status: WorkoutLiveTrackerAttributes.ContentState = WorkoutLiveTrackerAttributes.ContentState(startDate: Date.now)

        Task {
            await workoutActivity?.end(using: status, dismissalPolicy: .immediate)
        }
    }
}