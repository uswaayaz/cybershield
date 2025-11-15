import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationModel {
  final String id;
  final String organizationName;
  final String location;
  final String about;
  final String email;

  final String role;
  final DateTime? timestamp;

  OrganizationModel({
    required this.id,
    required this.organizationName,
    required this.location,
    required this.about,
    required this.email,

    required this.role,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'organizationName': organizationName,
      'location': location,
      'about': about,
      'email': email,

      'role': role,
      'timestamp': timestamp,
    };
  }

  factory OrganizationModel.fromMap(Map<String, dynamic> data, String id) {
    return OrganizationModel(
      id: id,
      organizationName: data['organizationName'] ?? '',
      location: data['location'] ?? '',
      about: data['about'] ?? '',
      email: data['email'] ?? '',

      role: data['role'] ?? '',
      timestamp: (data['timestamp'] != null)
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
    );
  }
}
