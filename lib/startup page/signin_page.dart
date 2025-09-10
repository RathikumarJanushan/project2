// lib/signin_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kopicue/app_bar.dart';
import 'signup_page.dart';

class SignInPage extends StatefulWidget {
  static const route = '/signin';
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _err;
  bool _obscure = true;

  Future<void> _loginEmail() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _err = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email
              ],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon:
                      Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_err != null)
              Text(_err!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _busy ? null : _loginEmail,
              child: _busy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Log In'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, SignUpPage.route),
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
