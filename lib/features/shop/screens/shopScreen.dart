import 'package:flutter/material.dart';

class ShopDashboardScreen extends StatelessWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Owner Dashboard'),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Text(
          'Welcome, Shop Owner!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
