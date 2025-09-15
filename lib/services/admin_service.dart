import 'package:abc/services/board_service.dart';
import 'package:abc/services/list_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user_model.dart';

class AdminService {
  final CollectionReference adminCollection =
      FirebaseFirestore.instance.collection('users');
  //  gget all users from firestore
  final BoardService _boardService = BoardService();
  final ListService _listService = ListService();

  Stream<QuerySnapshot> getAllUsers() {
    return adminCollection.where('role', isNotEqualTo: 'admin').snapshots();
  }

  // delete user from firestore
  Future<void> deleteUser(String userId) async {
    //  delete user from board
    try {
      // check if user exists in user collection
      DocumentSnapshot userDoc = await adminCollection.doc(userId).get();
      if (!userDoc.exists) {
        return;
      }
      UserModel user =
          UserModel.fromJson(userDoc.data() as Map<String, dynamic>);

      await _boardService.deleteBoardByUserId(user.email);
      await _boardService.deleteMemberInAllBoard(userId);
      await _listService.deleteUserInTasks(userId);
      await adminCollection.doc(userId).delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
