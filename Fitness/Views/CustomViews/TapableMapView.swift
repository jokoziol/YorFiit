import Foundation
import SwiftUI
import MapKit

struct TapableMapView: UIViewRepresentable {

    public typealias UIViewType = MKMapView
    @State private var mapView: MKMapView?

    public class Coordinator: NSObject, MKMapViewDelegate {
        var control: TapableMapView

        init(_ control: TapableMapView) {
            self.control = control
        }

        @objc func addOnTapGesture(sender: UITapGestureRecognizer) {
            if sender.state == .ended {
                let point = sender.location(in: control.mapView)
                let coordinate = control.mapView?.convert(point, toCoordinateFrom: control.mapView)

                if coordinate == nil {
                    return
                }

                GeofenceLocation.shared.coordinates = coordinate

                control.mapView?.removeAnnotations(control.mapView!.annotations)

                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate!
                control.mapView?.addAnnotation(annotation)
            }
        }
    }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.mapType = .hybridFlyover

        let button = MKUserTrackingButton(mapView: map)
        map.addSubview(button)

        DispatchQueue.main.async {
            self.mapView = map
        }

        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.addOnTapGesture(sender:)))
        map.addGestureRecognizer(gestureRecognizer)

        return map
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func updateUIView(_ uiView: MKMapView, context: Context) {
    }
}