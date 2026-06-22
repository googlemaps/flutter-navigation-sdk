// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import CarPlay
import GoogleNavigation
import MapKit
import UIKit
import google_navigation_flutter

/// Example CarPlay scene delegate that shows how to extend the SDK-provided
/// `BaseCarSceneDelegate` to build a full turn-by-turn CarPlay experience.
///
/// This class is intended to be read as documentation. It demonstrates the two
/// responsibilities an app has when integrating the Google Navigation SDK with
/// Apple CarPlay:
///
/// 1. Rendering the map and CarPlay UI. `BaseCarSceneDelegate` already creates
///    the `GMSMapView`-backed navigation view and attaches it to the CarPlay
///    window. We only customize the `CPMapTemplate` (buttons, panning) by
///    overriding `getTemplate()`.
/// 2. Feeding turn-by-turn guidance into CarPlay's navigation card. CarPlay does
///    not read guidance from the map automatically: the app must translate the
///    SDK's `GMSNavigationNavInfo` updates into CarPlay's `CPTrip`,
///    `CPManeuver` and `CPTravelEstimates` objects. We do this by conforming to
///    `GMSNavigatorListener` and driving a `CPNavigationSession`.
///
/// The overall data flow is:
///
///     GMSNavigator --(didUpdate navInfo)--> CarSceneDelegate
///         --> CPNavigationSession (maneuvers, road name, estimates)
///         --> CarPlay guidance card
///
/// See https://developers.google.com/maps/documentation/navigation/ios-sdk/carplay
/// for the official guide that this example follows.
class CarSceneDelegate: BaseCarSceneDelegate, GMSNavigatorListener {
  /// Tracks whether `self` is currently registered as a `GMSNavigatorListener`.
  /// Used to avoid registering twice or removing a listener that was never added.
  private var isNavigatorListenerRegistered = false

  /// The map template currently shown on the CarPlay screen. Held weakly because
  /// the template's lifetime is owned by `BaseCarSceneDelegate`/CarPlay; we only
  /// need it to start and update the navigation session.
  private weak var activeMapTemplate: CPMapTemplate?

  /// The CarPlay trip describing the origin/destination of the active route.
  /// A trip must exist before a `CPNavigationSession` can be started, and the
  /// trip is what trip-level estimates (time/distance to destination) are
  /// reported against.
  private var activeTrip: CPTrip?

  /// The live CarPlay navigation session. This is the object that actually
  /// renders the turn-by-turn guidance card and that we push maneuvers and
  /// travel estimates into as `navInfo` updates arrive.
  private var activeNavigationSession: CPNavigationSession?

  /// Options used to render the maneuver instructions and images that the
  /// Navigation SDK provides for the turn-by-turn guidance card. Reusing a
  /// single instance keeps the instruction styling consistent across updates.
  private lazy var instructionOptions: GMSNavigationInstructionOptions = {
    let options = GMSNavigationInstructionOptions()
    options.imageOptions = GMSNavigationStepInfoImageOptions()
    return options
  }()

  /// An object stored in the `userInfo` field of a `CPManeuver` so the template
  /// delegate (`mapTemplate(_:displayStyleFor:)`) can determine the correct
  /// `CPManeuverDisplayStyle`. CarPlay does not distinguish a regular turn
  /// maneuver from a lane-guidance maneuver on its own, so we tag each maneuver
  /// here and inspect the tag when CarPlay asks how to display it.
  private struct ManeuverUserInfo {
    var stepInfo: GMSNavigationStepInfo
    var isLaneGuidance: Bool
  }

  // MARK: - CarPlay template

  /// Builds the root `CPMapTemplate` shown on the CarPlay screen.
  ///
  /// `BaseCarSceneDelegate` calls this whenever it needs to (re)build the
  /// template, for example after the navigation session attaches/detaches. We
  /// use it to add our custom toolbar buttons and to enable map panning.
  override func getTemplate() -> CPMapTemplate {
    let template = CPMapTemplate()
    template.showPanningInterface(animated: true)
    // Keep a reference so navigator updates can start/update the navigation
    // session on the currently visible template.
    activeMapTemplate = template

    // A button that demonstrates sending a custom event back to Flutter. This
    // lets the Flutter side react to app-specific actions taken on the car
    // screen (e.g. accepting an order).
    let customEventButton = CPBarButton(title: "Custom Event") { [weak self] _ in
      let data = ["sampleDataKey": "sampleDataContent"]
      self?.sendCustomNavigationAutoEvent(event: "CustomCarPlayEvent", data: data)
    }
    // A button that re-centers the camera on the user's location. Re-centering
    // only makes sense once navigation guidance is active, so it is added
    // conditionally below.
    let recenterButton = CPBarButton(title: "Re-center") { [weak self] _ in
      self?.getNavView()?.followMyLocation(
        perspective: GMSNavigationCameraPerspective.tilted,
        zoomLevel: nil
      )
    }

    let navView = getNavView()
    var leadingButtons = [customEventButton]
    // Only offer "Re-center" when the view is attached to a navigation session
    // and the navigation UI is enabled, otherwise the action would have nothing
    // to follow.
    if (navView?.isAttachedToSession ?? false) && (navView?.isNavigationUIEnabled() ?? false) {
      leadingButtons.append(recenterButton)
    }
    template.leadingNavigationBarButtons = leadingButtons
    return template
  }

  // MARK: - Custom Flutter events

  /// Called when Flutter sends a custom event to the native side via
  /// `GoogleMapsAutoViewController.sendCustomNavigationAutoEvent`. This example
  /// surfaces the message as a CarPlay alert.
  override func onCustomNavigationAutoEventFromFlutter(event: String, data: Any) {
    NSLog("CarSceneDelegate: Received custom event from Flutter: event=\(event), data=\(data)")

    let message = (data as? [String: Any])?["message"] as? String ?? "No message"
    showCarPlayMessage(String(message.prefix(120)))
  }

  // MARK: - Map options

  /// Provides the map options used when `BaseCarSceneDelegate` creates the
  /// CarPlay map view. Returning `super`'s value uses the options supplied from
  /// Flutter; override to hard-code native options instead.
  override func getAutoMapOptions() -> AutoMapViewOptions? {
    // Call super to use Flutter-provided options.
    return super.getAutoMapOptions()

    // Or provide your own custom options:
    // let cameraPosition = GMSCameraPosition(latitude: 37.7749, longitude: -122.4194, zoom: 14)
    // return AutoMapViewOptions(
    //   cameraPosition: cameraPosition,
    //   mapId: "your-custom-map-id",
    //   mapType: .satellite,
    //   mapColorScheme: .dark,
    //   forceNightMode: .lowLight
    // )
  }

  // MARK: - Prompt visibility

  /// Called when a traffic/incident prompt appears or disappears on the CarPlay
  /// screen. Always call `super` so the event is forwarded to Flutter; add
  /// custom UI adjustments afterwards if needed.
  override func onPromptVisibilityChanged(promptVisible: Bool) {
    // Call super to ensure Flutter receives the event.
    super.onPromptVisibilityChanged(promptVisible: promptVisible)

    NSLog("CarSceneDelegate: onPromptVisibilityChanged called with promptVisible=\(promptVisible)")

    // Example: Hide custom UI when prompt appears, show it when prompt disappears
    // Uncomment to enable this behavior:
    // if promptVisible {
    //   mapTemplate?.leadingNavigationBarButtons = []
    // } else {
    //   // Restore your custom buttons
    //   let customEventButton = CPBarButton(title: "Custom Event") { [weak self] _ in
    //     let data = ["sampleDataKey": "sampleDataContent"]
    //     self?.sendCustomNavigationAutoEvent(event: "CustomCarPlayEvent", data: data)
    //   }
    //   let recenterButton = CPBarButton(title: "Re-center") { [weak self] _ in
    //     self?.getNavView()?.followMyLocation(
    //       perspective: GMSNavigationCameraPerspective.tilted,
    //       zoomLevel: nil
    //     )
    //   }
    //   mapTemplate?.leadingNavigationBarButtons = [customEventButton, recenterButton]
    // }
  }

  // MARK: - Navigation lifecycle

  /// Called when the navigation UI is enabled or disabled. We keep our
  /// navigator-listener registration in sync (we only want guidance updates
  /// while the navigation UI is active) and rebuild the template so the
  /// conditional "Re-center" button reflects the new state.
  override func onNavigationUIEnabledChanged(isEnabled: Bool) {
    super.onNavigationUIEnabledChanged(isEnabled: isEnabled)
    syncNavigatorListenerRegistration()
    refreshTemplate()
  }

  /// Tells CarPlay that this delegate supplies navigation metadata (maneuvers,
  /// estimates, lane guidance). Required on iOS 17.4+ for the guidance card to
  /// display the data we push into the `CPNavigationSession`.
  @available(iOS 17.4, *)
  func mapTemplateShouldProvideNavigationMetadata(_ mapTemplate: CPMapTemplate) -> Bool {
    true
  }

  /// Determines how each maneuver is rendered in the guidance card. Lane
  /// guidance maneuvers only show their symbol, while regular maneuvers show a
  /// leading symbol alongside the instruction text. We rely on the
  /// `ManeuverUserInfo` tag attached when the maneuver was created.
  func mapTemplate(
    _ mapTemplate: CPMapTemplate,
    displayStyleFor maneuver: CPManeuver
  ) -> CPManeuverDisplayStyle {
    if let maneuverUserInfo = maneuver.userInfo as? ManeuverUserInfo {
      return maneuverUserInfo.isLaneGuidance ? .symbolOnly : .leadingSymbol
    }
    return .leadingSymbol
  }

  /// Called when the view attaches to or detaches from a navigation session.
  /// On detach we tear down the CarPlay navigation session so no stale guidance
  /// card remains, and we keep the navigator-listener registration in sync.
  override func onSessionAttachmentChanged(isAttachedToSession: Bool) {
    super.onSessionAttachmentChanged(isAttachedToSession: isAttachedToSession)
    syncNavigatorListenerRegistration()
    if !isAttachedToSession {
      clearCarPlayNavigationSession()
    }
    refreshTemplate()
  }

  deinit {
    // Always release the navigation session and unregister the listener so we
    // don't leak or receive callbacks after this delegate is gone.
    clearCarPlayNavigationSession()
    unregisterNavigatorListener()
  }

  // MARK: - GMSNavigatorListener

  /// The SDK calls this on every guidance update. This is the entry point for
  /// translating SDK guidance into CarPlay's navigation card.
  func navigator(_ navigator: GMSNavigator, didUpdate navInfo: GMSNavigationNavInfo) {
    updateCarPlayNavigationMetadata(navigator: navigator, navInfo: navInfo)
  }

  // MARK: - Navigator listener registration

  /// Registers `self` as a `GMSNavigatorListener` exactly once. The navigator is
  /// a singleton owned by the SDK; we obtain it through `ExposedGoogleMapsNavigator`.
  private func registerNavigatorListener() {
    do {
      let navigator = try ExposedGoogleMapsNavigator.getNavigator()
      if !isNavigatorListenerRegistered {
        navigator.add(self)
        isNavigatorListenerRegistered = true
      }
    } catch {
      isNavigatorListenerRegistered = false
      NSLog("CarSceneDelegate: Unable to register navigator listener: \(error)")
    }
  }

  /// Removes `self` as a `GMSNavigatorListener` if it was previously registered.
  private func unregisterNavigatorListener() {
    do {
      let navigator = try ExposedGoogleMapsNavigator.getNavigator()
      if isNavigatorListenerRegistered {
        _ = navigator.remove(self)
        isNavigatorListenerRegistered = false
      }
    } catch {
      isNavigatorListenerRegistered = false
      NSLog("CarSceneDelegate: Unable to unregister navigator listener: \(error)")
    }
  }

  /// Registers the navigator listener only while the CarPlay view is attached to
  /// a session and its navigation UI is enabled, and unregisters it otherwise.
  /// This guarantees we only consume guidance updates when there is a CarPlay
  /// guidance card to populate.
  private func syncNavigatorListenerRegistration() {
    let navView = getNavView()
    let shouldRegister =
      (navView?.isAttachedToSession ?? false) &&
      (navView?.isNavigationUIEnabled() ?? false)
    if shouldRegister {
      registerNavigatorListener()
    } else {
      unregisterNavigatorListener()
    }
  }

  // MARK: - Populating the CarPlay guidance card

  /// Translates a single `GMSNavigationNavInfo` update into the CarPlay
  /// navigation session. This is the heart of the integration and runs on every
  /// guidance update:
  ///
  /// 1. If there is no current step, tear down the session (navigation ended).
  /// 2. Start a `CPNavigationSession` (once) for the current trip.
  /// 3. Build the current maneuver (+ optional lane guidance) and hand it to the
  ///    session.
  /// 4. Update both the trip-level and step-level travel estimates.
  private func updateCarPlayNavigationMetadata(
    navigator: GMSNavigator,
    navInfo: GMSNavigationNavInfo
  ) {
    guard let currentStep = navInfo.currentStep else {
      // No active step means guidance is not (or no longer) running.
      clearCarPlayNavigationSession()
      return
    }

    guard let mapTemplate = activeMapTemplate else {
      // Nothing to render into yet; the template will be rebuilt and a later
      // update will populate it.
      return
    }

    // When the route changes (e.g. a reroute) the previous trip is no longer
    // valid, so drop the old session and start a fresh one below.
    if navInfo.routeChanged {
      clearCarPlayNavigationSession()
    }

    // Start the navigation session lazily the first time we have guidance. A
    // `CPNavigationSession` is always associated with a `CPTrip`.
    if activeNavigationSession == nil || activeTrip == nil {
      let trip = makeTrip(navigator: navigator, navInfo: navInfo)
      activeTrip = trip
      activeNavigationSession = mapTemplate.startNavigationSession(for: trip)
    }

    let maneuver = makeManeuver(for: currentStep, navInfo: navInfo)
    maneuver.initialTravelEstimates = makeStepTravelEstimates(navInfo: navInfo)

    // Build the list of maneuvers shown in the guidance card. The current
    // maneuver is shown first, optionally followed by a lane guidance maneuver
    // that only displays the lanes image.
    var upcomingManeuvers = [maneuver]
    if let laneGuidance = makeLaneGuidanceManeuver(for: currentStep) {
      upcomingManeuvers.append(laneGuidance)
    }

    if #available(iOS 17.4, *) {
      // On iOS 17.4+ maneuvers must first be registered with the session via
      // `add(_:)` before they can be shown through `upcomingManeuvers`.
      activeNavigationSession?.add(upcomingManeuvers)
      let roadName = currentStep.fullRoadName
      if !roadName.isEmpty {
        activeNavigationSession?.currentRoadNameVariants = [roadName]
      }
    }
    // The display list of maneuvers. Available since iOS 12; on 17.4+ these must
    // have been added above first.
    activeNavigationSession?.upcomingManeuvers = upcomingManeuvers

    // Trip-level estimates drive the "time/distance to destination" UI.
    if let trip = activeTrip {
      mapTemplate.updateEstimates(makeTripTravelEstimates(navInfo: navInfo), for: trip)
    }
    // Step-level estimates drive the "distance to next maneuver" UI.
    activeNavigationSession?.updateEstimates(
      makeStepTravelEstimates(navInfo: navInfo),
      for: maneuver
    )
  }

  /// Builds the `CPTrip` describing the current route's origin and destination.
  /// CarPlay needs a trip before a navigation session can be created, and uses
  /// the trip for the destination name and route summary.
  private func makeTrip(navigator: GMSNavigator, navInfo: GMSNavigationNavInfo) -> CPTrip {
    let originCoordinate =
      getNavView()?.getMyLocation()
      ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)

    let destinationCoordinate = navigator.currentRouteLeg?.destinationCoordinate
      ?? originCoordinate
    let destinationTitle =
      navigator.currentRouteLeg?.destinationWaypoint?.title
      ?? "Destination"

    let originPlacemark = MKPlacemark(coordinate: originCoordinate)
    let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

    let originItem = MKMapItem(placemark: originPlacemark)
    originItem.name = "Current Location"

    let destinationItem = MKMapItem(placemark: destinationPlacemark)
    destinationItem.name = destinationTitle

    let routeSummary = buildRouteSummary(navInfo: navInfo)
    let routeDetails = buildRouteDetails(navInfo: navInfo)
    let routeChoice = CPRouteChoice(
      summaryVariants: [routeSummary],
      additionalInformationVariants: [routeDetails],
      selectionSummaryVariants: [routeSummary]
    )

    let trip = CPTrip(origin: originItem, destination: destinationItem, routeChoices: [routeChoice])
    if #available(iOS 17.4, *) {
      trip.destinationNameVariants = [destinationTitle]
    }
    return trip
  }

  // Builds a CPManeuver for the given step. Uses the attributed instruction
  // variants generated by the Navigation SDK for most maneuvers, and provides
  // friendly text for the arrival maneuvers. The maneuver symbol image is also
  // generated by the SDK.
  //
  // The maneuver is tagged via `ManeuverUserInfo` so the template delegate can
  // render it with the `.leadingSymbol` style.
  private func makeManeuver(
    for step: GMSNavigationStepInfo,
    navInfo: GMSNavigationNavInfo
  ) -> CPManeuver {
    let maneuver = CPManeuver()
    maneuver.userInfo = ManeuverUserInfo(stepInfo: step, isLaneGuidance: false)

    switch step.maneuver {
    case .destination:
      maneuver.instructionVariants = ["Your destination is ahead."]
    case .destinationLeft:
      maneuver.instructionVariants = ["Your destination is ahead on your left."]
    case .destinationRight:
      maneuver.instructionVariants = ["Your destination is ahead on your right."]
    default:
      let attributedInstructions = navInfo.instructions(
        forStep: step,
        options: instructionOptions
      )
      if !attributedInstructions.isEmpty {
        maneuver.attributedInstructionVariants = attributedInstructions
      } else {
        maneuver.instructionVariants = [step.fullInstructionText]
      }
    }

    if let maneuverImage = step.maneuverImage(with: instructionOptions.imageOptions) {
      maneuver.symbolImage = maneuverImage
    }

    return maneuver
  }

  // Builds a separate CPManeuver that only renders the lane guidance image for
  // the given step, or nil if no lanes image is available. It is tagged as lane
  // guidance so the template delegate renders it with the `.symbolOnly` style.
  private func makeLaneGuidanceManeuver(for step: GMSNavigationStepInfo) -> CPManeuver? {
    guard let lanesImage = step.lanesImage(with: instructionOptions.imageOptions) else {
      return nil
    }
    let maneuver = CPManeuver()
    maneuver.userInfo = ManeuverUserInfo(stepInfo: step, isLaneGuidance: true)
    maneuver.symbolImage = lanesImage
    return maneuver
  }

  // Travel estimates to the final destination, shown on the trip overview.
  // `roundedDistance`/`roundedTime` apply the SDK's locale-aware rounding so the
  // values match what the on-phone navigation UI displays.
  private func makeTripTravelEstimates(navInfo: GMSNavigationNavInfo) -> CPTravelEstimates {
    CPTravelEstimates(
      distanceRemaining: navInfo.roundedDistance(navInfo.distanceToFinalDestinationMeters)
        as Measurement<UnitLength>,
      timeRemaining: navInfo.roundedTime(navInfo.timeToFinalDestinationSeconds)
    )
  }

  // Travel estimates to the next maneuver (current step), shown on the guidance
  // card. Uses the same SDK rounding as the trip estimates above.
  private func makeStepTravelEstimates(navInfo: GMSNavigationNavInfo) -> CPTravelEstimates {
    CPTravelEstimates(
      distanceRemaining: navInfo.roundedDistance(navInfo.distanceToCurrentStepMeters)
        as Measurement<UnitLength>,
      timeRemaining: navInfo.roundedTime(navInfo.timeToCurrentStepSeconds)
    )
  }

  // A short, human-readable summary ("~12 min") used for the trip's route choice.
  private func buildRouteSummary(navInfo: GMSNavigationNavInfo) -> String {
    let seconds = max(Int(navInfo.timeToFinalDestinationSeconds), 0)
    let minutes = Int((Double(seconds) / 60.0).rounded())
    return minutes > 0 ? "~\(minutes) min" : "Arriving"
  }

  // A short, human-readable distance ("3.4 km" / "850 m") used for the trip's
  // route choice additional information.
  private func buildRouteDetails(navInfo: GMSNavigationNavInfo) -> String {
    let meters = max(Int(navInfo.distanceToFinalDestinationMeters), 0)
    return meters >= 1000
      ? String(format: "%.1f km", Double(meters) / 1000.0)
      : "\(meters) m"
  }

  // Cancels and releases the active CarPlay navigation session and trip, so the
  // guidance card disappears and a fresh session can be started later.
  private func clearCarPlayNavigationSession() {
    activeNavigationSession?.cancelTrip()
    activeNavigationSession = nil
    activeTrip = nil
  }

  // Presents a simple dismissible alert on the CarPlay screen. Used here to
  // surface messages received from Flutter.
  private func showCarPlayMessage(_ message: String) {
    DispatchQueue.main.async {
      guard
        let interfaceController = UIApplication.shared.connectedScenes
          .compactMap({ $0 as? CPTemplateApplicationScene })
          .first?
          .interfaceController
      else {
        return
      }

      let alertAction = CPAlertAction(title: "OK", style: .default) { _ in
        interfaceController.dismissTemplate(animated: true, completion: nil)
      }
      let alert = CPAlertTemplate(titleVariants: [message], actions: [alertAction])

      interfaceController.presentTemplate(alert, animated: true, completion: nil)
    }
  }
}
