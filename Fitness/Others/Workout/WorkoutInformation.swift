import Foundation
import CoreLocation

class WorkoutInformation {

    public static var workout: WorkoutHelper?

    class func startWorkout(workoutType: String) {

        workout = WorkoutHelper(startDate: Date(), type: workoutType)

        //Reset temporary data
        deleteTemporaryWorkout()
    }

    class func stopWorkout() -> (WorkoutItem?, [CLLocationCoordinate2D]?) {

        workout?.endDate = Date()

        let timeDifference: Int = Int(workout?.endDate?.timeIntervalSince(workout?.startDate ?? Date()) ?? 0) - (workout?.pausedWorkoutTime ?? 0)

        WorkoutTime.persistDailyTime(timeInSeconds: timeDifference)
        WorkoutDistance.persistDailyDistance(distanceInMeters: workout?.distance ?? 0.0)

        let coordinates: [CLLocationCoordinate2D]? = !WorkoutDistance.shouldDisplaySwimLaps(workoutType: workout?.type ?? nil) ? workout?.coordinateList : nil
        let workoutItem: WorkoutItem? = workout?.getWorkoutItem()

        workout = nil

        return (workoutItem, coordinates)
    }

    //MARK: -

    public class func persistTemporaryWorkout(_ workout: WorkoutItem, _ workoutCoordinates: [CLLocationCoordinate2D]?) {

        if !SettingsInformation.showLastTraining() {
            deleteTemporaryWorkout()
            return
        }

        WorkoutTime.persistTemporaryTime(timeInSeconds: workout.timeInSeconds)
        WorkoutDistance.persistTemporaryDistance(distanceInMeters: workout.distanceInMeters)
        WorkoutType.persistTemporaryWorkoutType(workoutType: workout.type!)

        WorkoutLocation.deleteCoordinates(id: "")
        WorkoutLocation.persistCoordinates(coordinates: workout.locations, id: "")
    }

    class func persistWorkout(_ workout: WorkoutItem) {

        let workoutId = String(workout.startDate.timeIntervalSince1970)
        
        let workoutItem = WorkoutItem(workoutId: workoutId,
                                      placeNames: workout.placeNames,
                                      startDate: workout.startDate,
                                      type: workout.type,
                                      timeInSeconds: workout.timeInSeconds,
                                      calories: workout.calories,
                                      distanceInMeters: workout.distanceInMeters,
                                      locations: workout.locations)
        
        guard let json = JsonHelper().toJson(type: workoutItem) else{
            return
        }
        
        KeychainService.persist(service: StorageKeys.workoutKey.rawValue, account: workoutId, data: json)
    }

    class func deleteWorkout(id: String) {
        KeychainService.delete(service: StorageKeys.workoutKey.rawValue, account: id)
    }

    public class func deleteTemporaryWorkout() {
        UserDefaults.standard.removeObject(forKey: StorageKeys.temporaryTime.rawValue)
        UserDefaults.standard.removeObject(forKey: StorageKeys.temporaryWorkoutType.rawValue)
        UserDefaults.standard.removeObject(forKey: StorageKeys.temporaryDistance.rawValue)

        WorkoutLocation.deleteCoordinates(id: "")
    }

    // MARK: -

    class func workoutStarted() -> Bool {
        return workout != nil
    }
}
