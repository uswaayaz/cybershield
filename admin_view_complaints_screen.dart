

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminViewComplaintsScreen extends StatefulWidget {
  const AdminViewComplaintsScreen({super.key});

  @override
  State<AdminViewComplaintsScreen> createState() =>
      _AdminViewComplaintsScreenState();
}

class _AdminViewComplaintsScreenState
    extends State<AdminViewComplaintsScreen> {
  String selectedCategory = 'All';
  String? adminOrganization;
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
    _fetchAdminOrganization();
  }

  Future<void> _fetchAdminOrganization() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('organizations')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          adminOrganization = querySnapshot.docs.first['organizationName'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No organization found for this admin.')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching organization: $e')),
      );
    }
  }



  Stream<QuerySnapshot> _getComplaintStream() {
    if (adminOrganization == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('complaints')
        .where('approvedByHR', isEqualTo: true)
        .where('institutionName', isEqualTo: adminOrganization)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }


  Future<void> _deleteComplaint(
      String id, Map<String, dynamic> data, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('deleted_complaints')
          .doc(id)
          .set({
        ...data,
        'deletedAt': Timestamp.now(),
        'isDeleted': true,
      });

      await FirebaseFirestore.instance.collection('complaints').doc(id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint moved to deleted complaints.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  void _updateStatus(String id, String currentStatus, BuildContext context) {
    final statuses = ['Pending', 'In Progress', 'Resolved', 'Not Resolved'];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: statuses.map((status) {
            return ListTile(
              title: Text(status),
              leading: currentStatus == status
                  ? const Icon(Icons.check_circle, color: Color(0xFF154688))
                  : const Icon(Icons.circle_outlined),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance
                    .collection('complaints')
                    .doc(id)
                    .update({'status': status});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Status updated to $status')),
                );
              },
            );
          }).toList(),
        );
      },
    );
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

    if (adminOrganization == null) {
      return const Scaffold(
        body: Center(
          child: Text('Organization not found. Cannot load complaints.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Complaints'),
        backgroundColor: const Color(0xFF154688),
        foregroundColor: const Color(0xFFFFFFFF),
        centerTitle: true,
      ),
      body: Column(
        children: [

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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getComplaintStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF154688)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No complaints found for your organization.',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                  );
                }
                // Filter complaints based on selected category
                final complaints = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (selectedCategory == 'All') return true;
                  return data['category'] == selectedCategory;
                }).toList();

                if (complaints.isEmpty) {
                  return const Center(
                    child: Text('No complaints found .',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                  );
                }


                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final doc = complaints[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
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

                          _buildInfoRow(
                              'Status:', data['status'] ?? 'Pending'),
                          const Divider(),
                          if (data['approvedByHR'] == true)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'This complaint is approved by HR',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color(0xFF154688)),
                                onPressed: () =>
                                    _updateStatus(id, data['status'] ?? 'Pending', context),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteComplaint(id, data, context),
                              ),
                            ],
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
              text: value ?? 'N/A',
              style: const TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

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
            final success =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (!success) throw 'Could not open file';
          } catch (e) {
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
                    decoration: TextDecoration.underline),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
