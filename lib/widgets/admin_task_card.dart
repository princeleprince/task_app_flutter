import 'package:flutter/material.dart';

class AdminTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDetails;

  const AdminTaskCard({
    Key? key,
    required this.task,
    this.onDelete,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = task['status'];
    final priority = task['priority'];
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'done':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'inProgress':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.radio_button_unchecked;
    }

    Color priorityColor;
    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: priorityColor.withOpacity(0.1),
          child: Icon(statusIcon, color: priorityColor, size: 20),
        ),
        title: Text(
          task['taskPreview'] ?? 'Tâche sans titre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Utilisateur: ${task['userId']}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status == 'done' ? 'Terminée' : 
                    status == 'inProgress' ? 'En cours' : 'À faire',
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priority == 'high' ? 'Haute' :
                    priority == 'medium' ? 'Moyenne' : 'Basse',
                    style: TextStyle(
                      fontSize: 10,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
          tooltip: 'Supprimer cette tâche',
        ),
        onTap: onViewDetails,
      ),
    );
  }
}