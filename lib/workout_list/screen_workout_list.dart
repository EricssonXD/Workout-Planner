import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/workout_list/models/workouts.dart';
import 'package:workoutplanner/workout_list/screen_edit_workout.dart';

class WorkoutList extends ConsumerWidget {
  const WorkoutList({super.key});
  // List<String> list = List<String>.generate(10000, (i) => 'Item $i')
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutList = ref.watch(workoutListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout List"),
      ),
      floatingActionButton: SpeedDial(
        overlayOpacity: 0,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          // SpeedDialChild(
          //   child: const Icon(Icons.delete),
          //   label: "Delete",
          // ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: "Add New",
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const WorkoutEditScreen()),
              ),
            ),
          ),
        ],
      ),
      // body: listbuilder(exerciseList),
      body: workoutList.when(
        data: (list) {
          return listbuilder(list);
        },
        loading: (() => const Center(child: CircularProgressIndicator())),
        error: ((error, stack) => Text(error.toString())),
      ),
    );
  }

  Widget listbuilder(List<Workout> list) {
    return ListView.builder(
      itemCount: list.length,
      prototypeItem: const ListTile(
        title: Text("list.first.name"),
      ),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(list[index].name),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => WorkoutEditScreen(
                    targetWorkout: list[index],
                  ))),
        );
      },
    );
  }
}
