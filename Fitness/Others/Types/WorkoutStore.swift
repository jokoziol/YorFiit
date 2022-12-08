import Foundation

class WorkoutStore: ObservableObject {
    @Published var workoutItems = [WorkoutItem]()

    func load() {

        workoutItems.removeAll()

        var workoutList = [String]()

        for item in KeychainService.getAll(targetService: StorageKeys.workoutKeys.rawValue) {
            if item != "" {
                workoutList.append(item)
            }
        }

        let sortedList = workoutList.sorted {
            $0 > $1
        }

        for item in sortedList {

            let workoutTimeInSeconds: Int = WorkoutTime.getTime(id: item)
            let workoutType: Int = WorkoutType.getWorkoutType(id: item)
            let workoutDistanceInMeters: Double = WorkoutDistance.getDistance(id: item)
            let workoutCalories: Double = WorkoutCalories.getCalories(workoutType: workoutType, timeInSeconds: workoutTimeInSeconds, distanceInMeters: workoutDistanceInMeters)
            let startDate = Date(timeIntervalSince1970: Double(item) ?? 0.0)
            let placeNames = WorkoutLocation.getLocation(id: item)

            workoutItems.append(WorkoutItem(workoutId: item,
                    placeNames: placeNames,
                    startDate: startDate,
                    type: workoutType,
                    timeInSeconds: workoutTimeInSeconds,
                    calories: workoutCalories,
                    distanceInMeters: workoutDistanceInMeters))
        }
    }

    func remove(_ workoutId: String) {

        for index in 0...workoutItems.count - 1 {

            if workoutItems[index].workoutId == workoutId {
                workoutItems.remove(at: index)
                return
            }
        }
    }
}