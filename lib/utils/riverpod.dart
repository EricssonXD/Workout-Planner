import 'package:hooks_riverpod/hooks_riverpod.dart';

final exerciseProvider = StateProvider<int>((ref) {
  return 50;
});

final helloWorldProvider = Provider<String>((ref) {
  return 'Hello world';
});
