import 'dart:developer';
import 'dart:io';

import 'package:abc/api/apis.dart';
import 'package:abc/main.dart';
import 'package:abc/model/user_model.dart';
import 'package:abc/utils/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  final APIs api = APIs();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? _imageUrl = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _uploadAvatar() async {
    var imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );

    if (imageFile == null) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      if (user?.id != null) {
        log(imageFile.path);
        await APIs.updateProfilePicture(user!.id, File(imageFile.path));
        await _loadUserData();
      } else {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('User ID is null')),
        );
      }

      setState(() {
        _imageUrl = imageFile?.path;
      });

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Avatar uploaded successfully!')),
      );
      imageFile = null;
    } catch (error) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Error uploading avatar: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      user = await api.getUser(firebaseUser.uid);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(
      "/login",
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await api.deleteUser(user!.id);
      await _auth.currentUser!.delete();
      Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(
        "/login",
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      Util.showToast(msg: 'Failed to delete account');
    }
  }

  @override
  Widget build(BuildContext context) {
    log('User: ${user.toString()}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? FutureBuilder(
                  future: _logout(),
                  builder: (context, snapshot) {
                    return const Center(child: CircularProgressIndicator());
                  },
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _uploadAvatar,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : CircleAvatar(
                                backgroundImage: NetworkImage(
                                  user!.image,
                                  scale: 0.2,
                                ),
                                radius: 100,
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(user!.username,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 8),
                      Text(user!.email, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _logout,
                        child: const Text('Logout'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _deleteAccount,
                        child: const Text('Delete Account'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
