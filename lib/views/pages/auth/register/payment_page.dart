import 'package:flutter/material.dart';
import 'package:fuodz/views/pages/auth/register/agreement_page.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({required this.name, required this.paymentLink, Key? key})
    : super(key: key);

  final String name;
  final String paymentLink;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          // Track every navigation event
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                print("Page started loading: $url");
                if (url.contains("success")) {
                  _finish();
                }
              },
              onPageFinished: (url) {
                print("Page finished loading: $url");
              },
              onNavigationRequest: (NavigationRequest request) {
                print("User clicked link: ${request.url}");

                // Example: block some links
                if (request.url.contains("facebook.com")) {
                  print("Blocked Facebook link");
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentLink));
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showLeadingAction: false,
      showAppBar: true,
      title: 'E2U',

      // Remove this line after testing payment
      actions: [IconButton(onPressed: _finish, icon: Icon(Icons.check)),],

      backgroundColor: context.theme.colorScheme.surface,
      body: WebViewWidget(controller: _controller),
    );
  }
  
  void _finish(){
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => AgreementPage(name: widget.name),
      ),
          (route) => false,
    );
  }
}
