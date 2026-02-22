import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class CacheService {
  static const String _tasksBox = 'tasks_cache';
  static const String _timestampBox = 'timestamps';
  
  Box? _box;
  Box? _timestampBoxInstance;

  Future<void> init() async {
    try {
      print('Initialisation Hive...');
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
      
      _box = await Hive.openBox(_tasksBox);
      _timestampBoxInstance = await Hive.openBox(_timestampBox);
      print('Hive initialisé');
    } catch (e) {
      print('Erreur Hive: $e');
    }
  }

  Future<void> saveTask(Task task) async {
    try {
      if (_box == null) await init();
      List<dynamic> tasks = _box?.get('tasks', defaultValue: []) ?? [];
      tasks.add(task.toJson());
      await _box?.put('tasks', tasks);
    } catch (e) {
      print('Erreur sauvegarde: $e');
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      if (_box == null || _timestampBoxInstance == null) {
        await init();
      }
      await _box?.put('tasks', tasks.map((t) => t.toJson()).toList());
      await _timestampBoxInstance?.put('last_sync', DateTime.now().toIso8601String());
      print('Tâches sauvegardées dans cache');
    } catch (e) {
      print('Erreur sauvegarde cache: $e');
    }
  }

  Future<List<Task>> getCachedTasks() async {
    try {
      if (_box == null) {
        await init();
      }
      if (_box?.containsKey('tasks') ?? false) {
        List<dynamic> cachedData = _box?.get('tasks', defaultValue: []) ?? [];
        return cachedData.map((json) => Task.fromJson(json)).toList();
      }
    } catch (e) {
      print('Erreur lecture cache: $e');
    }
    return [];
  }

  Future<void> deleteTask(String taskId) async {
    try {
      if (_box == null) await init();
      List<dynamic> tasks = _box?.get('tasks', defaultValue: []) ?? [];
      tasks.removeWhere((t) => t['id'] == taskId);
      await _box?.put('tasks', tasks);
    } catch (e) {
      print('Erreur suppression: $e');
    }
  }

  DateTime? getLastSyncTime() {
    try {
      String? timestamp = _timestampBoxInstance?.get('last_sync');
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      print('Erreur lecture timestamp: $e');
    }
    return null;
  }

  Future<void> clearCache() async {
    try {
      await _box?.clear();
      await _timestampBoxInstance?.clear();
      print('Cache vidé');
    } catch (e) {
      print('Erreur vidage cache: $e');
    }
  }
}