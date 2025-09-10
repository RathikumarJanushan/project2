import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'adminhome.dart';

class AdminAppBar extends StatelessWidget {
  const AdminAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : 'admin';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // removes back button
        title: Text('Welcome $name'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.popUntil(context, (r) => r.isFirst);
            },
          ),
        ],
      ),
      body: const AdminHome(),
    );
  }
}
