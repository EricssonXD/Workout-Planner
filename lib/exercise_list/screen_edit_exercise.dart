import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';

class ExerciseEditScreen extends ConsumerWidget {
  ExerciseEditScreen({super.key});

  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerReps = TextEditingController();
  final TextEditingController _controllerSets = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final exerciseManager = ref.watch(exerciseManagerProvider.future);

    void submitForm() async {
      Exercise newExercise = Exercise()
        ..name = _controllerTitle.text
        ..defaultReps = int.parse(_controllerReps.text)
        ..defaultSets = int.parse(_controllerSets.text);
      ref
          .read(exerciseManagerProvider.future)
          .then((value) => value.addExercise(newExercise));
      Navigator.of(context).pop();
    }

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
              onPressed: () => submitForm(), child: const Text("Done")),
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
}
