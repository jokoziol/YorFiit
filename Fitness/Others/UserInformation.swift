import Foundation

class UserInformation {

    //MARK: -
    class func persistUsername(username: String) {

        if username.count >= 50 {
            return
        }

        KeychainService.persist(service: StorageKeys.userSettings.rawValue, account: StorageKeys.username.rawValue, data: username)
    }

    class func getUsername() -> String {
        guard let username = KeychainService.load(service: StorageKeys.userSettings.rawValue, account: StorageKeys.username.rawValue) else {
            return "Username"
        }

        return username
    }

    //MARK: -

    class func persistHeight(height: Double) {

        if height <= 0 {
            return
        }

        if Locale.current.measurementSystem == Locale.MeasurementSystem.metric {
            KeychainService.persist(service: StorageKeys.userSettings.rawValue, account: StorageKeys.height.rawValue, data: "\(height)")
            return
        }

        let heightInFeet = Measurement(value: height, unit: UnitLength.feet)
        let heightInCentimeter = heightInFeet.converted(to: .meters)

        KeychainService.persist(service: StorageKeys.userSettings.rawValue, account: StorageKeys.height.rawValue, data: "\(heightInCentimeter.value)")
    }

    class func getHeight() -> Double {
        guard let heightString = KeychainService.load(service: StorageKeys.userSettings.rawValue, account: StorageKeys.height.rawValue) else {
            return 1.70
        }
        guard let height = Double(heightString) else {
            return 1.70
        }

        return height
    }

    class func getFormattedHeight() -> String {
        let formatter = LengthFormatter()
        formatter.isForPersonHeightUse = true
        formatter.unitStyle = .short

        return formatter.string(fromMeters: getHeight())
    }

    class func getFormattedHeightFromMeters(_ height: Double) -> String {

        let formatter = LengthFormatter()
        formatter.numberFormatter.usesGroupingSeparator = false

        if Locale.current.measurementSystem == Locale.MeasurementSystem.metric {
            return formatter.string(fromValue: height, unit: .meter)
        }

        let heightInMeter = Measurement(value: height, unit: UnitLength.meters).converted(to: .feet)

        return formatter.string(fromValue: heightInMeter.value, unit: .foot)
    }

    //MARK: -

    class func persistWeight(weight: Double) {

        if weight <= 0 {
            return
        }

        if Locale.current.measurementSystem == Locale.MeasurementSystem.metric {
            KeychainService.persist(service: StorageKeys.userSettings.rawValue, account: StorageKeys.weight.rawValue, data: "\(weight)")
            return
        }

        let weightMeasurement = Measurement(value: weight, unit: UnitMass.pounds)
        let weightInKilogram = weightMeasurement.converted(to: .kilograms)

        KeychainService.persist(service: StorageKeys.userSettings.rawValue, account: StorageKeys.weight.rawValue, data: "\(weightInKilogram.value)")
    }

    class func getWeight() -> Double {
        guard let weightString = KeychainService.load(service: StorageKeys.userSettings.rawValue, account: StorageKeys.weight.rawValue) else {
            return 75.0
        }
        guard let weight = Double(weightString) else {
            return 75.0
        }

        return weight
    }

    class func getFormattedWeight() -> String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.usesGroupingSeparator = false

        let weightMeasurement = Measurement(value: getWeight(), unit: UnitMass.kilograms)

        return formatter.string(from: weightMeasurement)
    }

    //MARK: -

    class func launchedForFirstTime() -> Bool {
        !UserDefaults.standard.bool(forKey: StorageKeys.launchedForFirstTime.rawValue)
    }

    class func launchedFirstTime() {
        UserDefaults.standard.set(true, forKey: StorageKeys.launchedForFirstTime.rawValue)
    }

    class func resetInProgress() -> Bool {
        UserDefaults.standard.bool(forKey: StorageKeys.resetInProgress.rawValue)
    }

    class func resetInProgress(_ progress: Bool) {
        UserDefaults.standard.set(progress, forKey: StorageKeys.resetInProgress.rawValue)
    }
}