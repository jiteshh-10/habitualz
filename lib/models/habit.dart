// lib/models/habit.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  String id;
  String name;
  String userId;
  List<String> completedDays;
  DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.userId,
    List<String>? completedDays,
    DateTime? createdAt,
  }) : 
    completedDays = completedDays ?? [],
    createdAt = createdAt ?? DateTime.now();

  // Create a Habit from a Map (for Firestore)
  factory Habit.fromMap(Map<String, dynamic> map, String documentId) {
    return Habit(
      id: documentId,
      name: map['name'] ?? '',
      userId: map['userId'] ?? '',
      completedDays: List<String>.from(map['completedDays'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert Habit to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'completedDays': completedDays,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}