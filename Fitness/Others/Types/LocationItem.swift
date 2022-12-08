import Foundation

struct LocationItem: Identifiable, Hashable {
    let id = UUID()
    let locationId: String
    let name: String

    func remove() {
        KeychainService.delete(service: StorageKeys.geofencing.rawValue, account: "\(StorageKeys.latitude.rawValue)\(locationId)")
        KeychainService.delete(service: StorageKeys.geofencing.rawValue, account: "\(StorageKeys.longitude.rawValue)\(locationId)")
        KeychainService.delete(service: StorageKeys.geofencing.rawValue, account: "\(StorageKeys.address.rawValue)\(locationId)")
        KeychainService.delete(service: StorageKeys.geofencingKeys.rawValue, account: "\(locationId)")
    }
}