import Foundation
import SwiftUI
import MapKit

public struct MapView: UIViewRepresentable {

    public typealias UIViewType = MKMapView
    @State private var mapView: MKMapView?
    private var coordinates: [CLLocationCoordinate2D]

    public init(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
    }

    public class Coordinator: NSObject, MKMapViewDelegate {

        var control: MapView

        public init(_ control: MapView) {
            self.control = control
        }

        public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let routePolyLine = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: routePolyLine)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 7
                return renderer
            }

            return MKOverlayRenderer()
        }
    }

    public func makeUIView(context: Context) -> MKMapView {
        let map = createMapView(MKMapView(), context: context)

        DispatchQueue.main.async {
            self.mapView = map
        }

        return map
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func updateUIView(_ uiView: MKMapView, context: Context) {
        let map = uiView

        DispatchQueue.main.async {
            self.mapView = createMapView(map, context: context)
        }
    }

    private func createMapView(_ map: MKMapView, context: Context) -> MKMapView {
        if coordinates.count < 2 {
            return map
        }

        map.delegate = context.coordinator
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)

        let firstAnnotation = MKPointAnnotation()
        firstAnnotation.coordinate = coordinates[0]
        map.addAnnotation(firstAnnotation)

        let secondAnnotation = MKPointAnnotation()
        secondAnnotation.coordinate = coordinates[coordinates.count - 1]
        map.addAnnotation(secondAnnotation)

        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polyLine)

        var regionRect = polyLine.boundingMapRect

        let widthPadding = regionRect.size.width * 0.25
        let heightPadding = regionRect.size.height * 0.25

        regionRect.size.width += widthPadding
        regionRect.size.height += heightPadding

        regionRect.origin.x -= widthPadding / 2
        regionRect.origin.y -= heightPadding / 2

        map.setRegion(MKCoordinateRegion(regionRect), animated: true)

        return map
    }
}