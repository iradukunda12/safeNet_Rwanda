import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  bool _isDisposed = false;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (_) {
        if (_isDisposed) return;

        // Schedule notifyListeners after current frame ends
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (_isDisposed) return;
          try {
            notifyListeners();
          } catch (e, st) {
            debugPrint('notifyListeners error: $e\n$st');
          }
        });
      },
      onError: (e, st) {
        debugPrint('GoRouterRefreshStream stream error: $e\n$st');
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
