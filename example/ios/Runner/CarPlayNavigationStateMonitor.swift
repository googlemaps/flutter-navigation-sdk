import Foundation
import GoogleNavigation
import google_navigation_flutter

protocol CarPlayNavigationStateMonitorDelegate: AnyObject {
    func navigationStateDidChange(isReady: Bool)
    func guidanceStateDidChange(isActive: Bool)
    func viewsDidBecomeAvailable()
}

class CarPlayNavigationStateMonitor {
    // MARK: - Properties

    weak var delegate: CarPlayNavigationStateMonitorDelegate?
    private var getNavView: () -> GoogleMapsNavigationView?
    private var stateCheckTimer: Timer?
    private var isMonitoringBasicState = false
    private(set) var isNavigationReady: Bool = false
    private(set) var lastGuidanceState: Bool = false

    // MARK: - Initialization

    init(getNavView: @escaping () -> GoogleMapsNavigationView?) {
        self.getNavView = getNavView
    }

    // MARK: - State Checking

    func checkNavigationReady() {
        guard let navView = getNavView(),
            let mapView = navView.view() as? GMSMapView,
            let navigator = mapView.navigator
        else {
            NSLog(
                "✅ [StateMonitor] checkNavigationReady() - views/navigator not available, NOT READY"
            )
            isNavigationReady = false
            return
        }

        let hasRoute = navigator.currentRouteLeg != nil
        isNavigationReady = hasRoute
        NSLog(
            "✅ [StateMonitor] checkNavigationReady() - currentRouteLeg: \(hasRoute ? "YES" : "NO"), isNavigationReady: \(isNavigationReady)"
        )
    }

    func areViewsAvailable() -> Bool {
        guard let navView = getNavView(),
            let mapView = navView.view() as? GMSMapView,
            mapView.superview != nil
        else {
            return false
        }
        return true
    }

    // MARK: - Monitoring

    func startBasicMonitoring() {
        NSLog("🟤 [StateMonitor] startBasicMonitoring() - starting fallback monitoring")

        guard !isMonitoringBasicState else {
            NSLog("🟤 [StateMonitor] startBasicMonitoring() - already monitoring, skipping")
            return
        }

        isMonitoringBasicState = true

        stateCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) {
            [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            if self.areViewsAvailable() {
                NSLog("🟤 [StateMonitor] Timer - views now available")
                timer.invalidate()
                self.stateCheckTimer = nil
                self.isMonitoringBasicState = false
                self.delegate?.viewsDidBecomeAvailable()
            }
        }
    }

    func startFullStateMonitoring() {
        NSLog("⏱️ [StateMonitor] startFullStateMonitoring() called")
        stateCheckTimer?.invalidate()
        isMonitoringBasicState = false

        guard let navView = getNavView(),
            let mapView = navView.view() as? GMSMapView,
            let navigator = mapView.navigator
        else {
            NSLog("⏱️ [StateMonitor] startFullStateMonitoring() - views not ready")
            return
        }

        let initialGuidanceState = navigator.isGuidanceActive
        lastGuidanceState = initialGuidanceState
        
        // If guidance is already active when monitoring starts, trigger the delegate immediately
        // This handles the case where CarPlay connects after navigation has already started
        if initialGuidanceState {
            NSLog("⏱️ [StateMonitor] startFullStateMonitoring() - guidance already active, triggering delegate")
            delegate?.guidanceStateDidChange(isActive: true)
        }

        stateCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            guard let navView = self.getNavView(),
                let mapView = navView.view() as? GMSMapView,
                let navigator = mapView.navigator
            else {
                return
            }

            let wasReady = self.isNavigationReady
            self.checkNavigationReady()

            // Handle navigation ready state changes
            if wasReady != self.isNavigationReady {
                NSLog(
                    "⏱️ [StateMonitor] Timer - navigation ready changed to: \(self.isNavigationReady)"
                )
                self.delegate?.navigationStateDidChange(isReady: self.isNavigationReady)
            }

            // Handle guidance state changes
            let currentState = navigator.isGuidanceActive
            if self.lastGuidanceState != currentState {
                NSLog("⏱️ [StateMonitor] Timer - guidance state changed to: \(currentState)")
                self.lastGuidanceState = currentState
                self.delegate?.guidanceStateDidChange(isActive: currentState)
            }
        }
    }

    func stopMonitoring() {
        NSLog("⏹️ [StateMonitor] stopMonitoring() called")
        stateCheckTimer?.invalidate()
        stateCheckTimer = nil
        isMonitoringBasicState = false
    }

    // MARK: - Cleanup

    func cleanup() {
        stopMonitoring()
        isNavigationReady = false
        lastGuidanceState = false
    }
}
