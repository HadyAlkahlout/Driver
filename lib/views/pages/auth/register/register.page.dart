import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import 'package:flutter/services.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_images.dart';
import 'package:fuodz/services/validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/register/register_vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/arrow_indicator.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(context),
      onViewModelReady: (model) {
        model.initialise();
      },
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          backgroundColor: context.theme.colorScheme.surface,
          leading: IconButton(
            icon: ArrowIndicator(leading: true),
            onPressed: () => Navigator.pop(context),
          ),
          body: SafeArea(
            top: true,
            bottom: false,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: context.mq.viewInsets.bottom),
                  child:
                  VStack([
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                      child: Image.asset(
                        AppImages.auth,
                        height: 80,
                        width: 120,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to placeholder if auth.png also doesn't exist
                          return Image.asset(
                            AppImages.placeholder,
                            height: context.screenHeight * 0.25,
                          ).centered();
                        },
                      ).hOneForth(context),
                    ),
                    //
                    VStack([
                      //
                      "Join Us".tr().text.xl2.semiBold.make(),
                      "Create an account now".tr().text.light.make(),
                      //form
                      Form(
                        key: model.formKey,
                        child: VStack([
                          //
                          CustomTextFormField(
                            labelText: "Full Name".tr(),
                            textEditingController: model.nameTEC,
                            validator: FormValidator.validateName,
                          ).py12(),
                          //
                          CustomTextFormField(
                            labelText: "Email".tr(),
                            keyboardType: TextInputType.emailAddress,
                            textEditingController: model.emailTEC,
                            validator: FormValidator.validateEmail,
                            //remove space
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp(' '),
                              ), // removes spaces
                            ],
                          ).py12(),
                          //
                          HStack([
                            CustomTextFormField(
                              prefixIcon: HStack([
                                //icon/flag
                                Flag.fromString(
                                  model.selectedCountry?.countryCode ?? "US",
                                  width: 20,
                                  height: 20,
                                ),
                                UiSpacer.horizontalSpace(space: 5),
                                //text
                                ("+" +
                                    (model.selectedCountry?.phoneCode ??
                                        "1"))
                                    .text
                                    .make(),
                              ]).px8().onInkTap(model.showCountryDialPicker),
                              labelText: "Phone".tr(),
                              hintText: "",
                              keyboardType: TextInputType.phone,
                              textEditingController: model.phoneTEC,
                              validator: FormValidator.validatePhone,
                              //remove space
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(' '),
                                ), // removes spaces
                              ],
                            ).expand(),
                          ]).py12(),
                          //
                          CustomTextFormField(
                            labelText: "Password".tr(),
                            obscureText: true,
                            textEditingController: model.passwordTEC,
                            validator: FormValidator.validatePassword,
                            //remove space
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp(' '),
                              ), // removes spaces
                            ],
                          ).py12(),
                          //
                          GestureDetector(
                            onTap: model.showMyDatePicker,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColor.primaryColor,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(Vx.dp4),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    model.dobTxt,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.calendar_month,
                                    color: AppColor.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ).py12(),

                          //terms
                          HStack([
                            Checkbox(
                              value: model.agreed,
                              onChanged: (value) {
                                model.agreed = value ?? false;
                                model.notifyListeners();
                              },
                            ),
                            //
                            "I agree with".tr().text.make(),
                            UiSpacer.horizontalSpace(space: 2),
                            "terms and conditions"
                                .tr()
                                .text
                                .color(AppColor.primaryColor)
                                .bold
                                .underline
                                .make()
                                .onInkTap(model.openTerms)
                                .expand(),
                          ]),

                          //
                          CustomButton(
                            title: "Create Account".tr(),
                            loading:
                            model.isBusy ||
                                model.busy(model.firebaseVerificationId),
                            onPressed: model.processRegister,
                          ).centered().py12(),

                        ], crossAlignment: CrossAxisAlignment.end),
                      ).py20(),
                    ]).wFull(context).p20(),
                  ]).scrollVertical(),
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
