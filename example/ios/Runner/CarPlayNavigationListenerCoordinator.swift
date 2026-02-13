import CoreLocation
import Foundation
import GoogleNavigation
import google_navigation_flutter

protocol CarPlayNavigationListenerCoordinatorDelegate: AnyObject {
    func navigatorDidUpdateRemainingTime(_ time: TimeInterval)
    func navigatorDidUpdateRemainingDistance(_ distance: CLLocationDistance)
    func navigatorDidUpdateNavInfo(
        _ navInfo: GMSNavigationNavInfo, nextManeuver: GMSNavigationManeuver?)
    func navigatorDidChangeRoute()
}

class CarPlayNavigationListenerCoordinator: NSObject, GMSNavigatorListener {
    // MARK: - Properties

    weak var delegate: CarPlayNavigationListenerCoordinatorDelegate?
    private var getNavView: () -> GoogleMapsNavigationView?
    private var isListenerAttached = false
    private(set) var cachedRemainingTime: TimeInterval?
    private(set) var cachedRemainingDistance: CLLocationDistance?
    private(set) var cachedNavInfo: GMSNavigationNavInfo?

    // MARK: - Initialization

    init(getNavView: @escaping () -> GoogleMapsNavigationView?) {
        self.getNavView = getNavView
        super.init()
    }

    // MARK: - Listener Management

    func attachListener() -> Bool {
        NSLog("🔶 [ListenerCoordinator] attachListener() called")

        if isListenerAttached {
            NSLog("🔶 [ListenerCoordinator] attachListener() - already attached")
            return false
        }

        guard let navView = getNavView(),
            let mapView = navView.view() as? GMSMapView,
            let navigator = mapView.navigator
        else {
            NSLog("🔶 [ListenerCoordinator] attachListener() - views/navigator not ready yet")
            return false
        }

        NSLog("🔶 [ListenerCoordinator] attachListener() - attaching listener")
        navigator.remove(self)
        navigator.add(self)
        isListenerAttached = true

        // Initialize cached values if navigation is active
        if navigator.isGuidanceActive, navigator.currentRouteLeg != nil {
            NSLog(
                "🔶 [ListenerCoordinator] attachListener() - navigation active, initializing cached values"
            )
            cachedRemainingTime = navigator.timeToNextDestination
            cachedRemainingDistance = navigator.distanceToNextDestination
            NSLog(
                "🔶 [ListenerCoordinator] attachListener() - initialized time: \(cachedRemainingTime ?? 0)s, distance: \(cachedRemainingDistance ?? 0)m"
            )

            // Notify delegate of initial values
            if let time = cachedRemainingTime {
                delegate?.navigatorDidUpdateRemainingTime(time)
            }
            if let distance = cachedRemainingDistance {
                delegate?.navigatorDidUpdateRemainingDistance(distance)
            }
        }

        return true
    }

    func detachListener() {
        NSLog("🔶 [ListenerCoordinator] detachListener() called")
        guard let navView = getNavView(),
            let mapView = navView.view() as? GMSMapView,
            let navigator = mapView.navigator
        else {
            return
        }

        navigator.remove(self)
        isListenerAttached = false
    }

    func reattachListenerAfterDelay(delay: TimeInterval = 0.1) {
        NSLog("🔶 [ListenerCoordinator] reattachListenerAfterDelay(\(delay)s) called")
        detachListener()

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            NSLog(
                "🔶 [ListenerCoordinator] reattachListenerAfterDelay() asyncAfter - re-attaching listener"
            )
            _ = self?.attachListener()
        }
    }

    // MARK: - GMSNavigatorListener

    func navigator(_ navigator: GMSNavigator, didUpdateRemainingTime remainingTime: TimeInterval) {
        cachedRemainingTime = remainingTime
        delegate?.navigatorDidUpdateRemainingTime(remainingTime)
    }

    func navigator(
        _ navigator: GMSNavigator, didUpdateRemainingDistance remainingDistance: CLLocationDistance
    ) {
        cachedRemainingDistance = remainingDistance
        delegate?.navigatorDidUpdateRemainingDistance(remainingDistance)
    }

    func navigator(_ navigator: GMSNavigator, didUpdate navInfo: GMSNavigationNavInfo) {
        NSLog("🔶 [ListenerCoordinator] navigator didUpdate navInfo - isGuidanceActive: \(navigator.isGuidanceActive)")
        
        // Cache the latest navInfo
        cachedNavInfo = navInfo
        
        if navigator.isGuidanceActive {
            let nextManeuver = navInfo.remainingSteps.first?.maneuver
            NSLog("🔶 [ListenerCoordinator] Forwarding navInfo to delegate - steps: \(navInfo.remainingSteps.count)")
            delegate?.navigatorDidUpdateNavInfo(navInfo, nextManeuver: nextManeuver)
        }
    }
    
    /// Get the last cached navInfo (useful for initializing CarPlay session)
    func getCachedNavInfo() -> GMSNavigationNavInfo? {
        return cachedNavInfo
    }

    func navigatorDidChangeRoute(_ navigator: GMSNavigator) {
        NSLog("🗺️ [ListenerCoordinator] navigatorDidChangeRoute() called")
        delegate?.navigatorDidChangeRoute()
        reattachListenerAfterDelay()
    }

    // MARK: - Cleanup

    func cleanup() {
        detachListener()
        cachedRemainingTime = nil
        cachedRemainingDistance = nil
        cachedNavInfo = nil
    }
}
