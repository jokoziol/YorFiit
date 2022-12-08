import SwiftUI
import MapKit

struct AddGeofenceLocationView: View {

    @StateObject var geofenceLocation: GeofenceLocation = GeofenceLocation.shared

    @State var showAlert: Bool = false
    @State var showProgressIndicator: Bool = false

    @State private var statusMessage = ""

    var body: some View {
        VStack {
            TapableMapView()
        }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {

                        if showProgressIndicator {
                            ProgressView().progressViewStyle(.circular)
                        } else {
                            Button {
                                addLocation()
                            } label: {
                                Image(systemName: "plus")
                            }
                                    .alert(statusMessage.localized(), isPresented: $showAlert) {

                                    }
                        }
                    }
                }
    }

    private func addLocation() {

        showAlert = false
        showProgressIndicator = true

        guard let location = geofenceLocation.coordinates else {
            Vibration.error.vibrate()
            showProgressIndicator = false

            statusMessage = "addLocationErrorTitle"
            showAlert.toggle()

            return
        }

        let clLocation: CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        LocationInformation().getCityNameAndAddress(with: clLocation) { (locationAddress: String?) in

            guard let address: String = locationAddress else {

                let latitude: String = String(format: "%.4f", locale: .current, clLocation.coordinate.latitude)
                let longitude: String = String(format: "%.4f", locale: .current, clLocation.coordinate.longitude)

                Geofencing().persistLocation(for: location, locationAddress: "\(latitude) \(longitude)")

                Vibration.success.vibrate()
                showProgressIndicator = false

                statusMessage = "addLocationSuccessTitle"
                showAlert.toggle()

                return
            }

            Geofencing().persistLocation(for: location, locationAddress: address)

            geofenceLocation.coordinates = nil

            Vibration.success.vibrate()
            showProgressIndicator = false

            statusMessage = "addLocationSuccessTitle"
            showAlert.toggle()
        }
    }
}

class GeofenceLocation: ObservableObject {
    @Published var coordinates: CLLocationCoordinate2D?
    static let shared: GeofenceLocation = GeofenceLocation()
}