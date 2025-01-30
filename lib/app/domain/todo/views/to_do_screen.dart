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
      appBar: AppBar(title: const Text('프로젝트')),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Drawer(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const DrawerHeader(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_3_rounded),
                            Text('TODO'),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        label: const Text('로그아웃'),
                        onPressed: () {
                          AuthController.to.signOut();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
            const Expanded(
              flex: 5,
              child: KanbanBoard(),
            ),
          ],
        ),
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
