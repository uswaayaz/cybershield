
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../themes/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // 🔹 Delete Account Logic with Reauthentication
  void _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Account', style: AppTextStyles.subHeading),
        content: const Text(
          'Are you sure you want to delete your account? '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.of(ctx).pop();

              try {
                final uid = user.uid;

                // 1. Delete Firestore user profile
                await FirebaseFirestore.instance.collection("users").doc(uid).delete();

                // 2. Delete complaints related to user
                final complaintsSnapshot = await FirebaseFirestore.instance
                    .collection("complaints")
                    .where("userId", isEqualTo: uid)
                    .get();

                for (var doc in complaintsSnapshot.docs) {
                  await doc.reference.delete();
                }

                // 3. Try deleting authentication account
                await user.delete();

                // 4. Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted successfully.')),
                );

                // 5. Redirect to login screen
                Navigator.of(context).pushReplacementNamed('/login');
              } catch (e) {
                if (e.toString().contains('requires-recent-login')) {
                  _reauthenticateAndDelete(context, user);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting account: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _reauthenticateAndDelete(BuildContext context, User user) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reauthenticate', style: AppTextStyles.subHeading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'For security, please enter your password to confirm account deletion.',
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              try {
                final cred = EmailAuthProvider.credential(
                  email: user.email!,
                  password: passwordController.text.trim(),
                );

                await user.reauthenticateWithCredential(cred);
                await user.delete();

                Navigator.of(ctx).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted successfully.')),
                );

                Navigator.of(context).pushReplacementNamed('/login');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reauthentication failed: $e')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _openTextPage(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Text(title, style: AppTextStyles.subHeading.copyWith(color: AppColors.white)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.subHeading.copyWith(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    const termsText = '''
1. Users must submit genuine complaints related to workplace issues.
2. Complaints must not include false or defamatory information.
3. User accounts are for authorized employees only.
4. Admin/HR reserves the right to review and resolve complaints per company policies.
5. Users agree to receive notifications regarding complaint status.
6. Misuse of the platform may result in account suspension or deletion.
''';

    const privacyText = '''
1. Personal Information Collected: Name, email, phone, department, complaint details, and attached files.
2. Use of Information: For complaint processing, tracking, and internal HR reporting only.
3. Data Sharing: Data is shared only with authorized HR and Admin users. No third-party sharing.
4. Data Retention: Complaint data is stored securely until resolved or as per company retention policy.
5. User Rights: Users can request deletion of personal information (except where legally required to retain).
6. Security Measures: All data is stored using encrypted Firestore storage, accessible only by authorized personnel.
''';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Untitled design5.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          children: [
            const SizedBox(height: AppDimensions.paddingLarge),
            _buildTile(context, Icons.delete_forever, 'Delete Account', () => _deleteAccount(context)),
            const Divider(),
            _buildTile(context, Icons.description, 'Terms & Conditions',
                    () => _openTextPage(context, 'Terms & Conditions', termsText)),
            const Divider(),
            _buildTile(context, Icons.privacy_tip, 'Privacy Policy',
                    () => _openTextPage(context, 'Privacy Policy', privacyText)),
            const Divider(),
            _buildTile(context, Icons.public, 'FIA Official Website', () {
              const url = 'https://www.fia.gov.pk/';
              Uri uri = Uri.parse(url);
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }),
          ],
        ),
      ),
    );
  }
}
