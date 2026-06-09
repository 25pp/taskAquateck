import 'dart:async';

import 'package:demo_apk_aquaktech/core/task_repo.dart';
import 'package:demo_apk_aquaktech/models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

class _TaskStringNotifier extends Notifier<String> {
  final String _default;
  _TaskStringNotifier(this._default);

  @override
  String build() => _default;
  void set(String value) => state = value;
}

class _TaskIntNotifier extends Notifier<int> {
  final int _default;
  _TaskIntNotifier(this._default);

  @override
  int build() => _default;
  void set(int value) => state = value;
}

final taskSearchQueryProvider =
    NotifierProvider<_TaskStringNotifier, String>(() => _TaskStringNotifier(''));

final taskSelectedFilterProvider =
    NotifierProvider<_TaskStringNotifier, String>(() => _TaskStringNotifier('All'));

final taskDisplayCountProvider =
    NotifierProvider<_TaskIntNotifier, int>(() => _TaskIntNotifier(20));

class TaskDebouncedSearchNotifier extends Notifier<String> {
  Timer? _timer;

  @override
  String build() {
    ref.onDispose(() => _timer?.cancel());
    return '';
  }

  void updateQuery(String query) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 400), () {
      state = query;
      ref.read(taskDisplayCountProvider.notifier).set(20);
    });
  }
}

final taskDebouncedSearchProvider =
    NotifierProvider<TaskDebouncedSearchNotifier, String>(
  TaskDebouncedSearchNotifier.new,
);

class TaskNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() async {
    final repo = ref.read(taskRepositoryProvider);
    final cached = await repo.getCachedTasks();
    if (cached != null && cached.isNotEmpty) {
      _fetchFreshInBackground(repo);
      return cached;
    }
    return repo.fetchTasks();
  }

  Future<void> _fetchFreshInBackground(TaskRepository repo) async {
    try {
      final fresh = await repo.fetchTasks();
      if (state.hasValue) state = AsyncValue.data(fresh);
    } catch (_) {}
  }

  Future<void> refreshTasks() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await ref.read(taskRepositoryProvider).fetchTasks());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final taskNotifierProvider =
    AsyncNotifierProvider<TaskNotifier, List<TaskModel>>(
  TaskNotifier.new,
);

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasksAsync = ref.watch(taskNotifierProvider);
  final search = ref.watch(taskDebouncedSearchProvider).toLowerCase();
  final filter = ref.watch(taskSelectedFilterProvider);

  return tasksAsync.when(
    data: (tasks) => tasks.where((t) {
      if (search.isNotEmpty) {
        final idMatch = t.id.toString().contains(search);
        final titleMatch = t.title.toLowerCase().contains(search);
        if (!idMatch && !titleMatch) return false;
      }

      if (filter == 'All') return true;
      if (filter == 'Open' && t.status != 'Open') return false;
      if (filter == 'In Progress' && t.status != 'In Progress') return false;
      if (filter == 'Resolved' && t.status != 'Resolved') return false;
      if (filter == 'High Priority' && t.priority != 'High') return false;
      if (filter == 'Medium Priority' && t.priority != 'Medium') return false;
      if (filter == 'Low Priority' && t.priority != 'Low') return false;

      return true;
    }).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

final paginatedTasksProvider = Provider<List<TaskModel>>((ref) {
  final all = ref.watch(filteredTasksProvider);
  final count = ref.watch(taskDisplayCountProvider);
  return all.take(count).toList();
});

final hasMoreTasksProvider = Provider<bool>((ref) {
  final all = ref.watch(filteredTasksProvider);
  final count = ref.watch(taskDisplayCountProvider);
  return all.length > count;
});
