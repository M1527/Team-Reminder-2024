import 'dart:developer';

import 'package:abc/services/list_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/board_model.dart';
import '../model/list_model.dart';
import '../model/task_mode.dart';
import '../model/user_model.dart';

class BoardService {
  final CollectionReference boardsCollection =
      FirebaseFirestore.instance.collection('boards');
  final ListService _listService = ListService();

  // Lấy danh sách các board từ Firestore
  Future<List<BoardModel>> getBoards() async {
    try {
      QuerySnapshot snapshot = await boardsCollection.get();
      return snapshot.docs.map((doc) {
        return BoardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Stream<QuerySnapshot> getBoardsStream() {
    return boardsCollection.snapshots();
  }

  Future<void> addBoard(BoardModel board) async {
    try {
      DocumentReference docRef = await boardsCollection.add(board.toMap());
      List<ListModel> defaultLists = [
        ListModel(
            name: "To Do",
            description: "Tasks to be done",
            createdBy: docRef.id),
        ListModel(
            name: "In Progress",
            description: "Tasks currently in progress",
            createdBy: docRef.id),
        ListModel(
            name: "Done", description: "Completed tasks", createdBy: docRef.id),
      ];
      for (var list in defaultLists) {
        ListService().addList(list.toMap());
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateBoard(BoardModel board) async {
    try {
      await boardsCollection.doc(board.id).update(board.toMap());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> deleteBoard(String boardId) async {
    try {
      // Xóa các list liên quan đến board
      await _listService.deleteListsByBoardId(boardId);
      // Xóa board
      await boardsCollection.doc(boardId).delete();
    } catch (e) {
      log(e.toString());
    }
  }

  // get all members of a board by boardId return list<UserModel>
  Future<List<UserModel>> getMembersByBoardId(String boardId) async {
    try {
      DocumentSnapshot snapshot = await boardsCollection.doc(boardId).get();
      var data = snapshot.data() as Map<String, dynamic>;
      return data['members']
          .map<UserModel>(
            (member) => UserModel.fromJson(member),
          )
          .toList();
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<BoardModel> getBoardById(String boardId) async {
    try {
      DocumentSnapshot snapshot = await boardsCollection.doc(boardId).get();
      var data = snapshot.data() as Map<String, dynamic>;
      return BoardModel.fromMap(data, boardId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Stream<List<TaskCard>> getAllTasksInBoardStream(String boardId) {
    return FirebaseFirestore.instance
        .collection('lists')
        .where('createdBy', isEqualTo: boardId)
        .snapshots()
        .map((listsSnapshot) {
      List<TaskCard> allTasks = [];
      // Duyệt qua từng 'List' để lấy 'task'
      for (var listDoc in listsSnapshot.docs) {
        List<dynamic> tasks = listDoc.data()['tasks'] ?? [];
        for (var taskData in tasks) {
          TaskCard task = TaskCard.fromMap(taskData, "");
          allTasks.add(task);
        }
      }
      return allTasks;
    });
  }

  Future<List<TaskCard>> getAllTasksInBoard(String boardId) async {
    List<TaskCard> allTasks = [];
    // Lấy tất cả các 'List' trong 'board'
    //  get all lists in board by boardId
    final listsSnapshot = await FirebaseFirestore.instance
        .collection('lists')
        .where('createdBy', isEqualTo: boardId)
        .get();

    // Duyệt qua từng 'List' để lấy 'task'
    for (var listDoc in listsSnapshot.docs) {
      List<dynamic> tasks = listDoc.data()['tasks'] ?? [];
      // log id list
      // Duyệt qua từng 'task' để thêm vào 'allTasks'
      for (var taskData in tasks) {
        TaskCard task = TaskCard.fromMap(taskData, "");
        allTasks.add(task);
      }
    }

    return allTasks;
  }

  // getall member of all board return list<UserModel>
  Future<List<UserModel>> getAllMembers() async {
    try {
      List<BoardModel> boards = await getBoards();
      List<UserModel> allMembers = [];
      for (var board in boards) {
        List<UserModel> members = await getMembersByBoardId(board.id);
        allMembers.addAll(members);
      }
      return allMembers;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  // update image of member in all member if member id = uid
  Future<void> updateImageOfMemberInAllBoard(
      String uid, String imageUrl) async {
    try {
      List<BoardModel> boards = await getBoards();
      for (var board in boards) {
        List<UserModel> members = await getMembersByBoardId(board.id);
        for (var member in members) {
          if (member.id == uid) {
            member.image = imageUrl;
            await updateMemberInBoard(board.id, member);
          }
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // update member in board
  Future<void> updateMemberInBoard(String boardId, UserModel member) async {
    try {
      DocumentSnapshot snapshot = await boardsCollection.doc(boardId).get();
      var data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> members = data['members'];
      for (var i = 0; i < members.length; i++) {
        if (members[i]['id'] == member.id) {
          members[i] = member.toJson();
          break;
        }
      }
      await boardsCollection.doc(boardId).update({'members': members});
    } catch (e) {
      log(e.toString());
    }
  }

  // delete member by id in all board
  Future<void> deleteMemberInAllBoard(String uid) async {
    try {
      List<BoardModel> boards = await getBoards();
      for (var board in boards) {
        await deleteMemberInBoard(board.id, uid);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // delete member by id in board
  Future<void> deleteMemberInBoard(String boardId, String uid) async {
    try {
      DocumentSnapshot snapshot = await boardsCollection.doc(boardId).get();
      var data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> members = data['members'];
      members.removeWhere((member) => member['id'] == uid);
      await boardsCollection.doc(boardId).update({'members': members});
    } catch (e) {
      log(e.toString());
    }
  }

  // delete board by createdBy id user
  Future<void> deleteBoardByUserId(String uid) async {
    try {
      QuerySnapshot snapshot =
          await boardsCollection.where('createdBy', isEqualTo: uid).get();
      for (var doc in snapshot.docs) {
        await deleteBoard(doc.id);
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
