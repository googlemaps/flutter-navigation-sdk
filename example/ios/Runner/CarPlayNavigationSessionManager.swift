import CarPlay
import CoreLocation
import GoogleNavigation
import MapKit
import UIKit

/// Manager for native CarPlay navigation session (maneuvers, ETA, lane panel in 2nd maneuver)
final class CarPlayNavigationSessionManager: NSObject {

    // MARK: - Properties

    private var navigationSession: CPNavigationSession?
    private var currentTrip: CPTrip?
    private var lastRouteHash: String?

    private weak var mapTemplate: CPMapTemplate?
    private weak var mapView: GMSMapView?

    /// We need to identify the "lane guidance maneuver" to return `.symbolOnly`
    /// because the display style only applies to the *second* maneuver.  [oai_citation:7‡CarPlay-Developer-Guide.pdf](sediment://file_000000003dc471f5944f8194e030d81e)
    private weak var currentLaneGuidanceManeuver: CPManeuver?

    private var cachedLaneSignature: String?
    private weak var cachedLaneManeuver: CPManeuver?

    private var cachedNextSignature: String?
    private weak var cachedNextManeuver: CPManeuver?

    // MARK: - Initialization

    init(mapTemplate: CPMapTemplate?, mapView: GMSMapView?) {
        self.mapTemplate = mapTemplate
        self.mapView = mapView
        super.init()
    }
    // MARK: - Public Methods

    /// Start the native CPNavigationSession
    func startSession(getCachedNavInfo: (() -> GMSNavigationNavInfo?)? = nil) {
        guard navigationSession == nil else {
            NSLog("🚗 [NavigationSession] Session already active, skipping")
            return
        }

        guard let mapView = mapView,
              let navigator = mapView.navigator,
              let template = mapTemplate else {
            NSLog("🚗 [NavigationSession] Cannot start - mapView:\(mapView != nil) navigator:\(mapView?.navigator != nil) template:\(mapTemplate != nil)")
            return
        }

        NSLog("🚗 [NavigationSession] Starting native CPNavigationSession...")
        NSLog("🚗 [NavigationSession] Template valid: \(template)")

        // Create trip
        let currentLocation = mapView.myLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let origin = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation))
        origin.name = "Current Location"

        let destinationLocation = navigator.currentRouteLeg?.destinationCoordinate ?? currentLocation
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationLocation))
        destination.name = "Destination"

        let trip = CPTrip(origin: origin, destination: destination, routeChoices: [])
        currentTrip = trip

        let session = template.startNavigationSession(for: trip)
        navigationSession = session

        NSLog("🚗 [NavigationSession] ✅ Started! Session: \(session)")

        // Try to trigger initial update with maneuvers if navInfo is available
        triggerInitialUpdate(getCachedNavInfo: getCachedNavInfo)
    }

    /// Stop the native CPNavigationSession
    func stopSession() {
        guard let session = navigationSession else { return }

        session.finishTrip()
        navigationSession = nil
        currentTrip = nil
        lastRouteHash = nil
        currentLaneGuidanceManeuver = nil

        NSLog("🚗 [NavigationSession] Session stopped")
    }

    /// Update ETA and maneuvers with navigation info
    func updateNavigation(
        distanceToFinal: CLLocationDistance,
        timeToFinal: TimeInterval,
        navInfo: GMSNavigationNavInfo
    ) {
        guard let session = navigationSession,
              let trip = currentTrip,
              let template = mapTemplate else {
            NSLog("🚗 [NavigationSession] ⚠️ Cannot update - session:\(navigationSession != nil) trip:\(currentTrip != nil) template:\(mapTemplate != nil)")
            return
        }

        // 1) ETA trip
        guard distanceToFinal > 0, timeToFinal > 0 else {
            NSLog("🚗 [NavigationSession] 📊 Skipping ETA update - invalid distance/time")
            return
        }

        let distanceRemaining = formatDistance(distanceToFinal)
        let formattedTime = formatTime(timeToFinal)

        template.updateEstimates(
            CPTravelEstimates(distanceRemaining: distanceRemaining, timeRemaining: formattedTime),
            for: trip
        )

        // 2) Maneuvers (+ lane panel as 2nd maneuver if lanes available)
        updateManeuver(from: navInfo, session: session)
    }

    /// Check if session is active
    var isSessionActive: Bool { navigationSession != nil }

    /// Update references
    func updateReferences(mapTemplate: CPMapTemplate?, mapView: GMSMapView?) {
        self.mapTemplate = mapTemplate
        self.mapView = mapView
    }

    /// Used by CPMapTemplateDelegate (CarSceneDelegate) to return .symbolOnly for the lane guidance maneuver.
    func isLaneGuidanceManeuver(_ maneuver: CPManeuver) -> Bool {
        guard let lane = currentLaneGuidanceManeuver else { return false }
        return maneuver === lane
    }

    /// Cleanup resources
    func cleanup() {
        stopSession()
        mapTemplate = nil
        mapView = nil
    }

    // MARK: - Private

    private func triggerInitialUpdate(getCachedNavInfo: (() -> GMSNavigationNavInfo?)? = nil) {
        guard let mapView = mapView,
              let navigator = mapView.navigator,
              navigator.isGuidanceActive,
              let session = navigationSession else {
            NSLog("🚗 [NavigationSession] Cannot trigger initial update - not ready")
            return
        }

        let distanceToFinal = navigator.distanceToNextDestination
        let timeToFinal = navigator.timeToNextDestination

        // Update ETA
        if distanceToFinal > 0, timeToFinal > 0, let trip = currentTrip, let template = mapTemplate {
            let travelEstimates = CPTravelEstimates(
                distanceRemaining: formatDistance(distanceToFinal),
                timeRemaining: formatTime(timeToFinal)
            )
            template.updateEstimates(travelEstimates, for: trip)
            NSLog("🚗 [NavigationSession] 📊 Initial ETA sent")
        }

        // Try to update maneuvers immediately if navInfo is available
        if let getNavInfo = getCachedNavInfo, let navInfo = getNavInfo() {
            NSLog("🚗 [NavigationSession] 📍 Initial navInfo available, updating maneuvers immediately")
            updateManeuver(from: navInfo, session: session)
        } else {
            NSLog("🚗 [NavigationSession] ⏳ No cached navInfo available, will wait for first update")
        }
    }

    private func laneSignature(from lanes: [GMSNavigationLane]) -> String {
        // stable: suite de shapes+recommended pour chaque lane
        lanes.map { lane in
            lane.laneDirections.map { dir in
                "\(dir.laneShape.rawValue):\(dir.recommended ? 1 : 0)"
            }.joined(separator: ",")
        }.joined(separator: "|")
    }

    private func getOrCreateLaneManeuver(lanes: [GMSNavigationLane]) -> CPManeuver? {
        let sig = laneSignature(from: lanes)
        if sig == cachedLaneSignature, let cached = cachedLaneManeuver {
            return cached
        }
        guard let created = createLaneGuidanceSecondManeuver(from: lanes) else { return nil }
        cachedLaneSignature = sig
        cachedLaneManeuver = created
        return created
    }

    private func nextSignature(step: GMSNavigationStepInfo) -> String {
        // stable enough to reuse the next maneuver object
        let name = step.simpleRoadName ?? step.fullInstructionText ?? "Continue"
        return "\(name)#\(Int(step.distanceFromPrevStepMeters))#\(step.maneuver.rawValue)"
    }

    private func getOrCreateNextManeuver(step: GMSNavigationStepInfo) -> CPManeuver {
        let sig = nextSignature(step: step)
        if sig == cachedNextSignature, let cached = cachedNextManeuver {
            return cached
        }
        let created = createPrimaryManeuver(
            from: step,
            distance: CLLocationDistance(step.distanceFromPrevStepMeters),
            stepName: step.simpleRoadName ?? step.fullInstructionText ?? "Continue"
        )
        cachedNextSignature = sig
        cachedNextManeuver = created
        return created
    }

    private func updateManeuver(from navInfo: GMSNavigationNavInfo, session: CPNavigationSession) {
        guard let currentStep = navInfo.currentStep else {
            NSLog("🚗 [NavigationSession] ⚠️ No current step available")
            return
        }

        let currentStepName = currentStep.simpleRoadName ?? currentStep.fullInstructionText ?? "Continue"
        let distanceToCurrentStep = CLLocationDistance(navInfo.distanceToCurrentStepMeters)

        // Detect route change (coarse but stable)
        let remainingStepsKey = navInfo.remainingSteps.prefix(5).map {
            $0.simpleRoadName ?? $0.fullInstructionText ?? "?"
        }.joined(separator: "|")
        let routeHash = "\(currentStepName)_\(remainingStepsKey)"

        // ---------- Helpers (local, no extra state needed) ----------
        // Hysteresis avoids flicker around thresholds.
        // Keep last state by using `currentLaneGuidanceManeuver != nil` as a weak “memory” for lanes visibility.
        func shouldShowLanePanel(distance: CLLocationDistance) -> Bool {
            // show at <= 900m, hide only when > 1100m
            let showThreshold: CLLocationDistance = 900
            let hideThreshold: CLLocationDistance = 1100

            let wasShowing = (currentLaneGuidanceManeuver != nil)
            if wasShowing {
                return distance <= hideThreshold
            } else {
                return distance <= showThreshold
            }
        }

        func shouldShowNextTurn(distance: CLLocationDistance) -> Bool {
            // show at <= 700m, hide only when > 900m
            let showThreshold: CLLocationDistance = 700
            let hideThreshold: CLLocationDistance = 900

            // We consider "wasShowingNext" as: we were not showing lanes, and we had at least 2 maneuvers previously.
            // (Not perfect, but works without adding persistent state.)
            let wasShowingNext = (currentLaneGuidanceManeuver == nil) && (session.upcomingManeuvers.count >= 2)

            if wasShowingNext {
                return distance <= hideThreshold
            } else {
                return distance <= showThreshold
            }
        }

        func buildPrimaryManeuver(step: GMSNavigationStepInfo, distance: CLLocationDistance) -> CPManeuver {
            let name = step.simpleRoadName ?? step.fullInstructionText ?? "Continue"
            return createPrimaryManeuver(from: step, distance: distance, stepName: name)
        }

        // ---------- Route change: rebuild maneuvers ----------
        if routeHash != lastRouteHash {
            lastRouteHash = routeHash
            cachedLaneSignature = nil
            cachedLaneManeuver = nil
            cachedNextSignature = nil
            cachedNextManeuver = nil
            NSLog("🚗 [NavigationSession] 🔄 Route changed, rebuilding maneuvers...")

            // Always compute full route list (your internal “complete logic”)
            var allPrimary: [CPManeuver] = []
            allPrimary.append(buildPrimaryManeuver(step: currentStep, distance: distanceToCurrentStep))

            let maxRemainingSteps = min(navInfo.remainingSteps.count, 10)
            for i in 0..<maxRemainingSteps {
                let step = navInfo.remainingSteps[i]
                allPrimary.append(buildPrimaryManeuver(step: step, distance: CLLocationDistance(step.distanceFromPrevStepMeters)))
            }

            // Publish only what you want CarPlay to show:
            // - 1st = current maneuver
            // - 2nd = lane panel IF allowed + lanes present (priority)
            // - else 2nd = next maneuver only when close enough
            var published: [CPManeuver] = []
            published.append(allPrimary[0])

            // 2nd slot decision
            var usedSecondSlot = false

            // Lanes have priority
            if shouldShowLanePanel(distance: distanceToCurrentStep),
            let lanes = currentStep.lanes, !lanes.isEmpty,
            let laneManeuver = getOrCreateLaneManeuver(lanes: lanes) {

                published.append(laneManeuver)
                currentLaneGuidanceManeuver = laneManeuver
                usedSecondSlot = true

            } else {
                currentLaneGuidanceManeuver = nil
            }

            // If no lanes panel, maybe show the next turn (but only when close enough)
            if !usedSecondSlot,
            shouldShowNextTurn(distance: distanceToCurrentStep),
            allPrimary.count >= 2 {
                if let nextStep = navInfo.remainingSteps.first {
                    published.append(getOrCreateNextManeuver(step: nextStep))
                }
            }

            session.upcomingManeuvers = published
            NSLog("🚗 [NavigationSession] ✅ Published \(published.count) maneuver(s) (lane panel priority)")
            return
        }

        // ---------- Same route: update distance for current maneuver and refresh 2nd slot if needed ----------
        guard distanceToCurrentStep > 10, let first = session.upcomingManeuvers.first else { return }

        let updated = CPTravelEstimates(distanceRemaining: formatDistance(distanceToCurrentStep), timeRemaining: 0)
        session.updateEstimates(updated, for: first)

        // Optionally refresh the published list even when route doesn't change,
        // so lanes/next appear at the right time as you approach.
        // This avoids “lanes too early” and also allows next turn to appear later.
        let wantLanes = shouldShowLanePanel(distance: distanceToCurrentStep)
        let wantNext = shouldShowNextTurn(distance: distanceToCurrentStep)

        var published: [CPManeuver] = [first]
        var usedSecondSlot = false

        if wantLanes,
        let lanes = currentStep.lanes, !lanes.isEmpty,
           let laneManeuver = getOrCreateLaneManeuver(lanes: lanes) {

            published.append(laneManeuver)
            currentLaneGuidanceManeuver = laneManeuver
            usedSecondSlot = true

        } else {
            currentLaneGuidanceManeuver = nil
        }

        if !usedSecondSlot, wantNext, let next = navInfo.remainingSteps.first {
            published.append(getOrCreateNextManeuver(step: next))
        }

        // Only assign if something changed to reduce UI churn
        let sameCount = (session.upcomingManeuvers.count == published.count)
        let sameSecond = (published.count < 2 && session.upcomingManeuvers.count < 2)
            || (published.count >= 2 && session.upcomingManeuvers.count >= 2
                && (session.upcomingManeuvers[1] === published[1]))

        if !(sameCount && sameSecond) {
            session.upcomingManeuvers = published
            NSLog("🚗 [NavigationSession] 🔁 Refreshed published maneuvers -> \(published.count)")
        }
    }

    // MARK: - Maneuver builders

    private func createPrimaryManeuver(
        from step: GMSNavigationStepInfo,
        distance: CLLocationDistance,
        stepName: String
    ) -> CPManeuver {
        let maneuver = CPManeuver()

        maneuver.instructionVariants = [stepName]
        maneuver.symbolImage = symbolImage(for: step.maneuver)
        maneuver.initialTravelEstimates = CPTravelEstimates(
            distanceRemaining: formatDistance(distance),
            timeRemaining: 0
        )

        return maneuver
    }

    /// Creates the special SECOND maneuver used to show lane guidance on the CarPlay screen.
    /// Doc: symbolSet with dark/light images, full width max 120pt×18pt, instructionVariants = [], return .symbolOnly in delegate.
    private func createLaneGuidanceSecondManeuver(from lanes: [GMSNavigationLane]) -> CPManeuver? {
        guard let light = renderLaneGuidanceImage(lanes: lanes, isDark: false),
              let dark = renderLaneGuidanceImage(lanes: lanes, isDark: true) else {
            return nil
        }

        let m = CPManeuver()
        m.instructionVariants = [] // required for lane guidance second maneuver
        m.symbolSet = CPImageSet(lightContentImage: light, darkContentImage: dark)
        // Required so CarPlay allocates the row for the symbol; doc says maneuver may include estimates.
        m.initialTravelEstimates = CPTravelEstimates(
            distanceRemaining: Measurement(value: 0, unit: .meters),
            timeRemaining: 0
        )
        return m
    }

    // MARK: - Lane image rendering (120pt x 18pt max)

    /// Doc: second maneuver symbol (symbol only) max 120pt×18pt; provide light and dark variants.
    /// Render at 2x scale so the symbol is sharp on CarPlay displays.
    private func renderLaneGuidanceImage(lanes: [GMSNavigationLane], isDark: Bool) -> UIImage? {
        let sizePt = CGSize(width: 120, height: 18) // points (doc max)
        let scale: CGFloat = 2
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: sizePt, format: format)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            cg.clear(CGRect(origin: .zero, size: sizePt))

            // Layout (in point space; context is scaled)
            let laneCount = max(1, min(lanes.count, 8))
            let padding: CGFloat = 2
            let availableWidth = sizePt.width - (padding * 2)
            let laneWidth = availableWidth / CGFloat(laneCount)
            let laneHeight: CGFloat = 12
            let topY: CGFloat = (sizePt.height - laneHeight) / 2

            // Colors: lightContentImage = for light backgrounds (use dark strokes), darkContentImage = for dark backgrounds (use light strokes)
            let neutral = (isDark ? UIColor(white: 1.0, alpha: 0.6) : UIColor(white: 0.0, alpha: 0.5))
            let preferred = (isDark ? UIColor.white : UIColor.black)

            for i in 0..<laneCount {
                let lane = lanes[i]
                let isRecommended = lane.laneDirections.contains(where: { $0.recommended })
                let x = padding + (CGFloat(i) * laneWidth)
                let rect = CGRect(x: x + 1, y: topY, width: max(2, laneWidth - 2), height: laneHeight)

                // Lane outline
                cg.setStrokeColor((isRecommended ? preferred : neutral).cgColor)
                cg.setLineWidth(1.0)
                cg.stroke(rect)

                // Draw a tiny arrow indicating best direction for that lane
                // (simple representation based on first recommended direction if available, otherwise first direction)
                let direction = lane.laneDirections.first(where: { $0.recommended }) ?? lane.laneDirections.first
                let shape = direction?.laneShape

                drawMiniArrow(
                    in: rect.insetBy(dx: 2, dy: 2),
                    shape: shape,
                    color: (isRecommended ? preferred : neutral),
                    context: cg
                )
            }
        }
    }

    private func drawMiniArrow(in rect: CGRect,
                               shape: GMSNavigationLaneShape?,
                               color: UIColor,
                               context cg: CGContext) {
        // Very compact arrow, just enough to be meaningful at 120x18
        // We'll draw a simple polyline: left / straight / right / uturn-ish
        let midX = rect.midX
        let midY = rect.midY

        let len: CGFloat = min(rect.width, rect.height) * 0.9

        // Basic vectors
        let start = CGPoint(x: midX, y: midY + len * 0.35)
        let endStraight = CGPoint(x: midX, y: midY - len * 0.35)
        let endLeft = CGPoint(x: midX - len * 0.35, y: midY - len * 0.10)
        let endRight = CGPoint(x: midX + len * 0.35, y: midY - len * 0.10)

        cg.setStrokeColor(color.cgColor)
        cg.setLineWidth(1.2)
        cg.setLineCap(.round)
        cg.setLineJoin(.round)

        cg.beginPath()
        cg.move(to: start)

        switch shape {
        case .some(.straight):
            cg.addLine(to: endStraight)
        case .some(.slightLeft), .some(.normalLeft), .some(.sharpLeft), .some(.uTurnLeft):
            cg.addLine(to: CGPoint(x: midX, y: midY))
            cg.addLine(to: endLeft)
        case .some(.slightRight), .some(.normalRight), .some(.sharpRight), .some(.uTurnRight):
            cg.addLine(to: CGPoint(x: midX, y: midY))
            cg.addLine(to: endRight)
        default:
            cg.addLine(to: endStraight)
        }

        cg.strokePath()
    }

    // MARK: - Distance / time formatting

    private func formatDistance(_ distance: CLLocationDistance) -> Measurement<UnitLength> {
        if distance >= 1000 {
            let km = distance / 1000.0
            let roundedKm = round(km * 10) / 10
            return Measurement(value: roundedKm, unit: .kilometers)
        } else if distance >= 100 {
            let roundedMeters = round(distance / 50.0) * 50.0
            return Measurement(value: roundedMeters, unit: .meters)
        } else {
            let roundedMeters = round(distance / 10.0) * 10.0
            return Measurement(value: roundedMeters, unit: .meters)
        }
    }

    private func formatTime(_ time: TimeInterval) -> TimeInterval {
        let minutes = Int(time / 60.0)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))

        let roundedMinutes: Int
        if time < 60 { roundedMinutes = 1 }
        else if seconds >= 30 { roundedMinutes = minutes + 1 }
        else { roundedMinutes = minutes }

        return TimeInterval(roundedMinutes * 60)
    }

    private func symbolImage(for maneuver: GMSNavigationManeuver) -> UIImage? {
        let symbolName: String
        switch maneuver {
        case .destination: symbolName = "flag.checkered"
        case .depart: symbolName = "arrow.up.circle"
        case .straight: symbolName = "arrow.up"
        case .turnLeft, .turnSharpLeft, .turnSlightLeft: symbolName = "arrow.turn.up.left"
        case .turnRight, .turnSharpRight, .turnSlightRight: symbolName = "arrow.turn.up.right"
        case .onRampLeft, .offRampLeft: symbolName = "arrow.up.left"
        case .onRampRight, .offRampRight: symbolName = "arrow.up.right"
        case .turnUTurnClockwise: symbolName = "arrow.uturn.left"
        case .mergeLeft, .mergeRight: symbolName = "arrow.merge"
        case .roundaboutClockwise: symbolName = "arrow.triangle.2.circlepath"
        case .ferryBoat: symbolName = "ferry"
        default: symbolName = "arrow.up"
        }
        return UIImage(systemName: symbolName)
    }
}

