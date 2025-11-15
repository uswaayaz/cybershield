// 📁 user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String? id;           // Firestore document ID
  final String displayName;
  final String email;

  final Timestamp? timestamp; // account creation time
  final String? uid;          // Firebase Auth UID

  AppUser({
    this.id,
    required this.displayName,
    required this.email,
    this.timestamp,
     this.uid,
  });

  /// ✅ Create AppUser object from Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      displayName: data['displayName'] ?? '',

      email: data['email'] ?? '',
      timestamp: data['timestamp'],
      uid: data['uid'] ?? '',
    );
  }

  /// ✅ Convert AppUser object → Firestore map
  Map<String, dynamic> toMap() {
    return {
       'displayName': displayName,
      'email': email,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'uid': uid,
    };
  }
}

