import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_chart_widget.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({Key? key}) : super(key: key);

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  String _selectedPeriod = '30j'; // 7j, 30j, 90j, an

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadGlobalStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final stats = adminProvider.globalStats;

    return Scaffold(
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sélecteur de période
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Période: '),
                      const SizedBox(width: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: '7j', label: Text('7j')),
                          ButtonSegment(value: '30j', label: Text('30j')),
                          ButtonSegment(value: '90j', label: Text('90j')),
                          ButtonSegment(value: 'an', label: Text('An')),
                        ],
                        selected: {_selectedPeriod},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            _selectedPeriod = selection.first;
                          });
                          // Recharger les stats pour la période
                          adminProvider.loadGlobalStats();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Cartes statistiques principales
                  const Text(
                    'Statistiques générales',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        title: 'Utilisateurs',
                        value: stats['totalUsers']?.toString() ?? '0',
                        icon: Icons.people,
                        color: Colors.blue,
                        subtitle: 'Total',
                      ),
                      _buildStatCard(
                        title: 'Tâches',
                        value: stats['totalTasks']?.toString() ?? '0',
                        icon: Icons.task,
                        color: Colors.green,
                        subtitle: 'Total',
                      ),
                      _buildStatCard(
                        title: 'Terminées',
                        value: stats['tasksDone']?.toString() ?? '0',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        subtitle: '${((stats['tasksDone'] ?? 0) / (stats['totalTasks'] ?? 1) * 100).toStringAsFixed(1)}%',
                      ),
                      _buildStatCard(
                        title: 'Moyenne/user',
                        value: stats['avgTasksPerUser']?.toString() ?? '0',
                        icon: Icons.analytics,
                        color: Colors.orange,
                        subtitle: 'Tâches par utilisateur',
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Graphiques
                  const Text(
                    'Répartition par statut',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AdminChartWidget(
                        stats: stats,
                        type: 'status',
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Répartition par priorité',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AdminChartWidget(
                        stats: stats,
                        type: 'priority',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Statistiques détaillées
                  const Text(
                    'Détails',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Tâches terminées',
                            stats['tasksDone']?.toString() ?? '0',
                            Colors.green,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            'Tâches en cours',
                            stats['tasksInProgress']?.toString() ?? '0',
                            Colors.orange,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            'Tâches à faire',
                            stats['tasksTodo']?.toString() ?? '0',
                            Colors.grey,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            'Priorité Haute',
                            stats['tasksHigh']?.toString() ?? '0',
                            Colors.red,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            'Priorité Moyenne',
                            stats['tasksMedium']?.toString() ?? '0',
                            Colors.orange,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            'Priorité Basse',
                            stats['tasksLow']?.toString() ?? '0',
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}