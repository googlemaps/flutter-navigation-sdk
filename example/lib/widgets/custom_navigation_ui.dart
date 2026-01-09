// Copyright 2025 Google LLC
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

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

import '../utils/utils.dart';

/// Threshold distance (in meters) below which lane info is shown for the current step.
const int _laneInfoLimit = 300;

/// Fixed heights for the navigation elements.
const double customNavigationHeaderHeight = 180;

/// Global cache for step images, keyed by registeredImageId.
final Map<String, Image> _stepImageCache = {};

/// Loads an image from the ImageDescriptor, using cache if available.
Future<Image?> _loadStepImage(ImageDescriptor? imageDescriptor) async {
  if (imageDescriptor == null || imageDescriptor.registeredImageId == null) {
    return null;
  }

  final cacheKey = imageDescriptor.registeredImageId!;
  if (_stepImageCache.containsKey(cacheKey)) {
    return _stepImageCache[cacheKey];
  }

  final image = await getRegisteredImageData(imageDescriptor);
  if (image != null) {
    _stepImageCache[cacheKey] = image;
  }
  return image;
}

/// Widget that lazily loads and displays a step image.
class _StepImageExample extends StatefulWidget {
  const _StepImageExample({
    super.key,
    required this.imageDescriptor,
    this.size = 32,
  });

  final ImageDescriptor? imageDescriptor;
  final double size;

  @override
  State<_StepImageExample> createState() => _StepImageExampleState();
}

class _StepImageExampleState extends State<_StepImageExample> {
  Image? _cachedImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(_StepImageExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageDescriptor?.registeredImageId !=
        oldWidget.imageDescriptor?.registeredImageId) {
      _loadImage();
    }
  }

  void _loadImage() {
    final descriptor = widget.imageDescriptor;
    if (descriptor == null || descriptor.registeredImageId == null) {
      setState(() {
        _cachedImage = null;
      });
      return;
    }

    // Check cache first
    final cacheKey = descriptor.registeredImageId!;
    if (_stepImageCache.containsKey(cacheKey)) {
      setState(() {
        _cachedImage = _stepImageCache[cacheKey];
      });
      return;
    }

    // Load async
    _loadStepImage(descriptor).then((image) {
      if (mounted) {
        setState(() {
          _cachedImage = image;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedImage != null) {
      return SizedBox(
        height: widget.size,
        width: widget.size,
        child: _cachedImage,
      );
    }

    // Return empty box if no image (images should always be preloaded)
    return SizedBox(height: widget.size, width: widget.size);
  }
}

/// Callback signature for step change events.
typedef OnStepChanged = void Function(StepInfo step, int stepIndex);

/// A custom navigation header widget example that mimics the official Google Maps
/// navigation header with swipe-to-preview functionality.
///
/// Features:
/// - Shows current step with maneuver icon and distance
/// - Swipe left to preview next steps
/// - Shows lane guidance when available
/// - Shows "Then" indicator for consecutive maneuvers
/// - Shows "Stay on" layout when continuing on same road
class CustomNavigationHeaderExample extends StatefulWidget {
  const CustomNavigationHeaderExample({
    super.key,
    required this.navInfo,
    this.backgroundColor,
    this.previewBackgroundColor,
    this.secondaryBackgroundColor,
    this.previewSecondaryBackgroundColor,
    this.textColor = Colors.white,
    this.secondaryTextColor,
    this.onStepChanged,
  });

  /// The navigation info containing current and remaining steps.
  final NavInfo navInfo;

  /// Primary background color for the header. Defaults to green.
  final Color? backgroundColor;

  /// Background color when previewing non-current steps. Defaults to grey.
  final Color? previewBackgroundColor;

  /// Secondary background color for additional info section.
  final Color? secondaryBackgroundColor;

  /// Secondary background color when previewing non-current steps. Defaults to grey.
  final Color? previewSecondaryBackgroundColor;

  /// Primary text color. Defaults to white.
  final Color textColor;

  /// Secondary text color for less prominent text.
  final Color? secondaryTextColor;

  /// Callback when user swipes to a different step.
  final OnStepChanged? onStepChanged;

  @override
  State<CustomNavigationHeaderExample> createState() =>
      _CustomNavigationHeaderExampleState();
}

class _CustomNavigationHeaderExampleState
    extends State<CustomNavigationHeaderExample> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomNavigationHeaderExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset to first page when nav info changes significantly
    if (widget.navInfo.routeChanged && _currentPageIndex != 0) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _currentPageIndex = 0;
    }
  }

  bool get _isStayOnRoad {
    final currentStep = widget.navInfo.currentStep;
    if (currentStep == null || widget.navInfo.remainingSteps.isEmpty) {
      return false;
    }
    final nextStep = widget.navInfo.remainingSteps.first;
    return currentStep.simpleRoadName != null &&
        currentStep.simpleRoadName == nextStep.simpleRoadName;
  }

  List<StepInfo> get _allSteps {
    final steps = <StepInfo>[];
    if (widget.navInfo.currentStep != null) {
      steps.add(widget.navInfo.currentStep!);
    }
    steps.addAll(widget.navInfo.remainingSteps);
    return steps;
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    final steps = _allSteps;
    if (index < steps.length && widget.onStepChanged != null) {
      widget.onStepChanged!(steps[index], index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.navInfo.currentStep;
    if (currentStep == null) {
      return const SizedBox.shrink();
    }
    final bgColor = widget.backgroundColor ?? Colors.teal.shade800;
    final previewBgColor =
        widget.previewBackgroundColor ?? Colors.grey.shade600;
    final secondaryBgColor =
        widget.secondaryBackgroundColor ?? Colors.teal.shade900;
    final previewSecondaryBgColor =
        widget.previewSecondaryBackgroundColor ?? Colors.grey.shade700;
    final secondaryTextColor =
        widget.secondaryTextColor ?? widget.textColor.withAlpha(200);

    return _buildSwipeableHeader(
      bgColor,
      previewBgColor,
      secondaryBgColor,
      previewSecondaryBgColor,
      secondaryTextColor,
    );
  }

  Widget _buildSwipeableHeader(
    Color bgColor,
    Color previewBgColor,
    Color secondaryBgColor,
    Color previewSecondaryBgColor,
    Color secondaryTextColor,
  ) {
    final steps = _allSteps;

    return SizedBox(
      height: customNavigationHeaderHeight,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          final isCurrentStep = index == 0;
          final cardBgColor = isCurrentStep ? bgColor : previewBgColor;
          final secondaryInfoBgColor =
              isCurrentStep ? secondaryBgColor : previewSecondaryBgColor;
          final distanceToStep =
              index == 0
                  ? widget.navInfo.distanceToCurrentStepMeters
                  : steps
                      .take(index + 1)
                      .skip(1)
                      .fold<int>(
                        widget.navInfo.distanceToCurrentStepMeters ?? 0,
                        (sum, s) => sum + (s.distanceFromPrevStepMeters ?? 0),
                      );

          final showLaneGuidance =
              step.laneImage != null &&
              (!isCurrentStep ||
                  (widget.navInfo.distanceToCurrentStepMeters ?? 0) <
                      _laneInfoLimit);

          // Corner rounding logic:
          // - Lane guidance: no bottom corners rounded
          // - Then indicator: bottom left not rounded (aligned to left)
          // - Otherwise: all corners rounded
          BorderRadius mainBorderRadius;
          BorderRadius secondaryBorderRadius;
          if (showLaneGuidance) {
            mainBorderRadius = const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            );
            secondaryBorderRadius = const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            );
          } else {
            mainBorderRadius = BorderRadius.circular(12);
            secondaryBorderRadius = BorderRadius.zero;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main header content
                Container(
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: mainBorderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isCurrentStep && _isStayOnRoad
                          ? _buildStayOnRoadContent(step)
                          : _buildStepContent(step, distanceToStep, index),
                      if (_allSteps.length > 1) // Page indicator dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (
                              int i = 0;
                              i < _allSteps.length.clamp(0, 20);
                              i++
                            )
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      i == _currentPageIndex
                                          ? widget.textColor
                                          : widget.textColor.withAlpha(100),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Secondary info for this step
                if (showLaneGuidance)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: secondaryInfoBgColor,
                      borderRadius: secondaryBorderRadius,
                    ),
                    child: _StepImageExample(
                      key: ValueKey(step.laneImage!.registeredImageId),
                      imageDescriptor: step.laneImage!,
                      size: 40,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(StepInfo step, int? distanceToStep, int pageIndex) {
    bool hasFullInstructions =
        (step.fullInstructions != null &&
            step.fullInstructions != step.fullRoadName);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Maneuver icon and distance column
          SizedBox(
            width: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepImageExample(
                  key: ValueKey(step.maneuverImage?.registeredImageId),
                  imageDescriptor: step.maneuverImage,
                  size: 55,
                ),
                const SizedBox(height: 4),
                if (distanceToStep != null) _buildDistanceText(distanceToStep),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Road name and instructions
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (step.simpleRoadName != null)
                  Text(
                    step.simpleRoadName!,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (hasFullInstructions)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      step.fullInstructions!,
                      style: TextStyle(
                        color: widget.textColor.withAlpha(200),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStayOnRoadContent(StepInfo step) {
    final secondaryTextColor =
        widget.secondaryTextColor ?? widget.textColor.withAlpha(200);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _StepImageExample(
            key: ValueKey(step.maneuverImage!.registeredImageId),
            imageDescriptor: step.maneuverImage,
            size: 60,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay on ${step.simpleRoadName ?? step.fullRoadName ?? ""}',
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Second line: distance to maneuver icon and exit number
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.navInfo.distanceToCurrentStepMeters != null)
                      _buildDistanceText(
                        widget.navInfo.distanceToCurrentStepMeters!,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      'to',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryTextColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StepImageExample(
                      imageDescriptor: step.maneuverImage,
                      size: 30,
                    ),
                    if (step.exitNumber != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: widget.textColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          step.exitNumber!,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceText(int meters) {
    final (value, unit) = _formatDistanceParts(meters);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              color: widget.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: ' $unit',
            style: TextStyle(
              color: widget.textColor.withAlpha(180),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _formatDistanceParts(int meters) {
    if (meters >= 1000) {
      final kilometers = meters / 1000;
      return (kilometers.toStringAsFixed(1), 'km');
    } else {
      return (meters.toString(), 'm');
    }
  }
}

/// A custom navigation footer widget example that mimics the official Google Maps
/// navigation footer with ETA and remaining distance.
///
/// Layout:
/// - Top row: Total time to goal (larger text)
/// - Bottom row: Distance • ETA time
class CustomNavigationFooterExample extends StatelessWidget {
  const CustomNavigationFooterExample({
    super.key,
    required this.navInfo,
    this.backgroundColor,
    this.primaryTextColor,
    this.secondaryTextColor,
  });

  /// The navigation info containing time and distance to destination.
  final NavInfo navInfo;

  /// Background color. Defaults to white.
  final Color? backgroundColor;

  /// Primary text color for the main ETA display.
  final Color? primaryTextColor;

  /// Secondary text color for distance and ETA time.
  final Color? secondaryTextColor;

  @override
  Widget build(BuildContext context) {
    final timeToDestination = navInfo.timeToFinalDestinationSeconds;
    final distanceToDestination = navInfo.distanceToFinalDestinationMeters;

    if (timeToDestination == null || distanceToDestination == null) {
      return const SizedBox.shrink();
    }

    final bgColor = backgroundColor ?? Colors.white;
    final primaryColor = primaryTextColor ?? Colors.green.shade800;
    final secondaryColor = secondaryTextColor ?? Colors.grey.shade700;
    final remainingDuration = Duration(seconds: timeToDestination);
    final etaTime = DateTime.now().add(remainingDuration);
    final etaTimeFormatted = TimeOfDay.fromDateTime(
      etaTime,
    ).format(context); // Uses locale settings

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Total remaining time (large)
          Text(
            formatRemainingDuration(remainingDuration),
            style: TextStyle(
              color: primaryColor,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Bottom row: Distance • ETA
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                formatRemainingDistance(distanceToDestination),
                style: TextStyle(color: secondaryColor, fontSize: 16),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '•',
                  style: TextStyle(color: secondaryColor, fontSize: 16),
                ),
              ),
              Text(
                etaTimeFormatted,
                style: TextStyle(color: secondaryColor, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A example card widget displaying a navigation step with maneuver image,
/// road name, instructions, and distance.
class StepCardExample extends StatelessWidget {
  const StepCardExample({super.key, required this.step});

  final StepInfo step;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _StepImageExample(
          key: ValueKey(step.maneuverImage?.registeredImageId),
          imageDescriptor: step.maneuverImage,
          size: 24,
        ),
        title: Text(step.fullRoadName ?? 'Unknown road'),
        subtitle: Text(
          step.fullInstructions ?? step.maneuver.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            step.distanceFromPrevStepMeters != null
                ? Text(
                  formatRemainingDistance(step.distanceFromPrevStepMeters!),
                )
                : null,
      ),
    );
  }
}
