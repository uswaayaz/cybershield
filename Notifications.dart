import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationFragment extends StatelessWidget {
  const NotificationFragment({super.key});

  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "User"; // default role

    //  Assuming roles are stored in a "users" collection
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()!.containsKey('role')) {
      return doc['role']; // "User", "Admin", "HR"
    } else {
      return "User"; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserRole(),
      builder: (context, roleSnapshot) {
        if (!roleSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        String role = roleSnapshot.data!;
        final currentUser = FirebaseAuth.instance.currentUser!;

        // Choose query based on role
        Stream<QuerySnapshot> notificationStream;
        if (role == "User") {
          notificationStream = FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: currentUser.uid)
              .orderBy('timestamp', descending: true)
              .snapshots();
        } else {
          notificationStream = FirebaseFirestore.instance
              .collection('notifications')
              .where('role', isEqualTo: role.toLowerCase()) // admin / hr
              .orderBy('timestamp', descending: true)
              .snapshots();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("$role Notifications"),
            backgroundColor: Colors.blue,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: notificationStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading notifications"));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No notifications yet"));
              }

              var notifications = snapshot.data!.docs;

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  var doc = notifications[index];
                  var data = doc.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getIconForType(data['type']),
                        color: data['status'] == "unread"
                            ? Colors.red
                            : Colors.blue,
                      ),
                      title: Text(data['title'] ?? "Notification"),
                      subtitle: Text(data['message'] ?? ""),
                      trailing: Text(
                        _formatTime(data['timestamp']),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () async {
                        // 🔹 Mark as read when tapped
                        await FirebaseFirestore.instance
                            .collection('notifications')
                            .doc(doc.id)
                            .update({'status': 'read'});

                        //  Handle navigation (open complaint details, HR/Admin view, etc.)
                        // Navigator.push(...);
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case "complaint":
        return Icons.report;
      case "status":
        return Icons.info;
      case "system":
        return Icons.warning;
      case "reply":
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }
}
