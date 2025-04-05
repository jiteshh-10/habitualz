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

import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAuLs9fsAmSUPMKwkL0JglTajlLrdXWXCk",
        authDomain: "habitualz-531f2.firebaseapp.com",
        projectId: "habitualz-531f2",
        storageBucket: "habitualz-531f2.firebasestorage.app",
        messagingSenderId: "1011121683672",
        appId: "1:1011121683672:web:4043b496f999ba98056bad",
        measurementId: "G-6N74F01JTH",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = true; // Default: dark mode

  // This callback will be passed to SettingsScreen to update the theme.
  void _updateTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habitualz',
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 40),
          titleLarge: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
          titleLarge: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/complete': (context) => const CompleteScreen(),
        '/everyday': (context) => const EverydayScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        // Pass current theme and callback to settings
        '/settings': (context) => SettingsScreen(
              isDarkTheme: _isDarkTheme,
              onThemeChanged: _updateTheme,
            ),
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
            Text('Habitualz',
                style: TextStyle(color: Colors.grey, fontSize: 24)),
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
