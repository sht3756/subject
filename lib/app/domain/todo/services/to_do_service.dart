import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subject/app/domain/todo/models/to_do_model.dart';
import 'package:logger/logger.dart';

class ToDoService {
  final FirebaseFirestore _fb = FirebaseFirestore.instance;
  final Logger logger = Logger();

  Future<List<ToDoModel>> fetchTasks() async {
    try {
      final snapshot = await _fb.collection('tasks').where('isDelete', isNotEqualTo: true).get();

      logger.i("[SUCCESS-Service] fetchTasks:");

      return snapshot.docs.map((doc) => ToDoModel.fromJson(doc.data())).toList();
    } catch(e) {
      logger.e("[Error-Service] fetchTasks: $e");
      return [];
    }

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
      logger.i("[SUCCESS-Service] createTask: ${todo.id}");
      return true;
    } catch (e) {
      logger.e("[Error-Service] createTask: ${todo.id} $e");
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
      logger.i("[SUCCESS-Service] updateTaskDetails: ${todo.id}");
      return true;
    } catch (e) {
      logger.e("[Error-Service] updateTaskDetails: ${todo.id} $e");
      return false;
    }
  }

  Future<void> updateTaskStatus(
      String taskId, String newStatus, double newWeight) async {
    try {
      await _fb.collection('tasks').doc(taskId).update({
        'status': newStatus,
        'weight': newWeight,
      });
      logger.i("[SUCCESS-Service] updateTaskStatus: $taskId");
    } catch(e) {
      logger.e("[Error-Service] updateTaskStatus: $taskId $e");
    }

  }

  Future<bool> deleteTask(String id) async {
    try {
      await _fb.collection('tasks').doc(id).update({'isDelete': true});
      logger.i("[SUCCESS-Service] deleteTask: $id");
      return true;
    } catch (e) {
      logger.e("[Error-Service] deleteTask: $id $e");
      return false;
    }
  }
}
