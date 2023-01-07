import Foundation

class WorkoutDistance {

    //MARK: - Daily Distance
    class func getDailyDistance() -> Double {
        return UserDefaults.standard.getDecryptedDouble(StorageKeys.dailyDistance.rawValue + Date().getDateString())
    }

    class func persistDailyDistance(distanceInMeters: Double) {
        UserDefaults.standard.persistEncrypted(getDailyDistance() + distanceInMeters, forKey: StorageKeys.dailyDistance.rawValue + Date().getDateString())
    }

    //MARK: - Temporary Distance

    class func getTemporaryDistance() -> Double {

        guard UserDefaults.standard.object(forKey: StorageKeys.temporaryDistance.rawValue) != nil else {
            return -1.0
        }
        return UserDefaults.standard.getDecryptedDouble(StorageKeys.temporaryDistance.rawValue)
    }

    class func persistTemporaryDistance(distanceInMeters: Double) {
        return UserDefaults.standard.persistEncrypted(distanceInMeters, forKey: StorageKeys.temporaryDistance.rawValue)
    }

    //MARK: -

    class func persistDistance(distanceInMeters: Double, _ id: String) {
        UserDefaults.standard.persistEncrypted(distanceInMeters, forKey: StorageKeys.saveWorkoutDistance.rawValue + id)
    }

    class func getDistance(id: String) -> Double {
        return UserDefaults.standard.getDecryptedDouble(StorageKeys.saveWorkoutDistance.rawValue + id)
    }

    class func shouldDisplayDistance(workoutType: String?) -> Bool {
        return WorkoutType.getWorkout(type: workoutType)?.usesLocation ?? false
    }

    class func shouldDisplaySwimLaps(workoutType: String?) -> Bool {
        return WorkoutType.getWorkout(type: workoutType)?.usesDistance ?? false
    }

    class func getSwimLaps(distanceInMeters: Double) -> String {

        if distanceInMeters < 0.0 {
            return "laps".localized(0.0)
        }

        return "laps".localized(Int(distanceInMeters / 25.0))
    }

    class func getDistanceString(distanceInMeters: Double) -> String {

        let measurementFormatter: MeasurementFormatter = MeasurementFormatter()

        if distanceInMeters > 0.0 {
            measurementFormatter.unitOptions = .naturalScale
        }

        if distanceInMeters < 0.0 {
            let distance: Measurement<UnitLength> = Measurement(value: 0.0, unit: UnitLength.meters)
            return measurementFormatter.string(from: distance)
        }

        let distance: Measurement<UnitLength> = Measurement(value: distanceInMeters, unit: UnitLength.meters)
        return measurementFormatter.string(from: distance)
    }

    class func getAverageDistanceString(distanceInMeters: Double, time: Int) -> String? {

        if distanceInMeters < 0.0 || time < 0 {
            return nil
        }

        let measurementFormatter: MeasurementFormatter = MeasurementFormatter()
        measurementFormatter.unitStyle = .medium

        let distance: Measurement<UnitSpeed> = Measurement(value: ((distanceInMeters / Double(time)) * 3.6), unit: UnitSpeed.kilometersPerHour)
        return measurementFormatter.string(from: distance)
    }

    class func getDailyDistanceFromDate(dateString: String) -> Double {
        return UserDefaults.standard.getDecryptedDouble(StorageKeys.dailyDistance.rawValue + dateString)
    }

    class func getMonthlyDistance(_ from: Int) -> Double {
        var distance: Double = 0.0

        for item in Date().getDaysFromMonth(from) {
            if UserDefaults.standard.object(forKey: StorageKeys.dailyDistance.rawValue + item.getDateString()) != nil {
                distance += getDailyDistanceFromDate(dateString: item.getDateString())
            }
        }

        return distance
    }

    class func getWeeklyDistance() -> Double {
        var distance: Double = 0.0

        for item in Date().getDaysFromWeek() {
            if UserDefaults.standard.object(forKey: StorageKeys.dailyDistance.rawValue + item.getDateString()) != nil {
                distance += getDailyDistanceFromDate(dateString: item.getDateString())
            }
        }

        return distance
    }
}