import Foundation

class SettingsInformation {

    class func persistShowHeartRate(_ showHeartRate: Bool) {
        UserDefaults.standard.set(showHeartRate, forKey: StorageKeys.showHeartRate.rawValue)
    }

    class func showHeartRate() -> Bool {

        if UserDefaults.standard.object(forKey: StorageKeys.showHeartRate.rawValue) != nil {
            return UserDefaults.standard.bool(forKey: StorageKeys.showHeartRate.rawValue)
        }

        return false
    }

    class func persistShowLastTraining(_ showLastTraining: Bool) {
        UserDefaults.standard.set(showLastTraining, forKey: StorageKeys.showLastWorkout.rawValue)
    }

    class func showLastTraining() -> Bool {

        if UserDefaults.standard.object(forKey: StorageKeys.showLastWorkout.rawValue) != nil {
            return UserDefaults.standard.bool(forKey: StorageKeys.showLastWorkout.rawValue)
        }

        return true
    }

    class func persistShowBestWorkout(_ showBestWorkout: Bool) {
        UserDefaults.standard.set(showBestWorkout, forKey: StorageKeys.showBestWorkout.rawValue)
    }

    class func showBestWorkout() -> Bool {

        if UserDefaults.standard.object(forKey: StorageKeys.showBestWorkout.rawValue) != nil {
            return UserDefaults.standard.bool(forKey: StorageKeys.showBestWorkout.rawValue)
        }

        return true
    }

    class func persistShowWorkout(_ showWorkout: Bool) {
        UserDefaults.standard.set(showWorkout, forKey: StorageKeys.showWorkout.rawValue)
    }

    class func showWorkout() -> Bool {

        if UserDefaults.standard.object(forKey: StorageKeys.showWorkout.rawValue) != nil {
            return UserDefaults.standard.bool(forKey: StorageKeys.showWorkout.rawValue)
        }

        return true
    }

    class func persistGetBodyMass(_ getBodyMass: Bool) {
        UserDefaults.standard.set(getBodyMass, forKey: StorageKeys.getBodyMass.rawValue)
    }

    class func canGetBodyMass() -> Bool {

        if UserDefaults.standard.object(forKey: StorageKeys.getBodyMass.rawValue) != nil {
            return UserDefaults.standard.bool(forKey: StorageKeys.getBodyMass.rawValue)
        }

        return false
    }

    class func persistCanSaveCoordinates(_ canSaveCoordinates: Bool) {
        UserDefaults.standard.set(canSaveCoordinates, forKey: StorageKeys.saveCoordinates.rawValue)
    }

    class func canSaveCoordinates() -> Bool {

        if UserDefaults.standard.object(forKey: StorageKeys.saveCoordinates.rawValue) != nil {
            return UserDefaults.standard.bool(forKey: StorageKeys.saveCoordinates.rawValue)
        }

        return true
    }
}