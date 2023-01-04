import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';
import 'package:workoutplanner/exercise_list/screen_edit_exercise.dart';

class ExerciseList extends ConsumerStatefulWidget {
  const ExerciseList({super.key, this.picker = false});
  final bool picker;

  @override
  ConsumerState<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends ConsumerState<ExerciseList> {
  // List<String> list = List<String>.generate(10000, (i) => 'Item $i')

  final TextEditingController _controllerSearchbar = TextEditingController();

  List<Exercise> _foundList = [];
  List<Exercise> _actualList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final exerciseList = ref.watch(exerciseListNotifierProvider);

    buildListView() {
      return exerciseList.when(
        data: (list) {
          _actualList = list;
          searchExercise(_controllerSearchbar.text);
          return Expanded(child: listbuilder(_foundList));
        },
        loading: (() => const Center(child: CircularProgressIndicator())),
        error: ((error, stack) => Text(error.toString())),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercise List"),
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
                builder: ((context) => const ExerciseEditScreen()),
              ),
            ),
          ),
        ],
      ),
      // body: listbuilder(exerciseList),
      body: Column(
        children: [
          searchBar(),
          buildListView(),
        ],
      ),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controllerSearchbar,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: "Exercise Name",
          border: InputBorder.none,
        ),
        onChanged: (e) => searchExercise(e),
      ),
    );
  }

  void searchExercise(String query) {
    final suggestions = _actualList.where((element) {
      final exerciseName = element.name.toLowerCase();
      final input = query.toLowerCase();

      return exerciseName.contains(input);
    }).toList();

    setState(() {
      _foundList = suggestions;
    });
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
          onTap: () => widget.picker
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
