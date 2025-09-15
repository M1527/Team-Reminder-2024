import 'dart:developer';

import 'package:abc/api/apis.dart';
import 'package:abc/constants.dart';
import 'package:abc/services/list_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/chat_message.dart';
import '../../model/task_mode.dart';
import '../../services/chat_service.dart';
import '../../utils/time_util.dart';
import '../../widgets/task_create_dialog.dart';

class TaskScreen extends StatefulWidget {
  TaskScreen(
      {super.key, required this.taskCard, required this.listId, this.boardId});
  TaskCard taskCard;
  final String listId;
  final String? boardId;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final TextEditingController messageController = TextEditingController();
    final ListService listService = ListService();
    final APIs api = APIs();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Screen',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              log("Edit task ${widget.taskCard.toString()}");
              // check if the user is the owner of the task
              if (widget.taskCard.createdBy != api.getCurrentUser()!.uid) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error'),
                    content: const Text(
                        'You are not the owner of this task, you cannot edit it'),
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
                return;
              }
              showDialog(
                context: context,
                builder: (context) => Center(
                  child: TaskCreateDialog(
                    taskCard: widget.taskCard,
                    idList: widget.listId,
                    idBoard: widget.boardId,
                    isFromEdit: true,
                    onSave: (task) async {
                      await listService.updateTaskInList(widget.listId, task);
                      log(task.toString());
                      setState(() {
                        widget.taskCard = task;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.taskCard.heading,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                widget.taskCard.body,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Members',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 55,
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final member = widget.taskCard.members[index];
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
                          )),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 10,
                    );
                  },
                  itemCount: widget.taskCard.members.length,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deadline',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        reformatDateTime(widget.taskCard.endTime),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  widget.taskCard.status == TaskStatus.done.value
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Actual End Time',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              reformatDateTime(widget.taskCard.actualEndTime ?? ""),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              widget.taskCard.status == TaskStatus.done.value
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Time Spend',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          '${widget.taskCard.totalTimeSpend}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Container(),
              // chat here
              const SizedBox(height: 10),

              Container(
                height: 400, // Adjust the height as needed
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: StreamBuilder<List<ChatMessage>>(
                  stream: chatService
                      .getChatMessagesStream(widget.taskCard.taskId ??" "),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ListTile(
                          title: Text(
                            message.sender,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(message.message),
                          trailing: Text(
                            DateFormat('HH:mm').format(message.timestamp),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter your message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      if (messageController.text.isNotEmpty) {
                        final message = ChatMessage(
                          sender: APIs().getCurrentUser()?.email ?? "",
                          message: messageController.text,
                          timestamp: DateTime.now(),
                        );
                        await chatService.sendMessage(
                            widget.taskCard.taskId ?? "", message);
                        messageController.clear();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
