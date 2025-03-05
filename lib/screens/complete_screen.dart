import 'package:flutter/material.dart';
import 'dart:async';

class CompleteScreen extends StatefulWidget {
  const CompleteScreen({super.key});

  @override
  _CompleteScreenState createState() => _CompleteScreenState();
}

class _CompleteScreenState extends State<CompleteScreen> {
  double _progress = 0.0;
  bool _showCheckmark = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_progress >= 1.0) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _showCheckmark = true;
          });
        });
      } else {
        setState(() {
          _progress += 0.05;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated circular progress with checkmark transition
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 10,
                    color: Colors.grey,
                    backgroundColor: Colors.grey.shade800,
                  ),
                  _showCheckmark
                      ? const Icon(Icons.check, color: Colors.white, size: 50)
                      : Container(), // Empty container until progress completes
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'COMPLETE',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 20),
            const Text(
              'One habit at a time',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            const SizedBox(height: 60),
            // Pagination dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(Colors.grey.shade700),
                const SizedBox(width: 5),
                _buildDot(Colors.white, width: 50),
                const SizedBox(width: 5),
                _buildDot(Colors.grey.shade700),
              ],
            ),
            const SizedBox(height: 60),
            // Next button
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/everyday');
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

  Widget _buildDot(Color color, {double width = 10}) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
