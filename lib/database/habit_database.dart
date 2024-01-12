import 'package:flutter/cupertino.dart';
import 'package:h_bits/models/app_settings.dart';
import 'package:h_bits/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  /*
  S E T U P
  */
  //  I N I T I A L I Z E - DATABASE
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  // Sabe first date of app startup (for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..fristLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // Get first date of app startup (for heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.fristLaunchDate;
  }

  /*
  CRUD OPERATIONS 
  */
  // List of habits
  final List<Habit> curretHabits = [];

  // CREATE - add a new habit
  Future<void> addHabit(String habitName) async {
    // create a new habit
    final newHabit = Habit()..name = habitName;
    // sabe to DB
    await isar.writeTxn(() => isar.habits.put(newHabit));
    // re-read from DB
    readHabits();
  }

  // READ - read saved habits from DB
  Future<void> readHabits() async {
    // fetch all habits from DB
    List<Habit> fetchedHabits = await isar.habits.where().findAll();
    // give to current habits
    curretHabits.clear();
    curretHabits.addAll(fetchedHabits);
    // update the UI
    notifyListeners();
  }

  // UPDATE - check habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // find the specific habit
    final habit = await isar.habits.get(id);
    // update the completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        // if habit is completed -> add the current date to the completedDays list
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          // today
          final today = DateTime.now();
          // add the current day if it's not alredy in the list
          habit.completedDays.add(DateTime(today.year, today.month, today.day));
        }
        //  if the habit is not completed -> remove the current day from the list
        else {
          // remove the current habit date if the habit is not completed
          habit.completedDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        // save the update habits back to the DB
        await isar.habits.put(habit);
      });
    }
    // re read from DB
    readHabits();
  }

  // UPDATE - edit habit name
  Future<void> updateHabitNmae(int id, String newName) async {
    // find the specific habit
    final habit = await isar.habits.get(id);

    // update habit  name
    if (habit != null) {
      // update name
      await isar.writeTxn(() async {
        habit.name = newName;
        // save updated habit back to the DB
        await isar.habits.put(habit);
      });
    }

    // re-read from DB
    readHabits();
  }

  // DELETE - delete habit
  Future<void> deleteHabit(int id) async {
    // perform the delete
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    // re-read  from DB
    readHabits();
  }
}
