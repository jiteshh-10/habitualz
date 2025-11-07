import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';

class HabitService {
  // Get all habits for a specific user from the subcollection
  Stream<List<Habit>> getUserHabits(String userId) {
    return FirebaseFirestore.instance
        .collection('habits')
        .doc(userId)
        .collection('userHabits')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Habit.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<List<Habit>> getUserHabitsOnce(String userId) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('habits')
          .doc(userId)
          .collection('userHabits')
          .get();

      return snapshot.docs.map((doc) {
        return Habit.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('Error fetching habits: $e');
      return [];
    }
  }

  // Add a new habit to the correct subcollection
  Future<String> addHabit(Habit habit) async {
    final CollectionReference habitCollection = FirebaseFirestore.instance
        .collection('habits')
        .doc(habit.userId)
        .collection('userHabits');
    final docRef = await habitCollection.add(habit.toMap());
    return docRef.id;
  }

  // Delete a habit from the correct subcollection
  Future<void> deleteHabit(String userId, String habitId) async {
    await FirebaseFirestore.instance
        .collection('habits')
        .doc(userId)
        .collection('userHabits')
        .doc(habitId)
        .delete();
  }

  // Mark a habit as complete for a specific day
  Future<void> markHabitComplete(
      String userId, String habitId, String date) async {
    await FirebaseFirestore.instance
        .collection('habits')
        .doc(userId)
        .collection('userHabits')
        .doc(habitId)
        .update({
      'completedDays': FieldValue.arrayUnion([date])
    });
  }

  // Mark a habit as incomplete for a specific day
  Future<void> markHabitIncomplete(
      String userId, String habitId, String date) async {
    await FirebaseFirestore.instance
        .collection('habits')
        .doc(userId)
        .collection('userHabits')
        .doc(habitId)
        .update({
      'completedDays': FieldValue.arrayRemove([date])
    });
  }

  // Get heatmap data for calendar display from the subcollection
  // Optimized: Pre-allocate map and cache parsed dates
  Future<Map<DateTime, int>> getHeatMapData(String userId, {int daysToInclude = 90}) async {
    final Map<DateTime, int> heatMapData = {};
    
    // Pre-allocate the map with zeroes for the date range
    final DateTime today = DateTime.now();
    for (int i = 0; i < daysToInclude; i++) {
      final DateTime date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      heatMapData[date] = 0;
    }

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('habits')
        .doc(userId)
        .collection('userHabits')
        .get();

    if (snapshot.docs.isNotEmpty) {
      final List<Habit> habits = snapshot.docs.map((doc) {
        return Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Optimize: Parse dates only once and normalize to date-only
      for (final habit in habits) {
        for (final dateString in habit.completedDays) {
          try {
            final DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateString);
            // Normalize to midnight for consistent comparison
            final DateTime dateOnly = DateTime(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
            );
            if (heatMapData.containsKey(dateOnly)) {
              heatMapData[dateOnly] = heatMapData[dateOnly]! + 1;
            }
          } catch (e) {
            // Silently skip invalid dates
            print('Warning: Invalid date format in completedDays: $dateString');
          }
        }
      }
    }

    return heatMapData;
  }
}
