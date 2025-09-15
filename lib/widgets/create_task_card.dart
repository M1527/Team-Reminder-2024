import 'package:flutter/material.dart';

class CreateTaskCard extends StatelessWidget {
  final Function() onPressed;
  const CreateTaskCard({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        color: Colors.grey,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.add,
              ),
              SizedBox(width: 8),
              Text('Create Task'),
            ],
          ),
        ),
      ),
    );
  }
}
