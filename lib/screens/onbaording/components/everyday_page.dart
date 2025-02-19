// lib/screens/onboarding/components/everyday_page.dart

import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:habitualz/widgets/common/navigation_button.dart';

class EverydayPage extends StatelessWidget {
  final VoidCallback onNext;

  const EverydayPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AnimatedEmoji(
                AnimatedEmojis.armMechanical,
                size: 80,
              ),
              const SizedBox(height: 40),
              const Text(
                'EVERYDAY',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Starting today!',
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
                icon: Icons.check,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
