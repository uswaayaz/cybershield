
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../themes/app_text_styles.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  final List<Map<String, String>> policies = const [
    {
      "title": "Complaint Filing Guidelines",
      "content":
      "Employees, interns, and contractors can file complaints regarding harassment, discrimination, workplace bullying, safety concerns, or unethical practices.\n\n"
          "Steps to file a complaint:\n"
          "1. Go to the Complaint Form.\n"
          "2. Fill in required details.\n"
          "3. Attach supporting documents/images (if any).\n"
          "4. Submit for review."
    },
    {
      "title": "Confidentiality Policy",
      "content":
      "All complaints are kept strictly confidential.\n\n"
          "Only authorized HR/Admin personnel have access.\n"
          "Your identity and details are protected under company policy."
    },
    {
      "title": "Complaint Resolution Process",
      "content":
      "Every complaint goes through the following stages:\n\n"
          "1. Submitted – Complaint received.\n"
          "2. Under Review – Initial assessment by HR/Admin.\n"
          "3. Investigation – Detailed inquiry if required.\n"
          "4. Resolved – Decision communicated to employee.\n\n"
          "Expected resolution time: 7–14 working days."
    },
    {
      "title": "Anti-Retaliation Policy",
      "content":
      "Employees will not face punishment, discrimination, or job loss for filing a complaint.\n\n"
          "Retaliation by colleagues, supervisors, or management is strictly prohibited and subject to disciplinary action."
    },
    {
      "title": "User Responsibilities",
      "content":
      "To ensure fair handling of complaints, employees must:\n\n"
          "✔ Provide accurate and truthful information.\n"
          "✔ Avoid false or malicious complaints.\n"
          "✔ Cooperate with investigations when required."
    },
    {
      "title": "Workplace Code of Conduct",
      "content":
      "Employees are expected to maintain professionalism and follow ethical practices:\n\n"
          "✔ Respect all colleagues.\n"
          "✔ No harassment or discrimination.\n"
          "✔ Report unethical or unsafe practices.\n"
          "✔ Uphold workplace integrity."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Policies & Guidelines",
          style: TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: policies.length,
        itemBuilder: (context, index) {
          final policy = policies[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            elevation: 3,
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              title: Text(
                policy["title"]!,
                style: AppTextStyles.subHeading.copyWith(color: AppColors.black),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Text(
                    policy["content"]!,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.black),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
