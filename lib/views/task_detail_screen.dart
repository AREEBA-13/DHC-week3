import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../utils/theme.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final Function(TaskModel) onUpdateTask;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onUpdateTask,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskModel _currentTask;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late TaskPriority _selectedPriority;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _initFormValues();
  }

  void _initFormValues() {
    _titleController = TextEditingController(text: _currentTask.title);
    _descriptionController = TextEditingController(text: _currentTask.description);
    _selectedCategory = _currentTask.category;
    _selectedPriority = _currentTask.priority;
    _selectedDate = _currentTask.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work_rounded;
      case 'Personal':
        return Icons.favorite_rounded;
      case 'Wellness':
        return Icons.spa_rounded;
      case 'Finance':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updated = _currentTask.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _selectedDate,
      );
      
      setState(() {
        _currentTask = updated;
        _isEditing = false;
      });
      
      widget.onUpdateTask(updated);
    }
  }

  void _toggleComplete() {
    widget.onToggleComplete();
    setState(() {
      _currentTask = _currentTask.copyWith(isCompleted: !_currentTask.isCompleted);
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Delete Task?"),
          content: const Text("This action cannot be undone. Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Dismiss Dialog
                widget.onDelete(); // Trigger delete action
                Navigator.of(context).pop(); // Back to Home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.priorityHigh,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = AppColors.categories[_currentTask.category] ?? AppColors.categories['Other']!;
    final priorityColor = _getPriorityColor(_currentTask.priority);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Task" : "Task Details"),
        actions: [
          if (!_isEditing) ...[
            // Edit Button
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  _initFormValues();
                });
              },
              tooltip: "Edit",
            ),
            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.priorityHigh),
              onPressed: _confirmDelete,
              tooltip: "Delete",
            ),
          ] else ...[
            // Cancel Editing
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
              tooltip: "Cancel",
            ),
            // Save Editing
            IconButton(
              icon: const Icon(Icons.check_rounded, color: AppColors.priorityLow),
              onPressed: _saveChanges,
              tooltip: "Save",
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isEditing ? _buildEditForm(isDark) : _buildDetailsView(isDark, categoryColor, priorityColor),
      ),
    );
  }

  Widget _buildDetailsView(bool isDark, Color categoryColor, Color priorityColor) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Priority row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(_currentTask.category),
                            size: 14,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _currentTask.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${_currentTask.priority.name.toUpperCase()} PRIORITY",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: priorityColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Task Title
                Text(
                  _currentTask.title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    decoration: _currentTask.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    color: _currentTask.isCompleted
                        ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Due Date pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262020) : const Color(0xFFF3EFE9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Due on ${DateFormat('EEEE, MMMM d, y').format(_currentTask.dueDate)}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Notes Header
                Text(
                  "NOTES",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Notes Description Body
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262020) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF332B2B) : const Color(0xFFEFECE6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _currentTask.description.isNotEmpty
                        ? _currentTask.description
                        : "No notes added to this task.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      fontStyle: _currentTask.description.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                      color: _currentTask.description.isNotEmpty
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Completion Bottom Button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _toggleComplete,
              icon: Icon(
                _currentTask.isCompleted ? Icons.undo_rounded : Icons.check_circle_rounded,
                size: 20,
              ),
              label: Text(
                _currentTask.isCompleted ? "Mark as Active" : "Mark as Completed",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentTask.isCompleted
                    ? (isDark ? const Color(0xFF262020) : const Color(0xFFF3EFE9))
                    : (isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
                foregroundColor: _currentTask.isCompleted
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : (isDark ? AppColors.darkBg : Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: _currentTask.isCompleted ? 0 : 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(bool isDark) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Form
            Text(
              "Edit Title",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(18),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Title is required";
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),

            // Description Form
            Text(
              "Edit Notes",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(18),
              ),
            ),

            const SizedBox(height: 20),

            // Category Selector
            Text(
              "Category",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppColors.categoryList.map((cat) {
                final isSelected = _selectedCategory == cat;
                final categoryColor = AppColors.categories[cat]!;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: categoryColor.withOpacity(0.2),
                  checkmarkColor: categoryColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? categoryColor
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? categoryColor : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Priority Selector
            Text(
              "Priority",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: TaskPriority.values.map((priority) {
                final isSelected = _selectedPriority == priority;
                Color priorityColor;
                switch (priority) {
                  case TaskPriority.high:
                    priorityColor = AppColors.priorityHigh;
                    break;
                  case TaskPriority.medium:
                    priorityColor = AppColors.priorityMedium;
                    break;
                  case TaskPriority.low:
                    priorityColor = AppColors.priorityLow;
                    break;
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? priorityColor.withOpacity(0.15) : (isDark ? const Color(0xFF262020) : const Color(0xFFF3EFE9)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? priorityColor : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            priority.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? priorityColor : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Due Date selector
            Text(
              "Due Date",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262020) : const Color(0xFFF3EFE9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
