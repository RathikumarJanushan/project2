// lib/signup_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kopicue/app_bar.dart';
import 'signin_page.dart';

class SignUpPage extends StatefulWidget {
  static const route = '/signup';
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _obscure = true;

  Future<void> _signUpEmail() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (_name.text.trim().isNotEmpty) {
        await cred.user?.updateDisplayName(_name.text.trim());
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _busy ? null : _signUpEmail,
              child: _busy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create account'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, SignInPage.route),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
