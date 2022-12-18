import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/workout_list/models/workouts.dart';

import 'screen_edit_workout_items.dart';

class WorkoutEditScreen extends ConsumerStatefulWidget {
  const WorkoutEditScreen({super.key, this.targetWorkout});

  final Workout? targetWorkout;

  @override
  ConsumerState<WorkoutEditScreen> createState() => _WorkoutEditScreenState();
}

class _WorkoutEditScreenState extends ConsumerState<WorkoutEditScreen> {
  final _formKey = GlobalKey<FormState>();

  Workout targetWorkout = Workout();
  bool createNew = true;
  bool editing = true;
  bool nameExists = false;
  List<WorkoutItem> workoutItemList = [];

  final TextEditingController _controllerTitle = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.targetWorkout != null) {
      targetWorkout = widget.targetWorkout!;
      createNew = false;
      editing = false;
      workoutItemList = targetWorkout.workoutItems.toList();
      _controllerTitle.text = targetWorkout.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    void submitForm() {
      if (!_formKey.currentState!.validate()) return;

      targetWorkout.name = _controllerTitle.text;
      targetWorkout.workoutItems = workoutItemList;

      ref.read(workoutManagerProvider.future).then((value) async {
        bool succeed = await value.addWorkout(targetWorkout);
        if (succeed) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        } else {
          nameExists = true;
          !_formKey.currentState!.validate();
          nameExists = false;
        }
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
                    BeveledRectangleBorder(borderRadius: BorderRadius.zero))),
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
            ? const Text("New Workout")
            : Text("Editing ${targetWorkout.name}"),
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
            titleForm(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Workout Rundown"),
            ),
            const Divider(),
            workoutRundown(),
          ],
        ),
      ),
    );
  }

  Expanded workoutRundown() {
    return Expanded(
      child: ListView(
        children: [
          listbuilder(),
          ListTile(
              onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (_) => const WorkoutItemEditScreen()))
                      .then((value) {
                    if (value.runtimeType == WorkoutItem) {
                      setState(() {
                        workoutItemList.add(value);
                      });
                    }
                  }),
              title: const Icon(Icons.add)),
        ],
      ),
    );
  }

  Widget listbuilder() {
    return ReorderableListView.builder(
      dragStartBehavior: DragStartBehavior.start,
      buildDefaultDragHandles: false,
      shrinkWrap: true,
      itemCount: workoutItemList.length,
      prototypeItem: const ListTile(
        title: Text("list.first.name"),
      ),
      itemBuilder: (context, index) {
        return listItemBuilder(index);
      },
      onReorder: (int oldIndex, int newIndex) {
        newIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
        workoutItemList.insert(newIndex, workoutItemList.removeAt(oldIndex));
      },
    );
  }

  Widget listItemBuilder(int index) {
    WorkoutItem item = workoutItemList[index];
    return Column(
      key: ValueKey(workoutItemList[index]),
      children: [
        Dismissible(
          direction: DismissDirection.startToEnd,
          movementDuration: const Duration(milliseconds: 200),
          key: ValueKey(workoutItemList[index]),
          confirmDismiss: (direction) async {
            return true;
          },
          onDismissed: ((direction) => setState(() {
                workoutItemList.remove(item);
              })),
          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: AlignmentDirectional.centerStart,
            color: Colors.red,
            child: Row(
              children: const [
                Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
          child: listTileBuilder(index),
        ),
      ],
    );
  }

  ListTile listTileBuilder(int index) {
    return ListTile(
      leading: ReorderableDragStartListener(
          index: index, child: const Icon(Icons.drag_indicator)),
      title: Text(workoutItemList[index].name),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (_) => WorkoutItemEditScreen(
                    targetWorkoutItem: workoutItemList[index],
                  )))
          .then((value) {
        if (value.runtimeType == WorkoutItem) {
          setState(() {
            workoutItemList[index] = value;
          });
        }
      }),
      // trailing: IconButton(
      //   icon: const Icon(Icons.more_vert),
      //   onPressed: () => print("object"),
      // ),
    );
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
