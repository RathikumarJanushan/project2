import 'package:flutter/material.dart';
import 'package:kopicue/startup%20page/signin_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final _slides = [
    {
      'image': 'assets/slide1.png',
      'title': 'Order like a King',
      'text': 'Skip the lines and order your favourite coffee with a few taps.'
    },
    {
      'image': 'assets/slide2.png',
      'title': 'Fast Delivery',
      'text': 'Your coffee, delivered to your table or home quickly.'
    },
    {
      'image': 'assets/slide3.png',
      'title': 'Earn Rewards',
      'text': 'Collect points and enjoy exclusive offers.'
    },
    {
      'image': 'assets/slide4.png',
      'title': 'Stay Connected',
      'text': 'Track your orders and stay updated with new offers.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) {
                final slide = _slides[i];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(slide['image']!, height: 200),
                      const SizedBox(height: 24),
                      Text(
                        slide['title']!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slide['text']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (i) => Container(
                margin: const EdgeInsets.all(4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == i
                      ? const Color(0xFFA26334)
                      : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA26334), // brown shade
                foregroundColor: Colors.white, // text color
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, SignInPage.route);
              },
              child: const Text('Log In'),
            ),
          ),
        ],
      ),
    );
  }
}
