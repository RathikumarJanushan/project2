import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorPrimary = const Color(0xFF0F766E); // teal
    final colorBg = const Color(0xFFF6F8FA);

    return Scaffold(
      backgroundColor: colorBg,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        title: const Text('KopiCue'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, snap) {
            final u = snap.data;
            final name = (u?.displayName?.trim().isNotEmpty ?? false)
                ? u!.displayName!.trim()
                : (u?.email ?? 'Guest');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Hi, $name',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  // Top shortcuts: Rewards | Balance | QR
                  Row(
                    children: [
                      Expanded(
                        child: _TopCard(
                          label: 'Rewards',
                          icon: Icons.loyalty,
                          color: colorPrimary,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TopCard(
                          label: 'Balance',
                          icon: Icons.account_balance_wallet,
                          color: colorPrimary,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TopCard(
                          label: 'QR Scanner',
                          icon: Icons.qr_code_scanner,
                          color: colorPrimary,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Advertisement poster
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Ink.image(
                          image: const NetworkImage(
                            // placeholder ad image
                            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200',
                          ),
                          fit: BoxFit.cover,
                          child: InkWell(onTap: () {}),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dine In / Take Away
                  Row(
                    children: [
                      Expanded(
                        child: _BigActionButton(
                          label: 'Dine In',
                          icon: Icons.restaurant,
                          color: colorPrimary,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BigActionButton(
                          label: 'Take Away',
                          icon: Icons.shopping_bag,
                          color: colorPrimary,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _TopCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _BigActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
