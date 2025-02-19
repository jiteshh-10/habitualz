// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:habitualz/screens/main_screen.dart';
import 'package:habitualz/screens/onbaording/components/complete_page.dart';
import 'package:habitualz/screens/onbaording/components/everyday_page.dart';
import 'package:habitualz/screens/onbaording/components/welcome_page.dart';
import 'package:habitualz/widgets/common/page_indicator.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to main app screen after onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()), // Create this screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            physics: const ClampingScrollPhysics(), // Prevents free scrolling
            children: [
              WelcomePage(onNext: _nextPage),
              CompletePage(
                animationController: _animationController,
                onNext: _nextPage,
              ),
              EverydayPage(onNext: _nextPage),
            ],
          ),
          Positioned(
            bottom: 100, // Moved up to make space for the button
            left: 0,
            right: 0,
            child: PageIndicator(currentPage: _currentPage, pageCount: 3),
          ),
        ],
      ),
    );
  }
}