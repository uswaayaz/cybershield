import 'package:cybershield/screens/Chats/hr_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybershield/screens/Chats/Admin_Chat_Screen.dart';

class AdminListScreen extends StatefulWidget {
  final String orgName;
  const AdminListScreen({super.key, required this.orgName});

  @override
  State<AdminListScreen> createState() => _AdminListScreenState();
}

class _AdminListScreenState extends State<AdminListScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        title: Text("Admins of ${widget.orgName}",
            style: const TextStyle(fontWeight: FontWeight.normal)),
        backgroundColor: const Color(0xFF154688),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value.trim()),
              decoration: InputDecoration(
                hintText: 'Search Admin by name or email...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF154688)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📋 Admin List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('organizations')
                  .where('role', isEqualTo: 'admin')
                  .where('organizationName', isEqualTo: widget.orgName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final adminDocs = snapshot.data!.docs;

                if (adminDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Admins found for this organization.",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                // Filter by search query
                final filteredAdmins = adminDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                  (data['displayName'] ?? '').toString().toLowerCase();
                  final email =
                  (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery.toLowerCase()) ||
                      email.contains(searchQuery.toLowerCase());
                }).toList();

                if (filteredAdmins.isEmpty) {
                  return const Center(
                    child: Text("No matching Admin found."),
                  );
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: filteredAdmins.length,
                  itemBuilder: (context, index) {
                    final adminData =
                    filteredAdmins[index].data() as Map<String, dynamic>;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF154688),
                          child: Text(
                            (adminData['displayName']?.substring(0, 1) ?? '?')
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          adminData['displayName'] ?? 'admin',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF154688),
                          ),
                        ),
                        subtitle: Text(
                          adminData['email'] ?? '',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: const Icon(Icons.chat_bubble_outline,
                            color: Color(0xFF154688)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HRChatScreen(
                                orgName: widget.orgName,
                                adminId: adminData['uid'] ?? '',
                              ),
                            ),
                          );
                        },
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
}

