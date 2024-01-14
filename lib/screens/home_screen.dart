import 'package:flutter/material.dart';
import 'package:h_bits/components/my_drawer.dart';
import 'package:h_bits/components/my_habit_tile.dart';
import 'package:h_bits/components/my_heat_map.dart';
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
  void editHabitBox(Habit habit) {
    // set the controller's text to the habit's current name
    textController.text = habit.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: () {
              // get the new habit name
              String newHabitName = textController.text;

              // save to DB
              context
                  .read<HabitDatabase>()
                  .updateHabitNmae(habit.id, newHabitName);

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

  // delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to delete?'),
        actions: [
          // delete button
          MaterialButton(
            onPressed: () {
              // save to DB
              context.read<HabitDatabase>().deleteHabit(habit.id);

              // pop box
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
          // cancel button
          MaterialButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(
          Icons.add,
        ),
      ),
      drawer: const MyDrawer(),
      body: ListView(
        children: [
          // heat map
          _buildHeatMap(),

          // habit list
          _buildHabitList(),
        ],
      ),
    );
  }

  // build heat map
  Widget _buildHeatMap() {
    // habit database
    final habitDatabase = context.watch<HabitDatabase>();

    // current habits
    List<Habit> currentHabits = habitDatabase.curretHabits;

    // return heatmap UI
    return FutureBuilder(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        // once the data is available -> build heatmap
        if (snapshot.hasData) {
          return MyHeatMap(
              startDate: snapshot.data!,
              datasets: prepHeatMapDataset(currentHabits));
        }

        // handle case whre no data is returned
        else {
          return Container();
        }
      },
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
  }
}
