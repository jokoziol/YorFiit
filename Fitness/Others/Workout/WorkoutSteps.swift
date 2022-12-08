import Foundation

class WorkoutSteps {

    //MARK: -
    class func persistDailySteps(steps: Double) {
        UserDefaults.standard.persistEncrypted(getDailySteps() + steps, forKey: StorageKeys.dailySteps.rawValue + Date().getDateString())
    }

    class func persistDailySteps(date: String, steps: Double) {
        let alreadySavedSteps: Double = getDailySteps(dateString: date)

        UserDefaults.standard.persistEncrypted(alreadySavedSteps + steps, forKey: StorageKeys.dailySteps.rawValue + date)
    }

    class func getDailySteps() -> Double {
        return UserDefaults.standard.getDecryptedDouble(StorageKeys.dailySteps.rawValue + Date().getDateString())
    }

    class func getDailySteps(dateString: String) -> Double {
        return UserDefaults.standard.getDecryptedDouble(StorageKeys.dailySteps.rawValue + dateString)
    }

    class func getStepsString(steps: Double) -> String {

        if steps <= -1.0 {
            return "steps".localized(0.0)
        }

        return "steps".localized(steps)
    }

    //MARK: -

    class func getMonthlySteps(_ from: Int) -> Double {
        var steps: Double = 0.0

        for item in Date().getDaysFromMonth(from) {
            if UserDefaults.standard.object(forKey: StorageKeys.dailySteps.rawValue + item.getDateString()) != nil {
                steps = steps + getDailySteps(dateString: item.getDateString())
            }
        }

        return steps
    }

    class func getWeeklySteps() -> Double {
        var steps: Double = 0.0

        for item in Date().getDaysFromWeek() {
            if UserDefaults.standard.object(forKey: StorageKeys.dailySteps.rawValue + item.getDateString()) != nil {
                steps = steps + getDailySteps(dateString: item.getDateString())
            }
        }

        return steps
    }
}