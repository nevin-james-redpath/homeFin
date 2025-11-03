import 'package:flutter/material.dart';
import 'package:homefin/services/auth_service.dart';
import 'LoginScreen.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool showResendButton = false;
  final _authService = AuthService();

  Future<void> _register() async {
    setState(() {
      loading = true;
      showResendButton = false;
    });

    try {
      final user = await _authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      print(user);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Check your email.'),
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      final errorMsg = e.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $errorMsg')));

      // 👇 Check if the error indicates existing user
      if (errorMsg.toLowerCase().contains('already registered')) {
        setState(() => showResendButton = true);
      }
    }

    setState(() => loading = false);
  }

  Future<void> _resendEmail() async {
    try {
      await _authService.resendVerificationEmail(emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email resent successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Resend failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth * 0.35;
    final screenHeight = MediaQuery.of(context).size.height;
    final formHeight = screenHeight * 0.55;
    final breakHeight = screenHeight * 0.02;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Color.fromARGB(255, 150, 115, 211),
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: formWidth,
              height: formHeight,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/app_icon.png',
                        fit: BoxFit.fitWidth,

                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: breakHeight),
                      const Text(
                        'Create an Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 150, 115, 211),
                        ),
                      ),
                      SizedBox(height: breakHeight),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Username or Email',
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: breakHeight),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: breakHeight),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: loading ? null : _register,
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                      SizedBox(height: breakHeight),
                      ElevatedButton(
                        onPressed: _authService.signInWithGoogle,
                        child: const Text('Sign up with Google'),
                      ),
                      SizedBox(height: breakHeight),
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text("Already have an account? Login"),
                      ),
                      if (showResendButton) ...[
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.email_outlined),
                          onPressed: _resendEmail,
                          label: const Text('Resend Verification Email'),
                        ),
                      ],
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
}
