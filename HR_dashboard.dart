
 import 'package:cybershield/screens/Chats/hr_chat_screen.dart';
import 'package:cybershield/screens/Feedback&Rating/feedback_Rating.dart';
import 'package:cybershield/screens/HR/HR_deleted_complaints_screen.dart';
import 'package:cybershield/screens/screens/About_us.dart';
import 'package:cybershield/screens/screens/Contact_us.dart';
import 'package:cybershield/screens/screens/Settings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Auth/login_screen.dart';
import '../screens/profile_screen.dart';
import 'package:cybershield/screens/HR/HR_view_complaints_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybershield/screens/Chats/hr_chat_screen.dart';
 import 'package:cybershield/screens/Chats/Admin_List_Screen.dart';

class HrDashboardScreen extends StatefulWidget {
  const HrDashboardScreen({super.key});

  @override
  _HrDashboardScreenState createState() => _HrDashboardScreenState(

  );
}

class _HrDashboardScreenState extends State<HrDashboardScreen> {
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
      );}
    else if (index == 1) {
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
  void _updateUserUidIfMissing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null && (data['uid'] == null || data['uid'] != user.uid)) {
        await userDoc.update({'uid': user.uid});
        debugPrint("✅ UID field updated for ${user.email}");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _updateUserUidIfMissing(); // update UID automatically
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        foregroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          "PROTECTU",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),
        ),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color( 0xFF154688), Color( 0xFF154688)],
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));

          }),
          _buildDrawerItem(Icons.info, 'About Us', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsScreen()));

          }),
          _buildDrawerItem(Icons.contact_mail, 'Contact Us', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsScreen()));

          }),
          _buildDrawerItem(Icons.logout, 'Logout', () => _logout(context)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF154688)),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF154688))),
      onTap: onTap,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF154688), Color(0xFF164889)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
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
        .collection('users')
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
                      "Organization Name: $orgName\n$email",
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,

                        fontWeight: FontWeight.bold,
                        color: Color(0xFF154688),
                      ),
                    ),
                  ),

                Wrap(
                  spacing: 18, // horizontal space between cards
                  runSpacing: 14, // vertical space between rows
                  alignment: WrapAlignment.center,
                  children: [
                    _buildOptionCard(Icons.list, 'HR View Complaints', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HrViewComplaintsScreen()),
                      );
                    }),
                    _buildOptionCard(Icons.delete, 'Deleted Complaints', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HRDeletedComplaintsScreen()),
                      );
                    }),
                    _buildOptionCard(Icons.chat, 'HR Chat', () async {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser == null) return;

                      try {
                        // Get HR's organizationName
                        final hrDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .get();

                        final orgName = hrDoc.data()?['organizationName'];

                        if (orgName == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Organization name not found.")),
                          );
                          return;
                        }

                        // ✅ FIXED: Find all Admins with the same organizationName
                        final adminQuery = await FirebaseFirestore.instance
                            .collection('organizations')
                            .where('organizationName', isEqualTo: orgName)
                            .where('role', isEqualTo: 'admin')
                            .get();

                        if (adminQuery.docs.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("No Admins found for $orgName.")),
                          );
                          return;
                        }

                        // ✅ Instead of going directly to chat, show list of Admins
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminListScreen(orgName: orgName,),
                          ),
                        );

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    }),
                  ],
                ),

                const SizedBox(height: 20),

                // Existing Option Cards + New Manage Roles Card

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
      child: Container(
        width: 160,
        height: 160,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF154688), Color(0xFF164889)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
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
              backgroundColor: Colors.white24,
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
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
    return const Center(child: Text("Location Page", style: TextStyle(fontSize: 18)));
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Notifications Page", style: TextStyle(fontSize: 18)));
  }
}

// Placeholder screen for Delete Complaint
class DeleteComplaintScreen extends StatelessWidget {
  const DeleteComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Complaint'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
