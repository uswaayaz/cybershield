//
// import 'package:cybershield/screens/Feedback&Rating/feedback_Rating.dart';
// import 'package:cybershield/screens/screens/About_us.dart';
// import 'package:cybershield/screens/screens/Contact_us.dart';
// import 'package:cybershield/screens/screens/Settings.dart';
// // import 'package:cybershield/screens/screens/User_Chat_with_HR_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../Auth/login_screen.dart';
// import 'complaint_detail_screen.dart';
// import 'profile_screen.dart';
// import 'view_complaints_screen.dart';
// import 'help_desk_screen.dart';
// import 'Notifications.dart';
//
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//
//   final List<Widget> _pages = [
//     HomePage(),
//     FeedbackPage(),
//     NotificationsPage(),
//   ];
//
//   void _onItemTapped(int index) {
//     if (index == 3) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const ProfileScreen()),
//       );
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const NotificationFragment()),
//       );
//     }
//     else if (index == 1) {
//        Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const RatingFeedbackScreen()),
//       );
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }
//
//   void _logout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginScreen()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFFFF),
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text(
//           "",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF154688), Color(0xFF164889)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       drawer: _buildDrawer(context),
//       body: _selectedIndex < _pages.length ? _pages[_selectedIndex] : Container(),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }
//
//   Widget _buildDrawer(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           Container(
//             height: 180,
//             width: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF56A8DC), Color(0xFF154688)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Center(
//               child: Image.asset('assets/bg_logo.png', height: 150),
//             ),
//           ),
//           _buildDrawerItem(Icons.settings, 'Settings', () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => SettingsScreen()),
//             );
//           }),
//           _buildDrawerItem(Icons.info, 'About Us', () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => AboutUsScreen()),
//             );
//           }),
//           _buildDrawerItem(Icons.contact_mail, 'Contact Us', () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => ContactUsScreen()),
//             );
//           }),
//           _buildDrawerItem(Icons.logout, 'Logout', () => _logout(context)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
//     return ListTile(
//       leading: Icon(icon, color: const Color(0xFF154688)),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           color: Color(0xFF154688),
//         ),
//       ),
//       onTap: onTap,
//     );
//   }
//
//   Widget _buildBottomNav() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF154688), Color(0xFF164889)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 6,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         backgroundColor: Colors.transparent,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.white70,
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         elevation: 0,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Feedback'),
//           BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }
//
// class HomePage extends StatelessWidget {
//   final List<Map<String, dynamic>> mainOptions = [
//     {
//       "title": "View Complaints",
//       "icon": Icons.list,
//       "screen": ViewComplaintsScreen()
//     },
//     // {
//     //   "title": "Chat With HR",
//     //   "icon": Icons.chat,
//     //   "screen": UserChatWithHrScreen()
//     // },
//     {"title": "Help Desk", "icon": Icons.rule, "screen": HelpDeskScreen()},
//   ];
//
//   final List<Map<String, dynamic>> categories = [
//     {"title": "Bullying", "icon": Icons.warning},
//     {"title": "Discrimination", "icon": Icons.people},
//     {"title": "Corruption/ Bribery", "icon": Icons.money},
//     {"title": "Physical Harassment", "icon": Icons.sports_kabaddi},
//     {"title": "Cyber Harassment", "icon": Icons.computer},
//     {"title": "Mental Health Concerns", "icon": Icons.health_and_safety},
//     {"title": "Staff Misconduct", "icon": Icons.badge},
//     {"title": "Violation Of Rules", "icon": Icons.rule},
//     {"title": "Misuse of Power", "icon": Icons.power_settings_new},
//     {"title": "Other(specify)", "icon": Icons.more_horiz},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // --- Main Options Section ---
//           const Text(
//             "Main Options",
//             style: TextStyle(
//               fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF154688),
//             ),
//           ),
//           const SizedBox(height: 12),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: mainOptions.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 2.2,
//             ),
//             itemBuilder: (context, index) {
//               final opt = mainOptions[index];
//               return _buildOptionTile(opt["icon"], opt["title"], () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => opt["screen"]),
//                 );
//               });
//             },
//           ),
//           const SizedBox(height: 24),
//
//           // --- Categories Section ---
//           const Text(
//             "Categories",
//             style: TextStyle(
//               fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF154688),
//             ),
//           ),
//           const SizedBox(height: 12),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: categories.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 1.9,
//             ),
//             itemBuilder: (context, index) {
//               final opt = categories[index];
//               return _buildOptionTile(opt["icon"], opt["title"], () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ComplaintDetailScreen(
//                       preSelectedCategory: opt["title"] == "Other (specify)"
//                           ? null // let user enter manually
//                           : opt["title"],
//                     ),
//                   ),
//                 );
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFF154688), Color(0xFF164889)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 6,
//               offset: const Offset(2, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, size: 30, color: Colors.white),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//                 softWrap: true,
//                 maxLines: 2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class FeedbackPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text(
//         "FeedbackPage",
//         style: TextStyle(fontSize: 18, color: Color(0xFF154688)),
//       ),
//     );
//   }
// }
//
// class NotificationsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text(
//         "Notifications Page",
//         style: TextStyle(fontSize: 18, color: Color(0xFF154688)),
//       ),
//     );
//   }
// }
 import 'package:cybershield/screens/Feedback&Rating/feedback_Rating.dart';
import 'package:cybershield/screens/screens/About_us.dart';
import 'package:cybershield/screens/screens/Contact_us.dart';
import 'package:cybershield/screens/screens/Settings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Auth/login_screen.dart';
import 'complaint_detail_screen.dart';
import 'profile_screen.dart';
import 'view_complaints_screen.dart';
import 'help_desk_screen.dart';
import 'Notifications.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    FeedbackPage(),
    NotificationsPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationFragment()),
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
        elevation: 0,
        foregroundColor: const Color(0xFFFFFFFF),

        title: const Text(
          "PROTECTU",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF154688), Color(0xFF164889)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.2),
        //     blurRadius: 6,
        //     offset: const Offset(0, -2),
        //   ),
        // ],
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
  final List<Map<String, dynamic>> mainOptions = [
    {
      "title": "View Complaints",
      "icon": Icons.list,
      "screen": ViewComplaintsScreen()
    },

    {"title": "Help Desk", "icon": Icons.rule, "screen": HelpDeskScreen()},

  ];

  final List<Map<String, dynamic>> categories = [
    {"title": "Bullying", "icon": Icons.warning},
    {"title": "Discrimination", "icon": Icons.people},
    {"title": "Corruption/ Bribery", "icon": Icons.money},
    {"title": "Physical Harassment", "icon": Icons.sports_kabaddi},
    {"title": "Cyber Harassment", "icon": Icons.computer},
    {"title": "Mental Health Concerns", "icon": Icons.health_and_safety},
    {"title": "Staff Misconduct", "icon": Icons.badge},
    {"title": "Violation Of Rules", "icon": Icons.rule},
    {"title": "Misuse of Power", "icon": Icons.power_settings_new},
    {"title": "Other(specify)", "icon": Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/Untitled design4.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Main Options Section ---
            const Text(
              "Main Options",
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF154688),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mainOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
              ),
              itemBuilder: (context, index) {
                final opt = mainOptions[index];
                return _buildOptionTile(opt["icon"], opt["title"], () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => opt["screen"]),
                  );
                });
              },
            ),
            const SizedBox(height: 24),

            // --- Categories Section ---
            const Text(
              "Categories",
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF154688),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.9,
              ),
              itemBuilder: (context, index) {
                final opt = categories[index];
                return _buildOptionTile(opt["icon"], opt["title"], () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComplaintDetailScreen(
                        preSelectedCategory: opt["title"] == "Other (specify)"
                            ? null
                            : opt["title"],
                      ),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF164889), Color(0xFF164889)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                softWrap: true,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "FeedbackPage",
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
