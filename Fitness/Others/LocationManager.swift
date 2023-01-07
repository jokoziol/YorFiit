import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    public static let shared: LocationManager = LocationManager()
    private let locationManager: CLLocationManager = CLLocationManager()

    private let maxHorizontalAccuracy: Double = 50.0

    private var workoutLocations: [CLLocation] = [CLLocation]()

    public func startUpdating() {
        removeAll()

        if !WorkoutDistance.shouldDisplayDistance(workoutType: WorkoutInformation.workout?.type ?? nil) && !WorkoutDistance.shouldDisplaySwimLaps(workoutType: WorkoutInformation.workout?.type ?? nil) {
            return
        }

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.distanceFilter = 25
        locationManager.activityType = .fitness
        locationManager.startUpdatingLocation()

        startMonitoringRegions()
    }

    public func stopUpdating() {
        locationManager.stopUpdatingLocation()

        stopMonitoringRegions()
    }

    public func removeAll() {
        workoutLocations.removeAll()
    }

    private func startMonitoringRegions() {
        let monitoredRegions = locationManager.monitoredRegions

        for region in monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }

        for item in Geofencing().getAllGeofencingLocations() {
            let geofenceRegion = CLCircularRegion(center: item.coordinate, radius: 150, identifier: KeychainService.generateRandomString(length: 200))

            locationManager.startMonitoring(for: geofenceRegion)
        }
    }

    private func stopMonitoringRegions() {
        workoutLocations.removeAll()

        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

        if !WorkoutInformation.workoutStarted() {
            return
        }

        NotificationCenter.default.post(name: Notification.Name(rawValue: "regionEntered"), object: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.last else {
            return
        }

        if location.horizontalAccuracy > maxHorizontalAccuracy {
            return
        }

        // MARK: - Calculate distance
        if (WorkoutInformation.workout?.coordinateList?.count ?? 0) > 1 {

            guard let lastLocation = workoutLocations.last else {
                return
            }

            if WorkoutInformation.workout?.distance == nil {
                WorkoutInformation.workout?.distance = 0.0
            }

            let distanceInMeters = lastLocation.distance(from: location)
            WorkoutInformation.workout?.distance? += distanceInMeters
        }
        // MARK: -

        if WorkoutInformation.workout?.coordinateList == nil {
            WorkoutInformation.workout?.coordinateList = [CLLocationCoordinate2D]()
        }

        WorkoutInformation.workout?.coordinateList?.append(location.coordinate)

        workoutLocations.append(location)

        LocationInformation().getCityName(with: location) { locationName in

            guard let newLocationName = locationName else {
                return
            }

            if WorkoutInformation.workout?.placeNames == nil {
                WorkoutInformation.workout?.placeNames = ""
            }

            WorkoutInformation.workout?.placeNames = LocationInformation().mergeLocations(WorkoutInformation.workout?.placeNames ?? "", with: newLocationName)

        }
    }
}