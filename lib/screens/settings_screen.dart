// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/habit_service.dart';
import '../widgets/app_drawer.dart';
import '../models/habit.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkTheme,
    required this.onThemeChanged,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HabitService _habitService = HabitService();
  bool _enableNotifications = true;
  bool _isLoading = false;
  late Stream<List<Habit>> _habitsStream;
  late bool _isDarkTheme;

  @override
  void initState() {
    super.initState();
    _loadUserHabits();
    _isDarkTheme = widget.isDarkTheme; // Initialize from widget value
  }

  void _loadUserHabits() {
    final User? user = _auth.currentUser;
    if (user != null) {
      _habitsStream = _habitService.getUserHabits(user.uid);
    }
  }

  void _deleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Delete Account?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will permanently delete your account and all your habits. This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (shouldDelete == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final User? user = _auth.currentUser;
        if (user != null) {
          final QuerySnapshot habitsSnapshot = await FirebaseFirestore.instance
              .collection('habits')
              .where('userId', isEqualTo: user.uid)
              .get();
          
          final batch = FirebaseFirestore.instance.batch();
          for (final doc in habitsSnapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          await user.delete();
          Navigator.pushReplacementNamed(context, '/auth');
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
        
        if (e.code == 'requires-recent-login') {
          await _auth.signOut();
          Navigator.pushReplacementNamed(context, '/auth');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(),
                    const SizedBox(height: 24),
                    const Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSettingSwitch(
                      'Dark Theme',
                      'Use dark theme throughout the app',
                      _isDarkTheme,
                      (value) {
                        setState(() {
                          _isDarkTheme = value;
                        });
                        widget.onThemeChanged(value);
                      },
                    ),
                    _buildSettingSwitch(
                      'Notifications',
                      'Receive daily reminders for your habits',
                      _enableNotifications,
                      (value) {
                        setState(() {
                          _enableNotifications = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Manage Habits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildHabitsList(),
                    const SizedBox(height: 24),
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAccountOption(
                      'Log Out',
                      'Sign out of your account',
                      Icons.logout,
                      Colors.orange,
                      () async {
                        try {
                          await _auth.signOut();
                          Navigator.pushReplacementNamed(context, '/auth');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error signing out: $e')),
                          );
                        }
                      },
                    ),
                    _buildAccountOption(
                      'Delete Account',
                      'Permanently delete your account and data',
                      Icons.delete_forever,
                      Colors.red,
                      _deleteAccount,
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'HABITUALZ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Version 1.1.0',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    final User? user = _auth.currentUser;
    final String userEmail = user?.email ?? 'User';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userEmail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Account since ${user?.metadata.creationTime?.toString().split(' ')[0] ?? 'Unknown'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.orange,
      ),
    );
  }
  
  Widget _buildHabitsList() {
    return StreamBuilder<List<Habit>>(
      stream: _habitsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
        }
        
        final List<Habit> habits = snapshot.data ?? [];
        
        if (habits.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'No habits yet. Create one from the home screen.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: habits.map((habit) => _buildHabitItem(habit)).toList(),
          ),
        );
      },
    );
  }
  
  Widget _buildHabitItem(Habit habit) {
    return ListTile(
      title: Text(habit.name, style: const TextStyle(color: Colors.white)),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _deleteHabit(habit),
      ),
    );
  }
  
  void _deleteHabit(Habit habit) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Delete Habit?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will permanently delete "${habit.name}" and all its history. This action cannot be undone.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _habitService.deleteHabit(user.uid, habit.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit deleted successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting habit: $e')),
        );
      }
    }
  }
  
  Widget _buildAccountOption(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        onTap: onTap,
      ),
    );
  }
}
