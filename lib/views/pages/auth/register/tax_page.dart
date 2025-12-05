import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/view_models/register/tax_vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxPage extends StatelessWidget {
  const TaxPage({required this.name, Key? key}) : super(key: key);

  final String name;

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
                      SizedBox(height: 24.0),
                      Text(
                        'Tax Info'.tr(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Please provide your tax information'.tr(),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      Row(
                        spacing: 16,
                        children: [
                          GestureDetector(
                            onTap: () {
                              model.changeIsFile(!model.isFile);
                            },
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                color:
                                    model.isFile ? AppColor.primaryColor : null,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColor.primaryColor,
                                  width: 2,
                                ),
                              ),
                              child:
                                  model.isFile
                                      ? Center(
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      )
                                      : null,
                            ),
                          ),
                          Text('Want to Upload Tax Information File'.tr()),
                        ],
                      ),
                      SizedBox(height: 16),
                      model.isFile
                          ? Column(
                          children: [
                            GestureDetector(
                              onTap: () => openDocs(context, model, 1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Tax Information File'.tr(),
                                            style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios, size: 16),
                                      ],
                                    ),
                                    Visibility(
                                      visible: model.taxFile.isNotEmpty,
                                      child: Row(
                                        children: [
                                          Text(
                                            'Click again to choose a new file'.tr(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: Colors.grey),
                                          ),
                                          Spacer(),
                                          Expanded(child: Text(model.taxFileName, style: TextStyle(fontSize: 12))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 24,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ]
                      )
                          : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //
                                Text(
                                  'Full Name'.tr(),
                                  style: TextStyle(fontSize: 14),
                                ),
                                CustomTextFormField(
                                  textEditingController: model.nameTEC,
                                ).py12(),
                                SizedBox(height: 16),
                                //
                                Text(
                                  'Business Name (optional)'.tr(),
                                  style: TextStyle(fontSize: 14),
                                ),
                                CustomTextFormField(
                                  textEditingController: model.businessTEC,
                                ).py12(),
                                SizedBox(height: 16),
                                //
                                Text(
                                  'SSN / Tax ID'.tr(),
                                  style: TextStyle(fontSize: 14),
                                ),
                                CustomTextFormField(
                                  textEditingController: model.ssnTEC,
                                ).py12(),
                                SizedBox(height: 16),
                                //
                                Text('Address'.tr(), style: TextStyle(fontSize: 14)),
                                CustomTextFormField(
                                  textEditingController: model.addressTEC,
                                ).py12(),
                                SizedBox(height: 16),
                                //
                                Row(
                                  spacing: 16,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        model.changCertify(!model.certify);
                                      },
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color:
                                              model.certify
                                                  ? AppColor.primaryColor
                                                  : null,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: AppColor.primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        child:
                                            model.certify
                                                ? Center(
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                )
                                                : null,
                                      ),
                                    ),
                                    Text(
                                      'I certify that the information above is correct'.tr(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      SizedBox(height: 16),
                      Spacer(),
                      Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: GestureDetector(
                          onTap: () {
                            model.processTaxInfo(name);
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
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  openDocs(BuildContext context, TaxVM model, int fileType) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.file_copy, color: Colors.grey),
                      title: Text(
                        'Pick File'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        model.pickFile();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.image, color: Colors.grey),
                      title: Text(
                        'Pick Image from Gallery'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        model.pickImageFromGallery();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.camera_alt, color: Colors.grey),
                      title: Text(
                        'Capture Image from Camera'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        model.pickImageFromCamera();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
