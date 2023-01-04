import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';
import 'package:workoutplanner/utils/providers/isar.dart';
import 'package:workoutplanner/utils/widgets/aleart_dialogs.dart';
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
  int currentUid = 0;

  @override
  void initState() {
    super.initState();
    resetFields();
    fetchExerciseInfo();
  }

  @override
  void dispose() {
    _controllerTitle.dispose();
    super.dispose();
  }

  void fetchExerciseInfo() async {
    final Isar isar = await ref.read(isarInstanceProvider.future);

    for (int i = 0; i < workoutItemList.length; i++) {
      debugPrint(i.toString());
      Exercise? item = await isar.exercises
          .filter()
          .idEqualTo(workoutItemList[i].id)
          .findFirst();
      if (item != null) {
        if (workoutItemList[i].name != item.name) {
          debugPrint("Gave Name");
          workoutItemList[i].name = item.name;
          submitForm();
        }
      } else {
        debugPrint("noID");
        item = await isar.exercises
            .filter()
            .nameEqualTo(workoutItemList[i].name)
            .findFirst();
        if (item != null) {
          workoutItemList[i].id = item.id;
          submitForm();
          debugPrint("Gave New id");
        } else {
          workoutItemList[i].exerciseNotExist = true;
          debugPrint("Exercise Not Found");
        }
      }
    }
  }

  void resetFields() {
    if (widget.targetWorkout != null) {
      targetWorkout = widget.targetWorkout!;
      createNew = false;
      editing = false;
      setFields();
    }
  }

  void setFields() {
    workoutItemList = targetWorkout.workoutItems.toList();
    _controllerTitle.text = targetWorkout.name;
    for (int i = 0; i < workoutItemList.length; i++) {
      workoutItemList[i].uid = i;
      currentUid++;
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
            child: const Text("Save")),
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
                resetFields();
                editing = false;
              });
            },
            child: const Text("Cancel")),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (!editing) {
          return true;
        }
        return await showConfirmDiscardDialog(context) ?? false;
      },
      child: Scaffold(
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniEndDocked,
        floatingActionButton: createNew
            ? null
            : SpeedDial(
                overlayOpacity: 0,
                animatedIcon: AnimatedIcons.menu_close,
                children: [
                  SpeedDialChild(
                    child: const Icon(Icons.delete),
                    label: "Delete Workout",
                    onTap: () async {
                      bool answer = await showYesNoDialog(context,
                          title:
                              "Are you sure you want to delete this Workout?");
                      if (answer) {
                        bool success = false;
                        await ref
                            .read(workoutManagerProvider.future)
                            .then((value) async {
                          success = await value.deleteWorkout(targetWorkout.id);
                        });
                        // ignore: use_build_context_synchronously
                        success ? Navigator.of(context).pop() : null;
                      }
                    },
                  ),
                ],
              ),
        appBar: AppBar(
          title: createNew
              ? const Text("New Workout")
              : Text(editing
                  ? "Editing ${targetWorkout.name}"
                  : targetWorkout.name),
          actions: [
            createNew
                ? Container()
                : IconButton(
                    onPressed: () => setState(() {
                      if (editing) {
                        editing = false;
                        setFields();
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
            // padding: EdgeInsets.only(
            //   bottom: MediaQuery.of(context).viewInsets.bottom,
            // ),
            shape: const CircularNotchedRectangle(),
            notchMargin: 4.0,
            clipBehavior: Clip.hardEdge,
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (editing && !createNew) cancelButton(),
                editing ? submitButton() : startButton(),
              ],
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              titleForm(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Workout Rundown",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(),
              listbuilder(),
            ],
          ),
        ),
      ),
    );
  }

  Expanded workoutRundown() {
    return Expanded(
      child: ListView(
        children: [
          listbuilder(),
        ],
      ),
    );
  }

  Widget listbuilder() {
    return Expanded(
      child: ReorderableListView.builder(
        physics: const ScrollPhysics(),
        dragStartBehavior: DragStartBehavior.start,
        buildDefaultDragHandles: false,
        itemCount: workoutItemList.length,
        // prototypeItem: const Dismissible(
        //   key: ValueKey("Prototype"),
        //   child: ListTile(
        //     title: Text("list.first.name"),
        //     subtitle: Text("abc"),
        //   ),
        // ),
        itemBuilder: (context, index) {
          return listItemBuilder(index);
        },
        onReorder: (int oldIndex, int newIndex) {
          newIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
          workoutItemList.insert(newIndex, workoutItemList.removeAt(oldIndex));
        },
        footer: editing
            ? ListTile(
                onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (_) => const WorkoutItemEditScreen()))
                        .then((value) {
                      if (value.runtimeType == WorkoutItem) {
                        setState(() {
                          value.uid = currentUid;
                          currentUid++;
                          workoutItemList.add(value);
                          submitForm();
                        });
                      }
                    }),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [Icon(Icons.add), Text(" Add Item")],
                ))
            : const ListTile(title: Center(child: Text("End of Rundown"))),
      ),
    );
  }

  Widget listItemBuilder(int index) {
    WorkoutItem item = workoutItemList[index];

    return Dismissible(
      direction: editing ? DismissDirection.startToEnd : DismissDirection.none,
      movementDuration: const Duration(milliseconds: 200),
      key: ValueKey(item),
      onDismissed: (direction) => setState(() {
        workoutItemList.remove(item);
      }),
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
    );
  }

  Widget listTileBuilder(int index) {
    WorkoutItem item = workoutItemList[index];
    return ListTile(
      horizontalTitleGap: 0,
      leading: editing
          ? ReorderableDragStartListener(
              index: index,
              enabled: true,
              child: const Padding(
                padding: EdgeInsets.only(right: 8.0, bottom: 8.0, top: 8.0),
                child: Icon(Icons.drag_indicator),
              ),
            )
          : null,
      trailing: editing
          ? IconButton(
              onPressed: () {
                showModalBottomSheet(
                  isDismissible: true,
                  enableDrag: true,
                  context: context,
                  builder: (context) {
                    return moreOptions(item);
                  },
                );
              },
              icon: const Icon(Icons.more_vert))
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

  Widget moreOptions(WorkoutItem item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (_) => const WorkoutItemEditScreen()))
                  .then((value) {
                if (value.runtimeType == WorkoutItem) {
                  setState(() {
                    value.uid = currentUid;
                    currentUid++;
                    workoutItemList.insert(
                        workoutItemList.indexOf(item) + 1, value);
                    submitForm();
                  });
                }
              });
            },
            title: const Center(child: Text("Insert New Exercise"))),
        const Divider(height: 0),
        ListTile(
            onTap: () => setState(() {
                  workoutItemList.remove(item);
                  Navigator.of(context).pop();
                }),
            title: const Center(child: Text("Delete"))),
      ],
    );
  }

  Future<bool?> showConfirmDiscardDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Save Changes?"),
          actions: [
            TextButton(
              child: Text(
                "No",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              child: Text(
                "Yes",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
                submitForm();
              },
            ),
          ],
        );
      },
    );
  }
}
