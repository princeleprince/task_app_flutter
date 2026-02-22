import 'package:flutter/material.dart';
import '../models/task.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool? isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onLongPress;

  const TaskCard({
    Key? key,
    required this.task,
    this.isSelected,
    this.onTap,
    this.onToggleComplete,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isSelected == true
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (isSelected != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    isSelected! ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected! ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                ),
              Checkbox(
                value: task.status == TaskStatus.done,
                onChanged: (_) => onToggleComplete?.call(),
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (task.status == TaskStatus.done) {
                    return Colors.green;
                  }
                  return null;
                }),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: task.status == TaskStatus.done
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: task.status == TaskStatus.done
                            ? Colors.grey
                            : null,
                      ),
                    ),
                    if (task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    if (task.dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event,
                              size: 12,
                              color: task.dueDate!.isBefore(DateTime.now()) &&
                                      task.status != TaskStatus.done
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                              style: TextStyle(
                                fontSize: 10,
                                color: task.dueDate!.isBefore(DateTime.now()) &&
                                        task.status != TaskStatus.done
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  PriorityBadge(priority: task.priority),
                  const SizedBox(height: 4),
                  Icon(
                    task.statusIcon,
                    size: 16,
                    color: task.status == TaskStatus.done
                        ? Colors.green
                        : task.status == TaskStatus.inProgress
                            ? Colors.orange
                            : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}