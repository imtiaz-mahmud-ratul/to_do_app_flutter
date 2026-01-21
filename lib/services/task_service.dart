import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _tasksCol =>
      _db.collection('users').doc(userId).collection('tasks');

  Stream<List<Task>> streamTasks() {
    return _tasksCol.orderBy('dueDateTime').snapshots().map(
          (snap) => snap.docs.map((d) => Task.fromDoc(d)).toList(),
        );
  }

  Future<void> addTask(Task task) async {
    await _tasksCol.add(task.toMap());
  }

  Future<void> updateTaskStatus(String id, TaskStatus status) async {
    await _tasksCol.doc(id).update({'status': status.name});
  }

  Future<void> deleteTask(String id) async {
    await _tasksCol.doc(id).delete();
  }
}
