// lib/services/habit_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';

class HabitService {
  final CollectionReference _habitsCollection = FirebaseFirestore.instance.collection('habits');

  // Get all habits for a specific user
  Stream<List<Habit>> getUserHabits(String userId) {
    return _habitsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Add a new habit
  Future<String> addHabit(Habit habit) async {
    final docRef = await _habitsCollection.add(habit.toMap());
    return docRef.id;
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    await _habitsCollection.doc(habitId).delete();
  }

  // Mark a habit as complete for a specific day
  Future<void> markHabitComplete(String habitId, String date) async {
    await _habitsCollection.doc(habitId).update({
      'completedDays': FieldValue.arrayUnion([date])
    });
  }

  // Mark a habit as incomplete for a specific day
  Future<void> markHabitIncomplete(String habitId, String date) async {
    await _habitsCollection.doc(habitId).update({
      'completedDays': FieldValue.arrayRemove([date])
    });
  }

  // Get heatmap data for calendar display
  Future<Map<DateTime, int>> getHeatMapData(String userId) async {
    final Map<DateTime, int> heatMapData = {};
    
    // Get all habits for the user
    final QuerySnapshot snapshot = await _habitsCollection
        .where('userId', isEqualTo: userId)
        .get();
    
    // Collect all completion data
    if (snapshot.docs.isNotEmpty) {
      final List<Habit> habits = snapshot.docs.map((doc) {
        return Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      // Create a map of date to completion count
      for (final habit in habits) {
        for (final dateString in habit.completedDays) {
          final DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);
          if (heatMapData.containsKey(date)) {
            heatMapData[date] = heatMapData[date]! + 1;
          } else {
            heatMapData[date] = 1;
          }
        }
      }
    }
    
    return heatMapData;
  }
}