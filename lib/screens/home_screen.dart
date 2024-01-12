import 'package:flutter/material.dart';
import 'package:h_bits/components/my_frawer.dart';
import 'package:h_bits/components/my_habit_tile.dart';
import 'package:h_bits/database/habit_database.dart';
import 'package:h_bits/models/habit.dart';
import 'package:provider/provider.dart';
import 'package:h_bits/util/habit_util.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // read exiton habit on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  // text controller
  final TextEditingController textController = TextEditingController();

// cretate new Habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Crea un nuevo habito',
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              // get the new habit name
              String newHabitName = textController.text;

              // save to DB
              context.read<HabitDatabase>().addHabit(newHabitName);

              // pop box
              Navigator.pop(context);

              // clear controller
              textController.clear();
            },
            child: const Text('Save'),
          ),
          // cancel button
          MaterialButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);

              // clear the controller
              textController.clear();
            },
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  // check habit on and off
  void checkHabitOnOff(bool? value, Habit habit) {
    // update habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  // edit habit  box

  // delete habit box

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(
          Icons.add,
        ),
      ),
      drawer: const MyDrawer(),
      body: _buildHabitList(),
    );
  }

  // build habit list
  Widget _buildHabitList() {
    // habit DB
    final habitDtabase = context.watch<HabitDatabase>();

    // get the current habits
    List<Habit> currentHabits = habitDtabase.curretHabits;

    // return the list to the UI
    return ListView.builder(
      itemCount: currentHabits.length,
      itemBuilder: (BuildContext context, int index) {
        // get ech individual habit
        final habit = currentHabits[index];

        // check if the habit is completd today
        bool isCompledToday = isHabitCompletedToday(habit.completedDays);
        // return to tile UI
        return MyHabitTile(
          isCompleted: isCompledToday,
          text: habit.name,
          onChanged: (value) => checkHabitOnOff(value, habit),
        );
      },
    );
  }
}
