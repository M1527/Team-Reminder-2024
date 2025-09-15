import 'dart:developer';

import 'package:abc/constants.dart';
import 'package:abc/model/task_mode.dart';
import 'package:flutter/material.dart';

import '../../model/board_model.dart';
import '../../services/board_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.boardId});
  final String boardId;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  BoardService _boardService = BoardService();
  final List<TaskCard> _tasks = [];
  loadAllTasks() async {
    final tasks = await _boardService.getAllTasksInBoard(widget.boardId);
    log('Tasks: ${tasks.toString()}');
    setState(() {
      _tasks.addAll(tasks);
    });
  }

  @override
  void initState() {
    loadAllTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Screen'),
      ),
      body: FutureBuilder<BoardModel>(
        future: BoardService().getBoardById(widget.boardId),
        builder: (context, boardSnapshot) {
          if (boardSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (boardSnapshot.hasError) {
            return Center(child: Text('Error: ${boardSnapshot.error}'));
          }
          if (!boardSnapshot.hasData) {
            return const Center(child: Text('No board found.'));
          }

          BoardModel board = boardSnapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'My project: ${board.name}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: blackColor),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<TaskCard>>(
                  stream:
                      _boardService.getAllTasksInBoardStream(widget.boardId),
                  builder: (context, taskSnapshot) {
                    if (taskSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (taskSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${taskSnapshot.error}'));
                    }
                    if (!taskSnapshot.hasData || taskSnapshot.data!.isEmpty) {
                      return const Center(child: Text('No tasks found.'));
                    }

                    List<TaskCard> tasks = taskSnapshot.data!;
                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        TaskCard task = tasks[index];
                        final endTime = DateTime.parse(task.endTime);
                        final now = DateTime.now();
                        final duration = endTime.difference(now);
                        final daysLeft = duration.inDays;
                        final hoursLeft = duration.inHours % 24;

                        String deadlineText;
                        log('Task: ${task.status}');
                        if (task.status == 'Done' ) {
                          deadlineText = 'Completed ahead of schedule';
                        } else if (duration.isNegative &&
                            task.status != 'Done') {
                          final overdueDuration = now.difference(endTime);
                          final overdueDays = overdueDuration.inDays;
                          final overdueHours = overdueDuration.inHours % 24;
                          deadlineText =
                              'Overdue by $overdueDays days, $overdueHours hours';
                        } else {
                          deadlineText =
                              '$daysLeft days, $hoursLeft hours left';
                        }

                        return ListTile(
                          title: Text(
                            task.heading,
                            style: TextStyle(fontSize: 20),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status: ${task.status}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Deadline: $deadlineText',
                                style: TextStyle(
                                    color: task.status != 'Done'
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 16),
                              ),
                              // list of members
                              SizedBox(
                                height: 55,
                                child: ListView.separated(
                                  itemBuilder: (context, index) {
                                    final member = task.members[index];
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(member.image),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                  scrollDirection: Axis.horizontal,
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(
                                      width: 10,
                                    );
                                  },
                                  itemCount: task.members.length,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
