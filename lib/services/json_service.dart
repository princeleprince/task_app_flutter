import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'cache_service.dart';

class JsonService {
  final String _jsonUrl = 'https://api.example.com/tasks.json'; // URL JSON
  final CacheService _cacheService = CacheService();

  Future<List<Task>> fetchTasks({int page = 1, int limit = 10}) async {
    try {
      // Vérifier la connexion
      final response = await http.get(Uri.parse('$_jsonUrl?page=$page&limit=$limit'));
      
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<Task> tasks = jsonData.map((item) => _parseTaskFromJson(item)).toList();
        
        // Mise en cache
        await _cacheService.saveTasks(tasks);
        
        return tasks;
      } else {
        // En cas d'erreur, charger depuis le cache
        return await _cacheService.getCachedTasks();
      }
    } catch (e) {
      // Erreur réseau, charger depuis le cache
      return await _cacheService.getCachedTasks();
    }
  }

  // Fonction pour parser le JSON en Task avec conversion completed -> status
  Task _parseTaskFromJson(Map<String, dynamic> json) {
    // Si le JSON a un champ 'completed' (bool), on le convertit en status
    if (json.containsKey('completed')) {
      bool completed = json['completed'] ?? false;
      TaskStatus status = completed ? TaskStatus.done : TaskStatus.todo;
      
      return Task(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        status: status,
        priority: _parsePriority(json['priority']),
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        category: json['category'],
        userId: json['userId'] ?? '',
      );
    }
    
    // Si le JSON a déjà un champ 'status', on l'utilise directement
    return Task.fromJson(json);
  }

  // Fonction pour parser la priorité
  Priority _parsePriority(dynamic priority) {
    if (priority == null) return Priority.medium;
    
    switch (priority.toString().toLowerCase()) {
      case 'high':
      case 'haute':
      case 'urgent':
        return Priority.high;
      case 'low':
      case 'basse':
        return Priority.low;
      case 'medium':
      case 'moyenne':
      default:
        return Priority.medium;
    }
  }

  // Recherche et filtrage
  List<Task> filterTasks(List<Task> tasks, {
    String? searchQuery,
    TaskStatus? status,
    Priority? priority,
    String? category,
  }) {
    return tasks.where((task) {
      bool matchesSearch = true;
      bool matchesStatus = true;
      bool matchesPriority = true;
      bool matchesCategory = true;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        matchesSearch = task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                       task.description.toLowerCase().contains(searchQuery.toLowerCase());
      }

      if (status != null) {
        matchesStatus = task.status == status;
      }

      if (priority != null) {
        matchesPriority = task.priority == priority;
      }

      if (category != null && category.isNotEmpty) {
        matchesCategory = task.category == category;
      }

      return matchesSearch && matchesStatus && matchesPriority && matchesCategory;
    }).toList();
  }

  // Filtrage par statut (pour compatibilité avec l'ancien code)
  List<Task> filterByCompleted(List<Task> tasks, bool completed) {
    TaskStatus targetStatus = completed ? TaskStatus.done : TaskStatus.todo;
    return tasks.where((task) => task.status == targetStatus).toList();
  }

  // Obtenir les statistiques des tâches JSON
  Map<String, int> getStats(List<Task> tasks) {
    int total = tasks.length;
    int done = tasks.where((t) => t.status == TaskStatus.done).length;
    int inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;
    int todo = total - done - inProgress;
    
    return {
      'total': total,
      'done': done,
      'inProgress': inProgress,
      'todo': todo,
    };
  }
}