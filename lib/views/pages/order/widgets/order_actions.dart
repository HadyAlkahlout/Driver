import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:fuodz/widgets/buttons/custom_swipe_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderActions extends StatefulWidget {
  const OrderActions({
    this.canChatCustomer = false,
    this.busy = false,
    required this.order,
    required this.processOrderCompletion,
    required this.processOrderEnroute,
    Key? key,
  }) : super(key: key);

  final bool canChatCustomer;
  final bool busy;
  final Order order;
  final Function processOrderCompletion;
  final Function processOrderEnroute;

  @override
  State<OrderActions> createState() => _OrderActionsState();
}

class _OrderActionsState extends State<OrderActions> {
  ObjectKey viewKey = new ObjectKey(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return (!["failed", "delivered", "cancelled"].contains(widget.order.status))
        ? SafeArea(
              child:
                  widget.busy
                      ? BusyIndicator().centered().wh(Vx.dp40, Vx.dp40)
                      : Builder(
                        builder: (context) {
                          bool isNotEnroute = widget.order.status != "enroute";
                          String actionText = "Swipe To Start".tr();
                          Function action = widget.processOrderEnroute;
                          if (!isNotEnroute) {
                            action = widget.processOrderCompletion;
                            actionText = "Swipe To Complete".tr();
                          }

                          return CustomSwipingButton(
                                key: viewKey,
                                height: 50,
                                radius: Sizes.radiusSmall / 2,
                                text: actionText,
                                swipeButtonColor: AppColor.primaryColor,
                                backgroundColor: Utils.textColorByColor(
                                  AppColor.primaryColor,
                                ),
                                iconColor: Utils.textColorByColor(
                                  AppColor.primaryColor,
                                ),
                                buttonTextStyle: context.titleSmall!.copyWith(
                                  color: Utils.textColorByColor(
                                    AppColor.primaryColor,
                                  ),
                                  fontSize: Sizes.fontSizeSmall,
                                  fontWeight: FontWeight.w700,
                                ),
                                textStyle: context.titleMedium!.copyWith(
                                  color: AppColor.primaryColor,
                                  fontSize: Sizes.fontSizeSmall,
                                  fontWeight: FontWeight.w700,
                                ),
                                onSwipeCallback: () {
                                  action();
                                },
                              ).box
                              .clip(Clip.antiAliasWithSaveLayer)
                              .withRounded(value: Sizes.radiusSmall)
                              .border(color: AppColor.primaryColor)
                              .color(
                                Utils.textColorByColor(AppColor.primaryColor),
                              )
                              .make();
                        },
                      ),
            ).box.p20.outerShadowXl.shadowSm
            .color(context.backgroundColor)
            .make()
            .wFull(context)
        : 0.squareBox;
  }
}
