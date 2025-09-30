import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/services/firebase_auth_service.dart';
import '../../core/models/user_role.dart';
import '../student/screens/home.dart';
import '../shop/screens/shopScreen.dart';
import '../admin/screens/adminScreen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final UserRole userRole;

  const EmailVerificationScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = FirebaseAuthService();
  Timer? _timer;
  bool _isLoading = false;
  bool _canResend = true;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkVerificationStatus();
    });
  }

  Future<void> _checkVerificationStatus() async {
    final result = await _authService.checkEmailVerification();

    if (result['success'] && result['verified'] == true) {
      _timer?.cancel();
      if (mounted) {
        _navigateToRoleDashboard();
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    final result = await _authService.sendEmailVerification();

    if (mounted) {
      _showMessage(result['message'], result['success']);

      if (result['success']) {
        setState(() {
          _canResend = false;
          _resendCooldown = 60;
        });

        _startResendCooldown();
      }
    }

    setState(() => _isLoading = false);
  }

  void _startResendCooldown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        timer.cancel();
        if (mounted) {
          setState(() => _canResend = true);
        }
      } else {
        if (mounted) {
          setState(() => _resendCooldown--);
        }
      }
    });
  }

  void _navigateToRoleDashboard() {
    Widget destination;
    switch (widget.userRole) {
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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  void _showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green.shade400 : Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.email_outlined,
                        size: 48,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Verify Your Email',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Resend button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canResend ? _resendVerificationEmail : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          _canResend
                              ? 'Resend Verification Email'
                              : 'Resend in ${_resendCooldown}s',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () async {
                        await _authService.signOut();
                        if (mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                      child: Text(
                        'Sign in with different email',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Check your spam folder if you don\'t see the email in your inbox.',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}