import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext c) {
    final u = FirebaseAuth.instance.currentUser;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(u?.email ?? 'Not signed in', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        if (u == null)
          ElevatedButton(
              onPressed: () => Navigator.pushNamed(c, '/signin'),
              child: const Text('Go to Sign In')),
      ]),
    );
  }
}
