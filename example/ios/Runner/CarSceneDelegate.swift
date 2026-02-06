import CarPlay
import GoogleNavigation
import UIKit
import google_navigation_flutter

class CarSceneDelegate: BaseCarSceneDelegate {
    // MARK: - Managers

    private var templateManager: CarPlayTemplateManager?
    private var stateMonitor: CarPlayNavigationStateMonitor?
    private var listenerCoordinator: CarPlayNavigationListenerCoordinator?
    private var overlayManager: CarPlayOverlayManager?
    private var buttonFactory: CarPlayButtonFactory?

    // MARK: - Properties

    private weak var carPlayScene: CPTemplateApplicationScene?

    // MARK: - Helper Methods

    private func getInterfaceController() -> CPInterfaceController? {
        return carPlayScene?.interfaceController
    }

    // MARK: - Template Creation

    override func getTemplate() -> CPMapTemplate {
        NSLog("🔵 [CarPlay] getTemplate() called")

        // Initialize managers
        initializeManagers()

        let template = templateManager?.createInitialMapTemplate() ?? CPMapTemplate()

        stateMonitor?.checkNavigationReady()
        NSLog(
            "🔵 [CarPlay] getTemplate() - isNavigationReady: \(stateMonitor?.isNavigationReady ?? false)"
        )

        return template
    }

    // MARK: - Managers Initialization

    private func initializeManagers() {
        guard templateManager == nil else { return }

        NSLog("🔵 [CarPlay] initializeManagers() called")

        templateManager = CarPlayTemplateManager(interfaceController: getInterfaceController())
        stateMonitor = CarPlayNavigationStateMonitor(getNavView: { [weak self] in self?.getNavView()
        })
        listenerCoordinator = CarPlayNavigationListenerCoordinator(getNavView: { [weak self] in
            self?.getNavView()
        })
        overlayManager = CarPlayOverlayManager(getNavView: { [weak self] in self?.getNavView() })
        buttonFactory = CarPlayButtonFactory(getNavView: { [weak self] in self?.getNavView() })

        // Set delegates
        stateMonitor?.delegate = self
        listenerCoordinator?.delegate = self
        buttonFactory?.delegate = self
    }

    // MARK: - Template Management

    private func showWaitingTemplate() {
        guard stateMonitor?.isNavigationReady == false else {
            NSLog("🟡 [CarPlay] showWaitingTemplate() - already ready, skipping")
            return
        }
        templateManager?.showWaitingTemplate()
    }

    private func switchToMapTemplate() {
        templateManager?.switchToMapTemplate()
    }

    // MARK: - Button Updates

    private func updateTemplateButtons() {
        NSLog("🔷 [CarPlay] updateTemplateButtons() called")

        guard let navView = getNavView(),
            let mapView = navView.view() as? GMSMapView,
            let navigator = mapView.navigator,
            navigator.currentRouteLeg != nil
        else {
            NSLog(
                "🔷 [CarPlay] updateTemplateButtons() - navigation not ready, showing waiting template"
            )
            showWaitingTemplate()
            return
        }

        switchToMapTemplate()

        guard let template = templateManager?.getCurrentMapTemplate() else {
            NSLog("🔷 [CarPlay] updateTemplateButtons() - no currentTemplate after switch")
            return
        }

        let isGuidanceActive = navigator.isGuidanceActive
        NSLog("🔷 [CarPlay] updateTemplateButtons() - isGuidanceActive: \(isGuidanceActive)")

        if isGuidanceActive {
            overlayManager?.showOverlays()
        } else {
            overlayManager?.hideOverlays()
        }

        buttonFactory?.updateTemplateButtons(template, isGuidanceActive: isGuidanceActive)
    }

    // MARK: - Scene Lifecycle

    override func sceneDidBecomeActive(_ scene: UIScene) {
        super.sceneDidBecomeActive(scene)
        NSLog("🟣 [CarPlay] sceneDidBecomeActive() called")

        if let carPlayScene = scene as? CPTemplateApplicationScene {
            self.carPlayScene = carPlayScene
            templateManager?.updateInterfaceController(carPlayScene.interfaceController)
        }

        NSLog("🟣 [CarPlay] sceneDidBecomeActive() - scheduling setupCustomOverlaysIfNeeded in 1.0s")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            NSLog("🟣 [CarPlay] sceneDidBecomeActive() asyncAfter - executing setup")
            self?.setupCustomOverlaysIfNeeded()
        }
    }

    override func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController,
        from window: CPWindow
    ) {
        NSLog("🔴 [CarPlay] templateApplicationScene didDisconnect - cleaning up")

        stateMonitor?.cleanup()
        listenerCoordinator?.cleanup()
        overlayManager?.cleanup()
        buttonFactory?.cleanup()
        templateManager?.cleanup()

        carPlayScene = nil

        super.templateApplicationScene(
            templateApplicationScene, didDisconnect: interfaceController, from: window)
    }

    // MARK: - Setup

    private func setupCustomOverlaysIfNeeded() {
        NSLog("🟠 [CarPlay] setupCustomOverlaysIfNeeded() called")

        if overlayManager?.isOverlaySetup() == true {
            NSLog("🟠 [CarPlay] setupCustomOverlaysIfNeeded() - overlay already exists")
            return
        }

        guard stateMonitor?.areViewsAvailable() == true else {
            NSLog(
                "🟠 [CarPlay] setupCustomOverlaysIfNeeded() - views not ready, starting basic monitoring"
            )
            showWaitingTemplate()
            stateMonitor?.startBasicMonitoring()
            return
        }

        NSLog("🟠 [CarPlay] setupCustomOverlaysIfNeeded() - setting up overlay")
        _ = overlayManager?.setupOverlay()
        attemptAttachListeners()
    }

    // MARK: - Listener Management

    private func attemptAttachListeners() {
        NSLog("🔶 [CarPlay] attemptAttachListeners() called")

        guard listenerCoordinator?.attachListener() == true else {
            NSLog("🔶 [CarPlay] attemptAttachListeners() - failed to attach")
            return
        }

        stateMonitor?.checkNavigationReady()

        if stateMonitor?.isNavigationReady == true {
            updateTemplateButtons()
        } else {
            NSLog(
                "🔶 [CarPlay] attemptAttachListeners() - navigation not ready, showing waiting template"
            )
            showWaitingTemplate()
        }

        stateMonitor?.startFullStateMonitoring()
    }

}

// MARK: - CarPlayNavigationStateMonitorDelegate

extension CarSceneDelegate: CarPlayNavigationStateMonitorDelegate {
    func navigationStateDidChange(isReady: Bool) {
        NSLog("⏱️ [CarPlay] navigationStateDidChange() - isReady: \(isReady)")

        if isReady {
            listenerCoordinator?.reattachListenerAfterDelay()
            updateTemplateButtons()
        } else {
            showWaitingTemplate()
        }
    }

    func guidanceStateDidChange(isActive: Bool) {
        NSLog("⏱️ [CarPlay] guidanceStateDidChange() - isActive: \(isActive)")

        guard let mapView = getNavView()?.view() as? GMSMapView else { return }

        if isActive {
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)

            sendCustomNavigationAutoEvent(
                event: "CarPlayPaddingApplied",
                data: ["bottom": "20"]
            )

            NSLog("⏱️ [CarPlay] guidanceStateDidChange() - switching to follow mode")
            buttonFactory?.resetViewState()
            getNavView()?.followMyLocation(
                perspective: GMSNavigationCameraPerspective.tilted,
                zoomLevel: nil
            )

            listenerCoordinator?.reattachListenerAfterDelay()
        } else {
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

            sendCustomNavigationAutoEvent(
                event: "CarPlayPaddingReset",
                data: ["bottom": "0"]
            )
        }

        updateTemplateButtons()
    }

    func viewsDidBecomeAvailable() {
        NSLog("🟤 [CarPlay] viewsDidBecomeAvailable() - retrying full setup")
        setupCustomOverlaysIfNeeded()
    }
}

// MARK: - CarPlayNavigationListenerCoordinatorDelegate

extension CarSceneDelegate: CarPlayNavigationListenerCoordinatorDelegate {
    func navigatorDidUpdateRemainingTime(_ time: TimeInterval) {
        overlayManager?.updateRemainingInfo(
            remainingTime: time,
            remainingDistance: listenerCoordinator?.cachedRemainingDistance
        )
    }

    func navigatorDidUpdateRemainingDistance(_ distance: CLLocationDistance) {
        overlayManager?.updateRemainingInfo(
            remainingTime: listenerCoordinator?.cachedRemainingTime,
            remainingDistance: distance
        )
    }

    func navigatorDidUpdateNavInfo(
        _ navInfo: GMSNavigationNavInfo, nextManeuver: GMSNavigationManeuver?
    ) {
        overlayManager?.updateNavigationInfo(navInfo, nextManeuver: nextManeuver)
    }

    func navigatorDidChangeRoute() {
        NSLog("🗺️ [CarPlay] navigatorDidChangeRoute() called")

        stateMonitor?.checkNavigationReady()
        NSLog(
            "🗺️ [CarPlay] navigatorDidChangeRoute() - isNavigationReady: \(stateMonitor?.isNavigationReady ?? false)"
        )

        buttonFactory?.resetViewState()

        if stateMonitor?.isNavigationReady == true {
            updateTemplateButtons()
        } else {
            showWaitingTemplate()
        }
    }
}

// MARK: - CarPlayButtonFactoryDelegate

extension CarSceneDelegate: CarPlayButtonFactoryDelegate {
    func buttonFactoryDidRequestStartStop(isActive: Bool) {
        NSLog("🔷 [CarPlay] buttonFactoryDidRequestStartStop() - isActive: \(isActive)")

        sendCustomNavigationAutoEvent(
            event: isActive ? "AutoEventStart" : "AutoEventStop",
            data: [:]
        )
    }

    func buttonFactoryDidRequestViewToggle(isShowingOverview: Bool) {
        NSLog(
            "🔷 [CarPlay] buttonFactoryDidRequestViewToggle() - isShowingOverview: \(isShowingOverview)"
        )

        let event = isShowingOverview ? "show_itinerary_button_pressed" : "recenter_button_pressed"
        let data = ["timestamp": String(Date().timeIntervalSince1970)]
        sendCustomNavigationAutoEvent(event: event, data: data)

        updateTemplateButtons()
    }
}
