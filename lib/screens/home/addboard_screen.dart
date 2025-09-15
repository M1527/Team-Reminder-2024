import 'package:abc/api/apis.dart';
import 'package:abc/main.dart';
import 'package:flutter/material.dart';

import '../../model/board_model.dart';
import '../../model/user_model.dart';
import '../../services/board_service.dart';

class AddboardScreen extends StatefulWidget {
  const AddboardScreen({super.key});

  @override
  State<AddboardScreen> createState() => _AddboardScreenState();
}

class _AddboardScreenState extends State<AddboardScreen> {
  final TextEditingController _nameController = TextEditingController();
  final BoardService _boardService = BoardService();
  final APIs _api = APIs();
  List<UserModel> allMembers = [];
  final List<UserModel> _selectedMembers = [];

  void _addBoard() async {
    if (_nameController.text.isNotEmpty) {
      BoardModel newBoard = BoardModel(
        id: '', // ID sẽ tự động tạo khi thêm vào Firestore
        name: _nameController.text,
        createdBy: _api.getCurrentUser()!.email!,
        members: _selectedMembers,
      );
      await _boardService.addBoard(newBoard);
      Navigator.pop(navigatorKey.currentContext!); // Quay lại màn hình trước
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a board name')));
    }
  }

  loadUser() async {
    List<UserModel> users = await _api.getUsers();

    setState(() {
      allMembers = users;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Board'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Board Name'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount:
                    allMembers.length, // Giả sử bạn đã có danh sách thành viên
                itemBuilder: (context, index) {
                  final member = allMembers[index];
                  return ListTile(
                    title: Text(member.username),
                    trailing: Checkbox(
                      value: _selectedMembers.contains(member),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedMembers.add(member);
                          } else {
                            _selectedMembers.remove(member);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addBoard,
              child: const Text('Add Board'),
            ),
          ],
        ),
      ),
    );
  }
}
