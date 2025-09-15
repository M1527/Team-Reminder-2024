import 'dart:developer';

import 'package:abc/api/apis.dart';
import 'package:abc/constants.dart';
import 'package:abc/main.dart';
import 'package:abc/model/task_mode.dart';
import 'package:abc/services/list_service.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/list_model.dart';
import '../../model/user_model.dart';
import '../../widgets/create_task_card.dart';
import '../../widgets/task_card_widget.dart';
import '../../widgets/task_create_dialog.dart';
import 'report_screen.dart';
import 'task_screen.dart';

class ListTaskScreen extends StatefulWidget {
  ListTaskScreen({super.key, required this.idBoard});
  String idBoard;

  @override
  State<ListTaskScreen> createState() => _ListTaskScreenState();
}

class _ListTaskScreenState extends State<ListTaskScreen> {
  final ListService _listService = ListService();
  List<UserModel> allMembers = [];
  List<ListModel> _lists = [];
  final APIs api = APIs();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Task Screen'),
        actions: [
          // show screen report
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ReportScreen(
                    boardId: widget.idBoard,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart),
          ),
        ],
      ),
      body: StreamBuilder<List<ListModel>>(
        stream: _listService.getListsByIdBoardStream(widget.idBoard),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No lists found.'));
          }

          _lists = snapshot.data!;
          List<ListModel>? lists = snapshot.data;
          List<DragAndDropList> contents = [];

          lists?.forEach((element) {
            contents.add(DragAndDropList(
                header: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                  child: Text(
                    element.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                ),
                footer: element.name.compareTo(TaskStatus.todo.value) == 0
                    ? CreateTaskCard(onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Center(
                            child: TaskCreateDialog(
                              idList: element.id,
                              idBoard: widget.idBoard,
                            ),
                          ),
                        );
                      })
                    : Container(),
                children: element.tasks.map((task) {
                  return DragAndDropItem(
                    child: TaskCardWidget(
                      heading: task.heading,
                      body: task.body,
                      allMembers: task.members,
                      endTimeStamp: task.endTime,
                      onClick: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskScreen(
                              taskCard: task,
                              listId: element.id!,
                              boardId: widget.idBoard,
                            ),
                          ),
                        );
                      },
                      onDelete: () async {
                        if (task.createdBy != api.getCurrentUser()?.uid) {
                          return showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Task'),
                              content: const Text(
                                  'You are not the creator of this task. You cannot delete it.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                        return showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Task'),
                            content: const Text(
                                'Are you sure you want to delete this task?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await ListService().removeTaskFromList(
                                      element.id!, task.taskId!);
                                  Navigator.pop(navigatorKey.currentContext!);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList()));
          });

          return DragAndDropLists(
            children: contents,
            onItemReorder: _onItemReorder,
            onListReorder: _onListReorder,
            axis: Axis.horizontal,
            listWidth: 180,
            listDraggingWidth: 180,
            listDecoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(Radius.circular(7.0)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black45,
                  spreadRadius: 3.0,
                  blurRadius: 6.0,
                  offset: Offset(2, 3),
                ),
              ],
            ),
            listPadding: const EdgeInsets.all(8.0),
          );
        },
      ),
    );
  }

  _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex,
      int newListIndex) async {
    try {
      TaskCard movedTask = _lists[oldListIndex].tasks[oldItemIndex];
      await ListService().removeTaskFromList(_lists[oldListIndex].id!,
          _lists[oldListIndex].tasks[oldItemIndex].taskId!);
      await ListService().addTaskToListAtPosition(
          _lists[newListIndex].id!, movedTask, newItemIndex);
    } catch (e) {
      log('Failed to update tasks in Firebase: $e');
    }
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    log('oldListIndex: $oldListIndex, newListIndex: $newListIndex');
  }
}
