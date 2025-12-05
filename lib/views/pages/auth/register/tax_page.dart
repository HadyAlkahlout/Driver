import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/view_models/driver/tax_vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxPage extends StatelessWidget {
  const TaxPage({
    required this.email,
    required this.name,
    required this.phoneCode,
    required this.phone,
    required this.password,
    required this.refferalCode,
    required this.city,
    Key? key,
  }) : super(key: key);

  final String email;
  final String name;
  final String phoneCode;
  final String phone;
  final String password;
  final String refferalCode;
  final String city;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TaxVM>.reactive(
      viewModelBuilder: () => TaxVM(context),
      onViewModelReady: (model) {},
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: false,
          showAppBar: true,
          title: 'E2U',
          appBarColor: AppColor.faintBgColor,
          body: SafeArea(
            top: true,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.0),
                  Text(
                    'Tax Info',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please provide your tax information.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  //
                  Text('Full Name', style: TextStyle(fontSize: 14)),
                  CustomTextFormField(
                    textEditingController: model.nameTEC,
                  ).py12(),
                  SizedBox(height: 16),
                  //
                  Text(
                    'Business Name (optional)',
                    style: TextStyle(fontSize: 14),
                  ),
                  CustomTextFormField(
                    textEditingController: model.businessTEC,
                  ).py12(),
                  SizedBox(height: 16),
                  //
                  Text('SSN / Tax ID', style: TextStyle(fontSize: 14)),
                  CustomTextFormField(
                    textEditingController: model.ssnTEC,
                  ).py12(),
                  SizedBox(height: 16),
                  //
                  Text('Address', style: TextStyle(fontSize: 14)),
                  CustomTextFormField(
                    textEditingController: model.addressTEC,
                  ).py12(),
                  SizedBox(height: 16),
                  //
                  Row(
                    children: [
                      Checkbox(
                        value: model.certify,
                        onChanged: (value) {
                          model.changCertify(value ?? false);
                        },
                      ),
                      Text('I certify that the information above is correct'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Spacer(),
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: GestureDetector(
                      onTap: () {},
                      child: Card(
                        color: Vx.gray200.withOpacity(true ? 0.3 : 0.8),
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
      },
    );
  }
}
