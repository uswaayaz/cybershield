
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageRolesScreen extends StatefulWidget {
  const ManageRolesScreen({super.key});

  @override
  State<ManageRolesScreen> createState() => _ManageRolesScreenState();
}

class _ManageRolesScreenState extends State<ManageRolesScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newRoleController = TextEditingController();
  String? _selectedRole;
  final List<String> _roles = ['HR'];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // // Assign role to user
  // void _assignRole() async {
  //   final email = _emailController.text.trim();
  //   String role = _selectedRole ?? '';
  //
  //   if (email.isEmpty || role.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please enter email and select a role")),
  //     );
  //     return;
  //   }
  //
  //   if (role == 'Create New Role') {
  //     role = _newRoleController.text.trim();
  //     if (role.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Please enter new role name")),
  //       );
  //       return;
  //     }
  //   }
  //
  //   try {
  //     final userQuery = await _firestore
  //         .collection('users')
  //         .where('email', isEqualTo: email)
  //         .limit(1)
  //         .get();
  //
  //     if (userQuery.docs.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("No user found with this email")),
  //       );
  //       return;
  //     }
  //
  //     final userDocId = userQuery.docs.first.id;
  //     final blocked = userQuery.docs.first.data()['blocked'] ?? false;
  //
  //     if (blocked) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("This user is blocked from HR access.")),
  //       );
  //       return;
  //     }
  //
  //     await _firestore.collection('users').doc(userDocId).update({
  //       'role': role,
  //       'blocked': false, // unblock when assigning new role
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Role '$role' assigned to $email")),
  //     );
  //
  //     _emailController.clear();
  //     _newRoleController.clear();
  //     setState(() => _selectedRole = null);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: $e")),
  //     );
  //   }
  // }
  void _assignRole() async {
    final email = _emailController.text.trim();
    String role = _selectedRole ?? '';

    if (email.isEmpty || role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and select a role")),
      );
      return;
    }

    if (role == 'Create New Role') {
      role = _newRoleController.text.trim();
      if (role.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter new role name")),
        );
        return;
      }
    }

    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // If user not found, create one for future signup
        await _firestore.collection('users').add({
          'email': email,
          'role': role,
          'blocked': false,
          'organizationName': 'YourOrgName', // optional if needed
          'uid': null, // will be filled when they sign up
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Role '$role' assigned to $email (new record created)")),
        );
      } else {
        // Update existing user
        final userDocId = userQuery.docs.first.id;
        await _firestore.collection('users').doc(userDocId).update({
          'role': role,
          'blocked': false,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Role '$role' updated for $email")),
        );
      }

      _emailController.clear();
      _newRoleController.clear();
      setState(() => _selectedRole = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  // Delete HR role and block the user
  void _deleteHRRole() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email to delete HR role")),
      );
      return;
    }

    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found with this email")),
        );
        return;
      }

      final userDocId = userQuery.docs.first.id;

      // Remove HR role and block user
      await _firestore.collection('users').doc(userDocId).update({
        'role': FieldValue.delete(),
        'blocked': true,
      });

      // Optional: If the user is currently logged in on this device, log them out
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null &&
          currentUser.email == email) {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your HR access has been revoked. Logged out."),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("HR role removed and $email blocked from HR login")),
      );

      _emailController.clear();
      _newRoleController.clear();
      setState(() => _selectedRole = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Roles"),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF154688), Color(0xFF164889)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "User Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: _selectedRole,
              hint: const Text("Select Role"),
              items: _roles.map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedRole = value);
              },
            ),
            if (_selectedRole == 'Create New Role') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _newRoleController,
                decoration: const InputDecoration(
                  labelText: "Enter New Role Name",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _assignRole,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF154688),
                    ),
                    child: const Text(
                      "Assign Role",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteHRRole,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      "Delete HR Role",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
