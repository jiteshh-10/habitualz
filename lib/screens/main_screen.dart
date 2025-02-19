// lib/screens/main/main_screen.dart
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitual'),
      ),
      body: const Center(
        child: Text('Main App Screen'),
      ),
    );
  }
}