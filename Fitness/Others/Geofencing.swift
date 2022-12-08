import Foundation
import CoreLocation

class Geofencing {

    public func persistLocation(for location: CLLocationCoordinate2D, locationAddress: String) {

        let id: TimeInterval = Date().timeIntervalSince1970

        KeychainService.persist(service: StorageKeys.geofencing.rawValue, account: "\(StorageKeys.latitude.rawValue)\(id)", data: "\(location.latitude)")
        KeychainService.persist(service: StorageKeys.geofencing.rawValue, account: "\(StorageKeys.longitude.rawValue)\(id)", data: "\(location.longitude)")
        KeychainService.persist(service: StorageKeys.geofencing.rawValue, account: "\(StorageKeys.address.rawValue)\(id)", data: locationAddress)
        KeychainService.persist(service: StorageKeys.geofencingKeys.rawValue, account: "\(id)", data: "\(id)")
    }

    public func getAllGeofencingLocations() -> [CLLocation] {
        var keyList = [String]()
        var coordinateList = [CLLocation]()

        let temporaryKeyList: [String] = KeychainService.getAll(targetService: StorageKeys.geofencingKeys.rawValue)

        for item in temporaryKeyList {
            keyList.append(item)
        }

        if keyList.isEmpty {
            return coordinateList
        }

        for index in 0...keyList.count - 1 {
            if let latitude: String = KeychainService.load(service: StorageKeys.geofencing.rawValue, account: "\(StorageKeys.latitude.rawValue)\(keyList[index])"),
               let longitude: String = KeychainService.load(service: StorageKeys.geofencing.rawValue, account: "\(StorageKeys.longitude.rawValue)\(keyList[index])") {
                coordinateList.append(CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!))
            }
        }

        return coordinateList
    }
}