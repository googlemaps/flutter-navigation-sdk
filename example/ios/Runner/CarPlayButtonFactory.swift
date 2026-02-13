import CarPlay
import GoogleNavigation
import UIKit
import google_navigation_flutter

protocol CarPlayButtonFactoryDelegate: AnyObject {
    func buttonFactoryDidRequestStartStop(isActive: Bool)
    func buttonFactoryDidRequestViewToggle(isShowingOverview: Bool)
}

class CarPlayButtonFactory {
    // MARK: - Properties

    weak var delegate: CarPlayButtonFactoryDelegate?
    private var getNavView: () -> GoogleMapsNavigationView?
    private(set) var isShowingRouteOverview: Bool = false

    // MARK: - Initialization

    init(getNavView: @escaping () -> GoogleMapsNavigationView?) {
        self.getNavView = getNavView
    }

    // MARK: - Button Creation

    func createStartStopButton(isGuidanceActive: Bool) -> CPBarButton {
        let button = CPBarButton(title: isGuidanceActive ? "Stop" : "Start") { [weak self] _ in
            self?.handleStartStopTapped(currentState: isGuidanceActive)
        }
        return button
    }

    func createViewToggleButton() -> CPBarButton {
        let button = CPBarButton(
            title: isShowingRouteOverview ? "Re-center" : "Show itinerary"
        ) { [weak self] _ in
            self?.handleViewToggleTapped()
        }
        return button
    }

    func updateTemplateButtons(_ template: CPMapTemplate, isGuidanceActive: Bool) {
        NSLog("🔷 [ButtonFactory] updateTemplateButtons() - isGuidanceActive: \(isGuidanceActive)")

        let startOrQuitButton = createStartStopButton(isGuidanceActive: isGuidanceActive)

        if isGuidanceActive {
            template.leadingNavigationBarButtons = [startOrQuitButton]
        } else {
            let viewToggleButton = createViewToggleButton()
            template.leadingNavigationBarButtons = [startOrQuitButton, viewToggleButton]
        }
    }

    // MARK: - Button Actions

    private func handleStartStopTapped(currentState: Bool) {
        NSLog("🔷 [ButtonFactory] handleStartStopTapped() - currentState: \(currentState)")

        guard let navView = getNavView(),
            let mapView = navView.view() as? GMSMapView,
            let navigator = mapView.navigator
        else {
            NSLog("🔷 [ButtonFactory] handleStartStopTapped() - navigator not available")
            return
        }

        navigator.isGuidanceActive = !currentState
        delegate?.buttonFactoryDidRequestStartStop(isActive: !currentState)
    }

    private func handleViewToggleTapped() {
        NSLog(
            "🔷 [ButtonFactory] handleViewToggleTapped() - isShowingOverview: \(isShowingRouteOverview)"
        )

        guard let navView = getNavView(),
            let mapView = navView.view() as? GMSMapView
        else {
            NSLog("🔷 [ButtonFactory] handleViewToggleTapped() - mapView not available")
            return
        }

        if isShowingRouteOverview {
            // Switch to re-center
            NSLog("🔷 [ButtonFactory] handleViewToggleTapped() - switching to re-center")
            navView.followMyLocation(
                perspective: GMSNavigationCameraPerspective.tilted,
                zoomLevel: nil
            )
            isShowingRouteOverview = false
        } else {
            // Switch to overview
            NSLog("🔷 [ButtonFactory] handleViewToggleTapped() - switching to route overview")
            mapView.cameraMode = .overview
            isShowingRouteOverview = true
        }

        delegate?.buttonFactoryDidRequestViewToggle(isShowingOverview: isShowingRouteOverview)
    }

    func resetViewState() {
        isShowingRouteOverview = false
    }

    // MARK: - Cleanup

    func cleanup() {
        isShowingRouteOverview = false
    }
}
