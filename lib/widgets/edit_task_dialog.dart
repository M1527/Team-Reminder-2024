import 'dart:developer';

import 'package:abc/constants.dart';
import 'package:abc/main.dart';
import 'package:abc/services/board_service.dart';
import 'package:abc/services/list_service.dart';
import 'package:abc/utils/time_util.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../api/apis.dart';
import '../model/task_mode.dart';
import '../model/user_model.dart';

class EditTaskDialog extends StatefulWidget {
  final TaskCard? taskCard;
  final bool isFromEdit;
  final String? idList;
  final String? idBoard;
  Function(TaskCard)? onSave;
  EditTaskDialog({
    super.key,
    this.taskCard,
    this.isFromEdit = false,
    this.idList,
    this.idBoard,
    this.onSave,
  }) : super();

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final TextEditingController _headingTextEditingController =
      TextEditingController();

  final TextEditingController _descriptionTextEditingController =
      TextEditingController();
  final APIs _api = APIs();
  List<UserModel> _selectedMembers = [];
  List<UserModel> allMembers = [];
  final BoardService _boardService = BoardService();

  loadUser() async {
    List<UserModel> members =
        await _boardService.getMembersByBoardId(widget.idBoard!);
    setState(() {
      allMembers = members;
      _selectedMembers.clear();
      _selectedMembers.addAll(widget.taskCard!.members);
    });
  }

  // load first all fields
  loadField() {
    if (widget.isFromEdit && widget.taskCard != null) {
      _headingTextEditingController.text = widget.taskCard!.heading;
      _descriptionTextEditingController.text = widget.taskCard!.body;
    }
  }

  String endTimeStamp = DateTime.now().toString();

  @override
  void initState() {
    loadUser();
    loadField();
    super.initState();
  }

  final bool isSmall = true;

  @override
  Widget build(BuildContext context) {
    if (widget.isFromEdit && widget.taskCard != null) {
      endTimeStamp = widget.taskCard!.endTime;
    }

    const Uuid uuid = Uuid();
    return Card(
        margin: const EdgeInsets.only(left: 16.0, right: 16),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 16,
              ),
              // TItle
              Text(
                widget.isFromEdit ? 'Edit Task' : 'Create Task',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _headingTextEditingController,
                decoration: const InputDecoration(
                  labelText: 'Heading',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {},
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextFormField(
                  controller: _descriptionTextEditingController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              DateTimePicker(
                type: DateTimePickerType.dateTimeSeparate,
                dateMask: 'dd MM yyyy',
                initialValue: endTimeStamp,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                icon: const Icon(Icons.event),
                onChanged: (val) {
                  endTimeStamp = val;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Members',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 55,
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final member = allMembers[index];
                    return GestureDetector(
                      onTap: () {
                        if (_selectedMembers.contains(member)) {
                          _selectedMembers.remove(member);
                        } else {
                          _selectedMembers.add(member);
                        }
                        setState(() {
                          _selectedMembers = _selectedMembers;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedMembers.contains(member)
                                ? primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(member.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: null,
                      ),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 10,
                    );
                  },
                  itemCount: allMembers.length,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  // check validation
                  if (_headingTextEditingController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter heading'),
                      ),
                    );
                    return;
                  }
                  if (_descriptionTextEditingController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter description'),
                      ),
                    );
                    return;
                  }
                  if (widget.isFromEdit) {
                    log(widget.taskCard!.actualEndTime.toString());
                    final updatedTask = TaskCard(
                      taskId: widget.taskCard!.taskId,
                      heading: _headingTextEditingController.text,
                      body: _descriptionTextEditingController.text,
                      endTime: endTimeStamp,
                      members: _selectedMembers,
                      createdAt: widget.taskCard!.createdAt,
                      actualEndTime: widget.taskCard!.actualEndTime,
                      createdBy: widget.taskCard!.createdBy,
                      status: widget.taskCard!.status,
                    );
                    await ListService()
                        .updateTaskInList(widget.idList!, updatedTask);
                    widget.onSave!(updatedTask);
                  } else {
                    await ListService().addTaskToList(
                        widget.idList!,
                        TaskCard(
                          taskId: uuid.v4().toString(),
                          heading: _headingTextEditingController.text,
                          body: _descriptionTextEditingController.text,
                          endTime: endTimeStamp,
                          members: _selectedMembers,
                          createdAt: formatDateTime(DateTime.now()),
                          createdBy: _api.getCurrentUser()!.uid.toString(),
                          status: 'todo',
                        ));
                  }
                  Navigator.pop(navigatorKey.currentContext!);
                },
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 16.0, left: 16, top: 8, bottom: 8),
                      child: Text(
                        widget.isFromEdit ? 'Update' : 'Create',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ));
  }
}
