
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  final Color primaryColor = const Color(0xFF154688);
  final Color secondaryColor = const Color(0xFF164889);

  void _launchPhone(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch phone $phoneNumber : $e');
    }
  }

  void _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Inquiry&body=Hello,',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch email $email : $e');
    }
  }

  void _launchWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch website $url : $e');
    }
  }

  Widget _contactCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: color ?? primaryColor),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: const Color(0xFFFFFFFF),
        title: const Text('Contact Us'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/Untitled design5.jpg"),
              fit: BoxFit.cover,
            )
          // gradient: LinearGradient(
          //   colors: [primaryColor.withOpacity(0.1), secondaryColor.withOpacity(0.1)],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                'This is the main headquarters where this app was developed.'
                    'If you encounter any issues related to app functionalities, please feel free to contact us.'
                    'Thank you very much!',
                style: const TextStyle(fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),

            _contactCard(
              icon: Icons.location_on,
              label: 'Office Address',
              value: 'COMSATS University Islamabad-Sahiwal Campus, Pakistan',
              onTap: () => _launchWebsite(
                'https://www.google.com/maps/place/COMSATS+University+Islamabad+-+Sahiwal+Campus/@30.6621396,73.1046747,17z/',
              ),
            ),

            _contactCard(
              icon: Icons.public,
              label: 'Visit Company Website',
              value: 'https://sahiwal.comsats.edu.pk/',
              onTap: () => _launchWebsite('https://sahiwal.comsats.edu.pk/'),
            ),

          ],
        ),
      ),
    );
  }
}
