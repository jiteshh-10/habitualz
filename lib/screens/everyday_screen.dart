import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importing the login screen

class EverydayScreen extends StatelessWidget {
  const EverydayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Calendar icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  '30',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'EVERYDAY',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 20),
            const Text(
              'Starting today!',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            const SizedBox(height: 60),
            // Pagination dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(width: 5),
                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            // Complete button navigates to LoginScreen
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
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
