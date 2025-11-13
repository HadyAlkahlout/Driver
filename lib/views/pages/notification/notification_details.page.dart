import 'package:flutter/material.dart';
import 'package:fuodz/models/notification.dart';
import 'package:fuodz/services/notification.service.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class NotificationDetailsPage extends StatefulWidget {
  const NotificationDetailsPage({
    required this.notification,
    Key? key,
  }) : super(key: key);

  final NotificationModel notification;

  @override
  State<NotificationDetailsPage> createState() =>
      _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  @override
  void initState() {
    super.initState();
    NotificationService.updateNotification(widget.notification);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Notification Details",
      showAppBar: true,
      showLeadingAction: true,
      body: SafeArea(
        child: VStack(
          [
            //title
            "${widget.notification.title}".text.bold.xl2.make(),
            //time
            widget.notification.formattedTimeStamp.text.medium
                .color(Colors.grey)
                .make()
                .pOnly(bottom: 10),
            //image
            if (widget.notification.image != null &&
                widget.notification.image!.isNotBlank)
              CustomImage(
                imageUrl: widget.notification.image!,
                width: double.infinity,
                height: context.percentHeight * 30,
              ).py12(),

            //body
            "${widget.notification.body}".text.lg.make(),
          ],
        ).p20().scrollVertical(),
      ),
    );
  }
}
