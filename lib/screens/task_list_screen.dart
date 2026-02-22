import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'add_edit_task_screen.dart';
import 'task_detail_screen.dart';
import 'stats_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.updateSearch(_searchController.text);
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrer par priorité',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Toutes'),
                        selected: taskProvider.selectedPriority == null,
                        onSelected: (_) {
                          taskProvider.updatePriorityFilter(null);
                          Navigator.pop(context);
                        },
                      ),
                      FilterChip(
                        label: const Text('Haute'),
                        selected: taskProvider.selectedPriority == Priority.high,
                        onSelected: (_) {
                          taskProvider.updatePriorityFilter(Priority.high);
                          Navigator.pop(context);
                        },
                        backgroundColor: Colors.red.shade50,
                        selectedColor: Colors.red,
                        labelStyle: TextStyle(
                          color: taskProvider.selectedPriority == Priority.high
                              ? Colors.white 
                              : Colors.red,
                        ),
                      ),
                      FilterChip(
                        label: const Text('Moyenne'),
                        selected: taskProvider.selectedPriority == Priority.medium,
                        onSelected: (_) {
                          taskProvider.updatePriorityFilter(Priority.medium);
                          Navigator.pop(context);
                        },
                        backgroundColor: Colors.orange.shade50,
                        selectedColor: Colors.orange,
                        labelStyle: TextStyle(
                          color: taskProvider.selectedPriority == Priority.medium
                              ? Colors.white 
                              : Colors.orange,
                        ),
                      ),
                      FilterChip(
                        label: const Text('Basse'),
                        selected: taskProvider.selectedPriority == Priority.low,
                        onSelected: (_) {
                          taskProvider.updatePriorityFilter(Priority.low);
                          Navigator.pop(context);
                        },
                        backgroundColor: Colors.green.shade50,
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(
                          color: taskProvider.selectedPriority == Priority.low
                              ? Colors.white 
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Filtrer par statut',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Tous'),
                        selected: taskProvider.selectedStatus == null,
                        onSelected: (_) {
                          taskProvider.updateStatusFilter(null);
                          Navigator.pop(context);
                        },
                      ),
                      FilterChip(
                        label: const Text('À faire'),
                        selected: taskProvider.selectedStatus == TaskStatus.todo,
                        onSelected: (_) {
                          taskProvider.updateStatusFilter(TaskStatus.todo);
                          Navigator.pop(context);
                        },
                      ),
                      FilterChip(
                        label: const Text('En cours'),
                        selected: taskProvider.selectedStatus == TaskStatus.inProgress,
                        onSelected: (_) {
                          taskProvider.updateStatusFilter(TaskStatus.inProgress);
                          Navigator.pop(context);
                        },
                      ),
                      FilterChip(
                        label: const Text('Terminées'),
                        selected: taskProvider.selectedStatus == TaskStatus.done,
                        onSelected: (_) {
                          taskProvider.updateStatusFilter(TaskStatus.done);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (taskProvider.searchQuery.isNotEmpty ||
                      taskProvider.selectedPriority != null ||
                      taskProvider.selectedStatus != null)
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          taskProvider.resetFilters();
                          _searchController.clear();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Réinitialiser les filtres'),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBatchActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${taskProvider.selectedCount} tâche(s) sélectionnée(s)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBatchAction(
                        icon: Icons.check_circle,
                        label: 'Terminer',
                        color: Colors.green,
                        onTap: () {
                          taskProvider.batchUpdateStatus(TaskStatus.done);
                          Navigator.pop(context);
                        },
                      ),
                      _buildBatchAction(
                        icon: Icons.priority_high,
                        label: 'Haute',
                        color: Colors.red,
                        onTap: () {
                          taskProvider.batchUpdatePriority(Priority.high);
                          Navigator.pop(context);
                        },
                      ),
                      _buildBatchAction(
                        icon: Icons.remove_circle,
                        label: 'Moyenne',
                        color: Colors.orange,
                        onTap: () {
                          taskProvider.batchUpdatePriority(Priority.medium);
                          Navigator.pop(context);
                        },
                      ),
                      _buildBatchAction(
                        icon: Icons.low_priority,
                        label: 'Basse',
                        color: Colors.green,
                        onTap: () {
                          taskProvider.batchUpdatePriority(Priority.low);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      _confirmBatchDelete(context);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Supprimer la sélection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBatchAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  void _confirmBatchDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return Text(
              'Voulez-vous vraiment supprimer ${taskProvider.selectedCount} tâche(s) ?',
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final taskProvider = Provider.of<TaskProvider>(context, listen: false);
              await taskProvider.batchDeleteSelected();
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${taskProvider.selectedCount} tâches supprimées'),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    
    // Initialiser le provider avec l'utilisateur
    if (authProvider.currentUser != null && taskProvider.userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        taskProvider.initialize(authProvider.currentUser!.uid);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: taskProvider.isSelectionMode
            ? Text('${taskProvider.selectedCount} sélectionné(s)')
            : const Text('Mes Tâches'),
        actions: [
          if (taskProvider.isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () => taskProvider.selectAll(),
              tooltip: 'Tout sélectionner',
            ),
            IconButton(
              icon: const Icon(Icons.playlist_add_check),
              onPressed: _showBatchActions,
              tooltip: 'Actions groupées',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => taskProvider.toggleSelectionMode(),
              tooltip: 'Quitter le mode sélection',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterMenu,
              tooltip: 'Filtres',
            ),
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () => taskProvider.toggleSelectionMode(),
              tooltip: 'Mode sélection',
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                );
              },
              tooltip: 'Statistiques',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
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
                          taskProvider.updateSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: taskProvider.isLoading
                ? const LoadingWidget(message: 'Chargement des tâches...')
                : taskProvider.error != null
                    ? ErrorDisplayWidget(
                        error: taskProvider.error!,
                        onRetry: () => taskProvider.initialize(authProvider.currentUser!.uid),
                      )
                    : taskProvider.tasks.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () async {
                              taskProvider.initialize(authProvider.currentUser!.uid);
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: taskProvider.tasks.length,
                              itemBuilder: (context, index) {
                                final task = taskProvider.tasks[index];
                                return TaskCard(
                                  task: task,
                                  isSelected: taskProvider.isSelectionMode 
                                      ? taskProvider.isTaskSelected(task.id)
                                      : null,
                                  onTap: taskProvider.isSelectionMode
                                      ? () => taskProvider.toggleTaskSelection(task.id)
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => TaskDetailScreen(task: task),
                                            ),
                                          );
                                        },
                                  onToggleComplete: () => taskProvider.toggleTaskStatus(task),
                                  onLongPress: () {
                                    if (!taskProvider.isSelectionMode) {
                                      taskProvider.toggleSelectionMode();
                                      taskProvider.toggleTaskSelection(task.id);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: taskProvider.isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditTaskScreen(),
                  ),
                );
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tâche ajoutée avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune tâche pour le moment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur le bouton + pour ajouter une tâche',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}