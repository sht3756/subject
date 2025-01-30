import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subject/app/domain/common/modal_screen.dart';
import 'package:subject/app/domain/todo/controller/to_do_controller.dart';
import 'package:subject/app/domain/todo/models/to_do_model.dart';
import 'package:subject/app/domain/todo/views/widgets/add_to_do_button.dart';
import 'package:subject/app/domain/todo/views/widgets/confirm_modal.dart';
import 'package:subject/app/domain/todo/views/widgets/to_do_card.dart';
import 'package:subject/core/utils/drag_anchor.dart';

class ToDoColumn extends StatefulWidget {
  final GlobalKey globalKey;
  final String status;
  final List<ToDoModel> items;

  const ToDoColumn({
    super.key,
    required this.globalKey,
    required this.status,
    required this.items,
  });

  @override
  State<ToDoColumn> createState() => _ToDoColumnState();
}

class _ToDoColumnState extends State<ToDoColumn> {
  Offset localPosition = Offset.zero;
  int? underLineIndex;
  String? selectTodo;
  final controller = Get.find<ToDoController>();

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
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<ToDoModel>(
      onMove: (details) {
        if (!mounted) return;

        final RenderBox columnBox =
            widget.globalKey.currentContext!.findRenderObject() as RenderBox;
        final columnPosition = columnBox.localToGlobal(Offset.zero);

        setState(() {
          localPosition = details.offset - columnPosition;

          final double dragY = localPosition.dy;
          const double cardHeight = 120;
          const double cardSpacing = 4;
          const double totalCardHeight = cardHeight + cardSpacing;

          if (dragY < 0) {
            // 맨 위
            underLineIndex = -1;
          } else if (dragY > columnBox.size.height) {
            // 마지막
            underLineIndex = widget.items.length;
          } else {
            // 가운데 일때
            for (int i = 0; i < widget.items.length; i++) {
              final double cardStartY = i * totalCardHeight;
              final double cardEndY = cardStartY + totalCardHeight;

              // 정위치
              if (dragY >= cardStartY && dragY < cardEndY) {
                underLineIndex = i;
                break;
              } else if (dragY >= cardEndY &&
                  dragY <= cardEndY + totalCardHeight) {
                // 아래
                underLineIndex = i + 1;
                break;
              }
            }
          }
          selectTodo = widget.status;
        });
      },
      onAcceptWithDetails: (details) async {
        if (!mounted) return;
        final data = details.data;

        setState(() {
          controller.schedule[data.status]!.remove(data);
          controller.schedule[widget.status]!.add(data);

          selectTodo = null;
          underLineIndex = null;
        });

        await controller.updateTask(data, widget.status, widget.items.length);
      },
      onLeave: (data) {
        if (!mounted) return;
        setState(() {
          if (selectTodo == widget.status) {
            selectTodo = null;
            underLineIndex = null;
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          key: widget.globalKey,
          width: 300,
          margin: const EdgeInsets.only(right: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.status),
                  ),
                  addToDoButton(() {
                    // 새로 생성
                    showModal(
                        isEditMode: true,
                        onSave: (todo) {
                          controller.createTask(ToDoModel(
                            id: '',
                            title: todo['title'].text,
                            content: todo['content'].text,
                            weight: 0,
                            status: widget.status,
                            worker: todo['worker'] ?? '',
                            createDate: null,
                          ));
                        });
                  }),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return Column(
                      children: [
                        if (index == 0 &&
                            underLineIndex == -1 &&
                            selectTodo == widget.status) ...[
                          Container(
                            height: 4,
                            width: 300,
                            color: Colors.blue,
                          ),
                        ] else if (index == 0) ...[
                          const SizedBox(height: 4),
                        ],
                        InkWell(
                          onTap: () {
                            // 업데이트
                            showModal(
                                todo: item,
                                onSave: (todo) {
                                  controller.updateTaskDetails(ToDoModel(
                                    id: item.id,
                                    title: todo['title'].text,
                                    content: todo['content'].text,
                                    weight: item.weight,
                                    status: item.status,
                                    worker: todo['worker'],
                                    createDate: item.createDate,
                                  ));
                                });
                          },
                          child: Draggable(
                            data: item,
                            dragAnchorStrategy: centerDrag,
                            feedback: SizedBox(
                              width: 300,
                              child: scheduleCard(item, isDragging: true),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: scheduleCard(item),
                            ),
                            onDragEnd: (details) {
                              setState(() {
                                underLineIndex = null;
                                selectTodo = null;
                              });
                            },
                            child: scheduleCard(
                              item,
                              deleteOnPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CustomAppDialog.dividedBtn(
                                        title: '삭제',
                                        subTitle: '해당 칸반을 삭제할까요?',
                                        leftBtnContent: '확인',
                                        rightBtnContent: '취소',
                                        onRightBtnClicked: () {
                                          Get.back();
                                        },
                                        onLeftBtnClicked: () {
                                          controller.deleteTask(item.id);
                                          Get.back();
                                        },
                                      );
                                    });
                              },
                            ),
                          ),
                        ),
                        if (index == underLineIndex &&
                            selectTodo == widget.status) ...[
                          Container(
                            height: 4,
                            width: 300,
                            color: Colors.blue,
                          )
                        ] else ...[
                          const SizedBox(height: 4),
                        ],
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
}
