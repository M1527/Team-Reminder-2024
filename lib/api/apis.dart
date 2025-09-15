import 'dart:io';
import 'dart:math';

import 'package:abc/dto/user_dto.dart';
import 'package:abc/services/board_service.dart';
import 'package:abc/services/list_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/user_model.dart';

class APIs {
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static UserModel me = UserModel(
    id: user.uid,
    email: user.email!,
    username: user.displayName ?? 'Anonymous',
    image: user.photoURL!,
    about: '',
    createdAt: '',
    pushToken: '',
  );
  static String imageUrl = '';
  static String role = '';
  // get role
  Future<String> getRole() async {
    String id = auth.currentUser!.uid;
    UserModel? user = await getUser(id);
    if (user == null) {
      return '';
    }
    return user.role ?? '';
  }

  Future<User?> signUp(UserDto userdto) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: userdto.email,
        password: userdto.password,
      );
      //  radom image
      final random = Random();
      final image = random.nextInt(12);
      final imageUrl = 'https://gomeet.tiendev.id.vn/uploads/assest/$image.png';

      await saveUser(UserModel(
        id: userCredential.user!.uid,
        email: userdto.email,
        username: userdto.username,
        about: '',
        createdAt: DateTime.now().toString(),
        pushToken: '',
        image: imageUrl,
        role: 'user',
      ));
      role = 'user';
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi từ FirebaseAuth
      if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(msg: 'Email đã được sử dụng.');
      } else if (e.code == 'invalid-email') {
        Fluttertoast.showToast(msg: 'Email không hợp lệ.');
      } else if (e.code == 'weak-password') {
        Fluttertoast.showToast(msg: 'Mật khẩu quá yếu.');
      } else {
        Fluttertoast.showToast(msg: e.message!);
      }
      return null;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return null;
    }
  }

  Future<UserDto?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //  lấy thông tin từ firestore
      UserModel? user = await getUser(userCredential.user!.uid);
      if (user == null) {
        return null;
      }
      role = user.role ?? 'user';
      return UserDto(
        id: user.id,
        email: user.email,
        username: user.username,
        password: '',
        role: user.role,
      );
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi từ FirebaseAuth
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: 'Không tìm thấy người dùng với email này.');
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'Mật khẩu không chính xác.');
      } else if (e.code == 'operation-not-allowed') {
        Fluttertoast.showToast(msg: 'Đăng nhập không được phép.');
      } else if (e.code == 'invalid-credential') {
        Fluttertoast.showToast(msg: 'Thông tin đăng nhập không hợp lệ.');
      } else {
        Fluttertoast.showToast(msg: e.message!);
      }
      return null;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  User? getCurrentUser() {
    return auth.currentUser;
  }

  Future<void> saveUser(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      print(e.toString());
      return;
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // get all users
  Future<List<UserModel>> getUsers() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateUserProfileImage(String uid, String imageUrl) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'image': imageUrl,
      });
    } catch (e) {
      print(e.toString());
      return;
    }
  }

  static Future<void> updateProfilePicture(String uid, File file) async {
    //getting image file extension
    try {
      final ext = file.path.split('.').last;

      final ref = storage.ref().child('profile_pictures/$uid.$ext');

      //uploading image
      await ref
          .putFile(file, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {});

      //updating image in firestore database
      imageUrl = await ref.getDownloadURL();

      await firestore.collection('users').doc(uid).update({'image': imageUrl});
      // tìm nhunwxgg member của board có id = uid
      // update image của member đó
      await BoardService().updateImageOfMemberInAllBoard(uid, imageUrl);
      await ListService().updateProfilePictureInTasks(uid, imageUrl);
    } catch (e) {
      print(e.toString());
    } finally {}
  }

  Future<void> deleteUser(String uid) async {
    try {
      await firestore.collection('users').doc(uid).delete();
    } catch (e) {
      print(e.toString());
      return;
    }
  }
}
