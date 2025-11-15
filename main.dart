
 import 'package:cybershield/screens/Feedback&Rating/feedback_Rating.dart';
import 'package:cybershield/screens/HR/HR_dashboard.dart';
import 'package:cybershield/screens/HR/HR_view_complaints_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../HR/HR_login_screen.dart';
import 'splash_screen.dart';
import '../Auth/login_screen.dart';
import '../Auth/signup_screen.dart';
import 'home_screen.dart';
import 'complaint_detail_screen.dart';
import 'profile_screen.dart';
import 'view_complaints_screen.dart';
import '../Auth/firebase_options.dart';
import 'Notifications.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CyberShieldApp());

  debugPrint = (String? message, {int? wrapWidth}) {
    if (message == null) return;
    // Only print warnings or errors
    if (message.contains("ERROR") || message.contains("WARN")) {
      print(message);
    }
  };

}




class CyberShieldApp extends StatelessWidget {
  const CyberShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ProtectU',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _handleAuthState(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (context) => const SignupScreen());
          case '/complaint_detail':
            return MaterialPageRoute(builder: (context) => ComplaintDetailScreen());
          case '/profile':
            return MaterialPageRoute(builder: (context) => const ProfileScreen());
          case '/view_complaints':
            return MaterialPageRoute(builder: (context) => ViewComplaintsScreen());
          case '/HR Dashboard':
            return MaterialPageRoute(builder: (context) => HrDashboardScreen());
          case '/HR login':
            return MaterialPageRoute(builder: (context) => HrLoginScreen());


        case '/HrViewComplaintsScreen':
            return MaterialPageRoute(builder: (context) => HrViewComplaintsScreen());
          case '/NotificationsScreen':
            return MaterialPageRoute(builder: (context) => NotificationFragment());
          case '/feedbackScreen':
            return MaterialPageRoute(builder: (context) => RatingFeedbackScreen());




          default:
            return MaterialPageRoute(builder: (context) => const SplashScreen());
        }
      },
    );
  }

  Widget _handleAuthState() {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? const HomeScreen() : const SplashScreen();
  }
}
