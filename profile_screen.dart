
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cybershield/models/Organization.dart';
// import 'package:cybershield/models/Users.dart';
// import 'package:cybershield/models/HR.dart';
//
//
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//
//   Future<Map<String, dynamic>> _loadUserAndOrganization() async {
//     final firebaseUser = FirebaseAuth.instance.currentUser;
//     if (firebaseUser == null) {
//       throw Exception("No logged-in user found");
//     }
//
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//     String role = 'User';
//     AppUser? appUser;
//     OrganizationModel? orgModel;
//
//     // 🟩 Try to get from 'users' collection (includes normal users and HR)
//     DocumentSnapshot userDoc =
//     await firestore.collection('users').doc(firebaseUser.uid).get();
//
//     if (userDoc.exists) {
//       final data = userDoc.data() as Map<String, dynamic>;
//       role = data['role'] ?? 'User';
//
//       // ✅ If HR, use HrUser model
//       if (role == 'HR') {
//         final hrUser = HrUser.fromFirestore(userDoc);
//         appUser = hrUser;
//
//         // ✅ Create a lightweight OrganizationModel so HR's organization info appears
//         orgModel = OrganizationModel(
//           id: hrUser.organizationName.toLowerCase().replaceAll(' ', '_'),
//           organizationName: hrUser.organizationName,
//           location: data['organizationLocation'] ?? 'N/A',
//           about: data['organizationAbout'] ?? 'N/A',
//           email: data['organizationEmail'] ?? hrUser.email,
//           organizationDp: data['organizationDp'] ?? '', // ✅ default empty or placeholder URL
//           organizationPics: List<String>.from(data['organizationPics'] ?? []), // ✅ empty list if none
//           role: 'Organization', // ✅ consistent label for organization-like entries
//           timestamp: (data['timestamp'] != null)
//               ? (data['timestamp'] as Timestamp).toDate()
//               : null,
//         );
//
//
//       } else {
//         appUser = AppUser.fromFirestore(userDoc);
//       }
//     }
//
//     // 🟩 Try to get from 'organizations' collection (admins)
//     DocumentSnapshot orgDoc =
//     await firestore.collection('organizations').doc(firebaseUser.uid).get();
//
//     if (orgDoc.exists) {
//       final data = orgDoc.data() as Map<String, dynamic>;
//       orgModel = OrganizationModel.fromMap(data, orgDoc.id);
//
//       appUser = AppUser(
//         uid: orgDoc.id,
//         email: orgModel.email,
//         displayName: orgModel.organizationName,
//       );
//
//       role = 'Admin';
//     }
//
//     if (appUser == null) {
//       throw Exception("User document not found in any collection");
//     }
//
//     return {
//       'user': appUser,
//       'organization': orgModel,
//       'role': role,
//     };
//   }
//
//
//
//
//
//
//   Future<Map<String, dynamic>> _getComplaintSummary(String role) async {
//     User? user = _auth.currentUser;
//     if (user == null) {
//       return {'all': _emptySummary(), 'userOnly': _emptySummary()};
//     }
//
//     try {
//       QuerySnapshot complaintsSnapshot;
//
//       // 🔹 Get current HR or Admin organization name
//       String? orgName;
//       DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
//       if (userDoc.exists) {
//         final data = userDoc.data() as Map<String, dynamic>;
//         orgName = data['organizationName'];
//       }
//
//       // If Admin, check organizations collection
//       if (orgName == null) {
//         DocumentSnapshot orgDoc =
//         await _firestore.collection('organizations').doc(user.uid).get();
//         if (orgDoc.exists) {
//           final orgData = orgDoc.data() as Map<String, dynamic>;
//           orgName = orgData['organizationName'];
//         }
//       }
//
//       // 🔹 CASE 1: Normal User — only see their own complaints
//       if (role == "User") {
//         complaintsSnapshot = await _firestore
//             .collection('complaints')
//             .where('userId', isEqualTo: user.uid)
//             .get();
//       }
//       // 🔹 CASE 2: HR or Admin — only see complaints from their organization
//       else if ((role == 'HR' || role == 'Admin') && orgName != null) {
//         complaintsSnapshot = await _firestore
//             .collection('complaints')
//             .where('institutionName', isEqualTo: orgName)
//             .get();
//       }
//       // fallback
//       else {
//         complaintsSnapshot = await _firestore.collection('complaints').get();
//       }
//
//       Map<String, int> allSummary = _calculateSummaryFromSnapshot(complaintsSnapshot);
//       return {'all': allSummary, 'userOnly': _emptySummary()};
//     } catch (e) {
//       print("Error loading complaints: $e");
//       return {'all': _emptySummary(), 'userOnly': _emptySummary()};
//     }
//   }
//
//
//   Map<String, int> _emptySummary() {
//     return {'Total': 0, 'Pending': 0, 'In Progress': 0, 'Resolved': 0, 'Not Resolved': 0};
//   }
//
//   Map<String, int> _calculateSummaryFromSnapshot(QuerySnapshot complaintsSnapshot) {
//     int total = complaintsSnapshot.docs.length;
//     int pending = 0, inProgress = 0, resolved = 0, notResolved = 0;
//
//     for (var doc in complaintsSnapshot.docs) {
//       var data = doc.data() as Map<String, dynamic>;
//       String status = data['status'] ?? 'Pending';
//       if (status == 'Pending') pending++;
//       else if (status == 'In Progress') inProgress++;
//       else if (status == 'Resolved') resolved++;
//       else if (status == 'Not Resolved') notResolved++;
//     }
//
//     return {
//       'Total': total,
//       'Pending': pending,
//       'In Progress': inProgress,
//       'Resolved': resolved,
//       'Not Resolved': notResolved,
//     };
//   }
//
//   /// 🧱 UI BUILD
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         elevation: 0,
//         foregroundColor: const Color(0xFFFFFFFF),
//
//         centerTitle: true,
//         title: const Text(
//           "Profile",
//           style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF154688), Color(0xFF164889)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _loadUserAndOrganization(),
//         builder: (context, userSnapshot) {
//           if (userSnapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
//             return const Center(child: Text("No user data found."));
//           }
//
//           AppUser user = userSnapshot.data!['user'];
//           OrganizationModel? org = userSnapshot.data!['organization'];
//           String role = userSnapshot.data!['role'];
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildProfileHeader(user.displayName, user.email),
//                 const SizedBox(height: 20),
//
//                 // 🧾 PERSONAL INFORMATION TITLE
//                 const Text(
//                   "Personal Information",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//
//                 // 👤 Show "Full Name" only if NOT organization user
//                 if (org == null)
//                   _buildInfoCard(Icons.person, "Full Name", user.displayName),
//                 if (org == null) const SizedBox(height: 10),
//
//                 _buildInfoCard(Icons.email, "Email", user.email),
//                 const SizedBox(height: 10),
//                 _buildInfoCard(Icons.admin_panel_settings, "Role", role),
//                 const SizedBox(height: 20),
//
//
//                 if (org != null) ...[
//                   const Text(
//                     "Organization Information",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   _buildInfoCard(Icons.business, "Organization Name", org.organizationName),
//
//                   // 🔹 Show location and about ONLY if role is Admin
//                   if (role == 'Admin') _buildInfoCard(Icons.location_on, "Location", org.location),
//                   if (role == 'Admin') _buildInfoCard(Icons.info_outline, "About", org.about),
//
//                   _buildInfoCard(Icons.email_outlined, "Org Email", org.email),
//                   const SizedBox(height: 20),
//                 ],
//
//
//                 // 📊 Complaint Summary Section
//                 const Text(
//                   "Complaint Summary",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//
//                 FutureBuilder<Map<String, dynamic>>(
//                   future: _getComplaintSummary(role),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const CircularProgressIndicator();
//                     } else if (snapshot.hasError) {
//                       return const Text("Error loading complaint summary");
//                     } else if (!snapshot.hasData) {
//                       return const Text("No complaint data found.");
//                     }
//
//                     Map<String, int> allSummary = snapshot.data!['all'];
//
//                     List<Widget> summaryWidgets = [];
//                     summaryWidgets.add(const Text("All Complaints",
//                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
//                     summaryWidgets.addAll(_summaryCards(allSummary));
//
//                     return Column(children: summaryWidgets);
//                   },
//                 ),
//               ],
//             ),
//           );
//
//
//
//         },
//       ),
//     );
//   }
//
//   /// 🧩 Small Widgets
//   List<Widget> _summaryCards(Map<String, int> summary) {
//     return [
//       _buildInfoCard(Icons.list, "Total Complaints", summary['Total'].toString()),
//       _buildInfoCard(Icons.pending, "Pending", summary['Pending'].toString()),
//       _buildInfoCard(Icons.hourglass_top, "In Progress", summary['In Progress'].toString()),
//       _buildInfoCard(Icons.check_circle, "Resolved", summary['Resolved'].toString()),
//       _buildInfoCard(Icons.cancel, "Not Resolved", summary['Not Resolved'].toString()),
//     ];
//   }
//
//   Widget _buildProfileHeader(String fullName, String email) {
//     return Column(
//       children: [
//         Container(
//           decoration: const BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               colors: [Color(0xFF164889), Color(0xFF154688)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           padding: const EdgeInsets.all(4),
//           child: const CircleAvatar(
//             radius: 55,
//             backgroundColor: Colors.white,
//             child: Icon(Icons.person, size: 60, color: Color(0xFF154688)),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Text(fullName,
//             style: const TextStyle(
//                 fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
//         Text(email, style: const TextStyle(fontSize: 14, color: Colors.black54)),
//       ],
//     );
//   }
//
//   Widget _buildInfoCard(IconData icon, String title, String value) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       elevation: 4,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           gradient: const LinearGradient(
//             colors: [Color(0xFF154688), Color(0xFF164889)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: ListTile(
//           leading: CircleAvatar(
//             backgroundColor: Colors.white,
//             child: Icon(icon, color: Color(0xFF154688)),
//           ),
//           title: Text(title,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
//           subtitle:
//           Text(value, style: const TextStyle(fontSize: 14, color: Colors.white70)),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybershield/models/Organization.dart';
import 'package:cybershield/models/Users.dart';
import 'package:cybershield/models/HR.dart';

// ✅ Theme imports
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../themes/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _loadUserAndOrganization() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception("No logged-in user found");
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String role = 'User';
    AppUser? appUser;
    OrganizationModel? orgModel;

    // 🟩 Try to get from 'users' collection (includes normal users and HR)
    DocumentSnapshot userDoc =
    await firestore.collection('users').doc(firebaseUser.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      role = data['role'] ?? 'User';

      // ✅ If HR, use HrUser model
      if (role == 'HR') {
        final hrUser = HrUser.fromFirestore(userDoc);
        appUser = hrUser;

        // ✅ Create a lightweight OrganizationModel so HR's organization info appears
        orgModel = OrganizationModel(
          id: hrUser.organizationName.toLowerCase().replaceAll(' ', '_'),
          organizationName: hrUser.organizationName,
          location: data['organizationLocation'] ?? 'N/A',
          about: data['organizationAbout'] ?? 'N/A',
          email: data['organizationEmail'] ?? hrUser.email,
          role: 'Organization', // ✅ consistent label for organization-like entries
          timestamp: (data['timestamp'] != null)
              ? (data['timestamp'] as Timestamp).toDate()
              : null,
        );


      } else {
        appUser = AppUser.fromFirestore(userDoc);
      }
    }

    // 🟩 Try to get from 'organizations' collection (admins)
    DocumentSnapshot orgDoc =
    await firestore.collection('organizations').doc(firebaseUser.uid).get();

    if (orgDoc.exists) {
      final data = orgDoc.data() as Map<String, dynamic>;
      orgModel = OrganizationModel.fromMap(data, orgDoc.id);

      appUser = AppUser(
        uid: orgDoc.id,
        email: orgModel.email,
        displayName: orgModel.organizationName,
      );

      role = 'Admin';
    }

    if (appUser == null) {
      throw Exception("User document not found in any collection");
    }

    return {
      'user': appUser,
      'organization': orgModel,
      'role': role,
    };
  }

Future<Map<String, dynamic>> _getComplaintSummary(String role) async {
  User? user = _auth.currentUser;
  if (user == null) {
    return {'all': _emptySummary(), 'userOnly': _emptySummary()};
  }

  try {
    QuerySnapshot complaintsSnapshot;

    // 🔹 Get current HR or Admin organization name
    String? orgName;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      orgName = data['organizationName'];
    }

    // If Admin, check organizations collection
    if (orgName == null) {
      DocumentSnapshot orgDoc =
      await _firestore.collection('organizations').doc(user.uid).get();
      if (orgDoc.exists) {
        final orgData = orgDoc.data() as Map<String, dynamic>;
        orgName = orgData['organizationName'];
      }
    }

    // 🔹 CASE 1: Normal User — only see their own complaints
    if (role == "User") {
      complaintsSnapshot = await _firestore
          .collection('complaints')
          .where('userId', isEqualTo: user.uid)
          .get();
    }
    // 🔹 CASE 2: HR or Admin — only see complaints from their organization
    else if ((role == 'HR' || role == 'Admin') && orgName != null) {
      complaintsSnapshot = await _firestore
          .collection('complaints')
          .where('institutionName', isEqualTo: orgName)
          .get();
    }
    // fallback
    else {
      complaintsSnapshot = await _firestore.collection('complaints').get();
    }

    Map<String, int> allSummary = _calculateSummaryFromSnapshot(complaintsSnapshot);
    return {'all': allSummary, 'userOnly': _emptySummary()};
  } catch (e) {
    print("Error loading complaints: $e");
    return {'all': _emptySummary(), 'userOnly': _emptySummary()};
  }
}


  Map<String, int> _emptySummary() {
    return {'Total': 0, 'Pending': 0, 'In Progress': 0, 'Resolved': 0, 'Not Resolved': 0};
  }

Map<String, int> _calculateSummaryFromSnapshot(QuerySnapshot complaintsSnapshot) {
  int total = complaintsSnapshot.docs.length;
  int pending = 0, inProgress = 0, resolved = 0, notResolved = 0;

  for (var doc in complaintsSnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    String status = data['status'] ?? 'Pending';
    if (status == 'Pending') pending++;
    else if (status == 'In Progress') inProgress++;
    else if (status == 'Resolved') resolved++;
    else if (status == 'Not Resolved') notResolved++;
  }

  return {
    'Total': total,
    'Pending': pending,
    'In Progress': inProgress,
    'Resolved': resolved,
    'Not Resolved': notResolved,
  };
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: AppColors.white,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: AppTextStyles.heading, // ✅ applied theme
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadUserAndOrganization(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
            return const Center(child: Text("No user data found."));
          }

          AppUser user = userSnapshot.data!['user'];
          OrganizationModel? org = userSnapshot.data!['organization'];
          String role = userSnapshot.data!['role'];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileHeader(user.displayName, user.email),
                const SizedBox(height: AppDimensions.paddingMedium),

                const Text(
                  "Personal Information",
                  style: AppTextStyles.subHeading,
                ),
                const SizedBox(height: AppDimensions.paddingSmall),

                if (org == null)
                  _buildInfoCard(Icons.person, "Full Name", user.displayName),
                if (org == null) const SizedBox(height: AppDimensions.paddingSmall),

                _buildInfoCard(Icons.email, "Email", user.email),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildInfoCard(Icons.admin_panel_settings, "Role", role),
                const SizedBox(height: AppDimensions.paddingLarge),

                if (org != null) ...[
                  const Text(
                    "Organization Information",
                    style: AppTextStyles.subHeading,
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  _buildInfoCard(Icons.business, "Organization Name", org.organizationName),
                  if (role == 'Admin') _buildInfoCard(Icons.location_on, "Location", org.location),
                  if (role == 'Admin') _buildInfoCard(Icons.info_outline, "About", org.about),
                  _buildInfoCard(Icons.email_outlined, "Org Email", org.email),
                  const SizedBox(height: AppDimensions.paddingLarge),
                ],

                const Text(
                  "Complaint Summary",
                  style: AppTextStyles.subHeading,
                ),
                const SizedBox(height: AppDimensions.paddingSmall),

                FutureBuilder<Map<String, dynamic>>(
                  future: _getComplaintSummary(role),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text("Error loading complaint summary");
                    } else if (!snapshot.hasData) {
                      return const Text("No complaint data found.");
                    }

                    Map<String, int> allSummary = snapshot.data!['all'];

                    List<Widget> summaryWidgets = [];
                    summaryWidgets.add(const Text(
                      "All Complaints",
                      style: AppTextStyles.subHeading,
                    ));
                    summaryWidgets.addAll(_summaryCards(allSummary));

                    return Column(children: summaryWidgets);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _summaryCards(Map<String, int> summary) {
    return [
      _buildInfoCard(Icons.list, "Total Complaints", summary['Total'].toString()),
      _buildInfoCard(Icons.pending, "Pending", summary['Pending'].toString()),
      _buildInfoCard(Icons.hourglass_top, "In Progress", summary['In Progress'].toString()),
      _buildInfoCard(Icons.check_circle, "Resolved", summary['Resolved'].toString()),
      _buildInfoCard(Icons.cancel, "Not Resolved", summary['Not Resolved'].toString()),
    ];
  }

  Widget _buildProfileHeader(String fullName, String email) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: const CircleAvatar(
            radius: AppDimensions.avatarRadius,
            backgroundColor: AppColors.white,
            child: Icon(Icons.person, size: 60, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(fullName, style: AppTextStyles.heading),
        Text(email, style: AppTextStyles.email),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius)),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.white,
            child: Icon(icon, color: AppColors.primary),
          ),
          title: Text(title, style: AppTextStyles.cardTitle),
          subtitle: Text(value, style: AppTextStyles.cardSubtitle),
        ),
      ),
    );
  }
}
