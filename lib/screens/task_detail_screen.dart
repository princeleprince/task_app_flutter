import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la tâche'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(task: task),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre et priorité
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: task.priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: task.priorityColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: task.priorityColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.priorityText,
                        style: TextStyle(
                          color: task.priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Statut
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    task.statusIcon,
                    size: 18,
                    color: task.status == TaskStatus.done
                        ? Colors.green
                        : task.status == TaskStatus.inProgress
                            ? Colors.orange
                            : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.statusText,
                    style: TextStyle(
                      color: task.status == TaskStatus.done
                          ? Colors.green
                          : task.status == TaskStatus.inProgress
                              ? Colors.orange
                              : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                task.description.isNotEmpty ? task.description : 'Aucune description',
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Informations supplémentaires
            const Text(
              'Informations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Créée le',
              value: '${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year}',
            ),

            if (task.dueDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.event,
                label: 'Date limite',
                value: '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                color: task.dueDate!.isBefore(DateTime.now()) && task.status != TaskStatus.done
                    ? Colors.red
                    : null,
              ),
            ],

            if (task.category != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.category,
                label: 'Catégorie',
                value: task.category!,
              ),
            ],

            const SizedBox(height: 24),

            // Actions rapides
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: task.status == TaskStatus.done
                        ? Icons.undo
                        : Icons.check_circle,
                    label: task.status == TaskStatus.done
                        ? 'Marquer non terminée'
                        : 'Marquer terminée',
                    color: Colors.green,
                    onTap: () async {
                      final taskProvider = Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      );
                      await taskProvider.toggleTaskStatus(task);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: Text('Voulez-vous vraiment supprimer "${task.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final taskProvider = Provider.of<TaskProvider>(
                context,
                listen: false,
              );
              await taskProvider.deleteTask(task.id);
              if (context.mounted) {
                Navigator.pop(ctx); // Fermer le dialogue
                Navigator.pop(context); // Revenir à la liste
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tâche supprimée'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}