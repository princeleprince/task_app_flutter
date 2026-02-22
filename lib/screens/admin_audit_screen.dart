import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audit_log.dart';
import '../providers/admin_provider.dart';

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({Key? key}) : super(key: key);

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  String _selectedAction = 'all';
  final List<String> _actionTypes = [
    'all',
    AuditLog.ACTION_CREATE_USER,
    AuditLog.ACTION_UPDATE_USER,
    AuditLog.ACTION_DELETE_USER,
    AuditLog.ACTION_CHANGE_ROLE,
    AuditLog.ACTION_DELETE_TASK,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadAuditLogs();
    });
  }

  String _getActionLabel(String action) {
    switch (action) {
      case AuditLog.ACTION_CREATE_USER:
        return 'Création utilisateur';
      case AuditLog.ACTION_UPDATE_USER:
        return 'Modification utilisateur';
      case AuditLog.ACTION_DELETE_USER:
        return 'Suppression utilisateur';
      case AuditLog.ACTION_CHANGE_ROLE:
        return 'Changement de rôle';
      case AuditLog.ACTION_DELETE_TASK:
        return 'Suppression tâche';
      default:
        return action;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case AuditLog.ACTION_CREATE_USER:
        return Colors.green;
      case AuditLog.ACTION_UPDATE_USER:
        return Colors.blue;
      case AuditLog.ACTION_DELETE_USER:
        return Colors.red;
      case AuditLog.ACTION_CHANGE_ROLE:
        return Colors.amber;
      case AuditLog.ACTION_DELETE_TASK:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final logs = _selectedAction == 'all'
        ? adminProvider.auditLogs
        : adminProvider.auditLogs.where((log) => log.action == _selectedAction).toList();

    return Scaffold(
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _actionTypes.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        action == 'all' ? 'Tous' : _getActionLabel(action),
                      ),
                      selected: _selectedAction == action,
                      onSelected: (_) {
                        setState(() {
                          _selectedAction = action;
                        });
                      },
                      selectedColor: _getActionColor(action).withOpacity(0.2),
                      checkmarkColor: _getActionColor(action),
                    ),
                  );
                }).toList(),
              ),
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
                    'Total: ${logs.length} actions',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

          // Liste des logs
          Expanded(
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : logs.isEmpty
                    ? const Center(
                        child: Text('Aucune action journalisée'),
                      )
                    : ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: _getActionColor(log.action).withOpacity(0.1),
                                child: Icon(
                                  Icons.history,
                                  color: _getActionColor(log.action),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                _getActionLabel(log.action),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Par: ${log.adminEmail}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year} ${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (log.targetId != null)
                                        _buildDetailRow(
                                          'Cible',
                                          log.targetId!,
                                        ),
                                      ...log.details.entries.map((entry) {
                                        return _buildDetailRow(
                                          entry.key,
                                          entry.value.toString(),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$key: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}