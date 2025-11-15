
import 'package:flutter/material.dart';

// ✅ Theme imports
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../themes/app_text_styles.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('About Us', style: AppTextStyles.heading),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          children: [
            // App Logo
            Center(
              child: CircleAvatar(
                radius: AppDimensions.avatarRadius,
                backgroundColor: AppColors.white70,
                child: Image.asset(
                  'assets/bg_logo.png',
                  height: AppDimensions.avatarRadius * 2,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // App Name
            Center(
              child: Text(
                'ProtectU',
                style: AppTextStyles.heading.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),

            // Mission / Purpose
            Text(
              'Our mission is to provide a safe and transparent platform for employees to submit workplace complaints, '
                  'ensuring that every concern is addressed promptly and professionally by HR and Admin both.',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Key Features
            Text(
              'Key Features',
              style: AppTextStyles.subHeading.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              '• Submit complaints securely and confidentially\n'
                  '• Track the status of your complaints in real-time\n'
                  '• Option to submit anonymous complaints\n'
                  '• Receive notifications for updates\n'
                  '• Direct access to HR support',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Data Security
            Text(
              'Data Privacy & Security',
              style: AppTextStyles.subHeading.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              'All complaint data is securely stored and accessible only by authorized HR and admin personnel. '
                  'We follow strict privacy guidelines to ensure your personal information remains confidential.',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Target Users
            Text(
              'Who Can Use This App',
              style: AppTextStyles.subHeading.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              'This app is designed for employees of the organization to submit complaints, '
                  'and for HR/admin staff to review and address them efficiently.',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Contact Info
            Text(
              'Contact & Support',
              style: AppTextStyles.subHeading.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              'For any queries or support, please contact your HR department directly through the app '
                  'or through the official website.\n'
                  'https://sahiwal.comsats.edu.pk/',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Version Info
            Text(
              'App Version',
              style: AppTextStyles.subHeading.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text('Version 1.0.0', style: AppTextStyles.bodyText),
            const SizedBox(height: AppDimensions.paddingLarge),
          ],
        ),
      ),
    );
  }
}
