import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/views/pages/auth/driver/earn_page.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:pinput/pinput.dart';
import 'package:velocity_x/velocity_x.dart';

class PinPage extends StatefulWidget {
  PinPage({
    required this.email,
    required this.name,
    required this.phoneCode,
    required this.phone,
    required this.password,
    required this.refferalCode,
    Key? key,
  }) : super(key: key);

  final String email;
  final String name;
  final String phoneCode;
  final String phone;
  final String password;
  final String refferalCode;

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool _canNext = false;

  int _remainingSeconds = 30; // countdown time in seconds
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer(); // start when screen opens
  }

  void startTimer() {
    setState(() {
      _canResend = false;
      _remainingSeconds = 30;
    });

    _timer?.cancel(); // cancel previous timer if any
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: AppColor.primaryColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final cursor = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );

    return BasePage(
      showLeadingAction: false,
      showAppBar: false,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome ${widget.name},',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Enter the 4-digit code sent to +${widget.phoneCode} ${widget.phone}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                Pinput(
                  controller: pinController,
                  focusNode: focusNode,
                  defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  validator: (value) {
                    // Add your validation logic here (e.g., check against a stored PIN)
                    if (value == '1234') {
                      return null; // Valid
                    }
                    return 'Pin is incorrect'; // Invalid
                  },
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) {
                    debugPrint('Completed: $pin');
                    if (formKey.currentState!.validate()) {
                      // Process the valid pin
                      setState(() {
                        _canNext = true;
                      });
                    }
                  },
                  onChanged: (value) {
                    // Callback when the pin value changes
                    debugPrint('Changed: $value');
                  },
                  cursor: cursor,
                ),
                SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    if (_canResend) {
                      startTimer();
                      Fluttertoast.showToast(
                        msg: "A new code has been sent!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  },
                  child: Card(
                    color: Vx.gray200.withOpacity(_canResend ? 0.3 : 0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Resend Code ${formatTime(_remainingSeconds)}',
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Card(
                        color: Vx.gray200.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(46),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: Icon(Icons.arrow_back_ios)),
                        ),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        if (_canNext) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => EarnPage(
                                    email: widget.email,
                                    name: widget.name,
                                    phoneCode: widget.phoneCode,
                                    phone: widget.phone,
                                    password: widget.password,
                                    refferalCode: widget.refferalCode,
                                  ),
                            ),
                          );
                        }
                      },
                      child: Card(
                        color: Vx.gray200.withOpacity(_canNext ? 0.3 : 0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Text('Next'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
