
 import 'package:cybershield/screens/Feedback&Rating/feedback_Rating.dart';
import 'package:cybershield/screens/HR/HR_deleted_complaints_screen.dart';
import 'package:cybershield/screens/admin/admin_deleted_complaints_screen.dart';
import 'package:cybershield/screens/admin/manage_roles.dart';
import 'package:cybershield/screens/screens/About_us.dart';
import 'package:cybershield/screens/screens/Contact_us.dart';
import 'package:cybershield/screens/screens/Settings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Auth/login_screen.dart';

import '../Chats/hr_list_screen.dart';
import '../screens/profile_screen.dart';
import 'admin_view_complaints_screen.dart';
import 'package:cybershield/screens/Chats/Admin_Chat_Screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    LocationPage(),
    NotificationsPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RatingFeedbackScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        foregroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          "PROTECTU",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF154688), Color(0xFF154688)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: _selectedIndex < _pages.length ? _pages[_selectedIndex] : Container(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF56A8DC), Color(0xFF154688)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Image.asset('assets/bg_logo.png', height: 150),
            ),
          ),
          _buildDrawerItem(Icons.settings, 'Settings', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          }),
          _buildDrawerItem(Icons.info, 'About Us', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutUsScreen()),
            );
          }),
          _buildDrawerItem(Icons.contact_mail, 'Contact Us', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactUsScreen()),
            );
          }),
          _buildDrawerItem(Icons.logout, 'Logout', () => _logout(context)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF154688)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF154688),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF154688), Color(0xFF154688)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        selectedItemColor: Color(0xFFFFFFFF),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Feedback'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> getUserData() async {
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('organizations')
        .doc(user!.uid)
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final orgName = userData?['organizationName'] ?? '';
        final email = userData?['email'] ?? user?.email ?? '';

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/Untitled design5.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Welcome as an Admin of $orgName\n$email",
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF154688),
                      ),
                    ),
                  ),
                Wrap(
                  spacing: 18, // horizontal gap between cards
                  runSpacing: 18, // vertical gap between rows
                  alignment: WrapAlignment.center,
                  children: [
                    _buildOptionCard(Icons.list, 'View Complaints', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminViewComplaintsScreen(),
                        ),
                      );
                    }),
                    _buildOptionCard(Icons.delete, 'Deleted Complaints', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminDeletedComplaintsScreen(),
                        ),
                      );
                    }),
                    _buildOptionCard(Icons.manage_accounts, 'Manage Roles', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageRolesScreen()),
                      );
                    }),
                    _buildOptionCard(Icons.chat, 'Admin Chat', () async {
                      final userData = await getUserData(); // ensure fresh fetch
                      final orgName = userData?['organizationName'] ?? '';

                      if (orgName.trim().isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HRListScreen(orgName: orgName.trim(),),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Organization name not found")),
                        );
                      }
                    }),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF154688), Color(0xFF164889)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black26.withOpacity(0.8),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: Icon(icon, size: 35, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Location Page",
        style: TextStyle(fontSize: 18, color: Color(0xFF154688)),
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Notifications Page",
        style: TextStyle(fontSize: 18, color: Color(0xFF154688)),
      ),
    );
  }
}

class DeleteComplaintScreen extends StatelessWidget {
  const DeleteComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Complaint'),
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
      body: const Center(child: Text('Delete Complaint Screen')),
    );
  }
}
