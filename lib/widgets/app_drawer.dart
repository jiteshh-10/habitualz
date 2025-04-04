// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final String userEmail = user?.email ?? 'User';

    return Drawer(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            // Drawer header with user info
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 4, 4, 4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    radius: 30,
                    child: Text(
                      userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Drawer items
            ListTile(
              leading: const Icon(Icons.home, color: Colors.grey),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.grey),
              title: const Text('Analytics', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/analytics');
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            
            const Spacer(),
            
            // Logout button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await _auth.signOut();
                      Navigator.pushReplacementNamed(context, '/auth');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error signing out: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}