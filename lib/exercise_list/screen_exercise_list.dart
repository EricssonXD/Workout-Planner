import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:workoutplanner/exercise_list/screen_edit_exercise.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList({super.key});

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  List<String> list = List<String>.generate(10000, (i) => 'Item $i');
  // List<String> list = [];

  @override
  Widget build(BuildContext context) {
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
                builder: ((context) => ExerciseEditScreen()),
              ),
            ),
          ),
        ],
      ),
      body: listbuilder(),
    );
  }

  Widget listbuilder() {
    return ListView.builder(
      itemCount: list.length,
      prototypeItem: ListTile(
        title: Text(list.first),
      ),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(list[index]),
        );
      },
    );
  }
}
