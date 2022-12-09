import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';

class ExerciseEditScreen extends StatelessWidget {
  ExerciseEditScreen({super.key});

  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerReps = TextEditingController();
  final TextEditingController _controllerSets = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Exercise"),
      ),
      body: Form(
        child: Column(children: [
          formTitleBox(_controllerTitle),
          formNumberBox(_controllerReps),
          formNumberBox(_controllerSets),
          ElevatedButton(
              onPressed: () => print("yeet"), child: const Text("Done")),
        ]),
      ),
    );
  }

  Widget formNumberBox(TextEditingController controller) {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: controller,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  Widget formTitleBox(TextEditingController controller) {
    return TextFormField(
      controller: controller,
    );
  }

  void submitForm() {
    Exercise newExercise = Exercise()
      ..name = _controllerTitle.text
      ..defaultReps = _controllerReps.text as int
      ..defaultSets = _controllerSets.text as int;
  }
}
