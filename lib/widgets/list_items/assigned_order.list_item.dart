import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/view_models/order_details.vm.dart';
import 'package:fuodz/widgets/list_items/parcel_order_stop.list_view.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class AssignedOrderListItem extends StatelessWidget {
  const AssignedOrderListItem({
    required this.order,
    this.onPayPressed,
    required this.orderPressed,
    Key? key,
  }) : super(key: key);

  final Order order;
  final Function? onPayPressed;
  final Function orderPressed;
  @override
  Widget build(BuildContext context) {
    return VStack([
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
            //time & methood
            HStack([
              order.formattedDate.text.sm.make().expand(),
              if (order.paymentMethod != null)
                order.paymentMethod!.name.text.make(),
            ], spacing: 10),
          ]).pSymmetric(
            h: Sizes.paddingSizeDefault,
            v: Sizes.paddingSizeExtraSmall,
          ),
          DottedLine(dashColor: Vx.zinc200),
          //addressess
          _orderAddressSummary(context, order),
        ], spacing: 2)
        .onInkTap(() {
          print('DEBUG: Order card tapped for order ${order.code}');
          orderPressed();
        })
        .box
        .border(color: Vx.zinc200)
        .withRounded(value: Sizes.radiusDefault)
        .clip(Clip.antiAlias)
        .make();
  }

  Widget _orderAddressSummary(context, Order order) {
    final vm = OrderDetailsViewModel(context, order);
    return VStack(
      [
        //
        if (!vm.order.isPackageDelivery)
          HStack([
            Icon(HugeIcons.strokeRoundedBuilding06, size: 16),
            "${vm.order.vendor?.address}".text
                .maxLines(1)
                .minFontSize(14)
                .ellipsis
                .make()
                .expand(),
          ], spacing: Sizes.paddingSizeExtraSmall),
        //end point
        VStack([
          //show package delivery addresses
          vm.order.isPackageDelivery
              ? VStack([
                //pickup location routing
                ParcelOrderStopListView(
                  "Pickup Location".tr(),
                  vm.order.orderStops!.first,
                  canCall: false,
                  routeToLocation: vm.routeToLocation,
                  verify: vm.order.packageType!.driverVerifyStops,
                  vm: vm,
                ),

                //stops
                ...((vm.order.orderStops ?? []).sublist(1).mapIndexed((
                  stop,
                  index,
                ) {
                  return ParcelOrderStopListView(
                    "Stop".tr() + " ${index + 1}",
                    stop,
                    canCall: false,
                    routeToLocation: vm.routeToLocation,
                    verify: vm.order.packageType!.driverVerifyStops,
                    vm: vm,
                  );
                }).toList()),
              ])
              :
              //regular delivery address
              HStack([
                Icon(HugeIcons.strokeRoundedPinLocation02, size: 16),
                if (vm.order.deliveryAddress != null)
                  "${vm.order.deliveryAddress!.address}".text.make().expand(),
              ], spacing: Sizes.paddingSizeExtraSmall),

          //
          if (!vm.order.isPackageDelivery && vm.order.deliveryAddress == null)
            "Customer Order Pickup".tr().text.xl.semiBold.make(),
        ]),
      ],
      spacing: 10,
    ).pSymmetric(h: Sizes.paddingSizeDefault, v: Sizes.paddingSizeExtraSmall);
  }
}
