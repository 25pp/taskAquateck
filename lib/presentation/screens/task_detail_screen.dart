import 'package:demo_apk_aquaktech/models/task_model.dart';
import 'package:demo_apk_aquaktech/presentation/widgets/priority_badge.dart';
import 'package:demo_apk_aquaktech/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  List<Map<String, String>> _buildTimeline() {
    final timeline = <Map<String, String>>[
      {"title": "Complaint Created", "subtitle": "Ticket #${task.id} registered in system"},
      {"title": "Assigned to ${task.assignedTo}", "subtitle": "Engineer picked up the case"},
    ];

    if (task.status == "Open") {
      timeline.add({"title": "Status: Open", "subtitle": "Complaint is being reviewed"});
    } else if (task.status == "In Progress") {
      timeline.add({"title": "Status: Open", "subtitle": "Complaint is being reviewed"});
      timeline.add({"title": "Status: In Progress", "subtitle": "Work started on the issue"});
    } else if (task.status == "Resolved") {
      timeline.add({"title": "Status: Open", "subtitle": "Complaint is being reviewed"});
      timeline.add({"title": "Status: In Progress", "subtitle": "Work started on the issue"});
      timeline.add({"title": "Status: Resolved", "subtitle": "Issue fixed and verified"});
    }

    return timeline;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey.shade100;
    final bodyColor = isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.8) : Colors.grey.shade800;
    final labelColor = isDark ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : Colors.grey.shade600;
    final timeline = _buildTimeline();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaint Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Complaint #${task.id}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              task.body,
              style: TextStyle(
                fontSize: 15,
                color: bodyColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow("Status", StatusBadge(status: task.status), labelColor),
                  const Divider(),
                  _detailRow("Priority", PriorityBadge(priority: task.priority), labelColor),
                  const Divider(),
                  _detailRow(
                    "Assigned Engineer",
                    Text(
                      task.assignedTo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    labelColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Activity Timeline",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ..._timelineWidgets(timeline, theme),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, Widget value, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: labelColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: value,
          ),
        ],
      ),
    );
  }

  List<Widget> _timelineWidgets(List<Map<String, String>> items, ThemeData theme) {
    final List<Widget> widgets = [];
    for (int i = 0; i < items.length; i++) {
      final isLast = i == items.length - 1;
      widgets.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[i]["title"]!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i]["subtitle"]!,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return widgets;
  }
}
