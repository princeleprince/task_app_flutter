import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log.dart';

class AuditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter une entrée de log
  Future<void> addLog(AuditLog log) async {
    try {
      await _firestore.collection('audit_logs').add(log.toJson());
    } catch (e) {
      print('Erreur ajout log: $e');
    }
  }

  // Récupérer tous les logs
  Stream<List<AuditLog>> getLogs() {
    return _firestore
        .collection('audit_logs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AuditLog.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  // Récupérer les logs d'un admin spécifique
  Stream<List<AuditLog>> getLogsByAdmin(String adminId) {
    return _firestore
        .collection('audit_logs')
        .where('adminId', isEqualTo: adminId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AuditLog.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  // Récupérer les logs par type d'action
  Stream<List<AuditLog>> getLogsByAction(String action) {
    return _firestore
        .collection('audit_logs')
        .where('action', isEqualTo: action)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AuditLog.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }
}