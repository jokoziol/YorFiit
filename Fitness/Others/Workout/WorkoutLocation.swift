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

    class func persistCoordinates(coordinates: [WorkoutItemLocation]?,
                                  id: String) {
        if !SettingsInformation.canSaveCoordinates() || coordinates == nil {
            return
        }
        
        guard let json = JsonHelper().toJson(type: coordinates) else{
            return
        }
        
        KeychainService.persist(service: StorageKeys.coordinates.rawValue, account: id, data: json)
    }

    class func deleteCoordinates(id: String) {
        KeychainService.delete(service: StorageKeys.coordinates.rawValue, account: id)
    }

    class func loadCoordinates(id: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        
        guard let json = KeychainService.load(service: StorageKeys.coordinates.rawValue, account: id) else{
            return coordinates
        }
        
        guard let workoutItemLocations = JsonHelper().toObject(type: [WorkoutItemLocation].self, json: json) else{
            return coordinates
        }
        
        for item: WorkoutItemLocation in workoutItemLocations{
            
            coordinates.append(CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude))
        }

        return coordinates
    }
}
