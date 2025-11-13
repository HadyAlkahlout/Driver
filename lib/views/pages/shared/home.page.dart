import 'dart:io';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_upgrade_settings.dart';

import 'package:fuodz/utils/color_utils.dart';
import 'package:fuodz/views/pages/finance/finance_report.page.dart';
import 'package:fuodz/views/pages/order/assigned_orders.page.dart';
import 'package:fuodz/view_models/home.vm.dart';
import 'package:fuodz/views/pages/order/orders.page.dart';
import 'package:fuodz/views/pages/profile/profile.page.dart';

import 'package:fuodz/widgets/base.page.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:upgrader/upgrader.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  //
  @override
  Widget build(BuildContext context) {
    //
    return DoubleBack(
      message: "Press back again to close".tr(),
      child: ViewModelBuilder<HomeViewModel>.reactive(
        viewModelBuilder: () => HomeViewModel(context),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          return BasePage(
            body: UpgradeAlert(
              showIgnore: !AppUpgradeSettings.forceUpgrade(),
              shouldPopScope: () => !AppUpgradeSettings.forceUpgrade(),
              dialogStyle:
                  Platform.isIOS
                      ? UpgradeDialogStyle.cupertino
                      : UpgradeDialogStyle.material,
              child: PageView(
                controller: model.pageViewController,
                onPageChanged: model.onPageChanged,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  //delivery driver view
                  AssignedOrdersPage(),

                  //
                  OrdersPage(),
                  //show report page
                  FinanceReportPage(),
                  //
                  ProfilePage(),
                ],
              ),
            ),
            bottomNavigationBar: Theme(
              data: ThemeData(
                //
                canvasColor: ColorUtils.shuffleColorByMode(
                  context,
                  lightMode: Colors.white,
                  darkMode: Colors.grey.shade800,
                ),
              ),
              child: BottomNavigationBar(
                elevation: 5,
                selectedItemColor: context.primaryColor,
                unselectedItemColor: ColorUtils.shuffleColorByMode(
                  context,
                  lightMode: Colors.black,
                  darkMode: Colors.grey.shade500,
                ),
                showSelectedLabels: true,
                showUnselectedLabels: true,
                currentIndex: model.currentIndex,
                onTap: model.onTabChange,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(HugeIcons.strokeRoundedHome02),
                    activeIcon: Icon(HugeIcons.strokeRoundedHome03),
                    label: 'Home'.tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(HugeIcons.strokeRoundedInboxUnread),
                    activeIcon: Icon(HugeIcons.strokeRoundedInbox),
                    label: "Orders".tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(HugeIcons.strokeRoundedChartBarLine),
                    activeIcon: Icon(HugeIcons.strokeRoundedChartBarLine),
                    label: 'Report'.tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(HugeIcons.strokeRoundedMenu01),
                    activeIcon: Icon(HugeIcons.strokeRoundedMenu02),
                    label: 'More'.tr(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
