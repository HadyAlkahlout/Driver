import 'dart:async';
// Removed Firebase imports

class GeneralAppService {
  //

  //Handle background message - DISABLED
  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(dynamic remoteMessage) async {
    print("Firebase background message handler disabled");
  }
}
