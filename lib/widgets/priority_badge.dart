import 'package:flutter/material.dart';
import '../models/task.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;

  const PriorityBadge({Key? key, required this.priority}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (priority) {
      case Priority.high:
        color = Colors.red;
        text = 'Haute';
        break;
      case Priority.medium:
        color = Colors.orange;
        text = 'Moyenne';
        break;
      case Priority.low:
        color = Colors.green;
        text = 'Basse';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}