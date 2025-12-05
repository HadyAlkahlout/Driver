import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/view_models/register/docs_vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class DocsPage extends StatelessWidget {
  const DocsPage({
    required this.name,
    required this.city,
    Key? key,
  }) : super(key: key);

  final String name;
  final String city;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DocsVM>.reactive(
      viewModelBuilder: () => DocsVM(context),
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
                        'Signing up for'.tr(),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Text(
                            '$city . ',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Orders'.tr(),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        spacing: 8,
                        children: [
                          Text(
                            'Welcome'.tr(),
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            name,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Upload the following documents'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 86,
                              color:
                                  model.getProgressValue() < 1
                                      ? Colors.grey
                                      : AppColor.primaryColor,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 86,
                              color:
                                  model.getProgressValue() < 2
                                      ? Colors.grey
                                      : AppColor.primaryColor,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 86,
                              color:
                                  model.getProgressValue() < 3
                                      ? Colors.grey
                                      : AppColor.primaryColor,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 86,
                              color:
                                  model.getProgressValue() < 4
                                      ? Colors.grey
                                      : AppColor.primaryColor,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 86,
                              color:
                                  model.getProgressValue() < 5
                                      ? Colors.grey
                                      : AppColor.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.0),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                              'Driver’s License (government ID)'.tr(),
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
                                        visible: model.driversLicense.isNotEmpty,
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
                                            Expanded(child: Text(model.driversLicenseName, style: TextStyle(fontSize: 12))),
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
                              GestureDetector(
                                onTap: () => openDocs(context, model, 2),
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
                                              'Vehicle Registration (if using a car)'.tr(),
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
                                        visible:
                                            model.vehicleRegistration.isNotEmpty,
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
                                            Expanded(child: Text(model.vehicleRegistrationName, style: TextStyle(fontSize: 12))),
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
                              GestureDetector(
                                onTap: () => openDocs(context, model, 3),
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
                                              'Insurance document'.tr(),
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
                                        visible: model.insuranceDoc.isNotEmpty,
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
                                            Expanded(child: Text(model.insuranceDocName, style: TextStyle(fontSize: 12))),
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
                              GestureDetector(
                                onTap: () => openDocs(context, model, 4),
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
                                              'Selfie photo holding their ID (for face match)'.tr(),
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
                                        visible: model.selfiePhoto.isNotEmpty,
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
                                            Expanded(child: Text(model.selfiePhotoName, style: TextStyle(fontSize: 12))),
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
                              // GestureDetector(
                              //   onTap: () => openDocs(context, model, 5),
                              //   child: Padding(
                              //     padding: const EdgeInsets.symmetric(
                              //       vertical: 8.0,
                              //     ),
                              //     child: Column(
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       spacing: 8,
                              //       children: [
                              //         Row(
                              //           children: [
                              //             Expanded(
                              //               child: Text(
                              //                 'Criminal record'.tr(),
                              //                 style:
                              //                     Theme.of(
                              //                       context,
                              //                     ).textTheme.bodyMedium,
                              //               ),
                              //             ),
                              //             Icon(Icons.arrow_forward_ios, size: 16),
                              //           ],
                              //         ),
                              //         Visibility(
                              //           visible: model.criminalRecords.isNotEmpty,
                              //           child: Row(
                              //             children: [
                              //               Text(
                              //                 'Click again to choose a new file'.tr(),
                              //                 style: Theme.of(context)
                              //                     .textTheme
                              //                     .bodySmall
                              //                     ?.copyWith(color: Colors.grey),
                              //               ),
                              //               Spacer(),
                              //               Expanded(child: Text(model.criminalRecordsName, style: TextStyle(fontSize: 12))),
                              //             ],
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              // Divider(
                              //   height: 24,
                              //   color: Colors.grey.withOpacity(0.2),
                              // ),
                              GestureDetector(
                                onTap: () => openDocs(context, model, 6),
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
                                              'Vehicle check report (Optional)'.tr(),
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
                                        visible: model.vehicleCheck.isNotEmpty,
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
                                            Expanded(child: Text(model.vehicleCheckName, style: TextStyle(fontSize: 12))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: GestureDetector(
                          onTap: () {
                            model.uploadDocs(name);
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

  openDocs(BuildContext context, DocsVM model, int fileType) {
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
                        model.pickFile(fileType);
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
                        model.pickImageFromGallery(fileType);
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
                        model.pickImageFromCamera(fileType);
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
