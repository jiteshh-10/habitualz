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
  Future<void> markHabitComplete(String userId, String habitId, String date) async {
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
  Future<void> markHabitIncomplete(String userId, String habitId, String date) async {
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
  Future<Map<DateTime, int>> getHeatMapData(String userId) async {
    final Map<DateTime, int> heatMapData = {};
    
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('habits')
        .doc(userId)
        .collection('userHabits')
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      final List<Habit> habits = snapshot.docs.map((doc) {
        return Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
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
