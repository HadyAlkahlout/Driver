import 'package:flutter/material.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WaitingPage extends StatefulWidget {
  const WaitingPage({required this.name, Key? key}) : super(key: key);

  final String name;

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {

  @override
  void initState() {
    super.initState();



  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showLeadingAction: false,
      showAppBar: true,
      title: 'E2U',
      backgroundColor: context.theme.colorScheme.surface,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/waiting.jpg'),
                SizedBox(height: 20.0),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Thank you for registering with us'.tr()),
                    Text(', ${widget.name}!'),
                  ],
                ),
                SizedBox(height: 4.0),
                Text('Please wait while we process your registration'.tr()),
                SizedBox(height: 4.0),
                Text(
                  'You can leave the app now and we will notify you when we finish the process'.tr(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
