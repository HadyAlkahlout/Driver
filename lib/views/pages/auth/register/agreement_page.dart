import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/views/pages/auth/register/waiting_page.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velocity_x/velocity_x.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({required this.name, Key? key}) : super(key: key);

  final String name;

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool agree = false;
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    final path = await loadPdfFromAssets("assets/pdf/agreement.pdf");
    setState(() {
      pdfPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (pdfPath == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BasePage(
      showLeadingAction: false,
      showAppBar: true,
      title: 'E2U',
      backgroundColor: context.theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.0),
          Expanded(
            child: PDFView(
              filePath: pdfPath!,
              swipeHorizontal: false,
              fitEachPage: true,
              fitPolicy: FitPolicy.BOTH,
              onError: (error) {
                print('Test Error: ${error.toString()}');
              },
            ),
          ),

          SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: agree,
                onChanged: (value) {
                  setState(() {
                    agree = value!;
                  });
                },
              ),
              Expanded(child: Text('I agree to these terms'.tr())),
              GestureDetector(
                onTap: () {
                  goNext();
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
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<String> loadPdfFromAssets(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${assetPath.split('/').last}');

    await file.writeAsBytes(bytes, flush: true);

    return file.path; // Actual usable file path
  }

  void goNext() async {
    if (agree) {
      await LocalStorageService.prefs!.setBool(AppStrings.driverWaiting, true);
      await LocalStorageService.prefs!.setString(
        AppStrings.driverName,
        widget.name,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WaitingPage(name: widget.name)),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to the agreement'.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: Colors.white),
          ),
        ),
      );
    }
  }
}
