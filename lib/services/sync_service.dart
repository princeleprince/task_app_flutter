import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/task.dart';
import 'cache_service.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheService _cacheService = CacheService();
  final Connectivity _connectivity = Connectivity();

  Stream<ConnectivityResult> get connectivityStream => 
      _connectivity.onConnectivityChanged;

  Future<void> syncTaskToCloud(Task task) async {
    try {
      await _firestore
          .collection('users')
          .doc(task.userId)
          .collection('tasks')
          .doc(task.id)
          .set({
            'id': task.id,
            'title': task.title,
            'description': task.description,
            'status': task.status.toString().split('.').last,
            'priority': task.priority.toString().split('.').last,
            'createdAt': Timestamp.fromDate(task.createdAt),
            'dueDate': task.dueDate != null ? Timestamp.fromDate(task.dueDate!) : null,
            'category': task.category,
            'userId': task.userId,
          });
      print('Tâche synchronisée: ${task.id}');
    } catch (e) {
      print('Erreur sync: $e');
    }
  }

  Future<void> syncPendingTasks(String userId) async {
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final tasks = await _cacheService.getCachedTasks();
    for (var task in tasks.where((t) => t.userId == userId)) {
      await syncTaskToCloud(task);
    }
  }
}