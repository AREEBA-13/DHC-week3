import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class StorageService {
  static const String _tasksKey = 'flowstate_tasks_list';
  
  // Singleton instance
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<TaskModel>> loadTasks() async {
    if (_prefs == null) {
      await init();
    }
    
    try {
      final List<String>? tasksJson = _prefs?.getStringList(_tasksKey);
      if (tasksJson == null) return [];
      
      return tasksJson
          .map((taskStr) => TaskModel.fromJson(taskStr))
          .toList();
    } catch (e) {
      // In case of parsing errors or version mismatches, return empty list
      return [];
    }
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    if (_prefs == null) {
      await init();
    }
    
    final List<String> tasksJson = tasks
        .map((task) => task.toJson())
        .toList();
        
    await _prefs?.setStringList(_tasksKey, tasksJson);
  }
}
