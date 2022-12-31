import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool requireRepInput = true;

  late WorkoutItem targetWorkoutItem;
  WorkoutItem? editedItem;
  Exercise? pickedExercise;

  final _repFormKey = GlobalKey();

  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerReps = TextEditingController();
  final TextEditingController _controllerRestTime = TextEditingController();
  final TextEditingController _controllerSets = TextEditingController();
  ExerciseRepType repType = ExerciseRepType.reps;

  @override
  void initState() {
    super.initState();
    setFields();
  }

  void setFields() {
    if (widget.targetWorkoutItem != null) {
      targetWorkoutItem = widget.targetWorkoutItem!;
      createNew = false;
      editing = false;
      _controllerReps.text = targetWorkoutItem.reps.toString();
      _controllerRestTime.text = targetWorkoutItem.restTime.toString();
      _controllerSets.text = targetWorkoutItem.sets.toString();
      repType = targetWorkoutItem.exerciseCountType;
      if (repType == ExerciseRepType.reps || repType == ExerciseRepType.timed) {
        requireRepInput = true;
      }
      ref.read(isarInstanceProvider.future).then((value) async {
        pickedExercise = await value.exercises
            .filter()
            .idEqualTo(targetWorkoutItem.id)
            .findFirst();
        setState(() {});
      });
      editedItem = targetWorkoutItem;
    }
  }

  @override
  Widget build(BuildContext context) {
    void exit() {
      if (createNew && pickedExercise == null) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop(editedItem);
      }
    }

    void submitForm() {
      if (!_formKey.currentState!.validate()) return;
      if (pickedExercise == null) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please pick an Exercise")));
        return;
      }

      WorkoutItem newItem = WorkoutItem()
        ..name = pickedExercise!.name
        ..id = pickedExercise!.id
        ..exerciseCountType = repType
        ..reps = int.parse(_controllerReps.text)
        ..sets = int.parse(_controllerSets.text)
        ..restTime = int.parse(_controllerRestTime.text);

      editedItem = newItem;
      setState(() {
        editing = false;
      });
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
            child: const Text("Save")),
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
              // Navigator.of(context).pop();
              setFields();
            },
            child: const Text("Cancel")),
      );
    }

    Widget backButton() {
      return ElevatedButton(
          style: const ButtonStyle(
              elevation: MaterialStatePropertyAll(0),
              shape: MaterialStatePropertyAll(
                  BeveledRectangleBorder(borderRadius: BorderRadius.zero))),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Back"));
    }

    return WillPopScope(
      onWillPop: () async {
        exit();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => exit(),
          ),
          title: createNew
              ? const Text("New Workout Item")
              : Text(editing
                  ? "Editing ${targetWorkoutItem.name}"
                  : targetWorkoutItem.name),
          actions: [
            createNew
                ? Container()
                : IconButton(
                    onPressed: () => setState(() {
                      if (editing) {
                        editing = false;
                        setFields();
                      } else {
                        editing = true;
                      }
                    }),
                    icon: Icon(
                      Icons.edit,
                      color: editing ? Colors.black : Colors.white,
                    ),
                  )
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: BottomAppBar(
            height: 50,
            child: editing
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      cancelButton(),
                      submitButton(),
                    ],
                  )
                : backButton(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              exercisePicker(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    requireRepInput ? repForm() : Container(),
                    repsTypeForm(),
                  ],
                ),
              ),
              setForm(),
              restTimeForm(),
            ],
          ),
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
        title: Center(child: Text("Exercise: ${pickedExercise!.name}")),
        onTap: () => editing ? pickExercise() : null,
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

  Widget repForm() {
    return Flexible(
      child: TextFormField(
        enabled: editing,
        validator: (value) {
          if (value == null || value.isEmpty) {
            _controllerReps.text = "8";
          }
          return null;
        },
        keyboardType: TextInputType.number,
        controller: _controllerReps,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          label: repFormInputText(),
          hintText: "8",
        ),
      ),
    );
  }

  Widget repFormInputText() {
    switch (repType) {
      case ExerciseRepType.reps:
        return const Text("Number of Reps");
      case ExerciseRepType.timed:
        return const Text("Duration of Exercise");
      default:
        return const Text("");
    }
  }

  Widget repsTypeForm() {
    return DropdownButton<ExerciseRepType>(
        key: _repFormKey,
        value: repType,
        onChanged: editing
            ? (ExerciseRepType? newValue) {
                setState(() {
                  repType = newValue ?? ExerciseRepType.reps;
                  if (repType == ExerciseRepType.maxRep ||
                      repType == ExerciseRepType.maxTime) {
                    requireRepInput = false;
                  } else {
                    requireRepInput = true;
                  }
                });
              }
            : null,
        items: ExerciseRepType.values.map((ExerciseRepType repType) {
          return DropdownMenuItem<ExerciseRepType>(
              value: repType, child: Text(repType.toString()));
        }).toList());
  }

  Widget setForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        enabled: editing,
        validator: (value) {
          if (value == null || value.isEmpty) {
            _controllerSets.text = '3';
          }
          return null;
        },
        keyboardType: TextInputType.number,
        controller: _controllerSets,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          label: Text("Number of Sets"),
          hintText: "3",
        ),
      ),
    );
  }

  Widget restTimeForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        enabled: editing,
        validator: (value) {
          if (value == null || value.isEmpty) {
            _controllerRestTime.text = "60";
          }
          return null;
        },
        keyboardType: TextInputType.number,
        controller: _controllerRestTime,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          label: Text("Rest Time"),
          hintText: "60",
        ),
      ),
    );
  }
}
