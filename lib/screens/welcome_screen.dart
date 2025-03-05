import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AnimatedEmoji(
                AnimatedEmojis.fire, // 🔥 Fire emoji animation
                size: 80,
              ),
            const SizedBox(height: 40),
            Text(
              'WELCOME',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 20),
            const Text(
              'Let\'s track your life',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            const SizedBox(height: 60),
            // Pagination dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            // Next button
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/complete');
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}