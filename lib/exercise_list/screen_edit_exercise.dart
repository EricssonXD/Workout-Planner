import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';

class ExerciseEditScreen extends ConsumerWidget {
  ExerciseEditScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerReps = TextEditingController();
  final TextEditingController _controllerSets = TextEditingController();
  final TextEditingController _controllerRestTime = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final exerciseManager = ref.watch(exerciseManagerProvider.future);

    void submitForm() {
      if (!_formKey.currentState!.validate()) return;

      Exercise newExercise = Exercise()
        ..name = _controllerTitle.text
        ..defaultReps = int.parse(_controllerReps.text)
        ..defaultSets = int.parse(_controllerSets.text);

      ref
          .read(exerciseManagerProvider.future)
          .then((value) => value.addExercise(newExercise));

      Navigator.of(context).pop();
    }

    Widget submitButton() {
      return ElevatedButton(
          onPressed: () {
            submitForm();
          },
          child: const Text("Done"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Exercise"),
      ),
      body: Form(
        key: _formKey,
        child: Column(children: [
          titleForm(),
          repForm(),
          setForm(),
          restTimeForm(),
          submitButton(),
        ]),
      ),
    );
  }

  Widget titleForm() {
    return TextFormField(
      controller: _controllerTitle,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          _controllerTitle.text = "";
          return 'Exercise Name is Required!';
        }
        _controllerTitle.text = value.trim();
        return null;
      },
      decoration: const InputDecoration(
        label: Text("Name of Exercise"),
        hintText: "Push Ups",
      ),
    );
  }

  Widget setForm() {
    return TextFormField(
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
    );
  }

  Widget repForm() {
    return TextFormField(
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
      decoration: const InputDecoration(
        label: Text("Number of Reps"),
        hintText: "8",
      ),
    );
  }

  Widget restTimeForm() {
    return TextFormField(
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
    );
  }
}
