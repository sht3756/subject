import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subject/app/domain/todo/controller/to_do_controller.dart';
import 'package:subject/app/domain/user/controller/auth_controller.dart';

import 'widgets/to_do_column.dart';

class ToDoScreen extends StatelessWidget {
  const ToDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'HIT',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Visibility(
              visible: AuthController.to.myUserData.value != null,
              child:
              Text('${AuthController.to.myUserData.value?.name} 님' ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => AuthController.to.signOut(),
              child: const Icon(
                Icons.logout_outlined,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: const SafeArea(
        child: Center(child: KanbanBoard()),
      ),
    );
  }
}

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  final controller = Get.find<ToDoController>();

  @override
  void initState() {
    super.initState();
    controller.fetchTaskData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
            () => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: controller.schedule.keys.map((key) {
            return ToDoColumn(
              globalKey: controller.columnKeys[key]!,
              status: key,
              items: controller.schedule[key] ?? [],
            );
          }).toList(),
        ),
      ),
    );
  }
}
