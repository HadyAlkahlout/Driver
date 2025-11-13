import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderListItem extends StatelessWidget {
  const OrderListItem({
    required this.order,
    required this.orderPressed,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function orderPressed;
  @override
  Widget build(BuildContext context) {
    return VStack([
          HStack([
            //vendor image
            CustomImage(
              imageUrl: order.vendor?.featureImage ?? "",
              width: context.percentWidth * 18,
              boxFit: BoxFit.contain,
              height: context.percentWidth * 18,
            ).cornerRadius(Sizes.radiusSmall),

            //
            VStack([
              //
              HStack([
                "#${order.code}".text.lg.medium.make().expand(),
                //amount
                "${AppStrings.currencySymbol} ${order.total}"
                    .currencyFormat()
                    .text
                    .lg
                    .semiBold
                    .make(),
              ], spacing: 10),
              //amount and total products
              HStack([
                (order.isPackageDelivery
                        ? "${order.packageType?.name}"
                        : "%s Product(s)".tr().fill([
                          order.orderProducts?.length,
                        ]))
                    .text
                    .medium
                    .make()
                    .expand(),
                "${order.status.tr().capitalized}".text.lg
                    .color(AppColor.getStausColor(order.status))
                    .medium
                    .make(),
              ], spacing: 10),
              //time
              order.formattedDate.text.sm.make(),
            ]).px12().expand(),
          ]),
        ])
        .onInkTap(() => orderPressed())
        .box
        .border(color: Vx.zinc200)
        .withRounded(value: Sizes.radiusDefault)
        .clip(Clip.antiAlias)
        .make();
  }
}
