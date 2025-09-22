import 'package:flutter/material.dart';
import 'features/auth/login.dart'; // Import the new login screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Food App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Define a consistent theme for input fields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // Set the LoginScreen as the first screen the user sees.
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false, // Hides the debug banner
    );
  }
}
