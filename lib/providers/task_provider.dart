import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/cache_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  final CacheService _cacheService = CacheService();
  
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = false;
  bool _isSelectionMode = false;
  Set<String> _selectedTaskIds = {};
  String? _error;
  String _searchQuery = '';
  Priority? _selectedPriority;
  TaskStatus? _selectedStatus;
  String? _userId;

  // Getters publics
  List<Task> get tasks => _filteredTasks;
  bool get isLoading => _isLoading;
  bool get isSelectionMode => _isSelectionMode;
  int get selectedCount => _selectedTaskIds.length;
  String? get error => _error;
  Priority? get selectedPriority => _selectedPriority;
  TaskStatus? get selectedStatus => _selectedStatus;
  String? get userId => _userId;
  String get searchQuery => _searchQuery;
  bool isTaskSelected(String taskId) => _selectedTaskIds.contains(taskId);

  // Initialisation avec l'utilisateur
  void initialize(String userId) {
    _userId = userId;
    _loadTasks();
  }

  // Charger les tâches depuis Firestore
  void _loadTasks() {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    _taskService.getUserTasks(_userId!).listen(
      (tasks) {
        _tasks = tasks;
        _applyFilters();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Ajouter une tâche
  Future<void> addTask(Task task) async {
    try {
      await _taskService.addTask(task);
    } catch (e) {
      _error = 'Erreur ajout: $e';
      notifyListeners();
    }
  }

  // Mettre à jour une tâche
  Future<void> updateTask(Task task) async {
    try {
      await _taskService.updateTask(task);
    } catch (e) {
      _error = 'Erreur mise à jour: $e';
      notifyListeners();
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    try {
      if (_userId != null) {
        await _taskService.deleteTask(_userId!, taskId);
      }
    } catch (e) {
      _error = 'Erreur suppression: $e';
      notifyListeners();
    }
  }

  // Marquer comme terminée / non terminée
  Future<void> toggleTaskStatus(Task task) async {
    TaskStatus newStatus = task.status == TaskStatus.done 
        ? TaskStatus.todo 
        : TaskStatus.done;
    
    final updatedTask = task.copyWith(status: newStatus);
    await updateTask(updatedTask);
  }

  // Mode batch
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedTaskIds.clear();
    }
    notifyListeners();
  }

  void toggleTaskSelection(String taskId) {
    if (_selectedTaskIds.contains(taskId)) {
      _selectedTaskIds.remove(taskId);
    } else {
      _selectedTaskIds.add(taskId);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedTaskIds = _tasks.map((t) => t.id).toSet();
    notifyListeners();
  }

  void clearSelection() {
    _selectedTaskIds.clear();
    notifyListeners();
  }

  // Actions batch
  Future<void> batchDeleteSelected() async {
    for (var id in _selectedTaskIds) {
      await deleteTask(id);
    }
    _selectedTaskIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  Future<void> batchUpdateStatus(TaskStatus newStatus) async {
    for (var id in _selectedTaskIds) {
      final task = _tasks.firstWhere((t) => t.id == id);
      final updated = task.copyWith(status: newStatus);
      await updateTask(updated);
    }
    _selectedTaskIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  Future<void> batchUpdatePriority(Priority newPriority) async {
    for (var id in _selectedTaskIds) {
      final task = _tasks.firstWhere((t) => t.id == id);
      final updated = task.copyWith(priority: newPriority);
      await updateTask(updated);
    }
    _selectedTaskIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  // Filtres
  void updateSearch(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void updatePriorityFilter(Priority? priority) {
    _selectedPriority = priority;
    _applyFilters();
  }

  void updateStatusFilter(TaskStatus? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedPriority = null;
    _selectedStatus = null;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredTasks = _tasks.where((task) {
      if (_searchQuery.isNotEmpty && 
          !task.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !task.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedPriority != null && task.priority != _selectedPriority) {
        return false;
      }
      if (_selectedStatus != null && task.status != _selectedStatus) {
        return false;
      }
      return true;
    }).toList();
  }

  // Obtenir les catégories uniques
  List<String> getCategories() {
    return _tasks
        .where((t) => t.category != null && t.category!.isNotEmpty)
        .map((t) => t.category!)
        .toSet()
        .toList();
  }

  // Statistiques
  Map<String, int> getStats() {
    int total = _tasks.length;
    int todo = _tasks.where((t) => t.status == TaskStatus.todo).length;
    int inProgress = _tasks.where((t) => t.status == TaskStatus.inProgress).length;
    int done = _tasks.where((t) => t.status == TaskStatus.done).length;
    int high = _tasks.where((t) => t.priority == Priority.high).length;
    int medium = _tasks.where((t) => t.priority == Priority.medium).length;
    int low = _tasks.where((t) => t.priority == Priority.low).length;
    
    return {
      'total': total,
      'todo': todo,
      'inProgress': inProgress,
      'done': done,
      'high': high,
      'medium': medium,
      'low': low,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}