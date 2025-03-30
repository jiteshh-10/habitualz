// home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../widgets/habit_tile.dart';
import '../widgets/app_drawer.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitService _habitService = HabitService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<List<Habit>> _habitsStream;
  Map<DateTime, int> _heatMapDataSet = {};

  @override
  void initState() {
    super.initState();
    _loadUserHabits();
    _loadHeatMapData();
  }

  void _loadUserHabits() {
    final User? user = _auth.currentUser;
    if (user != null) {
      _habitsStream = _habitService.getUserHabits(user.uid);
    }
  }

  void _loadHeatMapData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final Map<DateTime, int> heatMapData =
          await _habitService.getHeatMapData(user.uid);
      setState(() {
        _heatMapDataSet = heatMapData;
      });
    }
  }

  // Format DateTime for heatmap display
  String _dateTimeToString(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  // Convert DateTime to simpler format for the calendar display
  DateTime _convertDateTimeFromString(String dateString) {
    return DateTime.parse(dateString);
  }

  // Build the heatmap cells
  Widget _buildHeatMapGrid() {
    // Get dates for the last 3 months
    final DateTime today = DateTime.now();
    final List<String> dates = [];

    for (int i = 90; i >= 0; i--) {
      final DateTime date = today.subtract(Duration(days: i));
      dates.add(_dateTimeToString(date));
    }

    // Calculate grid dimensions
    const int rows = 7; // Days of the week
    // ignore: unused_local_variable
    final int cols = (dates.length / rows).ceil();

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habit Tracker',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: MediaQuery.of(context).size.width, // Ensure proper width
            height: 180,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rows,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                // Calculate the actual date
                final int reverseIndex = dates.length - 1 - index;
                final String date = dates[reverseIndex];

                // Get activity level for the date (0 = none, 1-10 for intensity)
                final int activityLevel = 
                _heatMapDataSet[_convertDateTimeFromString(date)] ?? 0;

                // Determine cell color intensity based on activity level
                final Color cellColor = activityLevel == 0
                    ? Colors.grey.shade900
                    : HSLColor.fromAHSL(
                        1.0,
                        120, // Green hue
                        0.8,
                        0.1 +
                            (activityLevel / 10) *
                                0.5, // Lightness varies with activity level
                      ).toColor();

                return Container(
                  width: 10, // Ensure minimum width
                  height: 10, // Ensure minimum height
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Habit heatmap
          _buildHeatMapGrid(),

          Divider(color: Colors.grey.shade800),

          // Habits list
          Expanded(
            child: StreamBuilder<List<Habit>>(
              stream: _habitsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final List<Habit> habits = snapshot.data ?? [];

                if (habits.isEmpty) {
                  return const Center(
                    child: Text(
                      'No habits yet. Add a new habit!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final Habit habit = habits[index];

                    return HabitTile(
                      habit: habit,
                      onTap: () {
                        _toggleHabitCompletion(habit);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Toggle habit completion for today
  void _toggleHabitCompletion(Habit habit) async {
    final String today = _dateTimeToString(DateTime.now());
    final bool isCompleted = habit.completedDays.contains(today);

    if (isCompleted) {
      // Remove today from completed days
      await _habitService.markHabitIncomplete(habit.id, today);
    } else {
      // Add today to completed days
      await _habitService.markHabitComplete(habit.id, today);
    }

    // Refresh heatmap data
    _loadHeatMapData();
  }

  // Show dialog to add a new habit
  void _showAddHabitDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            'Add New Habit',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Habit name',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _addNewHabit(nameController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  // Add a new habit to Firestore
  void _addNewHabit(String name) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final Habit newHabit = Habit(
        id: '',
        userId: user.uid,
        name: name,
        completedDays: [],
        createdAt: DateTime.now(),
      );

      await _habitService.addHabit(newHabit);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh heatmap data
      _loadHeatMapData();
    }
  }
}
