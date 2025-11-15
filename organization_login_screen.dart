
import 'package:cybershield/screens/admin/signup_organization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/home_screen.dart';
import 'admin_home_screen.dart'; // Update path if needed
import 'package:cybershield/models/Organization.dart'; // ✅ ADDED


class OrganizationLoginScreen extends StatefulWidget {
  const OrganizationLoginScreen({super.key});

  @override
  State<OrganizationLoginScreen> createState() => _OrganizationLoginScreenState();
}

class _OrganizationLoginScreenState extends State<OrganizationLoginScreen> {
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isSubmitting = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _loginOrganization() async {
    setState(() => _isSubmitting = true);
    try {
      String orgName = _orgNameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      if (orgName.isEmpty || email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields.')),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      // ✅ Step 1: Authenticate user via Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // ✅ Step 2: Check if organization exists in Firestore
      DocumentSnapshot orgDoc = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(uid)
          .get();

      if (!orgDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No organization found with this account.'),
          ),
        );
        await _auth.signOut();
        return;
      }
      // ✅ Step 3: Convert Firestore document to model
      final organization = OrganizationModel.fromMap(   // ✅ NEW
        orgDoc.data() as Map<String, dynamic>,
        orgDoc.id,
      );

      // ✅ Optional: Verify organization name matches the one stored
      if (orgDoc['organizationName'] != orgName) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization name does not match.')),
        );
        await _auth.signOut();
        return;
      }
      // ✅ You can now use this 'organization' object anywhere
      // Example: print(organization.organizationName);
      print('✅ Logged in Organization: ${organization.organizationName}'); // ✅ NEW

      // ✅ Step 3: Navigate to Admin HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
      );

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed. Please try again.';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email.';
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email to reset password.')),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent! Check your inbox.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Untitled design1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenWidth > 500 ? 420 : screenWidth * 0.9,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.business, size: 80, color: Color(0xFF154688)),
                    const SizedBox(height: 10),
                    const Text(
                      'Organization Login',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF154688),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ✅ Organization Name
                    _buildTextField('Organization Name', Icons.apartment, _orgNameController),

                    // ✅ Email and Password fields
                    _buildTextField('Email', Icons.email, _emailController),
                    _buildPasswordField(),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _resetPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Color(0xFF154688)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _loginOrganization,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF154688),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrganizationSignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
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

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF154688)),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _passwordController,
        obscureText: _isPasswordHidden,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF154688)),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF154688),
            ),
            onPressed: () {
              setState(() {
                _isPasswordHidden = !_isPasswordHidden;
              });
            },
          ),
          hintText: 'Password',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}