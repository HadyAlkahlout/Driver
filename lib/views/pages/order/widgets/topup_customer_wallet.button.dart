import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/views/pages/order/widgets/wallet_transfer.dialog.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class TopupCustomerWalletButton extends StatelessWidget {
  const TopupCustomerWalletButton(this.order, {super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !["failed", "delivered", "cancelled"].contains(order.status),
      child: IconButton(
        tooltip: "Topup Customer Wallet".tr(),
        onPressed: () {
          //show the wallet transfer dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Dialog(
                child: WalletTransferDialog(order),
              );
            },
          );
        },
        icon: Icon(
          FlutterIcons.wallet_plus_outline_mco,
        ),
      ),
    );
  }
}
