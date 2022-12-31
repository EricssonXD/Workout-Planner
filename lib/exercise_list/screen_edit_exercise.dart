import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';

class ExerciseEditScreen extends ConsumerStatefulWidget {
  const ExerciseEditScreen({super.key, this.targetExercise});

  final Exercise? targetExercise;

  @override
  ConsumerState<ExerciseEditScreen> createState() => _ExerciseEditScreenState();
}

class _ExerciseEditScreenState extends ConsumerState<ExerciseEditScreen> {
  Exercise targetExercise = Exercise();

  final _formKey = GlobalKey<FormState>();
  bool createNew = true;
  bool editing = true;
  bool nameExists = false;

  final TextEditingController _controllerTitle = TextEditingController();
  // final TextEditingController _controllerReps = TextEditingController();
  // final TextEditingController _controllerSets = TextEditingController();
  // final TextEditingController _controllerRestTime = TextEditingController();

  @override
  void initState() {
    super.initState();
    setFields();
  }

  void setFields() {
    if (widget.targetExercise != null) {
      targetExercise = widget.targetExercise!;
      createNew = false;
      editing = false;
      _controllerTitle.text = targetExercise.name;
      // _controllerReps.text = targetExercise.defaultReps.toString();
      // _controllerSets.text = targetExercise.defaultSets.toString();
      // _controllerRestTime.text = targetExercise.defaultRestTime.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final exerciseManager = ref.watch(exerciseManagerProvider.future);
    void submitForm() {
      if (!_formKey.currentState!.validate()) return;

      Exercise newExercise = Exercise()..name = _controllerTitle.text;
      // ..defaultReps = int.parse(_controllerReps.text)
      // ..defaultSets = int.parse(_controllerSets.text);
      newExercise.id = targetExercise.id;

      ref.read(exerciseManagerProvider.future).then((value) async {
        bool succeed = await value.addExercise(newExercise);
        if (succeed) {
          // ignore: use_build_context_synchronously
          // Navigator.of(context).pop();
          setState(() {
            editing = false;
          });
        } else {
          nameExists = true;
          !_formKey.currentState!.validate();
          nameExists = false;
        }
      });
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

    Widget submitButton() {
      return Expanded(
        child: ElevatedButton(
            onPressed: () {
              submitForm();
            },
            style: const ButtonStyle(
                elevation: MaterialStatePropertyAll(0),
                shape: MaterialStatePropertyAll(
                    BeveledRectangleBorder(borderRadius: BorderRadius.zero))),
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
              setFields();
              setState(() {
                editing = false;
              });
            },
            child: const Text("Cancel")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(createNew
            ? "New Exercise"
            : (editing
                ? "Editing ${targetExercise.name.toString()}"
                : targetExercise.name.toString())),
        actions: [
          createNew
              ? Container()
              : IconButton(
                  onPressed: () => setState(() {
                    if (editing) {
                      setFields();
                      editing = false;
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
        child: Column(children: [
          titleForm(),
          // repForm(),
          // setForm(),
          // restTimeForm(),
        ]),
      ),
    );
  }

  Widget titleForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        enabled: editing,
        controller: _controllerTitle,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            _controllerTitle.text = "";
            return 'Exercise Name is Required!';
          }
          _controllerTitle.text = value.trim();
          return nameExists ? "Exercise Already Exists!" : null;
        },
        decoration: const InputDecoration(
          fillColor: Colors.black,
          label: Text("Name of Exercise"),
          hintText: "Push Ups",
        ),
      ),
    );
  }

  // Widget setForm() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: TextFormField(
  //       enabled: editing,
  //       validator: (value) {
  //         if (value == null || value.isEmpty) {
  //           _controllerSets.text = '3';
  //         }
  //         return null;
  //       },
  //       keyboardType: TextInputType.number,
  //       controller: _controllerSets,
  //       inputFormatters: <TextInputFormatter>[
  //         FilteringTextInputFormatter.digitsOnly,
  //       ],
  //       decoration: const InputDecoration(
  //         label: Text("Number of Sets"),
  //         hintText: "3",
  //       ),
  //     ),
  //   );
  // }

  // Widget repForm() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: TextFormField(
  //       enabled: editing,
  //       validator: (value) {
  //         if (value == null || value.isEmpty) {
  //           _controllerReps.text = "8";
  //         }
  //         return null;
  //       },
  //       keyboardType: TextInputType.number,
  //       controller: _controllerReps,
  //       inputFormatters: <TextInputFormatter>[
  //         FilteringTextInputFormatter.digitsOnly,
  //       ],
  //       decoration: const InputDecoration(
  //         label: Text("Number of Reps"),
  //         hintText: "8",
  //       ),
  //     ),
  //   );
  // }

  // Widget restTimeForm() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: TextFormField(
  //       enabled: editing,
  //       validator: (value) {
  //         if (value == null || value.isEmpty) {
  //           _controllerRestTime.text = "60";
  //         }
  //         return null;
  //       },
  //       keyboardType: TextInputType.number,
  //       controller: _controllerRestTime,
  //       inputFormatters: <TextInputFormatter>[
  //         FilteringTextInputFormatter.digitsOnly,
  //       ],
  //       decoration: const InputDecoration(
  //         label: Text("Rest Time"),
  //         hintText: "60",
  //       ),
  //     ),
  //   );
  // }
}
