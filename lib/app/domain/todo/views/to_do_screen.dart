import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            if (kIsWeb)
              const Expanded(
                child: Drawer(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        DrawerHeader(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_3_rounded),
                              Text('TODO'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
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
  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  Offset dragStartPosition = Offset.zero;

  Map<String, List<Map<String, dynamic>>> schedule = {
    'todo': [],
    'urgent': [],
    'doing': [],
    'finish': [],
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('tasks').get();
    final data = querySnapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      schedule = {
        'todo': data.where((task) => task['status'] == 'todo').toList(),
        'urgent': data.where((task) => task['status'] == 'urgent').toList(),
        'doing': data.where((task) => task['status'] == 'doing').toList(),
        'finish': data.where((task) => task['status'] == 'finish').toList(),
      };
    });
  }

  Future<void> _updateTask(
      Map<String, dynamic> task, String newStatus, int newIndex) async {
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(task['id'])
        .update({
      'status': newStatus,
      'index': newIndex,
    });

    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: schedule.keys.map((key) {
          return _buildColumn(
            title: key,
            items: schedule[key] ?? [],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColumn({
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    return DragTarget<Map<String, dynamic>>(
      onAcceptWithDetails: (details) async {
        final data = details.data;
        await _updateTask(data, title, items.length);

        setState(() {
          schedule[data['status']]!.remove(data);
          data['status'] = title;
          schedule[title]!.add(data);
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        context.replace('/modal/${item['id']}');
                      },
                      child: Draggable(
                        data: item,
                        feedback: scheduleCard(item, isDragging: true),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: scheduleCard(item),
                        ),
                        child: scheduleCard(item),
                        onDragStarted: () {
                          dragStartPosition = Offset.zero;
                        },
                        onDragUpdate: (details) {
                          dragStartPosition = details.globalPosition;
                        },
                        onDragEnd: (details) {
                          final dragDistance =
                              (dragStartPosition - details.offset).distance;
                          if (dragDistance < 50) {
                            setState(() {
                              item['status'] = title;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget scheduleCard(Map<String, dynamic> item, {bool isDragging = false}) {
    return Opacity(
      opacity: isDragging ? 0.8 : 1.0,
      child: Card(
        elevation: isDragging ? 10 : 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['id']),
                  const CircleAvatar(
                    child: Icon(Icons.person_sharp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
