import 'package:abc/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class TaskCardWidget extends StatelessWidget {
  final String heading;
  final String body;
  final List<UserModel>? allMembers;
  final String endTimeStamp;
  final Function() onClick;

  final Function() onDelete; // Add a callback for delete action

  const TaskCardWidget(
      {super.key,
      required this.heading,
      required this.body,
      required this.allMembers,
      required this.endTimeStamp,
      required this.onClick,
      required this.onDelete});
  @override
  Widget build(BuildContext context) {
    DateTime parsedDateTime = DateTime.parse(endTimeStamp);
    String formattedDateTime =
        DateFormat("dd-MM-yyyy HH:mm").format(parsedDateTime);

    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    heading,
                    maxLines: 2,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: blackColor,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    onDelete();
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              body,
              maxLines: 4,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                color: blackColor,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 30,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final member = allMembers![index];
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(member.image),
                  );
                },
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    width: 10,
                  );
                },
                itemCount: allMembers!.length,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedDateTime,
                    style: const TextStyle(
                      color: errorColor,
                      fontSize: 13.0,
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  const Icon(
                    Icons.timer_sharp,
                    color: errorColor,
                    size: 18.0,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
