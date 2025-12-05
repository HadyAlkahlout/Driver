import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/view_models/register/pin_vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pinput/pinput.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class PinPage extends StatelessWidget {
  PinPage({
    required this.name,
    required this.countryCode,
    required this.phoneCode,
    required this.phone,
    Key? key,
  }) : super(key: key);

  final String name;
  final String countryCode;
  final String phoneCode;
  final String phone;


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
        border: Border.all(color: AppColor.primaryColor),
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

    return ViewModelBuilder<PinViewModel>.reactive(
      viewModelBuilder: () => PinViewModel(context),
      onViewModelReady: (model) {
        model.initialise();
      },
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: false,
          showAppBar: false,
          body: SafeArea(
            top: true,
            bottom: false,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0),
                  child: Form(
                    key: model.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 4,
                          children: [
                            Text(
                              'Welcome'.tr(),
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${name},',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          spacing: 4,
                          children: [
                            Text(
                              'Enter the 6-digit code sent to'.tr(),
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '+${phoneCode} ${phone}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Pinput(
                          controller: model.pinController,
                          focusNode: model.focusNode,
                          defaultPinTheme: defaultPinTheme,
                          separatorBuilder: (index) => const SizedBox(width: 8),
                          validator: (value) => null,
                          length: 6,
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          onCompleted: (pin) {
                            debugPrint('Completed: $pin');
                            model.verifyPin(
                              name,
                              countryCode,
                              phoneCode,
                              phone,
                            );
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
                            if (model.canResend) {
                              model.resendPin(
                                phone,
                                countryCode,
                              );
                              Fluttertoast.showToast(
                                msg: "A new code has been sent!".tr(),
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          },
                          child: Card(
                            color: Vx.gray200.withOpacity(model.canResend ? 0.3 : 0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                'Resend Code ${model.remainingTime}',
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
                                model.verifyPin(
                                  name,
                                  countryCode,
                                  phoneCode,
                                  phone,
                                );
                              },
                              child: Card(
                                color: Vx.gray200.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Text('Next'.tr()),
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
                if (model.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


}
