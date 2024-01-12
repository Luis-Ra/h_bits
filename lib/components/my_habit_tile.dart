import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final String text;
  final bool isCompleted;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;

  const MyHabitTile(
      {super.key,
      required this.isCompleted,
      required this.text,
      this.onChanged,
      this.editHabit,
      this.deleteHabit});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        // edit option
        SlidableAction(
          onPressed: editHabit,
          backgroundColor: Colors.grey.shade800,
          icon: Icons.settings,
          borderRadius: BorderRadius.circular(8),
        ),

        // delete option
        SlidableAction(
          onPressed: deleteHabit,
          backgroundColor: Colors.red,
          icon: Icons.delete,
          borderRadius: BorderRadius.circular(8),
        ),
      ]),
      child: GestureDetector(
        onTap: () {
          if (onChanged != null) {
            // toggle completion status
            onChanged!(!isCompleted);
          }
        },
        child: Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary,
            ),
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            child: ListTile(
              title: Text(text),
              leading: Checkbox(
                  activeColor: Colors.green,
                  value: isCompleted,
                  onChanged: onChanged),
            )),
      ),
    );
  }
}
