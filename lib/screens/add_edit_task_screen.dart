import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  
  late Priority _selectedPriority;
  late TaskStatus _selectedStatus;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _categoryController = TextEditingController(text: widget.task?.category ?? '');
    _selectedPriority = widget.task?.priority ?? Priority.medium;
    _selectedStatus = widget.task?.status ?? TaskStatus.todo;
    _selectedDueDate = widget.task?.dueDate;
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      final task = Task(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        status: _selectedStatus,
        priority: _selectedPriority,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        dueDate: _selectedDueDate,
        category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
        userId: authProvider.currentUser!.uid,
      );

      if (widget.task == null) {
        await taskProvider.addTask(task);
      } else {
        await taskProvider.updateTask(task);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Priorité
              const Text(
                'Priorité',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPriorityOption(
                      priority: Priority.high,
                      label: 'Haute',
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityOption(
                      priority: Priority.medium,
                      label: 'Moyenne',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityOption(
                      priority: Priority.low,
                      label: 'Basse',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Statut (si édition)
              if (isEditing) ...[
                const Text(
                  'Statut',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusOption(
                        status: TaskStatus.todo,
                        label: 'À faire',
                        icon: Icons.radio_button_unchecked,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatusOption(
                        status: TaskStatus.inProgress,
                        label: 'En cours',
                        icon: Icons.pending,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatusOption(
                        status: TaskStatus.done,
                        label: 'Terminée',
                        icon: Icons.check_circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Date limite
              const Text(
                'Date limite',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDueDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDueDate == null
                            ? 'Sélectionner une date'
                            : 'Date: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                        style: TextStyle(
                          color: _selectedDueDate == null ? Colors.grey : Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              if (_selectedDueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                          });
                        },
                        child: const Text('Effacer la date'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Catégorie
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Catégorie (optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption({
    required Priority priority,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _selectedPriority == priority
              ? color.withOpacity(0.2)
              : Colors.grey.shade100,
          border: Border.all(
            color: _selectedPriority == priority ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              priority == Priority.high
                  ? Icons.arrow_upward
                  : priority == Priority.medium
                      ? Icons.remove
                      : Icons.arrow_downward,
              color: _selectedPriority == priority ? color : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: _selectedPriority == priority ? color : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required TaskStatus status,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _selectedStatus == status
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          border: Border.all(
            color: _selectedStatus == status
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: _selectedStatus == status
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: _selectedStatus == status
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
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
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}