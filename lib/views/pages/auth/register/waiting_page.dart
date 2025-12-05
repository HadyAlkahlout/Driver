import 'package:flutter/material.dart';
import 'package:fuodz/view_models/register/tax_vm.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({
    required this.name,
    Key? key,
  }) : super(key: key);

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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.0),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Training Info',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
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
