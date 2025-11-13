import 'package:bg_launcher/bg_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/models/new_order.dart';

import 'package:velocity_x/velocity_x.dart';

class FloatingAppBubble extends StatefulWidget {
  const FloatingAppBubble({Key? key}) : super(key: key);

  @override
  State<FloatingAppBubble> createState() => _FloatingAppBubbleState();
}

class _FloatingAppBubbleState extends State<FloatingAppBubble> {
  NewOrder? newOrder;

  Widget currentWidget = SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      print("event: $event");
      //
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          BgLauncher.bringAppToForeground();
        },
        child:
            Image.asset(
              AppImages.appLogo,
              width: context.screenWidth,
              height: context.screenWidth,
            ).box.roundedFull.clip(Clip.antiAlias).make(),
      ),
    );
  }
}
