import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import 'admin_users_screen.dart';
import 'admin_tasks_screen.dart';
import 'admin_stats_screen.dart';
import 'admin_audit_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_add_user_screen.dart';  

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard, 'color': Colors.blue},
    {'title': 'Utilisateurs', 'icon': Icons.people, 'color': Colors.green},
    {'title': 'Tâches', 'icon': Icons.task, 'color': Colors.orange},
    {'title': 'Statistiques', 'icon': Icons.bar_chart, 'color': Colors.purple},
    {'title': 'Journal', 'icon': Icons.history, 'color': Colors.teal},
    {'title': 'Catégories', 'icon': Icons.category, 'color': Colors.pink},
    {'title': 'Paramètres', 'icon': Icons.settings, 'color': Colors.grey},
  ];

  final List<Widget> _screens = [
    const _DashboardScreen(),
    const AdminUsersScreen(),
    const AdminTasksScreen(),
    const AdminStatsScreen(),
    const AdminAuditScreen(),
    const AdminCategoriesScreen(),
    const AdminSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panneau d\'administration'),
        backgroundColor: Colors.amber,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, size: 16),
                const SizedBox(width: 4),
                Text(authProvider.currentUser?.email ?? 'Admin'),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Menu latéral
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ...List.generate(_menuItems.length, (index) {
                  return _buildMenuItem(
                    title: _menuItems[index]['title'],
                    icon: _menuItems[index]['icon'],
                    color: _menuItems[index]['color'],
                    isSelected: _selectedIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          
          // Contenu
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dashboard Screen (vue d'ensemble)
class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final stats = adminProvider.globalStats;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vue d\'ensemble',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Cartes statistiques
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: 'Utilisateurs',
                value: stats['totalUsers']?.toString() ?? '0',
                icon: Icons.people,
                color: Colors.blue,
              ),
              _buildStatCard(
                title: 'Tâches totales',
                value: stats['totalTasks']?.toString() ?? '0',
                icon: Icons.task,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Terminées',
                value: stats['tasksDone']?.toString() ?? '0',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Moyenne/user',
                value: stats['avgTasksPerUser']?.toString() ?? '0',
                icon: Icons.analytics,
                color: Colors.orange,
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          const Text(
            'Actions rapides',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 16,
            children: [
              _buildQuickAction(
                title: 'Ajouter un utilisateur',
                icon: Icons.person_add,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminAddUserScreen()),
                  );
                },
              ),
              _buildQuickAction(
                title: 'Voir les signalements',
                icon: Icons.flag,
                color: Colors.red,
                onTap: () {
                  
                },
              ),
              _buildQuickAction(
                title: 'Exporter les données',
                icon: Icons.download,
                color: Colors.blue,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonction à implémenter')),
                  );
                },
              ),
              _buildQuickAction(
                title: 'Nettoyer le cache',
                icon: Icons.cleaning_services,
                color: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonction à implémenter')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
}