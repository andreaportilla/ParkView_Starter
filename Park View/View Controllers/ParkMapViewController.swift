/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit


class ParkMapViewController: UIViewController {
  
  var selectedOptions : [MapOptionsType] = []
  
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let latDelta = park.overlayTopLeftCoordinate.latitude -
            park.overlayBottomRightCoordinate.latitude
        
        // Think of a span as a tv size, measure from one corner to another
        let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
        let region = MKCoordinateRegionMake(park.midCoordinate, span)
        
        mapView.region = region
    }

    var park = Park(filename: "MagicMountain")

    func loadSelectedOptions() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        for option in selectedOptions {
            switch (option) {
            case .mapOverlay:
                addOverlay()
            case .mapPins:ll
                addAttractionPins()
            case .mapRoute:
                addRoute()
            case .mapBoundary:
                addBoundary()
            case .mapCharacterLocation:
                addCharacterLocation()

           // default:
           //     break;
                
            }
        }
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    (segue.destination as? MapOptionsViewController)?.selectedOptions = selectedOptions
  }
  
  @IBAction func closeOptions(_ exitSegue: UIStoryboardSegue) {
    guard let vc = exitSegue.source as? MapOptionsViewController else { return }
    selectedOptions = vc.selectedOptions
    loadSelectedOptions()
  }
  
  @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
    mapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard

  }
    func addOverlay() {
        let overlay = ParkMapOverlay(park: park)
        mapView.add(overlay)
    }
    func addAttractionPins() {
        guard let attractions = Park.plist("MagicMountainAttractions") as? [[String : String]] else { return }
        
        for attraction in attractions {
            let coordinate = Park.parseCoord(dict: attraction, fieldName: "location")
            let title = attraction["name"] ?? ""
            let typeRawValue = Int(attraction["type"] ?? "0") ?? 0
            let type = AttractionType(rawValue: typeRawValue) ?? .misc
            let subtitle = attraction["subtitle"] ?? ""
            let annotation = AttractionAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: type)
            mapView.addAnnotation(annotation)
        }
    }
    func addRoute() {
        guard let points = Park.plist("EntranceToGoliathRoute") as? [String] else { return }
        
        let cgPoints = points.map { CGPointFromString($0) }
        let coords = cgPoints.map { CLLocationCoordinate2DMake(CLLocationDegrees($0.x), CLLocationDegrees($0.y)) }
        let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
        
        mapView.add(myPolyline)
    }
    func addBoundary() {
        mapView.add(MKPolygon(coordinates: park.boundary, count: park.boundary.count))
    }
    func addCharacterLocation() {
        mapView.add(Character(filename: "BatmanLocations", color: .blue))
        mapView.add(Character(filename: "TazLocations", color: .orange))
        mapView.add(Character(filename: "TweetyBirdLocations", color: .yellow))
    }
}
extension ParkMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is ParkMapOverlay {
            return ParkMapOverlayView(overlay: overlay, overlayImage: #imageLiteral(resourceName: "overlay_park"))
        } else if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.green
            return lineView
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.magenta
            return polygonView
        } else if let character = overlay as? Character {
            let circleView = MKCircleRenderer(overlay: character)
            circleView.strokeColor = character.color
            return circleView
        }
        
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
        annotationView.canShowCallout = true
        return annotationView
    }

}
