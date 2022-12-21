import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/workout_list/models/workouts.dart';
import 'package:workoutplanner/workout_list/screen_start_workout.dart';

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
  bool snackBarOn = false;

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

    Widget startButton() {
      return Expanded(
        child: ElevatedButton(
            onPressed: () {
              if (targetWorkout.workoutItems.isEmpty) {
                snackBarOn
                    ? null
                    : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text("Rundown Cannot be Empty!"),
                        behavior: SnackBarBehavior.floating,
                        onVisible: () {
                          snackBarOn = true;
                          Future.delayed(const Duration(seconds: 4))
                              .then((value) => snackBarOn = false);
                        },
                      ));
                return;
              }
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => StartWorkoutScreen(
                        workout: targetWorkout,
                      )));
            },
            style: const ButtonStyle(
                elevation: MaterialStatePropertyAll(0),
                shape: MaterialStatePropertyAll(
                    BeveledRectangleBorder(borderRadius: BorderRadius.zero))),
            child: const Text("Start Workout")),
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
              setState(() {
                editing = false;
              });
            },
            child: const Text("Cancel")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: createNew
            ? const Text("New Workout")
            : Text(
                editing ? "Editing ${targetWorkout.name}" : targetWorkout.name),
        actions: [
          createNew
              ? Container()
              : IconButton(
                  onPressed: () => setState(() {
                    editing = !editing;
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                editing ? cancelButton() : Container(),
                editing ? submitButton() : startButton(),
              ],
            )),
      ),
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
          editing
              ? ListTile(
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
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Icon(Icons.add), Text(" Add Item")],
                  ))
              : const ListTile(title: Center(child: Text("End of Rundown"))),
        ],
      ),
    );
  }

  Widget listbuilder() {
    return ReorderableListView.builder(
      physics: const ScrollPhysics(),
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
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      key: ValueKey(workoutItemList[index]),
      children: [
        Dismissible(
          direction:
              editing ? DismissDirection.startToEnd : DismissDirection.none,
          movementDuration: const Duration(milliseconds: 200),
          key: ValueKey(workoutItemList[index]),
          onDismissed: ((direction) => setState(() {
                workoutItemList.remove(item);
              })),
          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.red,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
    WorkoutItem item = workoutItemList[index];
    return ListTile(
      horizontalTitleGap: 0,
      leading: editing
          ? ReorderableDragStartListener(
              index: index, child: const Icon(Icons.drag_indicator))
          : null,
      title: Text(item.name),
      subtitle: Text(
          "${item.reps} ${item.exerciseCountType} | ${item.sets} Sets | ${item.restTime}s Rest"),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (_) => WorkoutItemEditScreen(
                    targetWorkoutItem: item,
                  )))
          .then((value) {
        if (value.runtimeType == WorkoutItem) {
          setState(() {
            if (workoutItemList[index] != value && value is WorkoutItem) {
              workoutItemList[index] = value;
              submitForm();
            }
          });
        }
      }),
      // trailing: IconButton(
      //   icon:  Icon(Icons.more_vert),
      //   onPressed: () => print("object"),
      // ),
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

  void submitForm() {
    print("object");
    if (!_formKey.currentState!.validate()) return;

    targetWorkout.name = _controllerTitle.text;
    targetWorkout.workoutItems = workoutItemList;

    ref.read(workoutManagerProvider.future).then((value) async {
      bool succeed = await value.addWorkout(targetWorkout);
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
}
