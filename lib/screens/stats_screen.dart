import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final stats = taskProvider.getStats();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte résumé
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Total des tâches',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats['total']}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Statistiques par statut
                const Text(
                  'Par statut',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildStatCard(
                  title: 'À faire',
                  count: stats['todo']!,
                  color: Colors.grey,
                  icon: Icons.radio_button_unchecked,
                ),
                _buildStatCard(
                  title: 'En cours',
                  count: stats['inProgress']!,
                  color: Colors.orange,
                  icon: Icons.pending,
                ),
                _buildStatCard(
                  title: 'Terminées',
                  count: stats['done']!,
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),

                const SizedBox(height: 24),

                // Statistiques par priorité
                const Text(
                  'Par priorité',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildStatCard(
                  title: 'Haute',
                  count: stats['high']!,
                  color: Colors.red,
                  icon: Icons.arrow_upward,
                ),
                _buildStatCard(
                  title: 'Moyenne',
                  count: stats['medium']!,
                  color: Colors.orange,
                  icon: Icons.remove,
                ),
                _buildStatCard(
                  title: 'Basse',
                  count: stats['low']!,
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                ),

                const SizedBox(height: 24),

                // Graphique simple en barres
                if (stats['total']! > 0) ...[
                  const Text(
                    'Aperçu visuel',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar(
                    label: 'Terminées',
                    value: stats['done']!,
                    total: stats['total']!,
                    color: Colors.green,
                  ),
                  _buildProgressBar(
                    label: 'En cours',
                    value: stats['inProgress']!,
                    total: stats['total']!,
                    color: Colors.orange,
                  ),
                  _buildProgressBar(
                    label: 'À faire',
                    value: stats['todo']!,
                    total: stats['total']!,
                    color: Colors.grey,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int value,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? value / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}