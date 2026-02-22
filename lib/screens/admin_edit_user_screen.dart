import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';

class AdminEditUserScreen extends StatefulWidget {
  final AppUser user;

  const AdminEditUserScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AdminEditUserScreen> createState() => _AdminEditUserScreenState();
}

class _AdminEditUserScreenState extends State<AdminEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late UserRole _selectedRole; // Déclaré comme late
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialisation dans initState
    _nameController = TextEditingController(text: widget.user.displayName);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedRole = widget.user.role; 
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'utilisateur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Avatar (non modifiable)
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: _selectedRole == UserRole.admin 
                      ? Colors.amber 
                      : Colors.blue,
                  child: Text(
                    _nameController.text.isNotEmpty 
                        ? _nameController.text[0].toUpperCase()
                        : _emailController.text[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Email (non modifiable pour des raisons de sécurité)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  enabled: false, // Désactivé
                ),
              ),
              const SizedBox(height: 16),

              // Nom (modifiable)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Rôle
              const Text(
                'Rôle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildRoleOption(
                      role: UserRole.user,
                      label: 'Utilisateur',
                      icon: Icons.person,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRoleOption(
                      role: UserRole.admin,
                      label: 'Administrateur',
                      icon: Icons.admin_panel_settings,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Message d'erreur
              if (adminProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    adminProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 16),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          
                          // Mise à jour du nom
                          if (_nameController.text != widget.user.displayName) {
                            await adminProvider.updateUser(
                              widget.user.uid,
                              {'displayName': _nameController.text},
                              authProvider.currentUser!.uid,
                              authProvider.currentUser!.email,
                            );
                          }
                          
                          // Mise à jour du rôle si changé
                          if (_selectedRole != widget.user.role) {
                            await adminProvider.updateUserRole(
                              widget.user.uid,
                              _selectedRole,
                              authProvider.currentUser!.uid,
                              authProvider.currentUser!.email,
                            );
                          }

                          setState(() => _isLoading = false);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Utilisateur modifié avec succès'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context, true);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required UserRole role,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _selectedRole == role
              ? color.withOpacity(0.2)
              : Colors.grey.shade100,
          border: Border.all(
            color: _selectedRole == role ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: _selectedRole == role ? color : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: _selectedRole == role ? color : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}