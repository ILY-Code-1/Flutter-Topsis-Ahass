
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/themes.dart';
import '../../../core/core.dart';
import '../../../widgets/widgets.dart';
import '../controllers/topsis_controller.dart';

class TopsisView extends GetView<TopsisController> {
  const TopsisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavbar(
        title: 'TOPSIS Analysis',
        showBackButton: true,
        onBackPressed: () => Get.offNamed('/'),
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form section is removed as analysis is now triggered from item management
                // _buildFormSection(context),
                // Gap.hXl,
                // _buildDataList(context),
                // Gap.hXl,
                // Align(
                //   alignment: Alignment.center,
                //   child: _buildSubmitButton(context),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
