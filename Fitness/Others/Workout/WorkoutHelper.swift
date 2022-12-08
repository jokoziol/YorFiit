import Foundation
import CoreLocation

class WorkoutHelper {

    public let startDate: Date
    public var endDate: Date?

    public var placeNames: String?

    public let type: Int
    public var distance: Double?

    public var coordinateList: [CLLocationCoordinate2D]?

    init(startDate: Date, type: Int) {
        self.startDate = startDate
        self.type = type
    }

    public func getWorkoutItem() -> WorkoutItem {

        let timeInSeconds: Int = Int(endDate?.timeIntervalSince(startDate) ?? 0.0)
        let calories: Double = WorkoutCalories.getCalories(workoutType: type, timeInSeconds: timeInSeconds, distanceInMeters: distance ?? 0.0)

        return WorkoutItem(workoutId: nil,
                placeNames: placeNames,
                startDate: startDate,
                type: type,
                timeInSeconds: timeInSeconds,
                calories: calories,
                distanceInMeters: distance ?? 0.0)
    }
}
