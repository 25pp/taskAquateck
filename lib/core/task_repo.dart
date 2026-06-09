import 'dart:convert';

import 'package:demo_apk_aquaktech/models/task_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskRepository {
  final Dio dio = Dio();

  Future<List<TaskModel>?> getCachedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString("tasks");
    if (cache != null) {
      final decoded = jsonDecode(cache);
      return (decoded as List)
          .map((e) => TaskModel.fromJson(e))
          .toList();
    }
    return null;
  }

  Future<List<TaskModel>> fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final response = await dio.get(
      "https://jsonplaceholder.typicode.com/posts",
    );

    List<TaskModel> tasks = (response.data as List)
        .map((e) => TaskModel.fromJson(e))
        .toList();

    await prefs.setString(
      "tasks",
      jsonEncode(tasks.map((e) => e.toJson()).toList()),
    );

    return tasks;
  }

  Future<List<TaskModel>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final tasks = await fetchTasks();
      return tasks;
    } catch (e) {
      final cache = prefs.getString("tasks");

      if (cache != null) {
        final decoded = jsonDecode(cache);
        return (decoded as List)
            .map((e) => TaskModel.fromJson(e))
            .toList();
      }

      rethrow;
    }
  }
}
