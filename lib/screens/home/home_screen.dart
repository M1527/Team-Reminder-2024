import 'package:abc/api/apis.dart';
import 'package:abc/main.dart';
import 'package:abc/screens/home/edit_board_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/board_model.dart';
import '../../services/board_service.dart';
import '../task/list_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BoardService _boardService = BoardService();
  final APIs api = APIs();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Project'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
               Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/addboard');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _boardService.getBoardsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No boards found.'));
          }

          List<BoardModel> boards = snapshot.data!.docs.map((doc) {
            return BoardModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: boards.length,
            itemBuilder: (context, index) {
              final board = boards[index];
              return Dismissible(
                key: Key(board.id), // Khóa duy nhất cho mỗi board
                background: Container(
                  color: Colors.red,
                  alignment: AlignmentDirectional.centerEnd,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await _showDeleteDialog(context, board.name);
                },
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  // check if the board is created by the current user
                  if (board.createdBy != api.getCurrentUser()!.email!) {
                    ScaffoldMessenger.of(navigatorKey.currentContext!)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                            'You are not allowed to delete board "${board.name}"'),
                      ),
                    );
                    return;
                  } else {
                    await _boardService.deleteBoard(board.id);
                    ScaffoldMessenger.of(navigatorKey.currentContext!)
                        .showSnackBar(
                      SnackBar(content: Text('Board "${board.name}" deleted')),
                    );
                  }
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(board.name),
                    subtitle: Text('Created by: ${board.createdBy}'),
                    onLongPress: () {
                      if (board.createdBy == api.getCurrentUser()!.email!) {
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (context) {
                          return EditBoardScreen(board: board);
                        }));
                      }
                    },
                    onTap: () {
                      // check member of board and navigate to list task screen
                      for (var member in board.members) {
                        if (member.email == api.getCurrentUser()!.email ||
                            board.createdBy == api.getCurrentUser()!.email) {
                          Navigator.push(context,
                              CupertinoPageRoute(builder: (context) {
                            return ListTaskScreen(idBoard: board.id);
                          }));
                          return;
                        }
                      }
                      ScaffoldMessenger.of(navigatorKey.currentContext!)
                          .showSnackBar(
                        const SnackBar(
                          content:
                              Text('You are not allowed to view this board'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, String boardName) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Board'),
          content:
              Text('Are you sure you want to delete the board "$boardName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
