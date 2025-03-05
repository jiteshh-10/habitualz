// lib/widgets/habit_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final bool showOptions;
  final VoidCallback? onDelete;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onTap,
    this.showOptions = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Check if habit is completed today
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final bool isCompleted = habit.completedDays.contains(today);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            width: 24,
            height: 24,
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
          title: Text(
            habit.name,
            style: TextStyle(
              color: Colors.white,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: showOptions
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: onDelete,
                )
              : null,
        ),
      ),
    );
  }
}