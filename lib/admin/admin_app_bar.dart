// lib/admin_app_bar.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const kPrimary = Color(0xFFA63334);
const kBg = Color(0xFF2A2928);
const kWhite = Color(0xFFFFFFFF);

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;
    final name = (u?.displayName?.trim().isNotEmpty ?? false)
        ? u!.displayName!.trim()
        : 'Admin';

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: kBg,
      foregroundColor: kWhite,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration:
                const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text('Welcome $name',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Log out',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (!context.mounted) return;
            Navigator.popUntil(context, (r) => r.isFirst);
          },
        ),
      ],
    );
  }
}
