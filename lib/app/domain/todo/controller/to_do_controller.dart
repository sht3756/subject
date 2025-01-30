import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subject/app/domain/todo/models/to_do_model.dart';
import 'package:subject/app/domain/todo/services/to_do_service.dart';

class ToDoController extends GetxController {
  final ToDoService _toDoService = ToDoService();
  final Map<String, GlobalKey> columnKeys = {};

  RxMap<String, List<ToDoModel>> schedule = {
    'todo': <ToDoModel>[],
    'urgent': <ToDoModel>[],
    'doing': <ToDoModel>[],
    'finish': <ToDoModel>[],
  }.obs;

  @override
  void onInit() {
    super.onInit();

    for (var key in schedule.keys) {
      columnKeys[key] = GlobalKey();
    }
  }

  Future<void> fetchTaskData() async {
    try {
      final data = await _toDoService.fetchTasks();

      Map<String, List<ToDoModel>> sortTask(List<ToDoModel> tasks) {
        return {
          for (var status in ['todo', 'urgent', 'doing', 'finish'])
            status: tasks.where((task) => task.status == status).toList()
              ..sort((a, b) => a.weight!.compareTo(b.weight as num)),
        };
      }

      schedule.value = sortTask(data);

      for (var key in schedule.keys) {
        columnKeys[key] = GlobalKey();
      }
    } catch (e) {
      Get.snackbar('Error', 'fetchTaskData: ${e.toString()}');
    }
  }

  Future<void> createTask(ToDoModel todo) async {
    try {
      final res = await _toDoService.createTask(todo);

      await fetchTaskData();
      if (res == true) {
        Get.snackbar('Success', '등록 성공');
      }
    } catch (e) {
      Get.snackbar('Error', 'createTask: ${e.toString()}');
    }
  }

  Future<void> updateTaskDetails(ToDoModel todo) async {
    try {
      final res = await _toDoService.updateTaskDetails(todo);
      await fetchTaskData();

      if (res == true) {
        Get.snackbar('Success', '수정 성공');
      }
    } catch (e) {
      Get.snackbar('Error', 'updateTaskDetails: ${e.toString()}');
    }
  }

  // 위치 수정
  Future<void> updateTask(
    ToDoModel task,
    String newStatus,
    int newIndex,
  ) async {
    try {
      await _toDoService.updateTaskStatus(task.id, newStatus, newIndex);
      await fetchTaskData();
    } catch (e) {
      Get.snackbar('Error', 'updateTask: ${e.toString()}');
    }
  }

  // 삭제
  Future<void> deleteTask(String id) async {
    try {
      final res = await _toDoService.deleteTask(id);
      if (res == true) {
        await fetchTaskData();
        Get.snackbar('Success', '삭제 성공');
      }
    } catch (e) {
      Get.snackbar('Error', 'deleteTask: ${e.toString()}');
    }
  }
}
