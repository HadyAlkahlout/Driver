import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/views/pages/auth/driver/docs_page.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../widgets/base.page.dart';

class EarnPage extends StatelessWidget {
  EarnPage({
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

  TextEditingController cityTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showLeadingAction: false,
      showAppBar: true,
      appBarColor: AppColor.faintBgColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/cash.png', height: 100),
              SizedBox(height: 10),
              Text(
                'Earn with E2U',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Decide when, where and how you want to earn.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                'Where would you like to earn?',
                style: TextStyle(fontSize: 14),
              ),
              //
              CustomTextFormField(textEditingController: cityTEC).py12(),
              SizedBox(height: 10),
              Text(
                'By proceeding, I agree that E2U or its representatives may contact me by email, phone or text message (including by automatic telephone dialling system) using the email address or number I provide, including for marketing purposes',
                style: TextStyle(fontSize: 12),
              ),
              Spacer(),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: GestureDetector(
                  onTap: () {
                    if (cityTEC.text.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => DocsPage(
                                email: email,
                                name: name,
                                phoneCode: phoneCode,
                                phone: phone,
                                password: password,
                                refferalCode: refferalCode,
                                city: cityTEC.text,
                              ),
                        ),
                      );
                    }
                    else {
                      Fluttertoast.showToast(
                        msg: "Please enter where you want to earn!!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  },
                  child: Card(
                    color: Vx.gray200.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Next'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
