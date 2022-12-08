import Foundation

class WorkoutTime {

    //MARK: -
    class func getTime(id: String) -> Int {

        guard UserDefaults.standard.object(forKey: StorageKeys.saveWorkoutTime.rawValue + id) != nil else {
            return -1
        }

        return UserDefaults.standard.getDecryptedInteger(StorageKeys.saveWorkoutTime.rawValue + id)
    }

    class func getTemporaryTime() -> Int {

        guard UserDefaults.standard.object(forKey: StorageKeys.temporaryTime.rawValue) != nil else {
            return -1
        }

        return UserDefaults.standard.getDecryptedInteger(StorageKeys.temporaryTime.rawValue)
    }

    class func getDailyTime() -> Int {
        return UserDefaults.standard.getDecryptedInteger(StorageKeys.dailyTime.rawValue + Date().getDateString())
    }

    class func persistTime(timeInSeconds: Int, _ workoutId: String) {
        UserDefaults.standard.persistEncrypted(timeInSeconds, forKey: StorageKeys.saveWorkoutTime.rawValue + workoutId)
    }

    class func persistTemporaryTime(timeInSeconds: Int) {
        UserDefaults.standard.persistEncrypted(timeInSeconds, forKey: StorageKeys.temporaryTime.rawValue)
    }

    class func persistDailyTime(timeInSeconds: Int) {
        UserDefaults.standard.persistEncrypted(getDailyTime() + timeInSeconds, forKey: StorageKeys.dailyTime.rawValue + Date().getDateString())
    }

    //MARK: -

    class func getTimeString(timeInSeconds: Int) -> String {

        let timeInMinutes: Int = timeInSeconds.minutes
        let timeInHours: Int = timeInSeconds.hours

        if timeInSeconds <= -1 {
            return "sec".localized(0)
        }

        if timeInHours < 1 && timeInMinutes > 0 {

            return "min".localized(timeInMinutes)
        } else if (timeInMinutes < 1 && timeInHours == 0) {

            return "sec".localized(timeInSeconds)
        } else {

            return "h".localized(timeInHours) + " " + "min".localized(timeInMinutes)
        }
    }

    class func getPace(timeInSeconds: Int, distanceInMeters: Double) -> String? {

        let calculatedPace: Double = floor(Double(timeInSeconds) / (Locale.current.measurementSystem == Locale.MeasurementSystem.metric ? (distanceInMeters / 1000) : ((distanceInMeters / 1000) / 1.60934)))

        if calculatedPace.isInfinite || timeInSeconds <= 0 || distanceInMeters <= 0.0 {
            return nil
        }
        let displayedPace: String = String(format: "%.0f", locale: Locale.current, floor(calculatedPace / 60)) + "'" + String(format: "%02d", locale: Locale.current, Int(floor(((calculatedPace / 60) - floor(calculatedPace / 60)) * 60))) + "''/" + (Locale.current.measurementSystem == Locale.MeasurementSystem.metric ? "km" : "mi")

        return displayedPace
    }

    //MARK: -

    class func getDailyTimeFromDate(dateString: String) -> Int {
        return UserDefaults.standard.getDecryptedInteger(StorageKeys.dailyTime.rawValue + dateString)
    }

    class func getMonthlyTime(_ from: Int) -> Int {
        var time: Int = 0

        for item in Date().getDaysFromMonth(from) {
            if UserDefaults.standard.object(forKey: StorageKeys.dailyTime.rawValue + item.getDateString()) != nil {
                time += getDailyTimeFromDate(dateString: item.getDateString())
            }
        }

        return time
    }

    class func getWeeklyTime() -> Int {
        var time: Int = 0

        for item in Date().getDaysFromWeek() {
            if UserDefaults.standard.object(forKey: StorageKeys.dailyTime.rawValue + item.getDateString()) != nil {
                time += getDailyTimeFromDate(dateString: item.getDateString())
            }
        }
        return time
    }

    //MARK: -

    class func getTimerStartTime() -> Int {

        if UserDefaults.standard.object(forKey: StorageKeys.timerStartTime.rawValue) == nil {
            return Int(Date().timeIntervalSince1970)
        }

        return UserDefaults.standard.getDecryptedInteger(StorageKeys.timerStartTime.rawValue)
    }

    class func saveTimerStartTime(timeInSeconds: Int) {
        UserDefaults.standard.persistEncrypted(timeInSeconds, forKey: StorageKeys.timerStartTime.rawValue)
    }
}