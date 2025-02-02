import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final controller = Get.find<ToDoController>();
  Offset localPosition = Offset.zero;
  int? underLineIndex;
  int? selectedFeedBackIndex;


  @override
  Widget build(BuildContext context) {
    return DragTarget<ToDoModel>(
      // Draggalbe 위젯이 DragTarget 위에서 움직이는 동안 동작
      onMove: (details) {
        if (!mounted) return;
        controller.setDraggingItem(controller.draggingItem.value);

        final RenderBox columnBox =
            widget.globalKey.currentContext!.findRenderObject() as RenderBox;
        final columnPosition = columnBox.localToGlobal(Offset.zero);

        setState(() {
          localPosition = details.offset - columnPosition;

          final double dragY = localPosition.dy;
          const double cardHeight = 120;
          const double cardSpacing = 4;
          const double totalCardHeight = cardHeight + cardSpacing;
          int? newUnderLineIndex;

          if (widget.items.isEmpty) {
            newUnderLineIndex = 0;
          } else {
            for (int i = 0; i < widget.items.length; i++) {
              final double cardMiddleY =
                  (i * totalCardHeight) + (cardHeight / 2);

              if (dragY < totalCardHeight / 2) {
                newUnderLineIndex = 0;
                break;
              }

              if (dragY > cardMiddleY) {
                newUnderLineIndex = i + 1;
              }
            }
          }

          underLineIndex = newUnderLineIndex;
        });
      },
      // onAccept 시 details 로 offset 얻기 가능
      onAcceptWithDetails: (details) async {
        if (!mounted) return;
        final item = details.data;

        int newIndex = underLineIndex ?? widget.items.length;
        double newWeight =
            controller.calculateNewWeight(newIndex, widget.items);

        setState(() {
          widget.items.remove(item);
          widget.items.insert(underLineIndex ?? widget.items.length, item);
          controller.setDraggingItem(null);
        });

        await controller.updateTaskPosition(item.id, widget.status, newWeight);
      },
      onLeave: (data) {
        if (!mounted) return;
        setState(() {
          underLineIndex = null;
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.status,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  addToDoButton(() {
                    // 새로 생성
                    controller.showModal(
                        isEditMode: true,
                        onSave: (todo) {
                          controller.createTask(
                            ToDoModel(
                              id: '',
                              title: todo['title'].text,
                              content: todo['content'].text,
                              weight: 0,
                              status: widget.status,
                              worker: todo['worker'] ?? '',
                              createDate: null,
                            ),
                          );
                        });
                  }),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.items.length +
                      (controller.draggingItem.value != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (controller.draggingItem.value != null &&
                        index == underLineIndex) {
                      return Opacity(
                        opacity: 0.5,
                        child: scheduleCard(controller.draggingItem.value!,
                            isDragging: true),
                      );
                    }

                    final realIndex = controller.draggingItem.value != null &&
                            index > (underLineIndex ?? widget.items.length)
                        ? index - 1
                        : index;

                    if (realIndex >= widget.items.length) {
                      return const SizedBox.shrink();
                    }

                    final item = widget.items[realIndex];

                    return Column(
                      children: [
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () {
                            // 업데이트
                            controller.showModal(
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
                            onDragStarted: () {
                              controller.setDraggingItem(item);
                              setState(() {
                                selectedFeedBackIndex = realIndex;
                              });
                            },
                            onDragUpdate: (detail) {
                              if (selectedFeedBackIndex != null &&
                                  selectedFeedBackIndex! <
                                      widget.items.length) {
                                setState(() {
                                  widget.items.removeAt(selectedFeedBackIndex!);
                                  selectedFeedBackIndex = null;
                                });
                              }
                            },
                            onDragCompleted: () {
                              controller.setDraggingItem(null);
                            },
                            childWhenDragging: const SizedBox.shrink(),
                            onDragEnd: (details) {
                              setState(() {
                                underLineIndex = null;
                                controller.setDraggingItem(null);
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
