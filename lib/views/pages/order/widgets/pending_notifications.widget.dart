import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/models/new_order.dart';

import 'package:fuodz/requests/auto_assignment.request.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/pending_notifications.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PendingNotificationsWidget extends StatelessWidget {
  const PendingNotificationsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NewOrder>>(
      stream: PendingNotificationsService().pendingOrdersStream,
      builder: (context, orderSnapshot) {
        final pendingOrders = orderSnapshot.data ?? [];
        final totalPending = pendingOrders.length;

        print(
          "DEBUG: Widget rebuild - Orders: ${pendingOrders.length}, Total: $totalPending",
        );

        // Debug: Always show a placeholder when no pending orders
        if (totalPending == 0) {
          return Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_none, color: Colors.grey),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No pending orders",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "New order notifications will appear here",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColor.primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 20,
                    ),
                    8.widthBox,
                    "New Order Alerts".tr().text.white.semiBold.make().expand(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          totalPending
                              .toString()
                              .text
                              .white
                              .bold
                              .size(12)
                              .make(),
                    ),
                  ],
                ),
              ),

              // Pending Orders List
              ...pendingOrders.map((order) => PendingOrderItem(order: order)),
            ],
          ),
        );
      },
    );
  }
}

class PendingOrderItem extends StatelessWidget {
  final NewOrder order;

  const PendingOrderItem({Key? key, required this.order}) : super(key: key);

  void _acceptOrder(BuildContext context, NewOrder order) async {
    try {
      if (order.assignmentId == null) {
        throw "Assignment ID not available";
      }

      // Call the API to accept the assignment
      final autoAssignmentRequest = AutoAssignmentRequest();
      await autoAssignmentRequest.acceptAssignment(
        order.assignmentId!,
        order.id!,
      );

      // Remove from pending notifications
      PendingNotificationsService().removeOrderById(order.id!);
      AppService().refreshAssignedOrders.add(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order accepted successfully!".tr()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to accept order: $error".tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _rejectOrder(BuildContext context, NewOrder order) async {
    try {
      if (order.assignmentId != null) {
        // Call the API to reject the assignment
        final autoAssignmentRequest = AutoAssignmentRequest();
        await autoAssignmentRequest.rejectAssignment(order.assignmentId!);
      }

      // Remove from pending notifications
      PendingNotificationsService().removeOrderById(order.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order rejected".tr()),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (error) {
      // Still remove from local list even if API call fails
      PendingNotificationsService().removeOrderById(order.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order rejected (with error: $error)".tr()),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag, color: AppColor.primaryColor, size: 16),
              8.widthBox,
              "Order #${order.id}".text.semiBold.make().expand(),
              "\$${order.total}".text.green600.bold.make(),
            ],
          ),
          8.heightBox,
          if (order.pickup?.address != null)
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange, size: 14),
                4.widthBox,
                "Pickup: ${order.pickup!.address}".text
                    .size(12)
                    .color(Colors.grey.shade600)
                    .make()
                    .expand(),
              ],
            ),
          4.heightBox,
          if (order.dropoff?.address != null)
            Row(
              children: [
                Icon(Icons.flag, color: Colors.red, size: 14),
                4.widthBox,
                "Delivery: ${order.dropoff!.address}".text
                    .size(12)
                    .color(Colors.grey.shade600)
                    .make()
                    .expand(),
              ],
            ),
          12.heightBox,
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptOrder(context, order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: "Accept".tr().text.make(),
                ),
              ),
              12.widthBox,
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _rejectOrder(context, order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: "Reject".tr().text.make(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
