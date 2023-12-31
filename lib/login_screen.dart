import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab3_mis/main.dart';


class LoginScreen extends StatefulWidget {
  final List<Map<String, String>> predefinedUsers;
  final Function(String email, String password) onLogin;
  final VoidCallback onSkip;
  final List<Map<String, String>> exams;

  const LoginScreen({Key? key, required this.predefinedUsers, required this.onLogin, required this.onSkip, required this.exams})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginWithEmailAndPassword() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        // Successful login, navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle invalid login
        print('Invalid Login');
      }
    } catch (e) {
      // Handle login error here (show error message, etc.)
      print('Login Error: $e');
    }
  }

  void _handleSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ExamList(exams: widget.exams)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _loginWithEmailAndPassword,
              child: Text('Log In'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _handleSkip,
              child: const Text('Skip Login'),
            )
    ],
        ),
      ),
    ),
    );
  }
}
