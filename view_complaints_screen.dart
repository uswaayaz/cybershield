//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class ViewComplaintsScreen extends StatefulWidget {
//   const ViewComplaintsScreen({super.key});
//
//   @override
//   _ViewComplaintsScreenState createState() => _ViewComplaintsScreenState();
// }
//
// class _ViewComplaintsScreenState extends State<ViewComplaintsScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   final Color lightBackground = const Color(0xFFFFFFFF);
//   final Color primaryColor = const Color(0xFF154688);
//
//   Stream<QuerySnapshot> _fetchComplaints() {
//     final currentUserEmail = _auth.currentUser?.email?.trim().toLowerCase();
//
//     if (currentUserEmail == null || currentUserEmail.isEmpty) {
//       debugPrint("No current user email found.");
//       return const Stream.empty();
//     }
//
//     debugPrint("Fetching complaints for email: $currentUserEmail");
//
//     return _firestore
//         .collection('complaints')
//         .where('email', isEqualTo: currentUserEmail)
//         .orderBy('createdAt', descending: true)
//         .snapshots();
//   }
//
//   Widget _buildRow(IconData icon, String label, String value, {bool link = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: primaryColor),
//           const SizedBox(width: 10),
//           Expanded(
//             child: link
//                 ? GestureDetector(
//               onTap: () async {
//                 if (value != 'No file attached' &&
//                     await canLaunchUrl(Uri.parse(value))) {
//                   await launchUrl(Uri.parse(value),
//                       mode: LaunchMode.externalApplication);
//                 }
//               },
//               child: RichText(
//                 text: TextSpan(
//                   text: '$label: ',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                   children: [
//                     TextSpan(
//                       text: value,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF164889),
//                         decoration: TextDecoration.underline,
//                         fontWeight: FontWeight.normal,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//                 : RichText(
//               text: TextSpan(
//                 text: '$label: ',
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                 ),
//                 children: [
//                   TextSpan(
//                     text: value,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.black87,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildComplaintTile(DocumentSnapshot complaint) {
//     var data = complaint.data() as Map<String, dynamic>;
//
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       elevation: 3,
//       color: lightBackground,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildRow(Icons.person, 'Name', data['name'] ?? 'N/A'),
//             _buildRow(Icons.phone, 'Phone No', data['phone'] ?? 'N/A'),
//             _buildRow(Icons.phone, 'WhatsApp', data['whatsapp'] ?? 'N/A'),
//             _buildRow(Icons.credit_card, 'CNIC', data['cnic'] ?? 'N/A'),
//             _buildRow(Icons.email, 'Email', data['email'] ?? 'N/A'),
//             _buildRow(Icons.male, 'Gender', data['gender'] ?? 'N/A'),
//             _buildRow(Icons.work, 'Occupation', data['occupation'] ?? 'N/A'),
//             _buildRow(Icons.location_city, 'City', data['city'] ?? 'N/A'),
//             _buildRow(Icons.home, 'Postal Address', data['postalAddress'] ?? 'N/A'),
//             _buildRow(Icons.apartment, 'Workplace Type', data['workplaceType'] ?? 'N/A'),
//             _buildRow(Icons.business, 'Institution Name', data['institutionName'] ?? 'N/A'),
//             _buildRow(Icons.account_tree, 'Department', data['department'] ?? 'N/A'),
//
//             // 🔹 Prominent Category with Dividers
//             Divider(thickness: 1, color: Colors.grey[300]),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(Icons.category, color: Color(0xFF164889)),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: RichText(
//                       text: TextSpan(
//                         text: 'Category: ',
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: data['category'] ?? 'N/A',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF163889),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(thickness: 1, color: Colors.grey[300]),
//
//             _buildRow(Icons.description, 'Complaint Details',
//                 data['complaintDetails'] ?? 'N/A'),
//             (data['fileUrl'] != null && data['fileUrl'].toString().isNotEmpty)
//                 ? Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildRow(Icons.attach_file, 'Attached File', ''),
//                 const SizedBox(height: 10),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) =>
//                             FullScreenImagePage(imageUrl: data['fileUrl']),
//                       ),
//                     );
//                   },
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.network(
//                       data['fileUrl'],
//                       width: double.infinity,
//                       fit: BoxFit.contain,
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return const Center(
//                             child: CircularProgressIndicator());
//                       },
//                       errorBuilder: (context, error, stackTrace) =>
//                       const Text(
//                         'Could not load image.',
//                         style: TextStyle(color: Colors.red),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//                 : _buildRow(Icons.attach_file, 'Attached File', 'No file attached'),
//             const SizedBox(height: 10),
//             _buildRow(
//                 Icons.timer,
//                 'Submitted On',
//                 data['createdAt'] != null
//                     ? data['createdAt'].toDate().toString()
//                     : 'Unknown'),
//             _buildRow(Icons.info_outline, 'Status', data['status'] ?? 'Pending'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: lightBackground,
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         centerTitle: true,
//         title: const Text('My Complaints'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _fetchComplaints(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Text('No complaints submitted yet.'),
//             );
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               return _buildComplaintTile(snapshot.data!.docs[index]);
//             },
//           );
//         },
//       ),
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class ViewComplaintsScreen extends StatefulWidget {
  const ViewComplaintsScreen({super.key});

  @override
  _ViewComplaintsScreenState createState() => _ViewComplaintsScreenState();
}

class _ViewComplaintsScreenState extends State<ViewComplaintsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Color lightBackground = const Color(0xFFFFFFFF);
  final Color primaryColor = const Color(0xFF154688);

  Stream<QuerySnapshot> _fetchComplaints() {
    final currentUserEmail = _auth.currentUser?.email?.trim().toLowerCase();

    if (currentUserEmail == null || currentUserEmail.isEmpty) {
      debugPrint("No current user email found.");
      return const Stream.empty();
    }

    debugPrint("Fetching complaints for email: $currentUserEmail");

    return _firestore
        .collection('complaints')
        .where('email', isEqualTo: currentUserEmail)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Detect file type from extension
  IconData _getFileIcon(String fileUrl) {
    String ext = path.extension(fileUrl).toLowerCase();

    if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".gif") {
      return Icons.image;
    } else if (ext == ".pdf") {
      return Icons.picture_as_pdf;
    } else if (ext == ".doc" || ext == ".docx") {
      return Icons.description;
    } else if (ext == ".mp4" || ext == ".mov" || ext == ".avi") {
      return Icons.videocam;
    } else if (ext == ".mp3" || ext == ".wav" || ext == ".aac") {
      return Icons.audiotrack;
    } else if (ext == ".xlsx" || ext == ".xls") {
      return Icons.table_chart;
    } else if (ext == ".zip" || ext == ".rar") {
      return Icons.archive;
    }
    return Icons.insert_drive_file;
  }

  Widget _buildRow(IconData icon, String label, String value,
      {bool link = false, IconData? fileIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: link
                ? Row(
              children: [
                Text(
                  "$label: ",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (value != 'No file attached') {
                        final uri = Uri.tryParse(value);

                        if (uri != null) {
                          final fileName = path.basename(uri.path);

                          try {
                            final success = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );

                            if (success) {
                              // ✅ Success snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Opening file: $fileName"),
                                  backgroundColor: const Color(0xFF154688),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              // ❌ Failed to open
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Could not open file: $fileName"),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            // ❌ Exception case
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error opening file: $e"),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      }
                    },

                    child: Row(
                      children: [
                        if (fileIcon != null)
                          Icon(fileIcon,
                              size: 18, color: const Color(0xFF164889)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Tooltip(
                            message: path.basename(Uri.parse(value).path),
                            child: Text(
                              path.basename(Uri.parse(value).path),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF164889),
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
                : RichText(
              text: TextSpan(
                text: '$label: ',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintTile(DocumentSnapshot complaint) {
    var data = complaint.data() as Map<String, dynamic>;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      color: lightBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow(Icons.person, 'Name', data['name'] ?? 'N/A'),
            _buildRow(Icons.phone, 'Phone No', data['phone'] ?? 'N/A'),
            _buildRow(Icons.phone, 'WhatsApp', data['whatsapp'] ?? 'N/A'),
            _buildRow(Icons.credit_card, 'CNIC', data['cnic'] ?? 'N/A'),
            _buildRow(Icons.email, 'Email', data['email'] ?? 'N/A'),
            _buildRow(Icons.male, 'Gender', data['gender'] ?? 'N/A'),
            _buildRow(Icons.work, 'Occupation', data['occupation'] ?? 'N/A'),
            _buildRow(Icons.location_city, 'City', data['city'] ?? 'N/A'),
            _buildRow(
                Icons.home, 'Postal Address', data['postalAddress'] ?? 'N/A'),
            // _buildRow(Icons.apartment, 'Workplace Type',
            //     data['workplaceType'] ?? 'N/A'),
            _buildRow(Icons.business, 'Institution Name',
                data['institutionName'] ?? 'N/A'),
            _buildRow(Icons.account_tree, 'Department',
                data['department'] ?? 'N/A'),

            Divider(thickness: 1, color: Colors.grey[300]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.category, color: Color(0xFF164889)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'Category: ',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: data['category'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF163889),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(thickness: 1, color: Colors.grey[300]),

            _buildRow(Icons.description, 'Complaint Details',
                data['complaintDetails'] ?? 'N/A'),

            (data['fileUrl'] != null && data['fileUrl'].toString().isNotEmpty)
                ? _buildRow(
              Icons.attach_file,
              'Attached File',
              data['fileUrl'],
              link: true,
              fileIcon: _getFileIcon(data['fileUrl']),
            )
                : _buildRow(
                Icons.attach_file, 'Attached File', 'No file attached'),

            const SizedBox(height: 10),
            _buildRow(
                Icons.timer,
                'Submitted On',
                data['createdAt'] != null
                    ? data['createdAt'].toDate().toString()
                    : 'Unknown'),
            _buildRow(
                Icons.info_outline, 'Status', data['status'] ?? 'Pending'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: const Color(0xFFFFFFFF),
        centerTitle: true,
        title: const Text('My Complaints'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No complaints submitted yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return _buildComplaintTile(snapshot.data!.docs[index]);
            },
          );
        },
      ),
    );
  }
}