import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/app_drawer.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final HabitService _habitService = HabitService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<List<Habit>> _habitsStream;
  
  List<Map<String, dynamic>> _weeklyData = [];
  Map<String, int> _habitCounts = {};
  int _totalCompletions = 0;
  double _completionRate = 0.0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  
  // Cache to avoid recalculating formatted dates
  final List<String> _formattedDates = [];
  final List<DateTime> _lastWeekDates = [];
  
  @override
  void initState() {
    super.initState();
    _initializeDateCache();
    _loadUserHabits();
  }

  void _initializeDateCache() {
    final DateTime today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      _lastWeekDates.add(date);
      _formattedDates.add(DateFormat('yyyy-MM-dd').format(date));
    }
  }

  void _loadUserHabits() {
    final User? user = _auth.currentUser;
    if (user != null) {
      _habitsStream = _habitService.getUserHabits(user.uid);
      _habitsStream.listen((habits) {
        _calculateAnalytics(habits);
      });
    }
  }

  void _calculateAnalytics(List<Habit> habits) {
    if (habits.isEmpty) {
      setState(() {
        _weeklyData = [];
        _habitCounts = {};
        _totalCompletions = 0;
        _completionRate = 0.0;
        _currentStreak = 0;
        _longestStreak = 0;
      });
      return;
    }
    // Reset data
    final Map<String, int> habitCounts = {};
    int totalCompletions = 0;
    
    // Count completions by day and habit
    for (final habit in habits) {
      // Count by habit
      int habitCompletions = 0;
      
      for (final day in _formattedDates) {
        if (habit.completedDays.contains(day)) {
          habitCompletions++;
        }
      }
      
      habitCounts[habit.name] = habitCompletions;
      totalCompletions += habitCompletions;
    }
    
    // Calculate completion rate
    final int totalPossible = habits.length * 7; // 7 days
    final double completionRate = totalPossible > 0 ? (totalCompletions / totalPossible) * 100 : 0;
    
    // Calculate weekly data for chart
    final List<Map<String, dynamic>> weeklyData = [];
    for (int i = 0; i < 7; i++) {
      final String day = DateFormat('E').format(_lastWeekDates[i]); // Get day abbreviation
      final String date = _formattedDates[i];
      
      int completions = 0;
      for (final habit in habits) {
        if (habit.completedDays.contains(date)) {
          completions++;
        }
      }
      
      weeklyData.add({
        'day': day,
        'completions': completions,
        'total': habits.length,
      });
    }
    
    // Calculate streaks
    final streaks = _calculateStreaks(habits);
    
    setState(() {
      _weeklyData = weeklyData;
      _habitCounts = habitCounts;
      _totalCompletions = totalCompletions;
      _completionRate = completionRate;
      _currentStreak = streaks.currentStreak;
      _longestStreak = streaks.longestStreak;
    });
  }

  StreakResult _calculateStreaks(List<Habit> habits) {
    if (habits.isEmpty) return const StreakResult(currentStreak: 0, longestStreak: 0);
    
    final DateTime today = DateTime.now();
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    
    // Optimize: Build set efficiently by adding all habit dates
    final Set<String> completedDatesSet = <String>{};
    for (final habit in habits) {
      completedDatesSet.addAll(habit.completedDays);
    }
    
    // Check for the last 100 days (arbitrary limit)
    for (int i = 0; i < 100; i++) {
      final DateTime checkDate = today.subtract(Duration(days: i));
      final String formattedDate = DateFormat('yyyy-MM-dd').format(checkDate);
      
      if (completedDatesSet.contains(formattedDate)) {
        tempStreak++;
        
        // Current streak only counts consecutive days including today
        if (i == 0) {
          currentStreak = tempStreak;
        }
      } else {
        // Streak broken
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        tempStreak = 0;
        
        // If the first day (today) has no completions, current streak is 0
        if (i == 0) {
          currentStreak = 0;
        }
      }
    }
    
    // Check if the last tempStreak is the longest
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }
    
    return StreakResult(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats cards
              Row(
                children: [
                  _buildStatCard(
                    'Current Streak',
                    '$_currentStreak days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    'Longest Streak',
                    '$_longestStreak days',
                    Icons.emoji_events,
                    Colors.yellow,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    'Completion Rate',
                    '${_completionRate.toStringAsFixed(1)}%',
                    Icons.pie_chart,
                    Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    'Total Completions',
                    '$_totalCompletions',
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Weekly progress
              const Text(
                'Weekly Progress',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:Color.fromARGB(255, 230, 119, 9),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _weeklyData.isEmpty
                    ? const Center(child: Text('No data available'))
                    : _buildWeeklyChart(),
              ),
              
              const SizedBox(height: 24),
              
              // Habit breakdown
              const Text(
                'Habit Breakdown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 230, 119, 9),
                ),
              ),
              const SizedBox(height: 16),
              _habitCounts.isEmpty
                  ? const Center(child: Text('No habits yet'))
                  : _buildHabitBreakdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // Simple bar chart
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _weeklyData.map((data) {
        final double percentage = data['total'] > 0
            ? (data['completions'] / data['total']) * 100
            : 0;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${data['completions']}/${data['total']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              width: 30,
              height: 150 * (percentage / 100),
              color: HSLColor.fromAHSL(
                1.0,
                120, // Green hue
                0.8,
                0.1 + (percentage / 100) * 0.5, // Lightness varies with percentage
              ).toColor(),
            ),
            const SizedBox(height: 8),
            Text(
              data['day'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHabitBreakdown() {
    return Column(
      children: _habitCounts.entries.map((entry) {
        final double percentage = 7 > 0 ? (entry.value / 7) * 100 : 0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(color: Color.fromARGB(255, 230, 119, 9)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${entry.value}/7 days (${percentage.toStringAsFixed(0)}%)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    height: 10,
                    width: (MediaQuery.of(context).size.width * (percentage / 100) - 32).clamp(0, double.infinity), // Ensures width is not negative
                    decoration: BoxDecoration(
                      color: HSLColor.fromAHSL(
                        1.0,
                        120, // Green hue
                        0.8,
                        0.1 + (percentage / 100) * 0.5, // Lightness varies with percentage
                      ).toColor(),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}