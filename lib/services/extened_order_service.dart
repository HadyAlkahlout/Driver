import 'package:fuodz/services/lifecycle_event_handler.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/services/overlay.service.dart';

class ExtendedOrderService {
  void fbListener() {
    //
    LocalStorageService.prefs!.setBool("appInBackground", false);
    LifecycleEventHandler().onLeaveHintCallback = () {
      LocalStorageService.prefs!.setBool("appInBackground", true);
      OverlayService().showFloatingBubble();
    };

    LifecycleEventHandler().onResumeCallback = () {
      LocalStorageService.prefs!.setBool("appInBackground", false);
      OverlayService().closeFloatingBubble();
    };
  }

  bool appIsInBackground() {
    return LocalStorageService.prefs!.getBool("appInBackground") ?? false;
  }

  void dispose() {
    LifecycleEventHandler().onLeaveHintCallback = null;
    LifecycleEventHandler().onResumeCallback = null;
  }
}
