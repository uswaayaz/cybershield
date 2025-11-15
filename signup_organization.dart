

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../screens/home_screen.dart';
import '../admin/organization_login_screen.dart';
import 'admin_home_screen.dart';
import 'package:cybershield/models/Organization.dart';

class OrganizationSignupScreen extends StatefulWidget {
  const OrganizationSignupScreen({super.key});

  @override
  State<OrganizationSignupScreen> createState() => _OrganizationSignupScreenState();
}

class _OrganizationSignupScreenState extends State<OrganizationSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  Future<void> _signupOrganization() async {
    if (!_validateInputs()) return;

    setState(() => _isSubmitting = true);

    try {
      // ✅ Step 1: Create Firebase Auth User
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user?.uid;

      // ✅ Step 2: Save Organization Info in Firestore
      final organization = OrganizationModel(
        id: uid ?? '',
        organizationName: _orgNameController.text.trim(),
        location: _locationController.text.trim(),
        about: _aboutController.text.trim(),
        email: _emailController.text.trim(),
        role: 'admin',
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('organizations')
          .doc(uid)
          .set(organization.toMap());

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Signup failed. Please try again.';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<String> _uploadImage(File image, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  bool _validateInputs() {
    if (_passwordController.text.length < 8 || _passwordController.text.length > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be between 8 and 12 characters')),
      );
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return false;
    }

    return true;
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
                width: screenWidth > 500 ? 450 : screenWidth * 0.9,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Register Your Organization',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF154688),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField('Organization Name', Icons.business, _orgNameController),
                      _buildTextField('Location', Icons.location_on, _locationController),
                      _buildTextField('About Organization', Icons.info, _aboutController),
                      _buildTextField('Email (Admin)', Icons.email, _emailController),

                      const SizedBox(height: 10),

                      _buildPasswordField(
                        'Password',
                        _passwordController,
                        _isPasswordHidden,
                            () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                      ),

                      _buildPasswordField(
                        'Confirm Password',
                        _confirmPasswordController,
                        _isConfirmPasswordHidden,
                            () => setState(() => _isConfirmPasswordHidden = !_isConfirmPasswordHidden),
                      ),

                      const SizedBox(height: 15),

                      _buildImagePickerSection(),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _signupOrganization,
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
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ✅ Added "Already have an account? Login"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OrganizationLoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Color(0xFF154688),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
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

  Widget _buildPasswordField(
      String hint, TextEditingController controller, bool isHidden, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isHidden,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF154688)),
          suffixIcon: IconButton(
            icon: Icon(
              isHidden ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF154688),
            ),
            onPressed: toggle,
          ),
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

  Widget _buildImagePickerSection() {
    return const Column(
      children: [
        Text(
          "",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF154688),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
