//
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mime/mime.dart';
//
// class AdminDeletedComplaintsScreen extends StatelessWidget {
//   const AdminDeletedComplaintsScreen({Key? key}) : super(key: key);
//
//   Future<void> _restoreComplaint(
//       String id, Map<String, dynamic> data, BuildContext context) async {
//     try {
//       // Move back to complaints collection
//       await FirebaseFirestore.instance.collection('complaints').doc(id).set({
//         ...data,
//         'restoredAt': Timestamp.now(),
//         'isDeleted': false,
//       });
//
//       // Delete from deleted_complaints
//       await FirebaseFirestore.instance.collection('deleted_complaints').doc(id).delete();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Complaint restored successfully.')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to restore: $e')),
//       );
//     }
//   }
//
//   void _confirmRestore(String id, Map<String, dynamic> data, BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Restore Complaint"),
//         content: const Text("Are you sure you want to restore this complaint?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF154688),
//               foregroundColor: Colors.white,
//             ),
//             onPressed: () {
//               Navigator.pop(ctx);
//               _restoreComplaint(id, data, context);
//             },
//             child: const Text("Yes, Restore"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFFFF),
//       appBar: AppBar(
//         title: const Text('Deleted Complaints'),
//         backgroundColor: const Color(0xFF154688),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('deleted_complaints')
//             .orderBy('deletedAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: Color(0xFF154688)),
//             );
//           }
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Text(
//                 'No deleted complaints found.',
//                 style: TextStyle(fontSize: 16, color: Colors.black54),
//               ),
//             );
//           }
//
//           final complaints = snapshot.data!.docs;
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: complaints.length,
//             itemBuilder: (context, index) {
//               final doc = complaints[index];
//               final data = doc.data() as Map<String, dynamic>;
//               final id = doc.id;
//
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: const Color(0xFF154688), width: 2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.4),
//                       blurRadius: 6,
//                       offset: const Offset(2, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildInfoRow('Name:', data['name']),
//                     const Divider(),
//                     _buildInfoRow('Email:', data['email']),
//                     const Divider(),
//                     _buildInfoRow('CNIC:', data['cnic']),
//                     const Divider(),
//                     _buildInfoRow('Phone No:', data['phone']),
//                     const Divider(),
//                     _buildInfoRow('WhatsApp:', data['whatsapp']),
//                     const Divider(),
//                     _buildInfoRow('Gender:', data['gender']),
//                     const Divider(),
//                     _buildInfoRow('Occupation:', data['occupation']),
//                     const Divider(),
//                     _buildInfoRow('Postal Address:', data['postalAddress']),
//                     const Divider(),
//                     _buildInfoRow('City:', data['city']),
//                     const Divider(),
//                     _buildInfoRow('Workplace Type:', data['workplaceType']),
//                     const Divider(),
//                     _buildInfoRow('Institution Name:', data['institutionName']),
//                     const Divider(),
//                     _buildInfoRow('Department:', data['department']),
//                     const Divider(),
//                     _buildInfoRow('Category:', data['category']),
//                     const Divider(),
//                     _buildInfoRow('Complaint Details:', data['complaintDetails']),
//                     const Divider(),
//                     _buildFileRow('Attached File:', data['fileUrl'], context),
//                     const Divider(),
//                     _buildInfoRow(
//                       'Submitted On:',
//                       data['createdAt'] != null
//                           ? (data['createdAt'] as Timestamp).toDate().toString()
//                           : 'N/A',
//                     ),
//                     const Divider(),
//                     _buildInfoRow(
//                       'Deleted On:',
//                       data['deletedAt'] != null
//                           ? (data['deletedAt'] as Timestamp).toDate().toString()
//                           : 'N/A',
//                     ),
//                     const Divider(),
//                     const SizedBox(height: 10),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF154688),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         icon: const Icon(Icons.restore),
//                         label: const Text("Restore"),
//                         onPressed: () => _confirmRestore(id, data, context),
//                       ),
//                     )
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: RichText(
//         text: TextSpan(
//           text: '$label ',
//           style: const TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 15,
//           ),
//           children: [
//             TextSpan(
//               text: value?.toString() ?? 'N/A',
//               style: const TextStyle(
//                 color: Colors.black87,
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// 🔹 Handles all file types (images or others) externally
//   Widget _buildFileRow(String label, String? url, BuildContext context) {
//     if (url == null || url.isEmpty) {
//       return _buildInfoRow(label, 'No file attached');
//     }
//
//     final fileName = url.split('/').last;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: GestureDetector(
//         onTap: () async {
//           try {
//             final uri = Uri.parse(url);
//             final success =
//             await launchUrl(uri, mode: LaunchMode.externalApplication);
//             if (!success) throw 'Could not open file';
//           } catch (e) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Could not open file: $e')),
//             );
//           }
//         },
//         child: Row(
//           children: [
//             const Icon(Icons.attach_file, color: Color(0xFF154688)),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 fileName,
//                 style: const TextStyle(
//                   color: Colors.blue,
//                   decoration: TextDecoration.underline,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';

class AdminDeletedComplaintsScreen extends StatefulWidget {
  const AdminDeletedComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<AdminDeletedComplaintsScreen> createState() =>
      _AdminDeletedComplaintsScreenState();
}

class _AdminDeletedComplaintsScreenState
    extends State<AdminDeletedComplaintsScreen> {
  String? adminOrganization;
  bool isLoading = true;

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

  Stream<QuerySnapshot> _getDeletedComplaintStream() {
    if (adminOrganization == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('deleted_complaints')
        .where('institutionName', isEqualTo: adminOrganization)
        .orderBy('deletedAt', descending: true)
        .snapshots();
  }

  Future<void> _restoreComplaint(
      String id, Map<String, dynamic> data, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('complaints').doc(id).set({
        ...data,
        'restoredAt': Timestamp.now(),
        'isDeleted': false,
      });

      await FirebaseFirestore.instance.collection('deleted_complaints').doc(id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint restored successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to restore: $e')),
      );
    }
  }

  void _confirmRestore(String id, Map<String, dynamic> data, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Restore Complaint"),
        content: const Text("Are you sure you want to restore this complaint?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF154688),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _restoreComplaint(id, data, context);
            },
            child: const Text("Yes, Restore"),
          ),
        ],
      ),
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
          child: Text('Organization not found. Cannot load deleted complaints.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Deleted Complaints'),
        backgroundColor: const Color(0xFF154688),
        foregroundColor: const Color(0xFFFFFFFF),
       ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getDeletedComplaintStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF154688)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No deleted complaints found .',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
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
                    _buildInfoRow('Workplace Type:', data['workplaceType']),
                    const Divider(),
                    _buildInfoRow('Institution Name:', data['institutionName']),
                    const Divider(),
                    _buildInfoRow('Department:', data['department']),
                    const Divider(),
                    _buildInfoRow('Category:', data['category']),
                    const Divider(),
                    _buildInfoRow('Complaint Details:', data['complaintDetails']),
                    const Divider(),
                    _buildFileRow('Attached File:', data['fileUrl'], context),
                    const Divider(),
                    _buildInfoRow(
                      'Submitted On:',
                      data['createdAt'] != null
                          ? (data['createdAt'] as Timestamp).toDate().toString()
                          : 'N/A',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      'Deleted On:',
                      data['deletedAt'] != null
                          ? (data['deletedAt'] as Timestamp).toDate().toString()
                          : 'N/A',
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF154688),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.restore,color: Colors.white,),
                        label: const Text("Restore"),
                        onPressed: () => _confirmRestore(id, data, context),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
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
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          children: [
            TextSpan(
              text: value?.toString() ?? 'N/A',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileRow(String label, String? url, BuildContext context) {
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
}
