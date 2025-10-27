import 'dart:async';
import 'package:flutter/foundation.dart';

/// A simple Listenable that listens to a Stream and notifies listeners when the stream emits a value.
/// Used with GoRouter to refresh routes automatically.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
