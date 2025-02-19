// lib/screens/onboarding/components/complete_page.dart
import 'package:flutter/material.dart';
import 'package:habitualz/widgets/common/navigation_button.dart';
import 'package:habitualz/widgets/common/circle_progress_painter.dart';

class CompletePage extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onNext;

  const CompletePage({
    super.key,
    required this.animationController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(80, 80),
                    painter: CircleProgressPainter(animationController.value),
                  );
                },
              ),
              const SizedBox(height: 40),
              const Text(
                'COMPLETE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'One habit at a time',
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