
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'FAQs.dart';
import 'Policies_and_Guidelines.dart';

import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../themes/app_text_styles.dart';

class HelpDeskScreen extends StatelessWidget {
  const HelpDeskScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactRef =
    FirebaseFirestore.instance.collection('helpdesk').doc('contact');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Help Desk",
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          /// FAQs
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.secondary),
            title: Text("FAQs", style: AppTextStyles.subHeading),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FaqsScreen()),
              );
            },
          ),
          const Divider(),

          /// Policies & Guidelines
          ListTile(
            leading: const Icon(Icons.policy, color: AppColors.secondary),
            title: Text("Policies & Guidelines", style: AppTextStyles.subHeading),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PoliciesScreen()),
              );
            },
          ),
          const Divider(),

          /// Laws
          _buildCard(
            icon: Icons.gavel,
            title: 'LAWS',
            items: [
              'FIA Act, 1974',
              'The Emigration Ordinance 1979',
              'Pakistan Penal Code',
              'Anti-Money Laundering Act, 2010',
              'The Anti-Terrorism Act, 1997',
              'Investigation for Fair Trial Act, 2013',
              'Code of Criminal Procedure, 1898',
              'Prevention of Electronic Crimes Act, 2016',
              'Prevention of Electronic Crime Investigation Rules 2018',
              'Financial Institutions (Recovery of Finances) Ordinance, 2001',
              'Prevention of Trafficking in Persons Act 2018 (Urdu)',
              'Prevention of Trafficking in Persons Act 2018 (English)',
              'Prevention of Smuggling of Migrants Act, 2018 (Urdu)',
              'Prevention of Smuggling of Migrants Act, 2018 (English)',
              'Financial Institutions (Recovery of Finances) Rules, 2018',
            ],
          ),

          /// SOPs
          _buildCard(
            icon: Icons.description,
            title: 'SOPs',
            items: [
              'Enforcement of Immigration Laws, SOP #27, Year 2005',
              'Interrogation of OPDs/DFDs, SOP #1, Year 2005',
              'Handling of Deportees, SOP #29, Year 2005',
              'Inadmissible Passenger',
              'Issuance of Visa on Arrival',
              'Registration of Foreigners and Issuance of “C” Form, Year 2005',
              'Anti-Corruption Wing!',
              'National Central Bureau (Interpol), SOP #14, Year 1983',
              'Technical, SOP #13',
              'Central Crime Record Office (CCRO)',
              'Checking/scanning for diplomatic clearance at Wagha Border',
              'S.O. No. 05/2020 (Guidelines regarding Enquiry/Investigation)',
              'Cyber Crimes SOP',
            ],
          ),

          /// SRO
          _buildCard(
            icon: Icons.settings,
            title: 'SRO',
            items: [
              'SRO 7(1)/2014 regarding merger of NARA with NADRA',
            ],
          ),

          /// RULES
          _buildCard(
            icon: Icons.rule,
            title: 'RULES',
            items: [
              'Prevention of Trafficking in Persons Rules 2020 (English)',
              'Prevention of Smuggling of Migrants Rules 2020 (English)',
              'FIA Appointment, Promotion and Transfer Rules 1975',
              'Prevention of Trafficking in Persons Rules 2002 (Urdu)',
              'FIA Appointment, Promotion and Transfer Rules 2020 (BS-15 and below)',
              'Notification to Repeal Clauses of FIA APT Rules 1975',
              'FIA Appointment, Promotion and Transfer Rules 2014',
              'FIA Rotation Policy 2021',
              'Prevention of Smuggling of Migrants Rules 2020 (Urdu)',
              'FIA Inquiry & Investigation Rules 2002',
            ],
          ),

          const Divider(),

          /// Escalation Support
          Text("Escalation Support", style: AppTextStyles.subHeading),
          ListTile(
            leading: const Icon(Icons.report_problem, color: Colors.red),
            title: const Text("Escalate an Unresolved Complaint"),
            subtitle: const Text("Forward your case to higher authority"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Escalation request initiated.")),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Reusable card for Laws, SOPs, Rules, SRO
  Widget _buildCard(
      {required IconData icon,
        required String title,
        required List<String> items}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius)),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.secondary),
        title: Text(title, style: AppTextStyles.subHeading),
        children: items
            .map((e) => ListTile(
          title: Text(e, style: TextStyle(color: AppColors.black)),
        ))
            .toList(),
      ),
    );
  }
}
