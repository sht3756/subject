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

Offset centerDrag(
    Draggable<Object> draggable, BuildContext context, Offset position) {
  final RenderBox renderObject = context.findRenderObject()! as RenderBox;
  // return renderObject.globalToLocal(position);
  return Offset(renderObject.size.width / 2, renderObject.size.height / 2);
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

  final GlobalKey _cardKey = GlobalKey();
  Offset localPosition = Offset.zero; // 카드 기준 상대 위치

  int? underLineIndex;
  String? selectTodo;
  bool isBool = false;

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
        // 위치 저장하는 로직 분간여기서

        final data = details.data;
        print('$data $title');
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
                    return Column(
                      children: [
                        if (index == 0 &&
                            underLineIndex == -1 &&
                            item['status'] == selectTodo) ...[
                          Container(
                            height: 4,
                            width: 300,
                            color: Colors.blue,
                          ),
                        ] else if (index == 0) ...[
                          const SizedBox(height: 4),
                        ],
                        GestureDetector(
                          onTap: () {
                            context.replace('/modal/${item['id']}');
                          },
                          child: Draggable(
                            data: item,
                            dragAnchorStrategy: centerDrag,
                            feedback: SizedBox(
                              width: 300,
                              child: scheduleCard(item, isDragging: true),
                            ),
                            childWhenDragging: Container(
                              key: _cardKey,
                              child: Opacity(
                                opacity: 0.5,
                                child: scheduleCard(item),
                              ),
                            ),
                            child: scheduleCard(item),
                            onDragStarted: () {
                              dragStartPosition = Offset.zero;
                              setState(() {
                                selectTodo = item['status'];
                              });
                            },
                            onDragUpdate: (details) {
                              // UI 보이게 하면 된다.
                              const cardHeight = 120;
                              const sizedHeight = 4;

                              const cardHeightHalf = cardHeight / 2;

                              if (_cardKey.currentContext != null) {
                                dragStartPosition = details.globalPosition;
                                final RenderBox cardBox =
                                    _cardKey.currentContext!.findRenderObject()
                                        as RenderBox;

                                final cardPosition =
                                    cardBox.localToGlobal(Offset.zero);

                                localPosition =
                                    details.globalPosition - cardPosition;

                                // 같은 라인 일떄만 이야
                                // 같은 라인이 아닐떄,
                                underLineIndex = null;
                                if (localPosition.dx < -16) {
                                  // 왼쪽
                                } else if (localPosition.dx > 316) {
                                  // 오른쪽
                                }
                                // TODO : 다른쪽 넘길때도 수정
                                setState(() {
                                  isBool = localPosition.dx < -16 ||
                                      localPosition.dx > 316;
                                });

                                if (selectTodo == item['status'] && !isBool) {
                                  setState(() {
                                    if (localPosition.dy < -312 &&
                                        localPosition.dy > -436) {
                                      underLineIndex = index - 4;
                                    } else if (localPosition.dy < -188 &&
                                        localPosition.dy > -312) {
                                      underLineIndex = index - 3;
                                    } else if (localPosition.dy < -64 &&
                                        localPosition.dy > -188) {
                                      underLineIndex = index - 2;
                                    } else if (localPosition.dy < 0 &&
                                        localPosition.dy > -64) {
                                      underLineIndex = index - 1;
                                    } else if (localPosition.dy > 60 &&
                                        localPosition.dy < 184) {
                                      underLineIndex = index;
                                    } else if (localPosition.dy > 184 &&
                                        localPosition.dy < 308) {
                                      underLineIndex = index + 1;
                                    } else if (localPosition.dy > 308 &&
                                        localPosition.dy < 432) {
                                      underLineIndex = index + 2;
                                    } else if (localPosition.dy > 432 &&
                                        localPosition.dy < 556) {
                                      underLineIndex = index + 3;
                                    } else if (localPosition.dy > 556 &&
                                        localPosition.dy < 680) {
                                      underLineIndex = index + 4;
                                    }
                                  });
                                }
                              }
                            },
                            onDragEnd: (details) {
                              final dragDistance =
                                  (dragStartPosition - details.offset).distance;
                              print(
                                  '$dragDistance = ${details.wasAccepted} ${item['status']} ${title}');
                              if (dragDistance < 50) {
                                print('50 이하');
                              }
                              underLineIndex = null;
                              selectTodo = null;
                            },
                          ),
                        ),
                        if (index == underLineIndex &&
                            item['status'] == selectTodo) ...[
                          if (!(index == 0 || index == -1)) ...[],
                          Container(
                            height: 4,
                            width: 300,
                            color: Colors.blue,
                          )
                        ] else ...[
                          const SizedBox(height: 4),
                        ]
                      ],
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
      child: SizedBox(
        height: 120,
        child: Card(
          margin: EdgeInsets.zero,
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
      ),
    );
  }
}
