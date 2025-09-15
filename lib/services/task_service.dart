import 'package:abc/model/task_mode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(TaskCard task) async {
    try {
      await tasksCollection.add(task);
    } catch (e) {
      print(e.toString());
    }
  }

  // get all tasks
  Stream<QuerySnapshot> getTasksStream() {
    return tasksCollection.snapshots();
  }

  // update task
  Future<void> updateTask(TaskCard task) async {
    try {
      await tasksCollection.doc(task.taskId).update(task.toMap());
    } catch (e) {
      print(e.toString());
    }
  }
}
