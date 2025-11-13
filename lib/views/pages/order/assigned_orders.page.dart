import 'package:flutter/material.dart';
import 'package:fuodz/constants/sizes.dart';

import 'package:fuodz/view_models/assigned_orders.vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/cards/driver_general_stats.view.dart';
import 'package:fuodz/widgets/custom_list_view.dart';
import 'package:fuodz/widgets/list_items/assigned_order.list_item.dart';
import 'package:fuodz/widgets/states/order.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'widgets/online_offline.fab.dart';
import 'widgets/pending_notifications.widget.dart';

class AssignedOrdersPage extends StatefulWidget {
  const AssignedOrdersPage({Key? key}) : super(key: key);

  @override
  _AssignedOrdersPageState createState() => _AssignedOrdersPageState();
}

class _AssignedOrdersPageState extends State<AssignedOrdersPage>
    with AutomaticKeepAliveClientMixin<AssignedOrdersPage> {
  @override
  Widget build(BuildContext context) {
    //
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<AssignedOrdersViewModel>.reactive(
        viewModelBuilder: () => AssignedOrdersViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            body: VStack([
              //online status
              OnlineOfflineFab(),
              SmartRefresher(
                controller: vm.refreshController,
                enablePullDown: true,
                onRefresh: vm.fetchOrders,
                child: SingleChildScrollView(
                  child: VStack([
                    //pending notifications
                    PendingNotificationsWidget(),

                    //orders
                    CustomListView(
                      isLoading: vm.isBusy,
                      noScrollPhysics: true,
                      dataSet: vm.orders,
                      padding: EdgeInsets.all(Sizes.paddingSizeDefault),
                      emptyWidget: VStack([
                        EmptyOrder(title: "Assigned Orders".tr()),
                      ]),
                      itemBuilder: (context, index) {
                        final order = vm.orders[index];
                        return AssignedOrderListItem(
                          order: order,
                          orderPressed: () => vm.openOrderDetails(order),
                        );
                      },
                    ),
                    //stats
                    DriverGeneralStatsView(key: GlobalKey()),
                  ], spacing: Sizes.paddingSizeDefault),
                ),
              ).expand(),
            ]),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
