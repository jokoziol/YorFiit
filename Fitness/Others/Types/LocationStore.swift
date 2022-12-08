import Foundation

class LocationStore: ObservableObject {
    @Published var locationList = [LocationItem]()

    func load() {

        locationList.removeAll()

        for item in KeychainService.getAll(targetService: StorageKeys.geofencingKeys.rawValue) {

            if let currentRegion = KeychainService.load(service: StorageKeys.geofencing.rawValue, account: "\(StorageKeys.address.rawValue)\(item)") {
                locationList.append(LocationItem(locationId: item, name: currentRegion))
            }
        }
    }

    func remove(_ locationId: String) {

        for index in 0...locationList.count - 1 {

            if locationList[index].locationId == locationId {
                locationList.remove(at: index)
                return
            }
        }
    }
}