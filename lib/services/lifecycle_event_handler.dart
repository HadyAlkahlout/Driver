import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class LifecycleEventHandler with WidgetsBindingObserver {
  static final LifecycleEventHandler _instance =
      LifecycleEventHandler._internal();
  factory LifecycleEventHandler() => _instance;
  LifecycleEventHandler._internal();

  static const MethodChannel _channel = MethodChannel('app.lifecycle/events');

  void Function()? onLeaveHintCallback;
  void Function()? onResumeCallback;

  bool _isListening = false;

  void startListening() {
    if (_isListening) return;

    WidgetsBinding.instance.addObserver(this);

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onUserLeaveHint') {
        print("[Lifecycle] onUserLeaveHint triggered");
        onLeaveHintCallback?.call();
      }
    });

    _isListening = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("[Lifecycle] App resumed");
      onResumeCallback?.call();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onLeaveHintCallback = null;
    onResumeCallback = null;
    _isListening = false;
  }
}
