import 'package:abc/main.dart';
import 'package:flutter/material.dart';

import '../../api/apis.dart';
import '../../model/board_model.dart';
import '../../model/user_model.dart';
import '../../services/board_service.dart';

class EditBoardScreen extends StatefulWidget {
  final BoardModel board;

  const EditBoardScreen({super.key, required this.board});

  @override
  State<EditBoardScreen> createState() => _EditBoardScreenState();
}

class _EditBoardScreenState extends State<EditBoardScreen> {
  final TextEditingController _nameController = TextEditingController();
  final BoardService _boardService = BoardService();
  List<UserModel> allMembers = [];
  final APIs _api = APIs();
  final List<UserModel> _selectedMembers = [];

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
    _nameController.text = widget.board.name;
    _selectedMembers.addAll(widget.board.members);
  }

  void _updateBoard() async {
    if (_nameController.text.isNotEmpty) {
      BoardModel updatedBoard = BoardModel(
        id: widget.board.id,
        name: _nameController.text,
        createdBy: widget.board.createdBy,
        members: _selectedMembers,
      );
      await _boardService.updateBoard(updatedBoard);
      Navigator.pop(navigatorKey.currentContext!);
    } else {
      // Hiển thị thông báo nếu tên board trống
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a board name')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Board'),
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
                itemCount: allMembers.length,
                itemBuilder: (context, index) {
                  final user = allMembers[index];

                  bool isSelected = false;
                  for (var member in _selectedMembers) {
                    if (member.id == user.id) {
                      isSelected = true;
                      break;
                    }
                  }
                  return CheckboxListTile(
                    title: Text(user.username),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedMembers.add(user);
                        } else {
                          _selectedMembers.remove(user);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _updateBoard,
              child: const Text('Update Board'),
            ),
          ],
        ),
      ),
    );
  }
}
