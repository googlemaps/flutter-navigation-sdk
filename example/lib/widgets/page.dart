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

import 'package:flutter/material.dart';

/// Base wrapper widget for example pages, holding mainmenu leading
/// icon and also page title.
abstract class ExamplePage extends StatefulWidget {
  /// [ExamplePage] constuctor
  const ExamplePage({required this.leading, required this.title, super.key});

  /// Leading widget is presented in main menu list before page tille.
  final Widget leading;

  /// Page title is presented in mainmenu and in page title.
  final String title;

  @override
  ExamplePageState<ExamplePage> createState();
}

/// Base state for example pages, holding overlay animation controller and
/// overlay visibility state.
abstract class ExamplePageState<T extends ExamplePage> extends State<T>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _overlayOffsetAnimation;

  bool _isOverlayVisible = false;

  /// Getter for overlay visibility state.
  bool get isOverlayVisible => _isOverlayVisible;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _overlayOffsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  /// Toggles overlay visibility.
  @protected
  void toggleOverlay() {
    if (!_isOverlayVisible) {
      setState(() {
        _isOverlayVisible = !_isOverlayVisible;
      });
      _controller.forward();
    } else {
      _controller.reverse().then((_) {
        setState(() {
          _isOverlayVisible = false;
        });
      });
    }
  }

  /// Helper method to hide overlay.
  @protected
  void hideOverlay() {
    if (_isOverlayVisible) {
      _controller.reverse().then((_) {
        setState(() {
          _isOverlayVisible = false;
        });
      });
    }
  }

  /// Builds overlay content.
  @protected
  Widget buildOverlayContent(BuildContext context) {
    throw UnimplementedError();
  }

  /// Wraps page content with scaffold and overlay.
  @protected
  Widget buildPage(BuildContext context, WidgetBuilder builder) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Builder(builder: (BuildContext context) => builder(context)),
        ),
        if (_isOverlayVisible) _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: <Widget>[
        // Overlay background, which is used to close overlay when tapped.
        GestureDetector(
            onTap: hideOverlay,
            child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) => Container(
                    color: Colors.black.withAlpha(
                        (255.0 * _controller.value * 0.5).round())))),
        // Overlay content
        SlideTransition(
          position: _overlayOffsetAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            // GestureDetector is used to prevent closing overlay when tapping
            // on the content itself.
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: Material(
                color: Theme.of(context).cardColor,
                elevation: 4,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Close button
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => hideOverlay(),
                        ),
                      ),
                    ),
                    // Container for overlay content
                    Container(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6),
                      child: SafeArea(
                        top: false,
                        minimum: const EdgeInsets.only(
                            left: 8, right: 8, bottom: 16),
                        // Make content scrollable
                        child: Scrollbar(
                          thumbVisibility: true,
                          radius: const Radius.circular(30),
                          child: SingleChildScrollView(
                            child: buildOverlayContent(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  /// Helper method to show message overlay.
  void showOverlaySnackBar(String message,
      {Alignment alignment = Alignment.bottomCenter}) {
    final OverlayState overlay = Overlay.of(context);
    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Align(
        alignment: alignment,
        child: SizedBox(
          width: double.infinity,
          child: Material(
            elevation: 10.0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).snackBarTheme.backgroundColor,
              child: SafeArea(
                  top: false,
                  child: Text(
                    message,
                    style: Theme.of(context).snackBarTheme.contentTextStyle,
                  )),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Automatically remove the snack bar after some duration
    Future<void>.delayed(const Duration(seconds: 3))
        .then((_) => overlayEntry.remove());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
