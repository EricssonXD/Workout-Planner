import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';
import 'package:workoutplanner/exercise_list/screen_edit_exercise.dart';

class ExerciseList extends ConsumerWidget {
  const ExerciseList({super.key, this.picker = false});
  final bool picker;

  // List<String> list = List<String>.generate(10000, (i) => 'Item $i')
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseList = ref.watch(exerciseListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercise List"),
      ),
      floatingActionButton: SpeedDial(
        overlayOpacity: 0,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.delete),
            label: "Delete",
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: "Add New",
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const ExerciseEditScreen()),
              ),
            ),
          ),
        ],
      ),
      // body: listbuilder(exerciseList),
      body: exerciseList.when(
        data: (list) {
          return listbuilder(list);
        },
        loading: (() => const Center(child: CircularProgressIndicator())),
        error: ((error, stack) => Text(error.toString())),
      ),
    );
  }

  Widget listbuilder(List<Exercise> list) {
    return ListView.builder(
      itemCount: list.length,
      prototypeItem: const ListTile(
        title: Text("list.first.name"),
      ),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(list[index].name),
          onTap: () => picker
              ? Navigator.of(context).pop(list[index])
              : Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) =>
                      ExerciseEditScreen(targetExercise: list[index])),
                )),
        );
      },
    );
  }
}
