import 'package:demo_apk_aquaktech/presentation/providers/task_provider.dart';
import 'package:demo_apk_aquaktech/presentation/providers/theme_provider.dart';
import 'package:demo_apk_aquaktech/presentation/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskManageScreen extends ConsumerWidget {
  const TaskManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final filtered = ref.watch(paginatedTasksProvider);
    final hasMore = ref.watch(hasMoreTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaint Manager"),
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeProvider) ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (_) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search by ID or Title",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(taskDebouncedSearchProvider.notifier).updateQuery(value);
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["All", "Open", "In Progress", "Resolved", "High Priority", "Medium Priority", "Low Priority"]
                      .map((v) => buildChip(ref, v))
                      .toList(),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                  child: Text("No Results Found"),
                )
                    : RefreshIndicator(
                  onRefresh: () => ref.read(taskNotifierProvider.notifier).refreshTasks(),
                  child: ListView.builder(
                    itemCount: filtered.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () => ref
                                  .read(taskDisplayCountProvider.notifier)
                                  .set(ref.read(taskDisplayCountProvider) + 20),
                              child: const Text("Load More"),
                            ),
                          ),
                        );
                      }
                      return TaskCard(task: filtered[index]);
                    },
                  ),
                ),
              )
            ],
          );
        },
        loading: () => const TaskSkeletonList(),
        error: (error, stack) => Center(
          child: ElevatedButton(
            onPressed: () => ref.read(taskNotifierProvider.notifier).refreshTasks(),
            child: const Text("Retry"),
          ),
        ),
      ),
    );
  }

  Widget buildChip(WidgetRef ref, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ChoiceChip(
      label: Text(value),
      selected: ref.watch(taskSelectedFilterProvider) == value,
      onSelected: (_) {
        ref.read(taskSelectedFilterProvider.notifier).set(value);
        ref.read(taskDisplayCountProvider.notifier).set(20);
      },
    ),
  );
}
