import Foundation
import CoreLocation

class WorkoutLocation {

    //MARK: - Location
    class func getLocation(id: String) -> String {
        guard let cityName: String = UserDefaults.standard.getDecrypted(StorageKeys.saveWorkoutLocation.rawValue + id) else {
            return ""
        }

        return cityName
    }

    class func persistLocation(locationName: String, _ id: String) {
        UserDefaults.standard.persistEncrypted(locationName, forKey: StorageKeys.saveWorkoutLocation.rawValue + id)
    }

    //MARK: - Coordinates

    class func persistCoordinates(coordinates: [CLLocationCoordinate2D]?,
                                  id: String) {
        if !SettingsInformation.canSaveCoordinates() || coordinates == nil {
            return
        }

        var count: Int = 0

        for item in coordinates! {
            count += 1

            let latitude: String = String(format: "%f", item.latitude)
            let longitude: String = String(format: "%f", item.longitude)

            KeychainService.persist(service: StorageKeys.coordinates.rawValue, account: StorageKeys.latitude.rawValue + String(count) + id, data: latitude)
            KeychainService.persist(service: StorageKeys.coordinates.rawValue, account: StorageKeys.longitude.rawValue + String(count) + id, data: longitude)
            KeychainService.persist(service: StorageKeys.locationKeys.rawValue, account: id, data: String(count))
        }
    }

    class func deleteCoordinates(id: String) {

        guard let countString: String = KeychainService.load(service: StorageKeys.locationKeys.rawValue, account: "\(id)") else {
            return
        }

        guard let count: Int = Int(countString) else {
            return
        }

        guard count > 0 else {
            return
        }

        KeychainService.delete(service: StorageKeys.locationKeys.rawValue, account: "\(id)")

        for i in 1...count {
            KeychainService.delete(service: StorageKeys.coordinates.rawValue, account: "\(StorageKeys.latitude.rawValue)\(i)\(id)")
            KeychainService.delete(service: StorageKeys.coordinates.rawValue, account: "\(StorageKeys.longitude.rawValue)\(i)\(id)")
        }
    }

    class func loadCoordinates(id: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []

        guard let countString: String = KeychainService.load(service: StorageKeys.locationKeys.rawValue, account: "\(id)") else {
            return coordinates
        }

        guard let count: Int = Int(countString) else {
            return coordinates
        }

        guard count > 0 else {
            return coordinates
        }

        for i in 1...count {

            guard let latitudeString: String = KeychainService.load(service: StorageKeys.coordinates.rawValue, account: "\(StorageKeys.latitude.rawValue)\(i)\(id)"),
                  let longitudeString: String = KeychainService.load(service: StorageKeys.coordinates.rawValue, account: "\(StorageKeys.longitude.rawValue)\(i)\(id)")
            else {
                continue
            }

            guard let latitude: Double = Double(latitudeString),
                  let longitude: Double = Double(longitudeString)
            else {
                continue
            }

            coordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }

        return coordinates
    }
}