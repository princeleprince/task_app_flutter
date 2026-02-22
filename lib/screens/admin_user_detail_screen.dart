import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final AppUser user;

  const AdminUserDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
  }

  Future<Map<String, int>> _getUserStats() async {
    // TODO: Récupération des stats utilisateur
    return {
      'total': 0,
      'done': 0,
      'pending': 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.displayName ?? 'Détails utilisateur'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (_isEditing) {
                // Sauvegarder
                await adminProvider.updateUser(
                  widget.user.uid,
                  {'displayName': _nameController.text},
                  authProvider.currentUser!.uid,
                  authProvider.currentUser!.email,
                );
                setState(() => _isEditing = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil mis à jour'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: widget.user.isAdmin ? Colors.amber : Colors.blue,
              child: Text(
                widget.user.displayName?[0].toUpperCase() ?? 
                widget.user.email[0].toUpperCase(),
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Nom
            _isEditing
                ? TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    widget.user.displayName ?? 'Non renseigné',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
            const SizedBox(height: 8),

            // Email
            Text(
              widget.user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),

            // Rôle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.user.isAdmin ? Colors.amber.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.user.isAdmin ? 'Administrateur' : 'Utilisateur',
                style: TextStyle(
                  color: widget.user.isAdmin ? Colors.amber : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Informations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<Map<String, int>>(
                  future: _getUserStats(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final stats = snapshot.data ?? {'total': 0, 'done': 0, 'pending': 0};
                    
                    return Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Inscrit le',
                          value: '${widget.user.createdAt.day}/${widget.user.createdAt.month}/${widget.user.createdAt.year}',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          icon: Icons.task,
                          label: 'Tâches totales',
                          value: stats['total'].toString(),
                        ),
                        const Divider(),
                        _buildInfoRow(
                          icon: Icons.check_circle,
                          label: 'Tâches terminées',
                          value: stats['done'].toString(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions admin
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      widget.user.isAdmin ? Icons.person : Icons.star,
                      color: widget.user.isAdmin ? Colors.amber : Colors.grey,
                    ),
                    title: Text(
                      widget.user.isAdmin 
                          ? 'Rétrograder en utilisateur' 
                          : 'Promouvoir en administrateur',
                    ),
                    onTap: () async {
                      final newRole = widget.user.isAdmin ? UserRole.user : UserRole.admin;
                      await adminProvider.updateUserRole(
                        widget.user.uid,
                        newRole,
                        authProvider.currentUser!.uid,
                        authProvider.currentUser!.email,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              widget.user.isAdmin 
                                  ? 'Utilisateur rétrogradé' 
                                  : 'Utilisateur promu admin'
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Supprimer cet utilisateur'),
                    onTap: () => _showDeleteDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(child: Text(value)),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer ${widget.user.displayName ?? widget.user.email} ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await adminProvider.deleteUser(
                widget.user.uid,
                authProvider.currentUser!.uid,
                authProvider.currentUser!.email,
              );
              if (context.mounted) {
                Navigator.pop(ctx); // Pop dialog
                Navigator.pop(context); // Pop detail screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Utilisateur supprimé'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}