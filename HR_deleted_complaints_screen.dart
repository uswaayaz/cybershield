//
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class HRDeletedComplaintsScreen extends StatelessWidget {
//   const HRDeletedComplaintsScreen({Key? key}) : super(key: key);
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
//
//                     // _buildInfoRow('Father Name:', data['fatherName']),
//                     // const Divider(),
//
//                     _buildInfoRow('Email:', data['email']),
//                     const Divider(),
//
//                     _buildInfoRow('CNIC:', data['cnic']),
//                     const Divider(),
//
//                     _buildInfoRow('Phone No:', data['phone']),
//                     const Divider(),
//
//                     _buildInfoRow('WhatsApp:', data['whatsapp']),
//                     const Divider(),
//
//                     _buildInfoRow('Gender:', data['gender']),
//                     const Divider(),
//
//                     _buildInfoRow('Occupation:', data['occupation']),
//                     const Divider(),
//
//                     _buildInfoRow('Postal Address:', data['postalAddress']),
//                     const Divider(),
//
//                     _buildInfoRow('City:', data['city']),
//                     const Divider(),
//
//                     _buildInfoRow('Workplace Type:', data['workplaceType']),
//                     const Divider(),
//
//                     _buildInfoRow('Institution Name:', data['institutionName']),
//                     const Divider(),
//
//                     _buildInfoRow('Department:', data['department']),
//                     const Divider(),
//
//                     _buildInfoRow('Category:', data['category']),
//                     const Divider(),
//
//                     _buildInfoRow('Complaint Details:', data['complaintDetails']),
//                     const Divider(),
//
//                     _buildImageRow(context, 'Attached File:', data['fileUrl']),
//                     const Divider(),
//
//                     _buildInfoRow(
//                       'Submitted On:',
//                       data['createdAt'] != null
//                           ? (data['createdAt'] as Timestamp).toDate().toString()
//                           : 'N/A',
//                     ),
//                     const Divider(),
//
//                     _buildInfoRow(
//                       'Deleted On:',
//                       data['deletedAt'] != null
//                           ? (data['deletedAt'] as Timestamp).toDate().toString()
//                           : 'N/A',
//                     ),
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
//   Widget _buildImageRow(BuildContext context, String label, String? url) {
//     if (url == null || url.isEmpty) {
//       return _buildInfoRow(label, 'No file attached');
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildInfoRow(label, ''),
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => FullScreenImagePage(imageUrl: url),
//               ),
//             );
//           },
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.network(
//               url,
//               width: double.infinity,
//               fit: BoxFit.contain,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return const Padding(
//                   padding: EdgeInsets.all(12),
//                   child: Center(child: CircularProgressIndicator()),
//                 );
//               },
//               errorBuilder: (context, error, stackTrace) =>
//               const Padding(
//                 padding: EdgeInsets.all(12),
//                 child: Text('Could not load image'),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class FullScreenImagePage extends StatelessWidget {
//   final String imageUrl;
//
//   const FullScreenImagePage({super.key, required this.imageUrl});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: InteractiveViewer(
//           child: Image.network(imageUrl, fit: BoxFit.contain),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mime/mime.dart';

class HRDeletedComplaintsScreen extends StatelessWidget {
  const HRDeletedComplaintsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('Deleted Complaints'),
        backgroundColor: const Color(0xFF154688),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('deleted_complaints')
            .orderBy('deletedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF154688)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No deleted complaints found.',
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

  /// 🔹 Handles all file types (images or others) externally
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
