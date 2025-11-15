
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybershield/screens/Chats/Admin_Chat_Screen.dart';

class HRListScreen extends StatefulWidget {
  final String orgName;
  const HRListScreen({super.key, required this.orgName});

  @override
  State<HRListScreen> createState() => _HRListScreenState();
}

class _HRListScreenState extends State<HRListScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        title: Text("HR's of ${widget.orgName}",
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
                hintText: 'Search HR by name or email...',
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

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'HR')
                  .where('organizationName', isEqualTo: widget.orgName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final hrDocs = snapshot.data!.docs;

                if (hrDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No HRs found for this organization.",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                // Filter by search query
                final filteredHrs = hrDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['displayName'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery.toLowerCase()) ||
                      email.contains(searchQuery.toLowerCase());
                }).toList();

                if (filteredHrs.isEmpty) {
                  return const Center(
                    child: Text("No matching HR found."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: filteredHrs.length,
                  itemBuilder: (context, index) {
                    final hrData =
                    filteredHrs[index].data() as Map<String, dynamic>;

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
                            (hrData['displayName']?.substring(0, 1) ?? '?')
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          hrData['displayName'] ?? 'HR',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF154688),
                          ),
                        ),
                        subtitle: Text(
                          hrData['email'] ?? '',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: const Icon(Icons.chat_bubble_outline,
                            color: Color(0xFF154688)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminChatScreen(
                                orgName: widget.orgName,
                                hrId: hrData['uid'] ?? '',
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

