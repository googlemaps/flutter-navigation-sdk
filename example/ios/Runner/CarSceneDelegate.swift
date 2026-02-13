import CarPlay
import CoreLocation
import GoogleNavigation
import MapKit
import UIKit
import google_navigation_flutter

class CarSceneDelegate: BaseCarSceneDelegate {
    // MARK: - Managers
    
    private var stateMonitor: CarPlayNavigationStateMonitor?
    private var listenerCoordinator: CarPlayNavigationListenerCoordinator?
    private var buttonFactory: CarPlayButtonFactory?
    private var waitingOverlayManager: CarPlayWaitingOverlayManager?
    private var navigationSessionManager: CarPlayNavigationSessionManager?
    
    // Keep reference to the single map template we use throughout
    private weak var mapTemplate: CPMapTemplate?
    
    // MARK: - Template Creation
    
    override func getTemplate() -> CPMapTemplate {
        NSLog("🔵 [CarPlay] getTemplate() called")
        
        // Initialize managers
        initializeManagers()
        
        // Create simple map template
        let template = CPMapTemplate()
        template.dismissPanningInterface(animated: false)
        template.automaticallyHidesNavigationBar = false  // Will be managed by WaitingOverlayManager
        mapTemplate = template
        
        // Update references in navigation session manager
        navigationSessionManager?.updateReferences(mapTemplate: template, mapView: getMapView())
        
        stateMonitor?.checkNavigationReady()
        NSLog("🔵 [CarPlay] getTemplate() - isNavigationReady: \(stateMonitor?.isNavigationReady ?? false)")
        
        return template
    }
    
    // MARK: - Managers Initialization
    
    private func initializeManagers() {
        guard stateMonitor == nil else { return }
        
        NSLog("🔵 [CarPlay] initializeManagers() called")
        
        stateMonitor = CarPlayNavigationStateMonitor(getNavView: { [weak self] in self?.getNavView() })
        listenerCoordinator = CarPlayNavigationListenerCoordinator(getNavView: { [weak self] in self?.getNavView() })
        buttonFactory = CarPlayButtonFactory(getNavView: { [weak self] in self?.getNavView() })
        waitingOverlayManager = CarPlayWaitingOverlayManager(carWindow: nil, mapTemplate: nil)
        navigationSessionManager = CarPlayNavigationSessionManager(mapTemplate: nil, mapView: getMapView())
        
        // Set delegates
        stateMonitor?.delegate = self
        listenerCoordinator?.delegate = self
        buttonFactory?.delegate = self
    }
    
    // MARK: - Button Updates
    
    private func updateTemplateButtons() {
        NSLog("🔷 [CarPlay] updateTemplateButtons() called")
        
        // Don't update buttons if waiting overlay is shown
        if waitingOverlayManager?.isShown == true {
            NSLog("🔷 [CarPlay] updateTemplateButtons() - skipping, overlay is shown")
            return
        }
        
        guard let navView = getNavView(),
              let mapView = navView.view() as? GMSMapView,
              let navigator = mapView.navigator,
              let template = mapTemplate else {
            NSLog("🔷 [CarPlay] updateTemplateButtons() - not ready")
            return
        }
        
        let isGuidanceActive = navigator.isGuidanceActive
        NSLog("🔷 [CarPlay] updateTemplateButtons() - isGuidanceActive: \(isGuidanceActive)")
        
        buttonFactory?.updateTemplateButtons(template, isGuidanceActive: isGuidanceActive)
    }
    
    // MARK: - Scene Lifecycle
    
    override func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController,
        to window: CPWindow
    ) {
        NSLog("🟢 [CarPlay] templateApplicationScene didConnect")
        NSLog("🚗📊 [CarPlay] Instrument cluster will be used automatically if vehicle supports it")
        
        // Call super first - this will call getTemplate() and initialize managers
        super.templateApplicationScene(templateApplicationScene, didConnect: interfaceController, to: window)
        
        // Now update references in managers (now that everything is initialized)
        waitingOverlayManager?.updateReferences(carWindow: window, mapTemplate: mapTemplate)
        navigationSessionManager?.updateReferences(mapTemplate: mapTemplate, mapView: getMapView())
        
        NSLog("🟢 [CarPlay] Updated references in managers - window: \(window), mapView: \(getMapView() != nil)")
    }
    
    override func sceneDidBecomeActive(_ scene: UIScene) {
        super.sceneDidBecomeActive(scene)
        NSLog("🟣 [CarPlay] sceneDidBecomeActive() called")
        
        NSLog("🟣 [CarPlay] sceneDidBecomeActive() - scheduling setup in 1.0s")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            NSLog("🟣 [CarPlay] sceneDidBecomeActive() asyncAfter - executing setup")
            self?.setupNavigationIfNeeded()
        }
    }
    
    override func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController,
        from window: CPWindow
    ) {
        NSLog("🔴 [CarPlay] templateApplicationScene didDisconnect - cleaning up")
        
        navigationSessionManager?.cleanup()
        waitingOverlayManager?.cleanup()
        stateMonitor?.cleanup()
        listenerCoordinator?.cleanup()
        buttonFactory?.cleanup()
        
        mapTemplate = nil
        
        super.templateApplicationScene(templateApplicationScene, didDisconnect: interfaceController, from: window)
    }
    
    // MARK: - Setup
    
    private func setupNavigationIfNeeded() {
        NSLog("🟠 [CarPlay] setupNavigationIfNeeded() called")
        
        guard stateMonitor?.areViewsAvailable() == true else {
            NSLog("🟠 [CarPlay] setupNavigationIfNeeded() - views not ready, starting basic monitoring")
            stateMonitor?.startBasicMonitoring()
            return
        }
        
        NSLog("🟠 [CarPlay] setupNavigationIfNeeded() - views ready, attaching listener")
        attemptAttachListeners()
    }
    
    // MARK: - Listener Management
    
    private func attemptAttachListeners() {
        NSLog("🔶 [CarPlay] attemptAttachListeners() called")
        
        guard listenerCoordinator?.attachListener() == true else {
            NSLog("🔶 [CarPlay] attemptAttachListeners() - failed to attach")
            return
        }
        
        // Now that listener is attached (meaning navigator is available),
        // try to attach the navigation session to CarPlay map view
        // setupNavigatorListener()
        
        stateMonitor?.checkNavigationReady()
        
        // Show waiting overlay ONLY if no route is available at all
        if hasNoRoute() {
            waitingOverlayManager?.show()
        }
        
        updateTemplateButtons()
        stateMonitor?.startFullStateMonitoring()
    }
    
    // MARK: - Helper Methods
    
    private func hasNoRoute() -> Bool {
        guard let mapView = getMapView(),
              let navigator = mapView.navigator else {
            return true // No navigator = no route
        }
        
        let hasRoute = navigator.currentRouteLeg != nil
        NSLog("🔍 [CarPlay] hasNoRoute() - currentRouteLeg: \(hasRoute ? "YES" : "NO")")
        return !hasRoute
    }
    
    
    // MARK: - CPMapTemplateDelegate
    
    /// Enable navigation metadata support for instrument cluster (iOS 17.4+)
    @available(iOS 17.4, *)
    override func mapTemplateShouldProvideNavigationMetadata(_ mapTemplate: CPMapTemplate) -> Bool {
        NSLog("🚗📊 [CarPlay] mapTemplateShouldProvideNavigationMetadata - returning TRUE (instrument cluster enabled)")
        return true
    }

    /// Override base: for the lane guidance (second) maneuver return .symbolOnly so CarPlay shows only the symbolSet image.
    /// Must use same selector as base: displayStyleFor (not maneuverDisplayStyleFor).
    override func mapTemplate(_ mapTemplate: CPMapTemplate, displayStyleFor maneuver: CPManeuver) -> CPManeuverDisplayStyle {
        if navigationSessionManager?.isLaneGuidanceManeuver(maneuver) == true {
            return .symbolOnly
        }
        return super.mapTemplate(mapTemplate, displayStyleFor: maneuver)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - CarPlayNavigationStateMonitorDelegate

extension CarSceneDelegate: CarPlayNavigationStateMonitorDelegate {
    func navigationStateDidChange(isReady: Bool) {
        NSLog("⏱️ [CarPlay] navigationStateDidChange() - isReady: \(isReady)")
        
        if isReady {
            // Hide waiting overlay first (this will re-enable auto-hide)
            waitingOverlayManager?.hide()
            
            // Ensure auto-hide is enabled when no overlay
            if waitingOverlayManager?.isShown == false {
                mapTemplate?.automaticallyHidesNavigationBar = true
            }
            
            // Reset and re-attach navigator listener in BaseCarSceneDelegate
            // This is important after stopping/starting navigation as the navigator may have been reinitialized
            // resetNavigatorListener()
            
            listenerCoordinator?.reattachListenerAfterDelay()
            
            // Update buttons after overlay is hidden
            updateTemplateButtons()
        } else {
            // Show waiting overlay ONLY if no route is available
            if hasNoRoute() {
                waitingOverlayManager?.show()
            } else {
                // No overlay but not ready - ensure auto-hide is enabled
                mapTemplate?.automaticallyHidesNavigationBar = true
            }
            
            navigationSessionManager?.stopSession()
            // Don't update buttons when overlay is shown (will be skipped anyway)
        }
    }
    
    func guidanceStateDidChange(isActive: Bool) {
        NSLog("⏱️ [CarPlay] guidanceStateDidChange() - isActive: \(isActive)")
        
        if isActive {
            // Update references BEFORE starting session (to ensure mapView is available)
            navigationSessionManager?.updateReferences(mapTemplate: mapTemplate, mapView: getMapView())
            
            // Start native CarPlay navigation session with callback to get cached navInfo
            navigationSessionManager?.startSession(getCachedNavInfo: { [weak self] in
                return self?.listenerCoordinator?.getCachedNavInfo()
            })
            
            NSLog("⏱️ [CarPlay] guidanceStateDidChange() - switching to follow mode")
            buttonFactory?.resetViewState()
            getNavView()?.followMyLocation(
                perspective: GMSNavigationCameraPerspective.tilted,
                zoomLevel: nil
            )
            
            // Force an immediate navInfo update using cached data if available
            // This ensures maneuvers are displayed right away when CarPlay connects
            // after navigation has already started
            if let cachedNavInfo = listenerCoordinator?.getCachedNavInfo() {
                NSLog("⏱️ [CarPlay] guidanceStateDidChange() - forcing initial navInfo update with cached data")
                navigationSessionManager?.updateNavigation(
                    distanceToFinal: cachedNavInfo.distanceToFinalDestinationMeters,
                    timeToFinal: TimeInterval(cachedNavInfo.timeToFinalDestinationSeconds),
                    navInfo: cachedNavInfo
                )
            } else {
                NSLog("⏱️ [CarPlay] guidanceStateDidChange() - no cached navInfo available, will wait for next update")
            }
            
            sendCustomNavigationAutoEvent(
                event: "CarPlayGuidanceStarted",
                data: [:]
            )
        } else {            
            // Stop native CarPlay navigation session
            navigationSessionManager?.stopSession()
            
            sendCustomNavigationAutoEvent(
                event: "CarPlayGuidanceStopped",
                data: [:]
            )
        }
        
        updateTemplateButtons()
    }
    
    func viewsDidBecomeAvailable() {
        NSLog("🟤 [CarPlay] viewsDidBecomeAvailable() - retrying full setup")
        setupNavigationIfNeeded()
    }
}

// MARK: - CarPlayNavigationListenerCoordinatorDelegate

extension CarSceneDelegate: CarPlayNavigationListenerCoordinatorDelegate {
    func navigatorDidUpdateRemainingTime(_ time: TimeInterval) {
        // Time is updated via navigatorDidUpdateNavInfo
    }
    
    func navigatorDidUpdateRemainingDistance(_ distance: CLLocationDistance) {
        // Distance is updated via navigatorDidUpdateNavInfo
    }
    
    func navigatorDidUpdateNavInfo(
        _ navInfo: GMSNavigationNavInfo, nextManeuver: GMSNavigationManeuver?
    ) {
        NSLog("🚗 [CarPlay] 📡 Received navInfo update - distance:\(navInfo.distanceToFinalDestinationMeters)m time:\(navInfo.timeToFinalDestinationSeconds)s")
        
        // Update native CarPlay display
        navigationSessionManager?.updateNavigation(
            distanceToFinal: navInfo.distanceToFinalDestinationMeters,
            timeToFinal: TimeInterval(navInfo.timeToFinalDestinationSeconds),
            navInfo: navInfo
        )
    }
    
    func navigatorDidChangeRoute() {
        NSLog("🗺️ [CarPlay] navigatorDidChangeRoute() called")
        
        stateMonitor?.checkNavigationReady()
        NSLog("🗺️ [CarPlay] navigatorDidChangeRoute() - isNavigationReady: \(stateMonitor?.isNavigationReady ?? false)")
        
        buttonFactory?.resetViewState()
        
        if stateMonitor?.isNavigationReady == true {
            waitingOverlayManager?.hide()
            
            // Ensure auto-hide is enabled when no overlay
            if waitingOverlayManager?.isShown == false {
                mapTemplate?.automaticallyHidesNavigationBar = true
            }
            
            updateTemplateButtons()
        } else {
            // Show waiting overlay ONLY if no route is available
            if hasNoRoute() {
                waitingOverlayManager?.show()
            } else {
                // Route exists but not ready yet, just hide overlay
                waitingOverlayManager?.hide()
                
                // Ensure auto-hide is enabled
                mapTemplate?.automaticallyHidesNavigationBar = true
            }
            navigationSessionManager?.stopSession()
            updateTemplateButtons()
        }
        
        listenerCoordinator?.reattachListenerAfterDelay()
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
        NSLog("🔷 [CarPlay] buttonFactoryDidRequestViewToggle() - isShowingOverview: \(isShowingOverview)")
        
        let event = isShowingOverview ? "show_itinerary_button_pressed" : "recenter_button_pressed"
        let data = ["timestamp": String(Date().timeIntervalSince1970)]
        sendCustomNavigationAutoEvent(event: event, data: data)
        
        updateTemplateButtons()
    }
}
