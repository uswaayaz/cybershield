
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';


class HrViewComplaintsScreen extends StatefulWidget {
  const HrViewComplaintsScreen({super.key});

  @override
  State<HrViewComplaintsScreen> createState() => _HrViewComplaintsScreenState();
}

class _HrViewComplaintsScreenState extends State<HrViewComplaintsScreen> {
  String selectedCategory = 'All';
  String? hrOrganizationName;
  bool isLoading = true;

  final List<String> categories = [
    'All',
    'Bullying',
    'Discrimination',
    'Corruption/ Bribery',
    'Physical Harassment',
    'Cyber Harassment',
    'Mental Health Concerns',
    'Staff Misconduct',
    'Violation Of Rules',
    'Misuse of Power',
    'Other(specify)',
  ];

  @override
  void initState() {
    super.initState();
    _fetchHrOrganization();
  }

  /// ✅ Fetch current HR's organization name from 'users' collection
  Future<void> _fetchHrOrganization() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          hrOrganizationName = userDoc.data()?['organizationName'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching HR data: $e')),
      );
    }
  }

  /// ✅ Show only complaints from HR's organization & selected category
  Stream<QuerySnapshot> _getComplaintStream() {
    if (hrOrganizationName == null) {
      return const Stream.empty();
    }

    Query query = FirebaseFirestore.instance
        .collection('complaints')
        .where('institutionName', isEqualTo: hrOrganizationName);

    if (selectedCategory != 'All') {
      query = query.where('category', isEqualTo: selectedCategory.trim());

     }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  /// ✅ Approve complaint (only once per organization)
  Future<void> _approveComplaint(String id, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('complaints').doc(id).update({
        'approvedByHR': true,
        'approvedAt': Timestamp.now(),
        'approvedByOrganization': hrOrganizationName, // ✅ record which org approved
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint approved and sent to Admin.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF154688)),
        ),
      );
    }

    if (hrOrganizationName == null) {
      return const Scaffold(
        body: Center(
          child: Text("No organization data found for this HR."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('HR View Complaints'),
        backgroundColor: const Color(0xFF154688),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// 🔹 Category filter buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isSelected ? const Color(0xFF154688) : Colors.grey[300],
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Text(category, style: const TextStyle(fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
          ),

          /// 🔹 Complaints Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getComplaintStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF154688)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No complaints found.',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                  );
                }

                final complaints = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final doc = complaints[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id;

                    final approvedBySameOrg =
                        data['approvedByHR'] == true &&
                            data['approvedByOrganization'] == hrOrganizationName;

                    final approvedByOtherOrgHR =
                        data['approvedByHR'] == true &&
                            data['approvedByOrganization'] != hrOrganizationName;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF154688), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Name:', data['name']),
                          const Divider(),
                          _buildInfoRow('Email:', data['email']),
                          const Divider(),
                          _buildInfoRow('CNIC:', data['cnic']),
                          const Divider(),
                          _buildInfoRow('Phone No:', data['phone']),
                          const Divider(),
                          _buildInfoRow('WhatsApp:', data['whatsapp']),
                          const Divider(),
                          _buildInfoRow('Gender:', data['gender']),
                          const Divider(),
                          _buildInfoRow('Occupation:', data['occupation']),
                          const Divider(),
                          _buildInfoRow('Postal Address:', data['postalAddress']),
                          const Divider(),
                          _buildInfoRow('City:', data['city']),
                          const Divider(),
                          _buildInfoRow('Category:', data['category']),
                          const Divider(),
                          _buildInfoRow('Workplace Type:', data['workplaceType']),
                          const Divider(),
                          _buildInfoRow('Institution Name:', data['institutionName']),
                          const Divider(),
                          _buildInfoRow('Department:', data['department']),
                          const Divider(),

                          _buildInfoRow('Complaint Details:', data['complaintDetails']),
                          const Divider(),
                          _buildFileRow('Attached File:', data['fileUrl']),
                          const Divider(),
                          _buildInfoRow('Submitted On:', data['createdAt'] != null ? data['createdAt'].toDate().toString() : 'Unknown'),
                          const Divider(),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoRow('Status:', data['status'] ?? 'Pending'),
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                tooltip: "Approve & Send to Admin",
                                onPressed: (approvedBySameOrg || approvedByOtherOrgHR)
                                    ? null
                                    : () => _approveComplaint(id, context),
                              ),
                            ],
                          ),

                          if (approvedBySameOrg)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                "✅ Approved & Sent to Admin (by your organization)",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),

                          if (approvedByOtherOrgHR)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                "✅ Approved by another HR of your organization",
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ File row with working URL open
  Widget _buildFileRow(String label, String? url) {
    if (url == null || url.isEmpty) {
      return _buildInfoRow(label, 'No file attached');
    }

    final fileName = url.split('/').last;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: () async {
          try {
            final uri = Uri.parse(url);
            debugPrint("Trying to open file: $uri");

            if (await canLaunchUrl(uri)) {
              final launched =
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!launched) throw 'launchUrl returned false';
            } else {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            debugPrint("Error opening file: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open file: $e')),
            );
          }
        },
        child: Row(
          children: [
            const Icon(Icons.attach_file, color: Color(0xFF154688)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }





  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
          children: [
            TextSpan(
              text: value?.toString() ?? 'N/A',
              style:
              const TextStyle(color: Colors.black87, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
