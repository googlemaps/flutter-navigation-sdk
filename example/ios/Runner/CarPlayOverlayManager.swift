import CoreLocation
import Foundation
import GoogleNavigation
import UIKit
import google_navigation_flutter

class CarPlayOverlayManager {
    // MARK: - Properties

    private var getNavView: () -> GoogleMapsNavigationView?
    private var overlaysLayout: CarPlayOverlayLayout?

    // MARK: - Initialization

    init(getNavView: @escaping () -> GoogleMapsNavigationView?) {
        self.getNavView = getNavView
    }

    // MARK: - Setup

    func setupOverlay() -> Bool {
        NSLog("🟠 [OverlayManager] setupOverlay() called")

        if overlaysLayout != nil {
            NSLog("🟠 [OverlayManager] setupOverlay() - customLayout already exists")
            return false
        }

        guard let navView = getNavView(),
            let mapView = navView.view() as? GMSMapView,
            let parentView = mapView.superview
        else {
            NSLog("🟠 [OverlayManager] setupOverlay() - views not ready")
            return false
        }

        NSLog("🟠 [OverlayManager] setupOverlay() - setting up overlays layout")
        mapView.settings.compassButton = false

        overlaysLayout = CarPlayOverlayLayout(navView: navView, frame: parentView.bounds)
        overlaysLayout?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView.addSubview(overlaysLayout!)
        parentView.bringSubviewToFront(overlaysLayout!)
        overlaysLayout?.hideOverlays()

        return true
    }

    // MARK: - Overlay Updates

    func updateNavigationInfo(_ navInfo: GMSNavigationNavInfo, nextManeuver: GMSNavigationManeuver?)
    {
        overlaysLayout?.updateNavigationInfo(navInfo, nextManeuver: nextManeuver)
    }

    func updateRemainingInfo(remainingTime: TimeInterval?, remainingDistance: CLLocationDistance?) {
        overlaysLayout?.updateRemainingInfo(
            remainingTime: remainingTime,
            remainingDistance: remainingDistance
        )
    }

    func showOverlays() {
        NSLog("🟢 [OverlayManager] showOverlays() called")
        overlaysLayout?.showOverlays()
    }

    func hideOverlays() {
        NSLog("🔴 [OverlayManager] hideOverlays() called")
        overlaysLayout?.hideOverlays()
    }

    func isOverlaySetup() -> Bool {
        return overlaysLayout != nil
    }

    // MARK: - Cleanup

    func cleanup() {
        NSLog("🔴 [OverlayManager] cleanup() called")
        overlaysLayout?.removeFromSuperview()
        overlaysLayout = nil
    }
}
