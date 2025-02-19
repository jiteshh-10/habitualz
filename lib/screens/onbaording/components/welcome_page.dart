// lib/screens/onboarding/components/welcome_page.dart

import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:habitualz/widgets/common/navigation_button.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomePage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AnimatedEmoji(
                AnimatedEmojis.fire, // 🔥 Fire emoji animation
                size: 80,
              ),
              const SizedBox(height: 40),
              const Text(
                'WELCOME',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Let\'s track your life',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: NavigationButton(
                onPressed: onNext,
                icon: Icons.arrow_forward,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
