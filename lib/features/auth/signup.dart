import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    // A simple placeholder screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        // The back button is automatically added by Navigator
      ),
      body: const Center(
        child: Text(
          'Sign-up page coming soon!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
