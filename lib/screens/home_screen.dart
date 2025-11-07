// home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // Heatmap data now holds values for the past 90 days.
  Map<DateTime, int> _heatMapDataSet = {};
  List<Habit> _cachedHabits = [];

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
      // Listen to stream to update cache and heatmap
      _habitsStream.listen((habits) {
        _cachedHabits = habits;
        _updateHeatMapFromCache();
      });
    }
  }

  // Load heatmap data for the past 90 days - optimized version
  void _loadHeatMapData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final heatMapData = await _habitService.getHeatMapData(user.uid, daysToInclude: 90);
      setState(() {
        _heatMapDataSet = heatMapData;
      });
    }
  }

  // Update heatmap from cached habits - avoids Firestore query
  void _updateHeatMapFromCache() {
    const int totalDays = 90;
    final Map<DateTime, int> heatMapData = {};
    final DateTime today = DateTime.now();

    // Pre-allocate map
    for (int i = 0; i < totalDays; i++) {
      final DateTime date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      heatMapData[date] = 0;
    }

    // Update the map using cached habits
    for (final habit in _cachedHabits) {
      for (final completedDay in habit.completedDays) {
        try {
          final DateTime completedDate = DateTime.parse(completedDay);
          final DateTime dateOnly = DateTime(
            completedDate.year,
            completedDate.month,
            completedDate.day,
          );
          if (heatMapData.containsKey(dateOnly)) {
            heatMapData[dateOnly] = heatMapData[dateOnly]! + 1;
          }
        } catch (e) {
          // Silently skip invalid dates
        }
      }
    }

    setState(() {
      _heatMapDataSet = heatMapData;
    });
  }

  // Helper to format DateTime as yyyy-MM-dd.
  String _dateTimeToString(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  // Build the heatmap grid.
  //
  // • Uses row‑major order so that the most recent day (index 0) is at the top‑left.
  // • The grid covers 90 days in total but the visible area shows about 32 cells
  //   (4 rows × 8 columns ~ recent 30+ days). The header displays the visible date range.
  // • Horizontal scrolling is enabled if the calculated grid width exceeds the screen.
  // • Vertical scrolling reveals additional rows (older days) if totalDays > visible cells.
  
  Widget _buildHeatMapGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenHeight = MediaQuery.of(context).size.height;
        final double heatmapHeight = screenHeight * 0.33;

        const double spacing = 4.0;
        const int visibleRows = 4;
        const int visibleColumns = 8;

        final double cellSize =
            (heatmapHeight - (visibleRows - 1) * spacing) / visibleRows;

        final double gridWidth =
            (cellSize * visibleColumns) + spacing * (visibleColumns-1);

        const int totalDays = 90;
        final DateTime today = DateTime.now();
        // Cache: Generate days list only once per build
        final List<DateTime> daysList = List.generate(totalDays, (index) {
          return DateTime(today.year, today.month, today.day)
              .subtract(Duration(days: index));
        });

        final DateTime newestVisible = daysList[0];
        final DateTime oldestVisible = daysList[(visibleRows * visibleColumns) - 1];
        final String dateRangeText =
            '${DateFormat('MMM dd').format(newestVisible)} - ${DateFormat('MMM dd').format(oldestVisible)}';

        return Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Habit Tracker',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    dateRangeText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: gridWidth,
                  height: heatmapHeight,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: visibleColumns,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: totalDays,
                    itemBuilder: (context, index) {
                      final DateTime date = daysList[index];
                      final String displayDate =
                          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
                      final int activityLevel = _heatMapDataSet[
                              DateTime(date.year, date.month, date.day)] ??
                          0;
                      // Optimize: Calculate color only when needed
                      final Color cellColor = activityLevel > 0
                          ? HSLColor.fromAHSL(
                              1.0,
                              120,
                              0.8,
                              0.3 + (activityLevel / 10) * 0.2,
                            ).toColor()
                          : Colors.grey.shade900;
                      return Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            displayDate,
                            style: TextStyle(
                              color: activityLevel > 0
                                  ? Colors.white
                                  : Colors.grey.shade400,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          // The heatmap area occupies about 35% of the screen.
          _buildHeatMapGrid(),
          Divider(color: Colors.grey.shade800),
          // The habits list takes the remaining space.
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

  // Toggle habit completion for today - optimized to avoid redundant queries
  void _toggleHabitCompletion(Habit habit) async {
    final String today = _dateTimeToString(DateTime.now());
    final bool isCompleted = habit.completedDays.contains(today);

    if (isCompleted) {
      await _habitService.markHabitIncomplete(habit.userId, habit.id, today);
    } else {
      await _habitService.markHabitComplete(habit.userId, habit.id, today);
    }
    // Heatmap will be updated automatically via the stream listener
  }

  // Show dialog to add a new habit.
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

  // Add a new habit to Firestore - optimized to avoid redundant reload
  void _addNewHabit(String name) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final CollectionReference habitCollection = FirebaseFirestore.instance
          .collection('habits')
          .doc(user.uid)
          .collection('userHabits');
      final DocumentReference docRef = habitCollection.doc();
      final Habit newHabit = Habit(
        id: docRef.id,
        userId: user.uid,
        name: name,
        completedDays: [],
        createdAt: DateTime.now(),
      );
      try {
        await docRef.set(newHabit.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Heatmap will be updated automatically via the stream listener
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding habit: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
