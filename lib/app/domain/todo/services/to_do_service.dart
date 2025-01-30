import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subject/app/domain/todo/models/to_do_model.dart';

class ToDoService {
  final FirebaseFirestore _fb = FirebaseFirestore.instance;

  Future<List<ToDoModel>> fetchTasks() async {
    final snapshot = await _fb.collection('tasks').get();
    return snapshot.docs.map((doc) => ToDoModel.fromJson(doc.data())).toList();
  }

  Future<bool> createTask(ToDoModel todo) async {
    final DocumentReference taskRef = _fb.collection('tasks-info').doc('detail');
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
        });

        transaction.update(taskRef, {
          'lastWeight': newWeight,
          'lastKanName': newLastKanName,
        });
      });

      return true;
    } catch (e,s) {
      print('createTask Error : $e , $s');
      return false;
    }
  }

  Future<void> updateTaskStatus(
      String taskId, String newStatus, int newIndex) async {
    await _fb.collection('tasks').doc(taskId).update({
      'status': newStatus,
      'index': newIndex,
    });
  }

  Future<void> updateTaskDetails(
      String taskId, String title, String content, String worker) async {
    await _fb.collection('tasks').doc(taskId).update({
      'title': title,
      'content': content,
      'worker': worker,
    });
  }
}
