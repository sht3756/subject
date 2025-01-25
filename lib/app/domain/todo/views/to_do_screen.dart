import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  final Map<String, dynamic> schedule = {
    'todo': [
      {
        'title': '방 청소하기',
        'content': '거실, 안방, 작은방 치우기',
        'worker': 'ㅇ',
        'index': 0,
        'status': 'todo',
      },
      {
        'title': '책 읽기',
        'content': '자기 계발서 읽기',
        'worker': 'ㅇ',
        'index': 1,
        'status': 'todo',
      },
    ],
    'urgent': [
      {
        'title': '서류 정리하기',
        'content': '계약서, 영수증 정리',
        'worker': 'ㄱ',
        'index': 0,
        'status': 'urgent',
      },
      {
        'title': '회의 준비하기',
        'content': '회의 자료 작성 및 인쇄',
        'worker': 'ㄱ',
        'index': 1,
        'status': 'urgent',
      },
    ],
    'doing': [
      {
        'title': '코드 작성',
        'content': 'Flutter 프로젝트 개발',
        'worker': 'ㄴ',
        'index': 0,
        'status': 'doing',
      },
    ],
    'finish': [
      {
        'title': '운동하기',
        'content': '헬스장 가서 운동',
        'worker': 'ㅇ',
        'index': 0,
        'status': 'finish',
      },
      {
        'title': '설거지하기',
        'content': '저녁 식사 후 설거지',
        'worker': 'ㅇ',
        'index': 1,
        'status': 'finish',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: schedule.keys.map((key) {
          return _buildColumn(
            title: key,
            items: schedule[key],
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
      onAcceptWithDetails: (details) {
        setState(() {
          final data = details.data;
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
                    return Draggable(
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
                      onPressed: () {}, icon: const Icon(Icons.more_horiz))
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['content']),
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
