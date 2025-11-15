
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/home_screen.dart';
import 'package:cybershield/models/Users.dart';
import 'package:cybershield/services/auth_service.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isSubmitting = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _signup() async {
    if (!_validateInputs()) return;

    setState(() => _isSubmitting = true);

    try {
      final authService = AuthService();

      AppUser user = await authService.signup(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Future<void> _signup() async {
  //   if (!_validateInputs()) return;
  //
  //   setState(() => _isSubmitting = true);
  //
  //   try {
  //     // 1️⃣ Create user in Firebase Authentication
  //     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //
  //     // 2️⃣ Update display name in Firebase Auth profile
  //     await userCredential.user?.updateDisplayName(_nameController.text.trim());
  //
  //     // 3️⃣ Create AppUser instance using your data class
  //     AppUser newUser = AppUser(
  //       uid: userCredential.user?.uid,
  //       displayName: _nameController.text.trim(),
  //       email: _emailController.text.trim(),
  //       timestamp: Timestamp.now(),
  //     );
  //
  //
  //
  //     // 4️⃣ Save AppUser to Firestore using the model’s `toMap()`
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(newUser.uid)
  //         .set(newUser.toMap());
  //
  //     // 5️⃣ Navigate to HomeScreen if mounted
  //     if (mounted) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const HomeScreen()),
  //       );
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     String errorMessage = 'Signup failed. Please try again.';
  //
  //     switch (e.code) {
  //       case 'email-already-in-use':
  //         errorMessage = 'This email is already registered.';
  //         break;
  //       case 'invalid-email':
  //         errorMessage = 'Please enter a valid email address.';
  //         break;
  //       case 'operation-not-allowed':
  //         errorMessage = 'Email/password accounts are not enabled.';
  //         break;
  //       case 'weak-password':
  //         errorMessage = 'The password is too weak.';
  //         break;
  //     }
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(errorMessage)),
  //     );
  //   } catch (_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('An error occurred. Please try again.')),
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isSubmitting = false);
  //     }
  //   }
  // }




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
            image: AssetImage("assets/Untitled design1.jpg"), // ✅ background image
            fit: BoxFit.cover,
          ),

          // gradient: LinearGradient(
          //   colors: [Color(0xFF56A8DC), Color(0xFF154688)],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenWidth > 500 ? 420 : screenWidth * 0.9,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF154688),
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildTextField('Full Name', Icons.person, _nameController),

                    _buildTextField('Email', Icons.email, _emailController),
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF154688),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.black87),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF154688), width: 1),
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
            icon: Icon(
              isHidden ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF154688),
            ),
            onPressed: toggleVisibility,
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF154688), width: 1),
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
