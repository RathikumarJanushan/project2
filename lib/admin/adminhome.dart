import 'package:flutter/material.dart';
import 'add_food_categories.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Admin Home View',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Food Categories'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddFoodCategories()),
              );
            },
          ),
        ],
      ),
    );
  }
}
