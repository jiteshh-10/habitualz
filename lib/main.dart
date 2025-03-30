import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitualz/screens/auth_screen.dart';
import 'dart:async';

// Import screens
import 'screens/welcome_screen.dart';
import 'screens/complete_screen.dart';
import 'screens/everyday_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/analytics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habitualz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
          titleLarge: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/complete': (context) => const CompleteScreen(),
        '/everyday': (context) => const EverydayScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    checkFirstTime();
  }

  void checkFirstTime() async {
  _authStateSubscription =
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      // User is not logged in, show auth screen
      Navigator.pushReplacementNamed(context, '/welcome');
    } else {
      // User is logged in, go to home screen
      Navigator.pushReplacementNamed(context, '/home');
    }
  });
}

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedEmoji(
              AnimatedEmojis.fire, // 🔥 Fire emoji animation
              size: 80,
            ),
            SizedBox(height: 20),
            Text('Habitualz', style: TextStyle(color: Colors.grey, fontSize: 24)),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
