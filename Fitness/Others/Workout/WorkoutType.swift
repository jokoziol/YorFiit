import Foundation

class WorkoutType {

    //MARK: -
    class func getTemporaryWorkoutType() -> Int {
        guard UserDefaults.standard.object(forKey: StorageKeys.temporaryWorkoutType.rawValue) != nil else {
            return -1
        }

        return UserDefaults.standard.getDecryptedInteger(StorageKeys.temporaryWorkoutType.rawValue)
    }

    class func persistTemporaryWorkoutType(workoutType: Int) {
        UserDefaults.standard.persistEncrypted(workoutType, forKey: StorageKeys.temporaryWorkoutType.rawValue)
    }

    //MARK: -

    class func getName(type: Int) -> String? {
        return getWorkout(type: type)?.name.localized()
    }

    class func getWorkout(type: Int) -> Workout? {
        if type == -1 || type > (WorkoutConfig.shared.workouts.count) - 1 {
            return nil
        }

        for item in WorkoutConfig.shared.workouts {
            if item.id == type {
                return item
            }
        }

        return nil
    }

    //MARK: -

    class func getWorkoutType(id: String) -> Int {
        guard UserDefaults.standard.object(forKey: StorageKeys.saveWorkoutType.rawValue + id) != nil else {
            return -1
        }

        return UserDefaults.standard.getDecryptedInteger(StorageKeys.saveWorkoutType.rawValue + id)
    }

    class func persistWorkoutType(type: Int, _ id: String) {
        UserDefaults.standard.persistEncrypted(type, forKey: StorageKeys.saveWorkoutType.rawValue + id)
    }
}