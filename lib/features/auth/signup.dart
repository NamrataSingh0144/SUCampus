import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/models/user_role.dart';
import 'login.dart';
import '../student/screens/home.dart';
import '../shop/screens/shopScreen.dart';
import '../admin/screens/adminScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers (Confirm Password controller is removed)
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final currentContext = context;
    if (!mounted) return;

    // --- UPDATED VALIDATION LOGIC ---
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(currentContext).showSnackBar(SnackBar(content: const Text('You must agree to the terms and conditions.'), backgroundColor: Colors.red.shade400, behavior: SnackBarBehavior.floating));
      return;
    }
    // Password match check is removed
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(currentContext).showSnackBar(SnackBar(content: const Text('Please fill in all fields.'), backgroundColor: Colors.red.shade400, behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call

    // --- FUTURE FIREBASE LOGIC ---
    // Here you will save the user to Firebase Auth and then
    // save their details (including the role) to Firestore.
    // e.g., 'role': _selectedRole.name

    if (!mounted) return;
    setState(() => _isLoading = false);

    // After successful sign-up, redirect them to their specific dashboard
    _redirectToDashboard(_selectedRole);
  }

  // Helper function to navigate based on role
  void _redirectToDashboard(UserRole role) {
    if (!mounted) return;

    Widget destination;
    switch (role) {
      case UserRole.student:
        destination = const StudentHomeScreen();
        break;
      case UserRole.shop:
        destination = const ShopDashboardScreen();
        break;
      case UserRole.admin:
        destination = const AdminPanelScreen();
        break;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => destination));
  }

  Future<void> _socialSignUp(String provider) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connecting with $provider...'), backgroundColor: Colors.blue.shade400));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: Icon(Icons.person_add_rounded, size: 48, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 16),
                      const Text('Create Account', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Text('Join Campus Connect today!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Username Field
                      TextField(controller: _usernameController, decoration: InputDecoration(labelText: 'Username', hintText: 'Choose a username', prefixIcon: Icon(Icons.person_rounded, color: Colors.grey.shade600), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50)),
                      const SizedBox(height: 16),

                      // Role Selection Dropdown
                      DropdownButtonFormField<UserRole>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'I am a',
                          prefixIcon: Icon(Icons.group_rounded, color: Colors.grey.shade600),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: const [
                          DropdownMenuItem(value: UserRole.student, child: Text('Student')),
                          DropdownMenuItem(value: UserRole.shop, child: Text('Shop')),
                        ],
                        onChanged: (UserRole? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedRole = newValue;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email Address', hintText: 'Enter your email', prefixIcon: Icon(Icons.email_rounded, color: Colors.grey.shade600), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50), keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),

                      // Password Field
                      TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password', hintText: 'Create a password', prefixIcon: Icon(Icons.lock_rounded, color: Colors.grey.shade600), suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey.shade600), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50), obscureText: !_isPasswordVisible),
                      const SizedBox(height: 20),

                      // Terms and Conditions Checkbox
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(value: _agreeToTerms, onChanged: (bool? value) => setState(() => _agreeToTerms = value ?? false), activeColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 8),
                            Expanded(child: RichText(text: TextSpan(style: TextStyle(color: Colors.grey.shade700, fontSize: 14), children: [const TextSpan(text: 'I agree to the '), TextSpan(text: 'Terms & Conditions', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, decoration: TextDecoration.underline), recognizer: TapGestureRecognizer()..onTap = () {/* Navigate to T&Cs */}), const TextSpan(text: ' and '), TextSpan(text: 'Privacy Policy', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, decoration: TextDecoration.underline), recognizer: TapGestureRecognizer()..onTap = () {/* Navigate to Policy */})]))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign Up Button
                      _isLoading ? Container(height: 56, decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.7), borderRadius: BorderRadius.circular(12)), child: const Center(child: CircularProgressIndicator(color: Colors.white))) : ElevatedButton(onPressed: _signUp, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2), child: const Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                      const SizedBox(height: 24),

                      // Divider
                      Row(children: [Expanded(child: Divider(color: Colors.grey.shade300)), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Or sign up with', style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500))), Expanded(child: Divider(color: Colors.grey.shade300))]),
                      const SizedBox(height: 24),

                      // Social Login Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red), onPressed: () => _socialSignUp('Google'), iconSize: 35),
                          const SizedBox(width: 24),
                          IconButton(icon: const FaIcon(FontAwesomeIcons.github, color: Colors.black87), onPressed: () => _socialSignUp('GitHub'), iconSize: 35),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Login Link
                Container(
                  padding: const EdgeInsets.all(16),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87, fontSize: 16),
                      children: <TextSpan>[
                        const TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

