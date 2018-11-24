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
            default:
                break;
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

}
extension ParkMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is ParkMapOverlay {
            return ParkMapOverlayView(overlay: overlay, overlayImage: #imageLiteral(resourceName: "overlay_park"))
        }
        
        return MKOverlayRenderer()
    }
}
