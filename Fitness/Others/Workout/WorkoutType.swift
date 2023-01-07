import Foundation

class WorkoutType {

    //MARK: -
    class func getTemporaryWorkoutType() -> String? {
        guard UserDefaults.standard.object(forKey: StorageKeys.temporaryWorkoutType.rawValue) != nil else {
            return nil
        }

        return UserDefaults.standard.getDecrypted(StorageKeys.temporaryWorkoutType.rawValue)
    }

    class func persistTemporaryWorkoutType(workoutType: String) {
        UserDefaults.standard.persistEncrypted(workoutType, forKey: StorageKeys.temporaryWorkoutType.rawValue)
    }

    //MARK: -

    class func getName(type: String?) -> String? {
        return getWorkout(type: type)?.name.localized()
    }

    class func getWorkout(type: String?) -> Workout? {
        if type == nil {
            return nil
        }

        for item in WorkoutConfig.shared.workouts {
            if item.name == type {
                return item
            }
        }

        return nil
    }

    //MARK: -

    class func getWorkoutType(id: String) -> String? {
        guard UserDefaults.standard.object(forKey: StorageKeys.saveWorkoutType.rawValue + id) != nil else {
            return nil
        }

        return UserDefaults.standard.getDecrypted(StorageKeys.saveWorkoutType.rawValue + id)
    }

    class func persistWorkoutType(type: String, _ id: String) {
        UserDefaults.standard.persistEncrypted(type, forKey: StorageKeys.saveWorkoutType.rawValue + id)
    }
}