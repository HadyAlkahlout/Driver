import 'package:flutter/material.dart';
import 'package:fuodz/view_models/register/earn_vm.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../widgets/base.page.dart';

class EarnPage extends StatelessWidget {
  EarnPage({
    required this.name,
    Key? key,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EarnViewModel>.reactive(
      viewModelBuilder: () => EarnViewModel(context),
      onViewModelReady: (model) {
        model.initialise();
      },
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: false,
          showAppBar: true,
          backgroundColor: context.theme.colorScheme.surface,
          body: SafeArea(
            top: true,
            bottom: false,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/cash.png', height: 100),
                      SizedBox(height: 10),
                      Text(
                        'Earn with E2U'.tr(),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Decide when, where and how you want to earn.'.tr(),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Where would you like to earn?'.tr(),
                        style: TextStyle(fontSize: 14),
                      ),
                      //
                      CustomTextFormField(
                        textEditingController: model.cityTEC,
                      ).py12(),
                      SizedBox(height: 12),
                      Text(
                        'Referral Code (Optional)'.tr(),
                        style: TextStyle(fontSize: 14),
                      ),
                      //
                      CustomTextFormField(
                        textEditingController: model.referralCodeTEC,
                      ).py12(),
                      SizedBox(height: 10),
                      Text(
                        'Earn Confirm'.tr(),
                        style: TextStyle(fontSize: 12),
                      ),
                      Spacer(),
                      Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: GestureDetector(
                          onTap: () {
                            model.continueToEarn(name);
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
                                  Text('Next'.tr()),
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
