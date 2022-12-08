import Foundation
import CoreLocation

class LocationInformation {

    public enum PermissionAuthorization {
        case denied
        case authorized
        case unknown
    }

    let geocoder: CLGeocoder = CLGeocoder()

    public func getCityName(with location: CLLocation, completion: @escaping (String?) -> Void) {

        let timer: Timer = Timer(timeInterval: 2, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)

        geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { placemarks, error in

            guard let place = placemarks?.first, error == nil else {
                completion(nil)
                return
            }

            guard let locationName = place.locality else {
                completion(nil)
                return
            }

            completion(locationName)
        }

        RunLoop.current.add(timer, forMode: .default)
    }

    public func getCityNameAndAddress(with location: CLLocation, completion: @escaping (String?) -> Void) {

        let timer: Timer = Timer(timeInterval: 2, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)

        geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { placemarks, error in

            guard let place = placemarks?.first, error == nil else {
                completion(nil)
                return
            }

            var result: String? = nil

            if let address = place.thoroughfare {
                result = address
            }

            if let cityName = place.locality {

                if result == nil {
                    result = cityName
                } else {
                    result! += ", \(cityName)"
                }
            }

            if result == nil {

                if let country = place.country {
                    result = country
                }
            }

            completion(result)
        }

        RunLoop.current.add(timer, forMode: .default)
    }

    @objc private func timeout() {
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }
    }

    public func mergeLocations(_ name: String, with locationName: String) -> String {

        if name.contains(locationName) || locationName.isEmpty {
            return name
        }

        let previousSavedCity = name

        return !previousSavedCity.contains("-") && previousSavedCity.isEmpty ? "\(locationName)" : "\(previousSavedCity) - \(locationName)"
    }
}