import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This line requires the auto-generated file
import 'features/auth/login.dart';

void main() async {
  // This is necessary for Firebase to initialize properly before the app runs
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the auto-generated options file
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        // Optional: A consistent theme for all text fields in the app
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      // The app will always start on the Login Screen
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
