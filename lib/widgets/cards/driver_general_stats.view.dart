import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/requests/report.request.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/widgets/busy_indicator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class DriverGeneralStatsView extends StatelessWidget {
  const DriverGeneralStatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DriverGeneralStatsViewModel>.reactive(
      viewModelBuilder: () => DriverGeneralStatsViewModel(),
      onViewModelReady: (vm) => vm.fetchDriverStats(),
      builder: (context, vm, child) {
        return vm.isBusy
            ? BusyIndicator().wh(40, 40).centered()
            : VStack([
              //earning
              VStack([
                "Earnings".tr().text.lg.semiBold.make(),
                Builder(
                  builder: (context) {
                    final bgColor = AppColor.primaryColor.swatch.shade400;
                    final textColor = Utils.textColorByColor(bgColor);
                    return _infoCardContainer(
                      bgColor: bgColor,
                      child: VStack([
                        //balance
                        HStack([
                          Icon(
                            HugeIcons.strokeRoundedWallet01,
                            size: 54,
                            color: textColor,
                          ),
                          //balance
                          VStack([
                            "Balance"
                                .tr()
                                .text
                                .sm
                                .medium
                                .color(textColor)
                                .make(),
                            "${AppStrings.currencySymbol} ${vm.earningBalance}"
                                .currencyFormat()
                                .text
                                .xl3
                                .semiBold
                                .color(textColor)
                                .make(),
                          ]).expand(),
                        ], spacing: Sizes.paddingSizeDefault),
                        //stats
                        HStack([
                          VStack(
                            [
                              "Today".tr().text.sm.color(textColor).make(),
                              "${AppStrings.currencySymbol} ${vm.todayEarningBalance}"
                                  .currencyFormat()
                                  .text
                                  .xl
                                  .semiBold
                                  .color(textColor)
                                  .make(),
                            ],
                            spacing: 5,
                            crossAlignment: CrossAxisAlignment.center,
                          ).expand(),
                          //divider
                          Container(width: 1.5, height: 30, color: textColor),
                          VStack(
                            [
                              "This Week".tr().text.sm.color(textColor).make(),
                              "${AppStrings.currencySymbol} ${vm.weekEarningBalance}"
                                  .currencyFormat()
                                  .text
                                  .xl
                                  .semiBold
                                  .color(textColor)
                                  .make(),
                            ],
                            spacing: 5,
                            crossAlignment: CrossAxisAlignment.center,
                          ).expand(),
                          //divider
                          Container(width: 1.5, height: 30, color: textColor),
                          VStack(
                            [
                              "This Month".tr().text.sm.color(textColor).make(),
                              "${AppStrings.currencySymbol} ${vm.monthEarningBalance}"
                                  .currencyFormat()
                                  .text
                                  .xl
                                  .semiBold
                                  .color(textColor)
                                  .make(),
                            ],
                            spacing: 5,
                            crossAlignment: CrossAxisAlignment.center,
                          ).expand(),
                        ], spacing: 10),
                      ], spacing: 10),
                    );
                  },
                ),
              ], spacing: 10),

              //order
              VStack([
                "Order".tr().text.lg.semiBold.make(),
                HStack([
                  _infoCard(
                    title: "${vm.todayOrders}",
                    subtitle: "Today".tr(),
                    thirdLine: "Orders".tr(),
                    bgColor: AppColor.primaryColor.swatch.shade400,
                  ).expand(),
                  _infoCard(
                    title: "${vm.weekOrders}",
                    subtitle: "This Week".tr(),
                    thirdLine: "Orders".tr(),
                    bgColor: AppColor.primaryColor.swatch.shade500,
                  ).expand(),
                ], spacing: Sizes.paddingSizeDefault),
                HStack([
                  _infoCard(
                    title: "${vm.monthOrders}",
                    subtitle: "This Month".tr(),
                    thirdLine: "Orders".tr(),
                    bgColor: AppColor.primaryColor.swatch.shade600,
                  ).expand(),
                  _infoCard(
                    title: "${vm.allTimeOrders}",
                    subtitle: "All Time".tr(),
                    thirdLine: "Orders".tr(),
                    bgColor: AppColor.primaryColor.swatch.shade700,
                  ).expand(),
                ], spacing: Sizes.paddingSizeDefault),
              ], spacing: 10),
              //remittance
              _infoCard(
                title:
                    "${AppStrings.currencySymbol} ${vm.pendingRemittance}"
                        .currencyFormat(),
                subtitle: "Pending Remittance".tr(),
                bgColor: AppColor.primaryColor.swatch.shade400,
              ),
            ], spacing: Sizes.paddingSizeLarge);
      },
    ).p(Sizes.paddingSizeDefault);
  }

  Widget _infoCard({
    required String title,
    required String subtitle,
    String? thirdLine,
    double? padding,
    Color? bgColor,
  }) {
    bgColor ??= AppColor.primaryColor;
    final textColor = Utils.textColorByColor(bgColor);
    return _infoCardContainer(
      padding: padding,
      bgColor: bgColor,
      child: VStack([
        title.text.xl4.bold.color(textColor).make(),
        subtitle.text.xl.semiBold.color(textColor).make(),
        if (thirdLine != null) thirdLine.text.color(textColor).make(),
      ], crossAlignment: CrossAxisAlignment.center),
    );
  }

  Widget _infoCardContainer({
    double? padding,
    Color? bgColor,
    required Widget child,
  }) {
    bgColor ??= AppColor.primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Sizes.radiusDefault),
      ),
      width: double.infinity,
      padding: EdgeInsets.all(padding ?? Sizes.paddingSizeExtraLarge),
      child: child,
    );
  }
}

//viewmodel
class DriverGeneralStatsViewModel extends BaseViewModel {
  int todayOrders = 0;
  int weekOrders = 0;
  int monthOrders = 0;
  int allTimeOrders = 0;
  double pendingRemittance = 0.0;
  double earningBalance = 0.0;
  double todayEarningBalance = 0.0;
  double weekEarningBalance = 0.0;
  double monthEarningBalance = 0.0;
  //
  fetchDriverStats() async {
    setBusy(true);
    try {
      final metries = await ReportRequest().driverMetrics();
      todayOrders = metries["orders"]["today"] as int;
      weekOrders = metries["orders"]["week"] as int;
      monthOrders = metries["orders"]["month"] as int;
      allTimeOrders = metries["orders"]["all_time"] as int;
      pendingRemittance =
          metries["money"]["pending_remittance"].toString().toDouble();
      earningBalance = metries["earnings"]["current"].toString().toDouble();
      todayEarningBalance = metries["earnings"]["today"].toString().toDouble();
      weekEarningBalance = metries["earnings"]["week"].toString().toDouble();
      monthEarningBalance = metries["earnings"]["month"].toString().toDouble();
      //
    } catch (error) {
      print("Driver stats error: $error");
    }
    setBusy(false);
  }
}
