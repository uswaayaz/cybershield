import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybershield/models/Users.dart'; // Base AppUser model

class HrUser extends AppUser {
  final String role;
  final String organizationName; // ✅ New field added

  HrUser({
    String? id,
    required String displayName,
    required String email,
    String? uid,
    Timestamp? timestamp,
    required this.organizationName, // ✅ required now
    this.role = 'HR',
  }) : super(
    id: id,
    displayName: displayName,
    email: email,
    uid: uid,
    timestamp: timestamp,
  );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'role': role,
      'organizationName': organizationName, // ✅ Save organization name
    });
    return map;
  }

  factory HrUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HrUser(
      id: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      uid: data['uid'] ?? '',
      timestamp: data['timestamp'],
      organizationName: data['organizationName'] ?? '',
      role: data['role'] ?? 'HR',
    );
  }
}
