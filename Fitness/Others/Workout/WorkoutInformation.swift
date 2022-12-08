import Foundation
import CoreLocation

class WorkoutInformation {

    public static var workout: WorkoutHelper?

    class func startWorkout(workoutType: Int) {

        workout = WorkoutHelper(startDate: Date(), type: workoutType)

        //Reset temporary data
        deleteTemporaryWorkout()
    }

    class func stopWorkout() -> (WorkoutItem?, [CLLocationCoordinate2D]?) {

        workout?.endDate = Date()

        let timeDifference: Int = Int(workout?.endDate?.timeIntervalSince(workout?.startDate ?? Date()) ?? 0)

        WorkoutTime.persistDailyTime(timeInSeconds: timeDifference)
        WorkoutDistance.persistDailyDistance(distanceInMeters: workout?.distance ?? 0.0)

        let coordinates: [CLLocationCoordinate2D]? = !WorkoutDistance.shouldDisplaySwimLaps(workoutType: workout?.type ?? -1) ? workout?.coordinateList : nil
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
        WorkoutType.persistTemporaryWorkoutType(workoutType: workout.type)

        WorkoutLocation.deleteCoordinates(id: "")
        WorkoutLocation.persistCoordinates(coordinates: workoutCoordinates, id: "")
    }

    class func persistWorkout(_ workout: WorkoutItem, _ workoutCoordinates: [CLLocationCoordinate2D]?) {

        let workoutId = String(workout.startDate.timeIntervalSince1970)

        WorkoutTime.persistTime(timeInSeconds: workout.timeInSeconds, workoutId)
        WorkoutDistance.persistDistance(distanceInMeters: workout.distanceInMeters, workoutId)
        WorkoutType.persistWorkoutType(type: workout.type, workoutId)
        WorkoutLocation.persistLocation(locationName: workout.placeNames ?? "", workoutId)

        KeychainService.persist(service: StorageKeys.workoutKeys.rawValue, account: workoutId, data: workoutId)

        WorkoutLocation.persistCoordinates(coordinates: workoutCoordinates, id: workoutId)
    }

    class func deleteWorkout(id: String) {

        UserDefaults.standard.removeObject(forKey: StorageKeys.saveWorkoutTime.rawValue + id)
        UserDefaults.standard.removeObject(forKey: StorageKeys.saveWorkoutDistance.rawValue + id)
        UserDefaults.standard.removeObject(forKey: StorageKeys.saveWorkoutType.rawValue + id)
        UserDefaults.standard.removeObject(forKey: StorageKeys.saveWorkoutLocation.rawValue + id)

        KeychainService.delete(service: StorageKeys.workoutKeys.rawValue, account: id)

        WorkoutLocation.deleteCoordinates(id: id)
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