import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybershield/models/Users.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SIGNUP FUNCTION
  Future<AppUser> signup(String name, String email, String password) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = userCredential.user!.uid;

      // Update display name
      await userCredential.user!.updateDisplayName(name.trim());

      // Create AppUser model
      AppUser newUser = AppUser(
        uid: uid,
        displayName: name.trim(),
        email: email.trim(),
        timestamp: Timestamp.now(),
      );

      // Save user in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toMap());

      return newUser;
    } catch (e) {
      throw e.toString();
    }
  }

  // LOGIN FUNCTION
  Future<AppUser?> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Get user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        return AppUser.fromFirestore(userDoc);
      } else {
        return null;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // RESET PASSWORD
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
