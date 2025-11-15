// 📁 complaint_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String? id; // Firestore document ID
  final String name;
  final String email;
  final String cnic;
  final String phone;
  final String whatsapp;
  final String gender;
  final String occupation;
  final String postalAddress;
  final String city;
  final String complaintDetails;
  final String category;
  final String workplaceType;
  final String institutionName;
  final String department;
  final String? fileUrl;
  final String? userId;
  final Timestamp createdAt;

  Complaint({
    this.id,
    required this.name,
    required this.email,
    required this.cnic,
    required this.phone,
    required this.whatsapp,
    required this.gender,
    required this.occupation,
    required this.postalAddress,
    required this.city,
    required this.complaintDetails,
    required this.category,
    required this.workplaceType,
    required this.institutionName,
    required this.department,
    this.fileUrl,
    this.userId,
    required this.createdAt,
  });

  /// ✅ Convert Firestore document → Complaint object
  factory Complaint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Complaint(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      cnic: data['cnic'] ?? '',
      phone: data['phone'] ?? '',
      whatsapp: data['whatsapp'] ?? '',
      gender: data['gender'] ?? '',
      occupation: data['occupation'] ?? '',
      postalAddress: data['postalAddress'] ?? '',
      city: data['city'] ?? '',
      complaintDetails: data['complaintDetails'] ?? '',
      category: data['category'] ?? '',
      workplaceType: data['workplaceType'] ?? '',
      institutionName: data['institutionName'] ?? '',
      department: data['department'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  /// ✅ Convert Complaint object → JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'cnic': cnic,
      'phone': phone,
      'whatsapp': whatsapp,
      'gender': gender,
      'occupation': occupation,
      'postalAddress': postalAddress,
      'city': city,
      'complaintDetails': complaintDetails,
      'category': category,
      'workplaceType': workplaceType,
      'institutionName': institutionName,
      'department': department,
      'fileUrl': fileUrl,
      'userId': userId,
      'createdAt': createdAt,
    };
  }
}
