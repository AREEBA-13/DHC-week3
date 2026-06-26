import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';
import '../utils/theme.dart';
import '../widgets/progress_card.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<TaskModel> _allTasks = [];
  List<TaskModel> _filteredTasks = [];

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedFilter = 'All'; // 'All', 'Active', 'Completed'

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _storageService.loadTasks();
    setState(() {
      _allTasks = tasks;
      _applyFilters();
    });
  }

  Future<void> _saveTasks() async {
    await _storageService.saveTasks(_allTasks);
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        // Search filter
        final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(_searchQuery.toLowerCase());

        // Category filter
        final matchesCategory = _selectedCategory == 'All' || task.category == _selectedCategory;

        // Completion filter
        bool matchesStatus = true;
        if (_selectedFilter == 'Active') {
          matchesStatus = !task.isCompleted;
        } else if (_selectedFilter == 'Completed') {
          matchesStatus = task.isCompleted;
        }

        return matchesSearch && matchesCategory && matchesStatus;
      }).toList();

      // Sort: Completed tasks to bottom, otherwise sort by due date, then priority
      _filteredTasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.dueDate.compareTo(b.dueDate);
      });
    });
  }

  void _toggleTaskCompletion(TaskModel task) {
    setState(() {
      final index = _allTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _allTasks[index] = task.copyWith(isCompleted: !task.isCompleted);
        _saveTasks();
        _applyFilters();
      }
    });
  }

  void _deleteTask(TaskModel task) {
    // Show a beautiful SnackBar with undo capability! Recruiters love this.
    final index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    final removedTask = _allTasks[index];
    
    setState(() {
      _allTasks.removeAt(index);
      _saveTasks();
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.lightCard,
        content: Text(
          "Task deleted",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        action: SnackBarAction(
          label: "UNDO",
          textColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkPrimary
              : AppColors.lightPrimary,
          onPressed: () {
            setState(() {
              _allTasks.insert(index, removedTask);
              _saveTasks();
              _applyFilters();
            });
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addTask(TaskModel task) {
    setState(() {
      _allTasks.add(task);
      _saveTasks();
      _applyFilters();
    });
  }

  void _updateTask(TaskModel updatedTask) {
    setState(() {
      final index = _allTasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _allTasks[index] = updatedTask;
        _saveTasks();
        _applyFilters();
      }
    });
  }

  void _navigateToAddTask() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AddTaskScreen(onAddTask: _addTask),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  void _navigateToTaskDetail(TaskModel task) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TaskDetailScreen(
          task: task,
          onToggleComplete: () => _toggleTaskCompletion(task),
          onDelete: () => _deleteTask(task),
          onUpdateTask: _updateTask,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.05, 0.05);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    ).then((_) {
      // Reload tasks if returned to home screen to ensure state sync
      _loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalTasksCount = _allTasks.length;
    final completedTasksCount = _allTasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimary.withOpacity(0.1) : AppColors.lightPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "FlowState",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Dark Mode Toggle Button
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.dark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              size: 22,
            ),
            onPressed: () {
              widget.onThemeChanged(
                widget.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              );
            },
            tooltip: "Switch Theme",
          ),
          
          // Custom Action Add Button in App Bar
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
            onPressed: _navigateToAddTask,
            tooltip: "Add New Task",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              
              // Progress Banner Widget
              ProgressCard(
                totalTasks: totalTasksCount,
                completedTasks: completedTasksCount,
              ),
              
              const SizedBox(height: 20),
              
              // Custom styled search field
              TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _applyFilters();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search tasks...",
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _applyFilters();
                            });
                          },
                        )
                      : null,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Horizontal Categories list view
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryPill('All'),
                    ...AppColors.categoryList.map((cat) => _buildCategoryPill(cat)),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Custom Filter segment row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Tasks",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      _buildFilterButton('All'),
                      _buildFilterButton('Active'),
                      _buildFilterButton('Completed'),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Tasks List Area
              Expanded(
                child: _filteredTasks.isEmpty ? _buildEmptyState() : _buildTasksList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        tooltip: "Create task",
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildCategoryPill(String categoryName) {
    final isSelected = _selectedCategory == categoryName;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color activeBg = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    Color activeText = isDark ? AppColors.darkBg : Colors.white;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = categoryName;
            _applyFilters();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : (isDark ? const Color(0xFF262020) : const Color(0xFFF3EFE9)),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.transparent : (isDark ? const Color(0xFF332B2B) : const Color(0xFFEFECE6)),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              categoryName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeText : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filterName) {
    final isSelected = _selectedFilter == filterName;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterName;
          _applyFilters();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          filterName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262020) : const Color(0xFFF3EFE9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.checklist_rounded,
              size: 54,
              color: isDark ? AppColors.darkTextSecondary.withOpacity(0.5) : AppColors.lightTextSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Clear space, clear mind",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? "No tasks match your search criteria"
                : "Enjoy the silence, or tap '+' to log a new task.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredTasks.length,
      itemBuilder: (context, index) {
        final task = _filteredTasks[index];
        return TaskTile(
          task: task,
          onToggleComplete: () => _toggleTaskCompletion(task),
          onDelete: () => _deleteTask(task),
          onTap: () => _navigateToTaskDetail(task),
        );
      },
    );
  }
}
