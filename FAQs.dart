
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../themes/app_text_styles.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        "question": "How do I submit a complaint?",
        "answer":
        "Go to the Home page where you see multiple complaint categories we handle, fill in the required details, and tap submit."
      },
      {
        "question": "What type of complaints can I file?",
        "answer":
        "You can file complaints related to workplace harassment, discrimination, misconduct and policy violations  etc."
      },
      {
        "question": "Can I edit my complaint?",
        "answer": "Yes, complaints can be edited before submission."
      },
      {
        "question": "How long does it take to resolve a complaint?",
        "answer":
        "The timeline varies depending on the case. However, you can track the status of your complaint in the 'View Complaints' section."
      },
      {
        "question": "Will my complaint remain confidential?",
        "answer":
        "Yes, all complaints are handled confidentially. Only the authorized HR/Admin has access to complaint details."
      },
      {
        "question": "What do complaint statuses mean?",
        "answer":
        "Submitted: Complaint received.\nUnder Review: HR/Admin is assessing the case.\nIn Progress: Investigation is ongoing.\nResolved: Complaint has been addressed."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FAQs",
          style: TextStyle(
              fontWeight: FontWeight.normal, color: AppColors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 2,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            child: ExpansionTile(
              leading: const Icon(Icons.help_outline, color: AppColors.secondary),
              title: Text(
                faqs[index]["question"]!,
                style: AppTextStyles.subHeading.copyWith(fontSize: 16),
              ),
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall),
                  child: Text(
                    faqs[index]["answer"]!,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: AppColors.black,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
