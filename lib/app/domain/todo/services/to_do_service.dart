import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subject/app/domain/todo/models/to_do_model.dart';

class ToDoService {
  final FirebaseFirestore _fb = FirebaseFirestore.instance;

  Future<List<ToDoModel>> fetchTasks() async {
    final snapshot = await _fb.collection('tasks').where('isDelete', isNotEqualTo: true).get();
    return snapshot.docs.map((doc) => ToDoModel.fromJson(doc.data())).toList();
  }

  Future<bool> createTask(ToDoModel todo) async {
    final DocumentReference taskRef =
        _fb.collection('tasks-info').doc('detail');
    try {
      await _fb.runTransaction((transaction) async {
        final taskSnapshot = await transaction.get(taskRef);

        int lastWeight = 0;
        int lastKanName = 0;

        if (taskSnapshot.exists) {
          lastWeight = taskSnapshot['lastWeight'];
          lastKanName = taskSnapshot['lastKanName'];
        }

        int newWeight = lastWeight + 100;
        int newLastKanName = lastKanName + 1;

        final newTaskRef = _fb.collection('tasks').doc('KAN-$newLastKanName');

        transaction.set(newTaskRef, {
          'title': todo.title,
          'content': todo.content,
          'status': todo.status,
          'id': 'KAN-$newLastKanName',
          'worker': todo.worker,
          'weight': newWeight,
          'createDate': FieldValue.serverTimestamp(),
          'isDelete': false,
        });

        transaction.update(taskRef, {
          'lastWeight': newWeight,
          'lastKanName': newLastKanName,
        });
      });

      return true;
    } catch (e, s) {
      print('createTask Error : $e , $s');
      return false;
    }
  }

  Future<bool> updateTaskDetails(ToDoModel todo) async {
    try {
      await _fb.collection('tasks').doc(todo.id).update({
        'title': todo.title,
        'content': todo.content,
        'worker': todo.worker,
      });
      return true;
    } catch (e) {
      print('updateTaskDetails Error : $e');
      return false;
    }
  }

  Future<void> updateTaskStatus(
      String taskId, String newStatus, int newIndex) async {
    // await _fb.collection('tasks').doc(taskId).update({
    //   'status': newStatus,
    //   'index': newIndex,
    // });
  }

  Future<bool> deleteTask(String id) async {
    try {
      await _fb.collection('tasks').doc(id).update({'isDelete': true});
      return true;
    } catch (e) {
      return false;
    }
  }

// TODO : 삭제 서비스, 컨트롤, 컨펌모달,
// TODO : 로거 추가
// TODO : Get.snackbar 왜 안나오는지 체크
// TODO : 드래그앤 드랍 로직 수정
// TODO : UI 수정
// TODO : 노션 정리
}
