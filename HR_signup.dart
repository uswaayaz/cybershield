

import 'package:cybershield/screens/HR/HR_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybershield/screens/HR/HR_login_screen.dart';
class HrSignupScreen extends StatefulWidget {
  const HrSignupScreen({super.key});

  @override
  _HrSignupScreenState createState() => _HrSignupScreenState();
}

class _HrSignupScreenState extends State<HrSignupScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isLoading = false;

  Future<void> _signupHR() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();
    final orgName = _orgController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty || orgName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);


    try {
      // ✅ Step 1: Check if admin assigned this email as HR
      final checkQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'HR')
          .limit(1)
          .get();

      if (checkQuery.docs.isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are not authorized to sign up as HR.")),
        );
        return;
      }

      // ✅ Step 2: Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Signup failed. Try again.");

      // ✅ Step 3: Update Firestore user info
      final userDocId = checkQuery.docs.first.id;
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': name,
        'email': email,
        'organizationName': orgName,
        'role': 'HR',
        'blocked': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // await _firestore.collection('users').doc(userDocId).update({
      //   'uid': user.uid,
      //   'displayName': name,
      //   'organizationName': orgName,
      //   'role': 'HR', // 👈 this is important
      //   'blocked': false,
      //   'timestamp': FieldValue.serverTimestamp(),
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful!")),
      );

      // ✅ Step 4: Navigate to HR dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HrDashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Error: ${e.message}";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------- UI SECTION ----------
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Untitled design1.jpg"), // ✅ Background image
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenWidth > 500 ? 420 : screenWidth * 0.9,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_circle, size: 80, color: Color(0xFF154688)),
                    const SizedBox(height: 16),
                    const Text(
                      'HR Signup',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF154688),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign up to manage your organization HR dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField('Organization Name', Icons.business, _orgController),
                    _buildTextField('Full Name', Icons.person, _nameController),
                    _buildTextField('Email', Icons.email, _emailController),
                    _buildPasswordField('Password', _passwordController, _isPasswordHidden, () {
                      setState(() => _isPasswordHidden = !_isPasswordHidden);
                    }),
                    _buildPasswordField('Confirm Password', _confirmPasswordController, _isConfirmPasswordHidden, () {
                      setState(() => _isConfirmPasswordHidden = !_isConfirmPasswordHidden);
                    }),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signupHR,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF154688),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HrLoginScreen(),
                              ),
                            );
                          },

                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFF154688),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- REUSABLE INPUT FIELDS ----------
  Widget _buildTextField(String hint, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: const Color(0xFF154688)),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF154688), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF154688), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      String hint, TextEditingController controller, bool isHidden, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isHidden,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF154688)),
          suffixIcon: IconButton(
            icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF154688)),
            onPressed: toggleVisibility,
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF154688), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF154688), width: 2),
          ),
        ),
      ),
    );
  }
}
