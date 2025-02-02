import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:subject/app/domain/todo/models/to_do_model.dart';
import 'package:subject/app/domain/user/controller/auth_controller.dart';
import 'package:subject/app/domain/user/models/user_model.dart';

class ModalScreen extends StatefulWidget {
  ToDoModel? todo;
  bool? isEditMode;

  ModalScreen({
    super.key,
    this.isEditMode = false,
    this.todo,
  });

  @override
  State<ModalScreen> createState() => _ModalScreenState();
}

class _ModalScreenState extends State<ModalScreen> {
  late bool isEditMode;
  late TextEditingController titleController;
  late TextEditingController contentController;
  String? selectedWorker;
  List<String> usersList = [];

  @override
  void initState() {
    super.initState();
    isEditMode = widget.isEditMode ?? false;
    getUserList();
    titleController = TextEditingController(text: widget.todo?.title);
    contentController = TextEditingController(text: widget.todo?.content);
    selectedWorker = widget.todo?.worker;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getUserList();
    });
  }

  Future<void> getUserList() async {
    List<UserModel> users = await AuthController.to.fetchUserList();

    setState(() {
      usersList = users.map((user) => user.name).toSet().toList();
    });

    if (selectedWorker != null && !usersList.contains(selectedWorker)) {
      selectedWorker = null;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditMode
                        ? widget.todo == null
                            ? 'Task 생성'
                            : 'Task 수정'
                        : 'Task 디테일',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const Divider(thickness: 1.2, color: Colors.grey),
              const SizedBox(height: 16),
              _buildEditableField(
                label: '제목',
                controller: titleController,
                isEditMode: isEditMode,
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: '내용',
                controller: contentController,
                isEditMode: isEditMode,
              ),
              const SizedBox(height: 16),
              _buildWorkerDropdown(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isEditMode)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          isEditMode = !isEditMode;
                        });
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                      ),
                      label: Text(
                        isEditMode || widget.todo == null ? 'Edit' : 'Update',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isEditMode)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          isEditMode = false;
                        });
                        Get.back(result: {
                          'title': titleController,
                          'content': contentController,
                          'worker': selectedWorker,
                        });
                      },
                      icon: const Icon(
                        Icons.save,
                        color: Colors.blue,
                      ),
                      label: const Text('Save'),
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        isEditMode
            ? TextField(
                controller: controller,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: '$label 입력해주세요',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  controller.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildWorkerDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '담당자',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        isEditMode && usersList.isNotEmpty
            ? DropdownButtonFormField<String>(
                hint: const Text('담당자를 선택해주세요!'),
                borderRadius: BorderRadius.circular(8),
                value: selectedWorker,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownColor: Colors.white,
                items: usersList
                    .map((user) => DropdownMenuItem<String>(
                          value: user,
                          child:
                              user == AuthController.to.myUserData.value!.name
                                  ? Text('$user (본인)')
                                  : Text(user),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedWorker = value;
                  });
                },
              )
            : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  selectedWorker ?? '담당자 없음',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
      ],
    );
  }
}
