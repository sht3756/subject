import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subject/app/domain/common/modal_screen.dart';
import 'package:subject/app/domain/todo/models/to_do_model.dart';
import 'package:subject/app/domain/todo/services/to_do_service.dart';
import 'package:logger/logger.dart';

class ToDoController extends GetxController {
  final ToDoService _toDoService = ToDoService();
  final Map<String, GlobalKey> columnKeys = {};
  Rxn<ToDoModel> draggingItem = Rxn<ToDoModel>();
  RxMap<String, List<ToDoModel>> schedule = {
    'todo': <ToDoModel>[],
    'urgent': <ToDoModel>[],
    'doing': <ToDoModel>[],
    'finish': <ToDoModel>[],
  }.obs;
  final Logger logger = Logger();

  @override
  void onInit() {
    super.onInit();
    logger.i("ToDoController 초기화");
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
      update();
      logger.i("[SUCCESS] fetchTaskData");
    } catch (e) {
      Get.snackbar('Error', 'fetchTaskData');
      logger.e("[Error] fetchTaskData : $e");
    }
  }

  Future<void> createTask(ToDoModel todo) async {
    try {
      final res = await _toDoService.createTask(todo);

      await fetchTaskData();
      if (res == true) {
        Get.snackbar('Success', '등록 성공');
        logger.i("[SUCCESS] createTask");
      }
    } catch (e) {
      Get.snackbar('Error', '등록 실패 ㅠㅠ');
      logger.e("[Error] createTask : $e");
    }
  }

  Future<void> updateTaskDetails(ToDoModel todo) async {
    try {
      final res = await _toDoService.updateTaskDetails(todo);
      await fetchTaskData();

      if (res == true) {
        Get.snackbar('Success', '수정 성공');
        logger.i("[SUCCESS] updateTaskDetails ${todo.id}");
      }
    } catch (e) {
      Get.snackbar('Error', '수정 실패 ㅠㅠ');
      logger.e("[Error] updateTaskDetails : $e");
    }
  }

  // 삭제
  Future<void> deleteTask(String id) async {
    try {
      final res = await _toDoService.deleteTask(id);
      if (res == true) {
        await fetchTaskData();
        Get.snackbar('Success', '삭제 성공');
        logger.i("[SUCCESS] deleteTask $id");
      }
    } catch (e) {
      Get.snackbar('Error', '삭제 실패 ㅠㅠ');
      logger.e("[Error] deleteTask : $id $e");
    }
  }

  double calculateNewWeight(int newIndex, List<ToDoModel> todoList) {
    if (todoList.isEmpty) {
      return 1000; // 리스트가 비어있다면 기본 weight = 1000
    }
    if (newIndex == 0) {
      return todoList.first.weight! - 100; // 리스트 맨 위로 이동시 기존 첫번째 weight - 100
    }
    if (newIndex >= todoList.length) {
      return todoList.last.weight! + 100; // 리스트 맨 아래로 이동시 기존 마지막 weight + 100
    }
    // 중간 위치로 이동시  위/아래 weight 평균 값 / 2
    double upperWeight = todoList[newIndex - 1].weight!;
    double lowerWeight = todoList[newIndex].weight!;
    logger.d("calculateNewWeight: 주입될 인덱스 : $newIndex, 가중치 : ${(upperWeight + lowerWeight) / 2}");
    return (upperWeight + lowerWeight) / 2;
  }

  void setDraggingItem(ToDoModel? item) {
    draggingItem.value = item;
    update();
    logger.d("setDraggingItem: ${item?.title ?? 'None'}");
  }

  Future<void> updateTaskPosition(
      String taskId, String newStatus, double newWeight) async {
    try {
      _toDoService.updateTaskStatus(taskId, newStatus, newWeight);

      await fetchTaskData();
      logger.i("[SUCCESS] 변경 아이디: $taskId, 변경 상태=$newStatus, 변경 가중치=$newWeight");
    } catch (e) {
      Get.snackbar('Error', '테스크 업데이트 실패');
      logger.e("[Error] updateTaskPosition: $e");
    }
  }

  void showModal({
    ToDoModel? todo,
    bool? isEditMode,
    required Function onSave,
  }) {
    Get.dialog(
      ModalScreen(todo: todo, isEditMode: isEditMode),
    ).then((result) {
      onSave(result);
    });
    logger.d("showModal: ${todo?.title ?? 'None'}");
  }
}