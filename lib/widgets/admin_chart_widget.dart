import 'package:flutter/material.dart';

class AdminChartWidget extends StatelessWidget {
  final Map<String, dynamic> stats;
  final String type; // 'status' ou 'priority'

  const AdminChartWidget({
    Key? key,
    required this.stats,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (type == 'status') {
      return _buildStatusChart();
    } else {
      return _buildPriorityChart();
    }
  }

  Widget _buildStatusChart() {
    final done = stats['tasksDone'] ?? 0;
    final inProgress = stats['tasksInProgress'] ?? 0;
    final todo = stats['tasksTodo'] ?? 0;
    final total = done + inProgress + todo;

    if (total == 0) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildProgressBar(
          label: 'Terminées',
          value: done,
          total: total,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        _buildProgressBar(
          label: 'En cours',
          value: inProgress,
          total: total,
          color: Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildProgressBar(
          label: 'À faire',
          value: todo,
          total: total,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildPriorityChart() {
    final high = stats['tasksHigh'] ?? 0;
    final medium = stats['tasksMedium'] ?? 0;
    final low = stats['tasksLow'] ?? 0;
    final total = high + medium + low;

    if (total == 0) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildProgressBar(
          label: 'Haute',
          value: high,
          total: total,
          color: Colors.red,
        ),
        const SizedBox(height: 8),
        _buildProgressBar(
          label: 'Moyenne',
          value: medium,
          total: total,
          color: Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildProgressBar(
          label: 'Basse',
          value: low,
          total: total,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int value,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? value / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(
              '$value ($value/${(percentage * 100).toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}