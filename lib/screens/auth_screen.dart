import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Toggle between login and signup modes
  void _toggleAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = '';
    });
  }

  // Handle regular email & password sign in
  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter both email and password';
          _isLoading = false;
        });
        return;
      }

      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred during sign in';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle email & password sign up
  Future<void> _signUpWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter both email and password';
          _isLoading = false;
        });
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match';
          _isLoading = false;
        });
        return;
      }

      if (_passwordController.text.length < 6) {
        setState(() {
          _errorMessage = 'Password must be at least 6 characters';
          _isLoading = false;
        });
        return;
      }

      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        // Optional: send email verification
        await userCredential.user!.sendEmailVerification();
        
        // Navigate to home screen or onboarding
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred during sign up';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle password reset
  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Failed to send reset email';
      });
    }
  }

  // Handle Google sign in - Enhanced with better error handling
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Begin interactive sign in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in flow
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain auth details from request
      try {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        // Create a new credential for Firebase
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        final UserCredential userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (authError) {
        setState(() {
          _errorMessage = 'Failed to authenticate with Google: $authError';
        });
        // Also try to sign out from Google to clean up the state
        await _googleSignIn.signOut();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // App logo
              const AnimatedEmoji(
                AnimatedEmojis.fire, // 🔥 Fire emoji animation
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'HABITUALZ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 24,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 40),

              // Email field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Password field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Confirm Password field (only shown in signup mode)
              if (!_isLoginMode)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                  ),
                ),

              // Forgot password (only shown in login mode)
              if (_isLoginMode)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

              // Error message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 15),

              // Login/Signup button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _isLoginMode
                          ? _signInWithEmailAndPassword
                          : _signUpWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isLoginMode ? 'Login' : 'Sign Up',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              // Toggle between login and signup
              TextButton(
                onPressed: _toggleAuthMode,
                child: Text(
                  _isLoginMode
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Login',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              // Or sign in with
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade700)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('OR', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade700)),
                ],
              ),

              const SizedBox(height: 20),

              // Google Sign In button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                    height: 24,
                  ),
                  label: const Text(
                    'Sign in with Google',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Terms of service
              const Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}