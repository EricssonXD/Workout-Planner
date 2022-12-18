import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';
import 'package:workoutplanner/exercise_list/screen_exercise_list.dart';
import 'package:workoutplanner/utils/providers/isar.dart';
import 'package:workoutplanner/workout_list/models/workouts.dart';

class WorkoutItemEditScreen extends ConsumerStatefulWidget {
  const WorkoutItemEditScreen({super.key, this.targetWorkoutItem});

  final WorkoutItem? targetWorkoutItem;

  @override
  ConsumerState<WorkoutItemEditScreen> createState() =>
      _WorkoutItemEditScreenState();
}

class _WorkoutItemEditScreenState extends ConsumerState<WorkoutItemEditScreen> {
  final _formKey = GlobalKey<FormState>();

  bool createNew = true;
  bool editing = true;
  bool nameExists = false;

  late WorkoutItem targetWorkoutItem;
  Exercise? pickedExercise;

  final TextEditingController _controllerTitle = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.targetWorkoutItem != null) {
      targetWorkoutItem = widget.targetWorkoutItem!;
      createNew = false;
      editing = false;
      _controllerTitle.text = targetWorkoutItem.name;
      ref.read(isarInstanceProvider.future).then((value) async {
        pickedExercise = await value.exercises
            .filter()
            .nameEqualTo(targetWorkoutItem.name)
            .findFirst();
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void submitForm() {
      if (!_formKey.currentState!.validate()) return;

      WorkoutItem newItem = WorkoutItem()
        ..name = pickedExercise!.name
        ..id = pickedExercise!.id;
      Navigator.of(context).pop(newItem);
    }

    Widget submitButton() {
      return Expanded(
        child: ElevatedButton(
            onPressed: () {
              submitForm();
            },
            style: const ButtonStyle(
              elevation: MaterialStatePropertyAll(0),
              shape: MaterialStatePropertyAll(
                  BeveledRectangleBorder(borderRadius: BorderRadius.zero)),
            ),
            child: const Text("Done")),
      );
    }

    Widget cancelButton() {
      return Expanded(
        child: ElevatedButton(
            style: const ButtonStyle(
                elevation: MaterialStatePropertyAll(0),
                shape: MaterialStatePropertyAll(
                    BeveledRectangleBorder(borderRadius: BorderRadius.zero))),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: createNew
            ? const Text("New Workout Item")
            : Text("Editing ${targetWorkoutItem.name}"),
      ),
      bottomNavigationBar: BottomAppBar(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              cancelButton(),
              submitButton(),
            ],
          )),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            exercisePicker(),
          ],
        ),
      ),
    );
  }

  Widget exercisePicker() {
    if (pickedExercise == null) {
      return ListTile(
        onTap: () => pickExercise(),
        title: const Icon(Icons.add),
      );
    } else {
      return ListTile(
        title: Text("${pickedExercise!.name} * ${pickedExercise!.defaultReps}"),
        onTap: () => pickExercise(),
      );
    }
  }

  void pickExercise() {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => const ExerciseList(
            picker: true,
          ),
        ))
        .then((value) => setState(() {
              pickedExercise = value ?? pickedExercise;
            }));
  }

  Widget titleForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _controllerTitle,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            _controllerTitle.text = "";
            return 'Workout Name is Required!';
          }
          _controllerTitle.text = value.trim();
          return nameExists ? "Workout Already Exists!" : null;
        },
        decoration: const InputDecoration(
          label: Text("Name of Workout"),
          hintText: "My Chest Workout",
        ),
      ),
    );
  }
}
