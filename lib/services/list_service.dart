import 'dart:developer';

import 'package:abc/model/list_model.dart';
import 'package:abc/model/task_mode.dart';
import 'package:abc/utils/time_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListService {
  final CollectionReference listsCollection =
      FirebaseFirestore.instance.collection('lists');

  Future<void> addList(Map<String, dynamic> list) async {
    try {
      await listsCollection.add(list);
    } catch (e) {
      log(e.toString());
    }
  }

  // get all lists
  Future<List<ListModel>> getLists() async {
    try {
      QuerySnapshot snapshot =
          await listsCollection.orderBy('name', descending: true).get();
      return snapshot.docs.map((doc) {
        return ListModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  // get list by id board
  Stream<List<ListModel>> getListsByIdBoardStream(String idBoard) {
    try {
      return listsCollection
          .where('createdBy', isEqualTo: idBoard)
          .orderBy('name', descending: true)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return ListModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      log(e.toString());
      return Stream.value([]);
    }
  }

  Future<List<ListModel>> getAllLists() async {
    try {
      QuerySnapshot snapshot = await listsCollection.get();
      return snapshot.docs
          .map((doc) =>
              ListModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<void> addTaskToList(String idList, TaskCard task) async {
    try {
      DocumentSnapshot docSnapshot = await listsCollection.doc(idList).get();

      if (docSnapshot.exists) {
        ListModel list = ListModel.fromMap(
            docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
        list.tasks.add(task);
        await listsCollection.doc(idList).update(list.toMap());
      }
    } catch (e) {
      log(e.toString());
    }
  }

  String calculateTotalTimeSpend(
      String createdAt, String actualEndTime, int totalTimeSpend) {
    DateTime start = DateTime.parse(createdAt);
    DateTime end = DateTime.parse(actualEndTime);
    int diff = end.difference(start).inSeconds;
    int totalSeconds = totalTimeSpend + diff;

    int days = totalSeconds ~/ (24 * 3600);
    totalSeconds %= (24 * 3600);
    int hours = totalSeconds ~/ 3600;
    totalSeconds %= 3600;
    int minutes = totalSeconds ~/ 60;

    return '$days days, $hours hours, $minutes minutes';
  }

  Future<void> addTaskToListAtPosition(
      String idList, TaskCard task, int position) async {
    try {
      DocumentSnapshot docSnapshot = await listsCollection.doc(idList).get();
      if (docSnapshot.exists) {
        ListModel list = ListModel.fromMap(
            docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);

        task.actualEndTime = formatDateTime(DateTime.now());

        task.status = list.name;

        DateTime createDateTime = DateTime.parse(task.createdAt);
        DateTime endDateTime = DateTime.now();

        log('createDateTime: $createDateTime');
        log('endDateTime: $endDateTime');
        // Tính sự khác biệt giữa endTime và createTime
        Duration difference = endDateTime.difference(createDateTime);

        // Tính số ngày, giờ, và phút
        int days = difference.inDays;
        int hours = difference.inHours % 24;
        int minutes = difference.inMinutes % 60;

        log('days: $days, hours: $hours, minutes: $minutes');
        // Trả về kết quả dưới dạng "ngày : giờ, phút"
        String totalTimeSpend = "$days ngày : $hours giờ, $minutes phút";
        task.totalTimeSpend = totalTimeSpend;
        list.tasks.insert(position, task);

        await listsCollection.doc(idList).update(list.toMap());
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> removeTaskFromList(String idList, String taskId) async {
    try {
      log('Removing task from list $idList');
      DocumentSnapshot docSnapshot = await listsCollection.doc(idList).get();
      if (docSnapshot.exists) {
        ListModel list = ListModel.fromMap(
            docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);

        list.tasks.removeWhere((task) => task.taskId == taskId);

        await listsCollection.doc(idList).update(list.toMap());
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> deleteListsByBoardId(String boardId) async {
    try {
      QuerySnapshot snapshot =
          await listsCollection.where('createdBy', isEqualTo: boardId).get();
      for (var doc in snapshot.docs) {
        await listsCollection.doc(doc.id).delete();
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateTaskInList(String idList, TaskCard task) async {
    try {
      DocumentSnapshot docSnapshot = await listsCollection.doc(idList).get();
      if (docSnapshot.exists) {
        ListModel list = ListModel.fromMap(
            docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);

        int index =
            list.tasks.indexWhere((element) => element.taskId == task.taskId);
        list.tasks[index] = task;

        await listsCollection.doc(idList).update(list.toMap());
      }
    } catch (e) {
      log(e.toString());
    }
  }

// Update profile picture in tasks
  Future<void> updateProfilePictureInTasks(
      String userId, String newProfilePictureUrl) async {
    try {
      List<ListModel> lists = await getAllLists();
      for (var list in lists) {
        bool updated = false;
        for (var task in list.tasks) {
          for (var member in task.members) {
            if (member.id == userId) {
              member.image = newProfilePictureUrl;
              updated = true;
            }
          }
        }
        if (updated) {
          await listsCollection.doc(list.id).update(list.toMap());
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // delete user by id in task of list
  Future<void> deleteUserInTasks(String userId) async {
    try {
      List<ListModel> lists = await getAllLists();
      for (var list in lists) {
        bool updated = false;
        for (var task in list.tasks) {
          task.members.removeWhere((member) => member.id == userId);
          updated = true;
        }
        if (updated) {
          await listsCollection.doc(list.id).update(list.toMap());
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
