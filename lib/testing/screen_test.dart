import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/utils/riverpod.dart';

class TestScreen extends HookConsumerWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(helloWorldProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Testing"),
      ),
      body: Center(child: Text(exercise)),
    );
  }
}
