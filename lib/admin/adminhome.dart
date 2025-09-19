// lib/admin_home.dart
import 'package:flutter/material.dart';
import 'drinkmenu/add_drinks_menu.dart';
import 'add_food_menu.dart';
import 'add_category.dart'; // <-- add this
import 'admin_app_bar.dart';

const kPrimary = Color(0xFFA63334);
const kBg = Color(0xFF2A2928);
const kMuted = Color(0xFFB7B7B6);
const kWhite = Color(0xFFFFFFFF);

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 520;

    return Scaffold(
      appBar: const AdminAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kBg, kPrimary],
            stops: [0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(child: CustomPaint(painter: _DotsPainter())),
            ),
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _SmallBtn(
                    icon: Icons.local_drink,
                    label: 'Add Drinks Menu',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddDrinksMenuPage()),
                    ),
                  ),
                  _SmallBtn(
                    icon: Icons.restaurant_menu,
                    label: 'Add Food Menu',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddFoodMenuPage()),
                    ),
                  ),
                  _SmallBtn(
                    // <-- new button
                    icon: Icons.category,
                    label: 'Add Menu Category',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddCategoryPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: kBg,
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SmallBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: kPrimary),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      style: FilledButton.styleFrom(
        backgroundColor: kWhite,
        foregroundColor: kBg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: const Size(180, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kMuted, width: 1),
        ),
        elevation: 1,
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = kMuted.withOpacity(0.08);
    const gap = 40.0;
    for (double y = 0; y < size.height; y += gap) {
      for (double x = 0; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x + 8, y + 8), 2.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
