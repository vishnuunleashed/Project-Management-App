import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DccResume {
  dynamic data;
  String source = "";
}

abstract class DccResumableState<T extends ConsumerStatefulWidget> extends ConsumerState<T>
    with WidgetsBindingObserver {
  DccResume resume = DccResume();

  // Separate flags for clarity
  bool _navCovered = false; // We're covered by another route we pushed
  bool _appBackgrounded = false; // App actually went to background (paused)

  /// Override these in your State
  void onResume() {}
  void onReady() {}
  void onPause() {}

  Future<T> push<T extends Object>(BuildContext context, Route<T> route,
      [String source = ""]) {
    _navCovered = true;
    onPause();

    return Navigator.of(context).push<T>(route).then((value) {
      _navCovered = false;

      resume.data = value;
      resume.source = source;

      if (!_appBackgrounded) {
        onResume();
      }
      return value!;
    });
  }

  Future<T> pushNamed<T extends Object>(
      BuildContext context, String routeName,
      {Object? arguments}) {
    _navCovered = true;
    onPause();

    return Navigator.of(context)
        .pushNamed<T>(routeName, arguments: arguments)
        .then((value) {
      _navCovered = false;

      resume.data = value;
      resume.source = routeName;

      if (!_appBackgrounded) {
        onResume();
      }
      return value!;
    });
  }

  @override
  void initState() {
    super.initState();
    _ambiguate(WidgetsBinding.instance).addObserver(this);
    _ambiguate(WidgetsBinding.instance).addPostFrameCallback((_) => onReady());
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance).removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        if (!_appBackgrounded) {
          _appBackgrounded = true;
          if (!_navCovered) {
            onPause();
          }
        }
        break;

      case AppLifecycleState.resumed:
        if (_appBackgrounded) {
          _appBackgrounded = false;
          if (!_navCovered) {
            onResume();
          }
        }
        break;

    // Treat hidden like inactive — ignore to avoid false resumes (e.g., notification shade)
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  T _ambiguate<T>(T value) => value;
}
