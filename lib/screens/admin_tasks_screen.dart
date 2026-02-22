import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/admin_task_card.dart';

class AdminTasksScreen extends StatefulWidget {
  const AdminTasksScreen({Key? key}) : super(key: key);

  @override
  State<AdminTasksScreen> createState() => _AdminTasksScreenState();
}

class _AdminTasksScreenState extends State<AdminTasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // all, todo, inProgress, done, reported
  List<Map<String, dynamic>> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTasks);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Écouter les changements dans le provider
    final adminProvider = Provider.of<AdminProvider>(context);
    _filterTasksFromProvider(adminProvider.anonymizedTasks);
  }

  void _filterTasks() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    _filterTasksFromProvider(adminProvider.anonymizedTasks);
  }

  void _filterTasksFromProvider(List<Map<String, dynamic>> tasks) {
    setState(() {
      _filteredTasks = tasks.where((task) {
        // Filtre par recherche
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          final preview = task['taskPreview'].toLowerCase();
          if (!preview.contains(query)) {
            return false;
          }
        }

        // Filtre par statut
        if (_selectedFilter != 'all' && _selectedFilter != 'reported') {
          if (task['status'] != _selectedFilter) {
            return false;
          }
        }

        // TODO: Ajout de filtre pour les signalées quand implémenté
        if (_selectedFilter == 'reported') {
          // Pour l'instant, retourne false car pas encore implémenté
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _showDeleteConfirmation(Map<String, dynamic> task) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Supprimer cette tâche ?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cette action sera journalisée.'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Raison de la suppression',
                  hintText: 'Contenu inapproprié, spam, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                reasonController.clear();
                Navigator.of(ctx).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.isNotEmpty) {
                  // Extraire l'userId réel (enlever le préfixe "User_")
                  String userId = task['userId'];
                  if (userId.startsWith('User_')) {
                    userId = userId.replaceAll('User_', '');
                    if (userId.contains('...')) {
                      // Si c'est anonymisé, on ne peut pas supprimer directement
                      if (context.mounted) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Impossible de supprimer une tâche anonymisée'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                      return;
                    }
                  }

                  final success = await adminProvider.deleteAnyTask(
                    userId,
                    task['id'],
                    reasonController.text,
                    authProvider.currentUser!.uid,
                    authProvider.currentUser!.email,
                  );

                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tâche supprimée'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Détails de la tâche'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', task['id']),
                const Divider(),
                _buildDetailRow('Titre', task['taskPreview']),
                const Divider(),
                _buildDetailRow('Statut', _getStatusLabel(task['status'])),
                const Divider(),
                _buildDetailRow('Priorité', _getPriorityLabel(task['priority'])),
                const Divider(),
                _buildDetailRow('Utilisateur', task['userId']),
                if (task['createdAt'] != null) ...[
                  const Divider(),
                  _buildDetailRow('Créée le', _formatDate(task['createdAt'])),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'done':
        return 'Terminée';
      case 'inProgress':
        return 'En cours';
      case 'todo':
        return 'À faire';
      default:
        return 'Inconnu';
    }
  }

  String _getPriorityLabel(String? priority) {
    switch (priority) {
      case 'high':
        return 'Haute';
      case 'medium':
        return 'Moyenne';
      case 'low':
        return 'Basse';
      default:
        return 'Inconnue';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Non spécifiée';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return date.toString();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          // Barre d'outils
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une tâche...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Filtres
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Toutes', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Signalées', 'reported', Colors.red),
                      const SizedBox(width: 8),
                      _buildFilterChip('À faire', 'todo'),
                      const SizedBox(width: 8),
                      _buildFilterChip('En cours', 'inProgress', Colors.orange),
                      const SizedBox(width: 8),
                      _buildFilterChip('Terminées', 'done', Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Statistiques rapides
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total: ${adminProvider.anonymizedTasks.length}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Affichées: ${_filteredTasks.length}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),

          // Liste des tâches
          Expanded(
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune tâche trouvée',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          return AdminTaskCard(
                            task: task,
                            onDelete: () => _showDeleteConfirmation(task),
                            onViewDetails: () => _showTaskDetails(task),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, [Color? color]) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          _filterTasks();
        });
      },
      backgroundColor: color?.withOpacity(0.1),
      selectedColor: color?.withOpacity(0.3) ?? Colors.blue.withOpacity(0.3),
      checkmarkColor: color ?? Colors.blue,
      labelStyle: TextStyle(
        color: _selectedFilter == value ? (color ?? Colors.blue) : Colors.black87,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}