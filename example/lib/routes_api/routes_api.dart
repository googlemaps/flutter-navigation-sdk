// Copyright 2024 Google LLC
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

import 'dart:convert';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:http/http.dart' as http;

// Note: This Routes API implementation is ment to be used only to
// support the example app, and only includes the bare minimum to get
// the route tokens.

const String _routesApiUrl = 'https://routes.googleapis.com/';
const String _computeRoutesUrl = '$_routesApiUrl/directions/v2:computeRoutes';
const String _mapsApiKey = String.fromEnvironment('MAPS_API_KEY');

/// Queries the Google Maps Routes API and returns a list of route tokens.
///
/// [waypoints] is a list of [NavigationWaypoint] representing the route waypoints.
/// [travelMode] is a string representing the travel mode.
/// Returns a list of route tokens or throws an error if the request fails.
Future<List<String>> getRouteToken(List<NavigationWaypoint> waypoints) async {
  assert(_mapsApiKey.isNotEmpty,
      'MAPS_API_KEY is not provided. Please pass it as a Dart define during the app build.');
  assert(waypoints.length >= 2,
      'At least two waypoints (origin and destination) are required.');

  final Uri apiUrl = Uri.parse(_computeRoutesUrl);

  final Map<String, dynamic> requestBody = <String, dynamic>{
    'origin': _toRoutesApiWaypoint(waypoints.first),
    'destination': _toRoutesApiWaypoint(waypoints.last),
    'intermediates': waypoints
        .sublist(1, waypoints.length - 1)
        .map((NavigationWaypoint wp) => _toRoutesApiWaypoint(wp, via: true))
        .toList(),
    'travelMode': 'DRIVE',
    'routingPreference': 'TRAFFIC_AWARE',
  };

  final Map<String, String> headers = <String, String>{
    'X-Goog-Api-Key': _mapsApiKey,
    'X-Goog-Fieldmask': 'routes.routeToken',
    'Content-Type': 'application/json',
  };

  final http.Response response =
      await http.post(apiUrl, headers: headers, body: jsonEncode(requestBody));

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic>? routeTokens = responseData['routes'] as List<dynamic>?;

    if (routeTokens == null) {
      throw Exception('Failed to get route tokens');
    }

    return routeTokens
        .map<String>((dynamic route) =>
            (route as Map<String, dynamic>)['routeToken'] as String)
        .toList();
  } else {
    throw Exception(
        'Failed to get route tokens: ${response.reasonPhrase}:\n${response.body}');
  }
}

/// Converts a [NavigationWaypoint] to a waypoint request format supported
/// by the Routes API.
Map<String, dynamic> _toRoutesApiWaypoint(NavigationWaypoint waypoint,
    {bool via = false}) {
  assert(waypoint.target != null || waypoint.placeID != null,
      'Invalid NavigationWaypoint: Either target or placeID must be provided.');
  final Map<String, dynamic> output = <String, dynamic>{
    'via': via,
  };
  if (waypoint.placeID != null) {
    output['placeId'] = waypoint.placeID;
  } else if (waypoint.target != null) {
    final Map<String, dynamic> location = <String, dynamic>{
      'latLng': <String, dynamic>{
        'latitude': waypoint.target!.latitude,
        'longitude': waypoint.target!.longitude
      }
    };

    if (waypoint.preferredSegmentHeading != null) {
      location['heading'] = waypoint.preferredSegmentHeading;
    }

    output['location'] = location;
  }
  return output;
}
