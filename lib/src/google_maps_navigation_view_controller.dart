import '../google_navigation_flutter.dart';
import 'google_navigation_flutter_platform_interface.dart';

/// Navigation View Controller class to handle navigation view events.
/// {@category Navigation View}
class GoogleNavigationViewController {
  /// Basic constructor.
  ///
  /// Don't create this directly, but access through
  /// [GoogleMapsNavigationView.onViewCreated] callback.
  GoogleNavigationViewController(this._viewId, [this._viewState])
      : settings = NavigationViewUISettings(_viewId) {
    _initListeners();
  }

  final int _viewId;

  final GoogleMapsNavigationViewState? _viewState;

  /// Settings for the user interface of the map.
  final NavigationViewUISettings settings;

  /// Getter for view ID.
  int getViewId() {
    return _viewId;
  }

  /// Initializes the event channel listeners for the navigation view instance.
  void _initListeners() {
    _setOnMapClickedListeners();
    _setOnRecenterButtonClickedListener();
    _setOnMarkerClickedListeners();
    _setOnMarkerDragListeners();
    _setOnPolygonClickedListener();
    _setOnPolylineClickedListener();
    _setOnCircleClickedListener();
    _setOnNavigationUIEnabledChangedListener();
    _setOnMyLocationClickedListener();
    _setOnMyLocationButtonClickedListener();
    _setOnCameraChangedListener();
  }

  /// Sets the event channel listener for the map click event listeners.
  void _setOnMapClickedListeners() {
    if (_viewState != null) {
      if (_viewState.widget.onMapClicked != null) {
        GoogleMapsNavigationPlatform.instance
            .getMapClickEventStream(viewId: _viewId)
            .listen((MapClickEvent event) {
          _viewState.widget.onMapClicked!(event.target);
        });
      }
      if (_viewState.widget.onMapLongClicked != null) {
        GoogleMapsNavigationPlatform.instance
            .getMapLongClickEventStream(viewId: _viewId)
            .listen((MapLongClickEvent event) {
          _viewState.widget.onMapLongClicked!(event.target);
        });
      }
    }
  }

  /// Sets the event channel listener for the on recenter button clicked event.
  void _setOnRecenterButtonClickedListener() {
    if (_viewState != null &&
        _viewState.widget.onRecenterButtonClicked != null) {
      GoogleMapsNavigationPlatform.instance
          .getNavigationRecenterButtonClickedEventStream(viewId: _viewId)
          .listen(_viewState.widget.onRecenterButtonClicked);
    }
  }

  /// Sets the event channel listener for the marker clicked events.
  void _setOnMarkerClickedListeners() {
    GoogleMapsNavigationPlatform.instance
        .getMarkerEventStream(viewId: _viewId)
        .listen((MarkerEvent event) {
      switch (event.eventType) {
        case MarkerEventType.clicked:
          _viewState?.widget.onMarkerClicked?.call(event.markerId);
        case MarkerEventType.infoWindowClicked:
          _viewState?.widget.onMarkerInfoWindowClicked?.call(event.markerId);
        case MarkerEventType.infoWindowClosed:
          _viewState?.widget.onMarkerInfoWindowClosed?.call(event.markerId);
        case MarkerEventType.infoWindowLongClicked:
          _viewState?.widget.onMarkerInfoWindowLongClicked
              ?.call(event.markerId);
      }
    });
  }

  /// Sets the event channel listener for the on my location clicked event.
  void _setOnMyLocationClickedListener() {
    if (_viewState != null && _viewState.widget.onMyLocationClicked != null) {
      GoogleMapsNavigationPlatform.instance
          .getMyLocationClickedEventStream(viewId: _viewId)
          .listen(_viewState.widget.onMyLocationClicked);
    }
  }

  /// Sets the event channel listener for the on my location button clicked event.
  void _setOnMyLocationButtonClickedListener() {
    if (_viewState != null &&
        _viewState.widget.onMyLocationButtonClicked != null) {
      GoogleMapsNavigationPlatform.instance
          .getMyLocationButtonClickedEventStream(viewId: _viewId)
          .listen(_viewState.widget.onMyLocationButtonClicked);
    }
  }

  /// Sets the event channel listener for camera changed events.
  void _setOnCameraChangedListener() {
    // Register listeners if any of the callbacks are not null.
    if (_viewState?.widget.onCameraMoveStarted != null ||
        _viewState?.widget.onCameraMove != null ||
        _viewState?.widget.onCameraIdle != null) {
      GoogleMapsNavigationPlatform.instance
          .registerOnCameraChangedListener(viewId: _viewId);
    }
    GoogleMapsNavigationPlatform.instance
        .getCameraChangedEventStream(viewId: _viewId)
        .listen((CameraChangedEvent event) {
      switch (event.eventType) {
        case CameraEventType.moveStartedByApi:
          _viewState?.widget.onCameraMoveStarted?.call(event.position, false);
        case CameraEventType.moveStartedByGesture:
          _viewState?.widget.onCameraMoveStarted?.call(event.position, true);
        case CameraEventType.onCameraMove:
          _viewState?.widget.onCameraMove?.call(event.position);
        case CameraEventType.onCameraIdle:
          _viewState?.widget.onCameraIdle?.call(event.position);
        case CameraEventType.onCameraStartedFollowingLocation:
          _viewState?.widget.onCameraStartedFollowingLocation
              ?.call(event.position);
        case CameraEventType.onCameraStoppedFollowingLocation:
          _viewState?.widget.onCameraStoppedFollowingLocation
              ?.call(event.position);
      }
    });
  }

  /// Sets the event channel listener for the marker drag event.
  void _setOnMarkerDragListeners() {
    GoogleMapsNavigationPlatform.instance
        .getMarkerDragEventStream(viewId: _viewId)
        .listen((MarkerDragEvent event) {
      switch (event.eventType) {
        case MarkerDragEventType.drag:
          _viewState?.widget.onMarkerDrag?.call(event.markerId, event.position);
        case MarkerDragEventType.dragEnd:
          _viewState?.widget.onMarkerDragEnd
              ?.call(event.markerId, event.position);
        case MarkerDragEventType.dragStart:
          _viewState?.widget.onMarkerDragStart
              ?.call(event.markerId, event.position);
      }
    });
  }

  /// Sets the event channel listener for the polygon clicked event.
  void _setOnPolygonClickedListener() {
    GoogleMapsNavigationPlatform.instance
        .getPolygonClickedEventStream(viewId: _viewId)
        .listen((PolygonClickedEvent event) {
      _viewState?.widget.onPolygonClicked?.call(event.polygonId);
    });
  }

  /// Sets the event channel listener for the polyline clicked event.
  void _setOnPolylineClickedListener() {
    GoogleMapsNavigationPlatform.instance
        .getPolylineClickedEventStream(viewId: _viewId)
        .listen((PolylineClickedEvent event) {
      _viewState?.widget.onPolylineClicked?.call(event.polylineId);
    });
  }

  /// Sets the event channel listener for the circle clicked event.
  void _setOnCircleClickedListener() {
    GoogleMapsNavigationPlatform.instance
        .getCircleClickedEventStream(viewId: _viewId)
        .listen((CircleClickedEvent event) {
      _viewState?.widget.onCircleClicked?.call(event.circleId);
    });
  }

  /// Sets the event channel listener for the navigation UI enabled changed event.
  void _setOnNavigationUIEnabledChangedListener() {
    GoogleMapsNavigationPlatform.instance
        .getNavigationUIEnabledChangedEventStream(viewId: _viewId)
        .listen((NavigationUIEnabledChangedEvent event) {
      _viewState?.widget.onNavigationUIEnabledChanged
          ?.call(event.navigationUIEnabled);
    });
  }

  /// Change status of my location enabled.
  ///
  /// By default, the my location layer is disabled, but gets
  /// automatically enabled on Android when the navigation starts.
  ///
  /// On iOS this property doesn't control the my location indication during
  /// the navigation.
  Future<void> setMyLocationEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setMyLocationEnabled(viewId: _viewId, enabled: enabled);
  }

  /// This method returns the current map type of the Google Maps view instance.
  Future<MapType> getMapType() {
    return GoogleMapsNavigationPlatform.instance.getMapType(viewId: _viewId);
  }

  /// Changes the type of the map being displayed on the Google Maps view.
  ///
  /// The [mapType] parameter specifies the new map type to be set.
  /// It should be one of the values defined in the [MapType] enum,
  /// such as [MapType.normal], [MapType.satellite], [MapType.terrain],
  /// or [MapType.hybrid].
  ///
  /// Example usage:
  /// ```dart
  /// _navigationViewController.changeMapType(MapType.satellite);
  /// ```
  Future<void> setMapType({required MapType mapType}) async {
    return GoogleMapsNavigationPlatform.instance
        .setMapType(viewId: _viewId, mapType: mapType);
  }

  /// Sets the styling of the base map using a string containing JSON.
  /// Null value will reset the base map to default style.
  /// If [styleJson] is invalid throws [MapStyleException].
  ///
  /// For more details see the official documentation:
  /// https://developers.google.com/maps/documentation/ios-sdk/styling
  /// https://developers.google.com/maps/documentation/android-sdk/styling
  Future<void> setMapStyle(String? styleJson) async {
    return GoogleMapsNavigationPlatform.instance
        .setMapStyle(_viewId, styleJson);
  }

  /// Gets whether the my location is enabled or disabled.
  ///
  /// By default, the my location layer is disabled, but gets
  /// automatically enabled on Android when the navigation starts.
  ///
  /// On iOS this property doesn't control the my location indication during
  /// the navigation.
  Future<bool> isMyLocationEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isMyLocationEnabled(viewId: _viewId);
  }

  /// Ask the camera to follow the user's location.
  ///
  /// Use [perspective] to specify the orientation of the camera
  /// and optional [zoomLevel] to control the map zoom.
  ///
  /// Automatically started in the perspective [CameraPerspective.tilted] when
  /// the navigation is initialized with [GoogleMapsNavigator.initializeNavigationSession]
  /// or when navigation UI gets re-enabled with [setNavigationUIEnabled].
  ///
  /// In Android, you can use [GoogleMapsNavigationView.onCameraStartedFollowingLocation]
  /// and [GoogleMapsNavigationView.onCameraStoppedFollowingLocation] callbacks
  /// to detect when the follow location mode is enabled or disabled.
  ///
  /// Note there are small differences on how Android and iOS handle the camera
  /// during the follow my location mode (tilt, zoom, transitions, etc.).
  ///
  /// See also [GoogleMapsNavigator.startGuidance], [showRouteOverview] and [animateCamera].
  Future<void> followMyLocation(CameraPerspective perspective,
      {double? zoomLevel}) async {
    return GoogleMapsNavigationPlatform.instance.followMyLocation(
        viewId: _viewId, perspective: perspective, zoomLevel: zoomLevel);
  }

  /// Gets user's current location.
  Future<LatLng?> getMyLocation() async {
    return GoogleMapsNavigationPlatform.instance.getMyLocation(viewId: _viewId);
  }

  /// Gets the current visible map region or camera bounds.
  Future<LatLngBounds> getVisibleRegion() async {
    return GoogleMapsNavigationPlatform.instance
        .getVisibleRegion(viewId: _viewId);
  }

  /// Gets the current position of the camera.
  Future<CameraPosition> getCameraPosition() async {
    return GoogleMapsNavigationPlatform.instance
        .getCameraPosition(viewId: _viewId);
  }

  /// Animates the movement of the camera from the current position
  /// to the position defined in the [cameraUpdate].
  ///
  /// See [CameraUpdate] for more information on how to create different camera
  /// animations.
  ///
  /// On Android you can override the default animation [duration] and
  /// set [onFinished] callback that is called when the animation completes
  /// (passes true) or is cancelled (passes false).
  ///
  /// Example usage:
  /// ```dart
  /// controller.animateCamera(CameraUpdate.zoomIn(),
  ///   duration: Duration(milliseconds: 600),
  ///   onFinished: (bool success) => {});
  /// ```
  /// On iOS [duration] and [onFinished] are not supported and defining them
  /// does nothing.
  ///
  /// See also [moveCamera], [followMyLocation], [showRouteOverview].
  Future<void> animateCamera(CameraUpdate cameraUpdate,
      {Duration? duration, AnimationFinishedCallback? onFinished}) {
    return GoogleMapsNavigationPlatform.instance.animateCamera(
        viewId: _viewId,
        cameraUpdate: cameraUpdate,
        duration: duration?.inMilliseconds,
        onFinished: onFinished);
  }

  /// Moves the camera from the current position to the position
  /// defined in the [cameraUpdate].
  ///
  /// See [CameraUpdate] for more information
  /// on how to create different camera movements.
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return GoogleMapsNavigationPlatform.instance
        .moveCamera(viewId: _viewId, cameraUpdate: cameraUpdate);
  }

  /// Is the navigation trip progress bar enabled.
  Future<bool> isNavigationTripProgressBarEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationTripProgressBarEnabled(viewId: _viewId);
  }

  /// Enable or disable the navigation trip progress bar.
  ///
  /// By default, the navigation trip progress bar is disabled.
  Future<void> setNavigationTripProgressBarEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setNavigationTripProgressBarEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Is the navigation header enabled.
  Future<bool> isNavigationHeaderEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationHeaderEnabled(viewId: _viewId);
  }

  /// Enable or disable the navigation header.
  ///
  /// By default, the navigation header is enabled.
  Future<void> setNavigationHeaderEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setNavigationHeaderEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Is the navigation footer enabled.
  Future<bool> isNavigationFooterEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationFooterEnabled(viewId: _viewId);
  }

  /// Enable or disable the navigation footer.
  ///
  /// By default, the navigation footer is enabled.
  ///
  /// Also known as ETA card, for example in Android
  /// calls [setEtaCardEnabled().](https://developers.google.com/maps/documentation/navigation/android-sdk/v1/reference/com/google/android/libraries/navigation/NavigationView#setEtaCardEnabled(boolean))
  Future<void> setNavigationFooterEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setNavigationFooterEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Is the recenter button enabled.
  Future<bool> isRecenterButtonEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isRecenterButtonEnabled(viewId: _viewId);
  }

  /// Enable or disable the recenter button.
  ///
  /// By default, the recenter button is enabled.
  Future<void> setRecenterButtonEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setRecenterButtonEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Can the speed limit indication be displayed.
  Future<bool> isSpeedLimitIconEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isSpeedLimitIconEnabled(viewId: _viewId);
  }

  /// Allow showing the speed limit indicator.
  ///
  /// By default, the speed limit is not displayed.
  Future<void> setSpeedLimitIconEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setSpeedLimitIconEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Can the speedometer be displayed.
  Future<bool> isSpeedometerEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isSpeedometerEnabled(viewId: _viewId);
  }

  /// Allow showing the speedometer.
  ///
  /// By default, the speedometer is not displayed.
  Future<void> setSpeedometerEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setSpeedometerEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Are the incident cards displayed.
  Future<bool> isTrafficIncidentCardsEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isTrafficIncidentCardsEnabled(viewId: _viewId);
  }

  /// Enable or disable showing of the incident cards.
  ///
  /// By default, the incident cards are shown.
  Future<void> setTrafficIncidentCardsEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setTrafficIncidentCardsEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Check if the navigation user interface is shown.
  Future<bool> isNavigationUIEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationUIEnabled(viewId: _viewId);
  }

  /// Show or hide the navigation user interface shown on top of the map.
  ///
  /// When enabled also actives [followMyLocation] camera mode.
  ///
  /// Disabling hides routes on iOS, but on Android the routes stay visible.
  ///
  /// By default, the navigation UI is enabled when the session has been
  /// initialized with [GoogleMapsNavigator.initializeNavigationSession].
  ///
  /// Fails on Android if the navigation session has not been initialized,
  /// and on iOS if the terms and conditions have not been accepted.
  Future<void> setNavigationUIEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setNavigationUIEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Move the map camera to show the route overview.
  ///
  /// See also [followMyLocation] and [animateCamera].
  Future<void> showRouteOverview() {
    return GoogleMapsNavigationPlatform.instance.showRouteOverview(
      viewId: _viewId,
    );
  }

  /// Returns the minimum zoom level preference from the map view.
  /// If minimum zoom preference is not set previously, returns minimum possible
  /// zoom level for the current map type.
  Future<double> getMinZoomPreference() {
    return GoogleMapsNavigationPlatform.instance
        .getMinZoomPreference(viewId: _viewId);
  }

  /// Returns the maximum zoom level preference from the map view.
  /// If maximum zoom preference is not set previously, returns maximum possible
  /// zoom level for the current map type.
  Future<double> getMaxZoomPreference() {
    return GoogleMapsNavigationPlatform.instance
        .getMaxZoomPreference(viewId: _viewId);
  }

  /// Removes any previously specified upper and lower zoom bounds.
  Future<void> resetMinMaxZoomPreference() {
    return GoogleMapsNavigationPlatform.instance
        .resetMinMaxZoomPreference(viewId: _viewId);
  }

  /// Sets a preferred lower bound for the camera zoom.
  ///
  /// When the minimum zoom changes, the SDK adjusts all later camera updates
  /// to respect that minimum if possible. Note that there are technical
  /// considerations that may prevent the SDK from allowing users to zoom too low.
  ///
  /// Throws [MinZoomRangeException] if [minZoomPreference] is
  /// greater than maximum zoom lavel.
  Future<void> setMinZoomPreference(double minZoomPreference) {
    return GoogleMapsNavigationPlatform.instance.setMinZoomPreference(
        viewId: _viewId, minZoomPreference: minZoomPreference);
  }

  /// Sets a preferred upper bound for the camera zoom.
  ///
  /// When the maximum zoom changes, the SDK adjusts all later camera updates
  /// to respect that maximum if possible. Note that there are technical
  /// considerations that may prevent the SDK from allowing users to zoom too
  /// deep into the map. For example, satellite or terrain may have a lower
  /// maximum zoom than the base map tiles.
  ///
  /// Throws [MaxZoomRangeException] if [maxZoomPreference] is
  /// less than minimum zoom lavel.
  Future<void> setMaxZoomPreference(double maxZoomPreference) {
    return GoogleMapsNavigationPlatform.instance.setMaxZoomPreference(
        viewId: _viewId, maxZoomPreference: maxZoomPreference);
  }

  /// Retrieves all markers that have been added to the map view.
  Future<List<Marker?>> getMarkers() {
    return GoogleMapsNavigationPlatform.instance.getMarkers(viewId: _viewId);
  }

  /// Add markers to the map view.
  Future<List<Marker?>> addMarkers(List<MarkerOptions> markerOptions) {
    return GoogleMapsNavigationPlatform.instance
        .addMarkers(viewId: _viewId, markerOptions: markerOptions);
  }

  /// Update markers to the map view.
  ///
  /// Throws [MarkerNotFoundException] if the [markers] list contains one or
  /// more markers that have not been added to the map view via [addMarkers] or
  /// contains markers that have already been removed from the map view.
  Future<List<Marker?>> updateMarkers(List<Marker> markers) async {
    return GoogleMapsNavigationPlatform.instance
        .updateMarkers(viewId: _viewId, markers: markers);
  }

  /// Remove markers from the map view.
  ///
  /// Throws [MarkerNotFoundException] if the [markers] list contains one or
  /// more markers that have not been added to the map view via [addMarkers] or
  /// contains markers that have already been removed from the map view.
  Future<void> removeMarkers(List<Marker> markers) async {
    return GoogleMapsNavigationPlatform.instance
        .removeMarkers(viewId: _viewId, markers: markers);
  }

  /// Remove all markers from the map view.
  Future<void> clearMarkers() {
    return GoogleMapsNavigationPlatform.instance.clearMarkers(viewId: _viewId);
  }

  /// Retrieves all polygons that have been added to the map view.
  Future<List<Polygon?>> getPolygons() {
    return GoogleMapsNavigationPlatform.instance.getPolygons(viewId: _viewId);
  }

  /// Add polygons to the map view.
  Future<List<Polygon?>> addPolygons(List<PolygonOptions> polygonOptions) {
    return GoogleMapsNavigationPlatform.instance
        .addPolygons(viewId: _viewId, polygonOptions: polygonOptions);
  }

  /// Update polygons to the map view.
  ///
  /// Throws [PolygonNotFoundException] if the [polygons] list contains
  /// polygon that has not beed added to the map view via [addPolygons] or
  /// contains polygon that has already been removed from the map view.
  Future<List<Polygon?>> updatePolygons(List<Polygon> polygons) async {
    return GoogleMapsNavigationPlatform.instance
        .updatePolygons(viewId: _viewId, polygons: polygons);
  }

  /// Remove polygons from the map view.
  ///
  /// Throws [PolygonNotFoundException] if the [polygons] list contains
  /// polygon that has not beed added to the map view via [addPolygons] or
  /// contains polygon that has already been removed from the map view.
  Future<void> removePolygons(List<Polygon> polygons) async {
    return GoogleMapsNavigationPlatform.instance
        .removePolygons(viewId: _viewId, polygons: polygons);
  }

  /// Remove all polygons from the map view.
  Future<void> clearPolygons() {
    return GoogleMapsNavigationPlatform.instance.clearPolygons(viewId: _viewId);
  }

  /// Retrieves all polylines that have been added to the map view.
  Future<List<Polyline?>> getPolylines() {
    return GoogleMapsNavigationPlatform.instance.getPolylines(viewId: _viewId);
  }

  /// Add polylines to the map view.
  Future<List<Polyline?>> addPolylines(List<PolylineOptions> polylineOptions) {
    return GoogleMapsNavigationPlatform.instance
        .addPolylines(viewId: _viewId, polylineOptions: polylineOptions);
  }

  /// Update polylines to the map view.
  ///
  /// Throws [PolylineNotFoundException] if the [polylines] list contains
  /// polyline that has not beed added to the map view via [addPolylines] or
  /// contains polyline that has already been removed from the map view.
  Future<List<Polyline?>> updatePolylines(List<Polyline> polylines) async {
    return GoogleMapsNavigationPlatform.instance
        .updatePolylines(viewId: _viewId, polylines: polylines);
  }

  /// Remove polylines from the map view.
  ///
  /// Throws [PolylineNotFoundException] if the [polylines] list contains
  /// polyline that has not beed added to the map view via [addPolylines] or
  /// contains polyline that has already been removed from the map view.
  Future<void> removePolylines(List<Polyline> polylines) async {
    return GoogleMapsNavigationPlatform.instance
        .removePolylines(viewId: _viewId, polylines: polylines);
  }

  /// Remove all polylines from the map view.
  Future<void> clearPolylines() {
    return GoogleMapsNavigationPlatform.instance
        .clearPolylines(viewId: _viewId);
  }

  /// Gets all circles from the map view.
  Future<List<Circle?>> getCircles() {
    return GoogleMapsNavigationPlatform.instance.getCircles(viewId: _viewId);
  }

  /// Add circles to the map view.
  Future<List<Circle?>> addCircles(List<CircleOptions> options) {
    return GoogleMapsNavigationPlatform.instance
        .addCircles(viewId: _viewId, options: options);
  }

  /// Update circles to the map view.
  ///
  /// Throws [CircleNotFoundException] if the [circles] list contains one or
  /// more circles that have not been added to the map view via [addCircles] or
  /// contains circles that have already been removed from the map view.
  Future<List<Circle?>> updateCircles(List<Circle> circles) async {
    return GoogleMapsNavigationPlatform.instance
        .updateCircles(viewId: _viewId, circles: circles);
  }

  /// Remove circles from the map view.
  ///
  /// Throws [CircleNotFoundException] if the [circles] list contains one or
  /// more circles that have not been added to the map view via [addCircles] or
  /// contains circles that have already been removed from the map view.
  Future<void> removeCircles(List<Circle> circles) async {
    return GoogleMapsNavigationPlatform.instance
        .removeCircles(viewId: _viewId, circles: circles);
  }

  /// Remove all circles from the map view.
  Future<void> clearCircles() {
    return GoogleMapsNavigationPlatform.instance.clearCircles(viewId: _viewId);
  }

  /// Remove all markers, polylines, polygons, overlays, etc from the map view.
  Future<void> clear() {
    return GoogleMapsNavigationPlatform.instance.clear(viewId: _viewId);
  }
}
