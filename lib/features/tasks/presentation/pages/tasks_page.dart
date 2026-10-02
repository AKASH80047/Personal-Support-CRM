import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/models/customer.dart';
import '../../../../shared/models/ticket.dart';
import '../../../../shared/services/mock_data.dart';
import '../../../../shared/widgets/app_modals.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedPriority = 'All Priorities';
  String _selectedAssignee = 'All Assignees';
  late List<SupportTask> _tasks;

  final List<String> _tabs = ['Today', 'Upcoming', 'Overdue', 'Completed', 'All Tasks'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tasks = List.from(MockData.tasks);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SupportTask> get _filteredTasks {
    var list = _tasks;

    // Tab filter
    switch (_tabCtrl.index) {
      case 0: // Today
        list = list.where((t) => t.isToday && t.status != TaskStatus.completed).toList();
        break;
      case 1: // Upcoming
        final now = DateTime.now();
        list = list.where((t) => t.dueDate != null && t.dueDate!.isAfter(now) && !t.isToday && t.status != TaskStatus.completed).toList();
        break;
      case 2: // Overdue
        list = list.where((t) => t.isOverdue).toList();
        break;
      case 3: // Completed
        list = list.where((t) => t.status == TaskStatus.completed).toList();
        break;
      case 4: // All
      default:
        break;
    }

    // Search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) =>
          t.title.toLowerCase().contains(q) ||
          (t.description?.toLowerCase().contains(q) ?? false) ||
          (t.customerName?.toLowerCase().contains(q) ?? false) ||
          (t.ticketNumber?.toLowerCase().contains(q) ?? false) ||
          (t.assigneeName?.toLowerCase().contains(q) ?? false)).toList();
    }

    // Priority filter
    if (_selectedPriority != 'All Priorities') {
      list = list.where((t) => t.priority.label == _selectedPriority).toList();
    }

    // Assignee filter
    if (_selectedAssignee != 'All Assignees') {
      list = list.where((t) => t.assigneeName == _selectedAssignee).toList();
    }

    return list;
  }

  void _toggleTaskStatus(SupportTask task) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        final newStatus = task.status == TaskStatus.completed ? TaskStatus.todo : TaskStatus.completed;
        _tasks[idx] = task.copyWith(
          status: newStatus,
          completedAt: newStatus == TaskStatus.completed ? DateTime.now() : null,
        );
      }
    });

    final isDone = task.status != TaskStatus.completed;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isDone ? Icons.check_circle_rounded : Icons.replay_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(isDone ? 'Task marked as completed! 🎉' : 'Task marked as open.'),
          ],
        ),
        backgroundColor: isDone ? const Color(0xFF10B981) : const Color(0xFF2563EB),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCreateTaskDialog({SupportTask? existingTask, String? defaultCustomerId, String? defaultCustomerName, String? defaultTicketId, String? defaultTicketNumber}) {
    final titleCtrl = TextEditingController(text: existingTask?.title ?? '');
    final descCtrl = TextEditingController(text: existingTask?.description ?? '');
    final notesCtrl = TextEditingController(text: existingTask?.notes ?? '');
    TaskPriority priority = existingTask?.priority ?? TaskPriority.high;
    DateTime dueDate = existingTask?.dueDate ?? DateTime.now().add(const Duration(hours: 4));
    String? selectedCustomer = existingTask?.customerName ?? defaultCustomerName ?? (MockData.customers.isNotEmpty ? MockData.customers.first.fullName : null);
    String? selectedTicket = existingTask?.ticketNumber ?? defaultTicketNumber;
    String? selectedAssignee = existingTask?.assigneeName ?? MockData.agents.first.fullName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_task_rounded, color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                existingTask == null ? 'Create Task / Follow-Up' : 'Edit Support Task',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Task Title *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Call customer to verify Stripe webhook resolution',
                      prefixIcon: Icon(Icons.title_rounded, size: 18),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('Description / Instructions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Context or specific steps to take for this follow-up...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      // Priority Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Priority', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<TaskPriority>(
                              value: priority,
                              items: TaskPriority.values.map((p) => DropdownMenuItem(
                                value: p,
                                child: Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: BoxDecoration(color: Color(p.colorValue), shape: BoxShape.circle)),
                                    const SizedBox(width: 8),
                                    Text(p.label, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              )).toList(),
                              onChanged: (val) => setDialogState(() => priority = val!),
                              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Assignee Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Assignee', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedAssignee,
                              items: MockData.agents.map((a) => DropdownMenuItem(
                                value: a.fullName,
                                child: Text(a.fullName, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (val) => setDialogState(() => selectedAssignee = val),
                              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      // Customer Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Linked Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String?>(
                              value: selectedCustomer,
                              items: [
                                const DropdownMenuItem(value: null, child: Text('None / Internal Task')),
                                ...MockData.customers.map((c) => DropdownMenuItem(
                                  value: c.fullName,
                                  child: Text(c.fullName, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                )),
                              ],
                              onChanged: (val) => setDialogState(() => selectedCustomer = val),
                              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Ticket Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Linked Ticket (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String?>(
                              value: selectedTicket,
                              items: [
                                const DropdownMenuItem(value: null, child: Text('None')),
                                ...MockData.tickets.take(6).map((t) => DropdownMenuItem(
                                  value: t.ticketNumber,
                                  child: Text('${t.ticketNumber} · ${t.subject.substring(0, t.subject.length > 15 ? 15 : t.subject.length)}...',
                                    style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                )),
                              ],
                              onChanged: (val) => setDialogState(() => selectedTicket = val),
                              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Due Date & Time Picker Row
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Due Date & Target Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (pickedDate != null) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(dueDate),
                            );
                            setDialogState(() {
                              dueDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime?.hour ?? dueDate.hour,
                                pickedTime?.minute ?? dueDate.minute,
                              );
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF2563EB)),
                              const SizedBox(width: 10),
                              Text(
                                '${dueDate.day}/${dueDate.month}/${dueDate.year} at ${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                              ),
                              const Spacer(),
                              const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                setState(() {
                  if (existingTask != null) {
                    final idx = _tasks.indexWhere((t) => t.id == existingTask.id);
                    if (idx != -1) {
                      _tasks[idx] = existingTask.copyWith(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                        priority: priority,
                        assigneeName: selectedAssignee,
                        customerName: selectedCustomer,
                        ticketNumber: selectedTicket,
                        dueDate: dueDate,
                      );
                    }
                  } else {
                    _tasks.insert(
                      0,
                      SupportTask(
                        id: 'task-${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                        priority: priority,
                        status: TaskStatus.todo,
                        assigneeName: selectedAssignee,
                        customerName: selectedCustomer,
                        ticketNumber: selectedTicket,
                        dueDate: dueDate,
                        createdAt: DateTime.now(),
                      ),
                    );
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(existingTask == null ? '✅ Task created and scheduled!' : 'Task updated successfully.'),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(existingTask == null ? 'Create Task' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTask(String taskId) {
    setState(() {
      _tasks.removeWhere((t) => t.id == taskId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted.'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayCount = _tasks.where((t) => t.isToday && t.status != TaskStatus.completed).length;
    final overdueCount = _tasks.where((t) => t.isOverdue).length;
    final completedCount = _tasks.where((t) => t.status == TaskStatus.completed).length;
    final inProgressCount = _tasks.where((t) => t.status == TaskStatus.inProgress).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ 1. Header (Tasks & Follow-Ups + New Task Button) ─
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tasks & Follow-Ups',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track customer commitments, follow-ups, and support callbacks in real-time.',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => showExportDataDialog(
                    context,
                    title: 'Tasks & Follow-Ups',
                    countText: '${_filteredTasks.length} tasks',
                  ),
                  icon: const Icon(Icons.file_download_outlined, size: 16, color: Color(0xFF475569)),
                  label: const Text('Export', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showCreateTaskDialog(),
                  icon: const Icon(Icons.add_task_rounded, size: 18, color: Colors.white),
                  label: const Text('New Task / Follow-Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─ 2. KPI Summary Cards ─
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              return GridView.count(
                crossAxisCount: isNarrow ? 2 : 4,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isNarrow ? 2.2 : 2.5,
                children: [
                  _buildStatCard('Due Today', '$todayCount', Icons.today_rounded, const Color(0xFF2563EB), 'Scheduled for today'),
                  _buildStatCard('Overdue', '$overdueCount', Icons.warning_amber_rounded, const Color(0xFFEF4444), 'Requires prompt action'),
                  _buildStatCard('In Progress', '$inProgressCount', Icons.timelapse_rounded, const Color(0xFFEA580C), 'Active follow-ups'),
                  _buildStatCard('Completed', '$completedCount', Icons.check_circle_outline_rounded, const Color(0xFF10B981), 'Resolved & done'),
                ],
              );
            }),
            const SizedBox(height: 20),

            // ─ 3. Filter Bar & Search ─
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Search Box
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: const InputDecoration(
                              hintText: 'Search tasks by title, customer, ticket ID, or assignee...',
                              hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Priority Filter
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPriority,
                            items: ['All Priorities', 'Urgent', 'High', 'Medium', 'Low']
                                .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedPriority = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tabs Row
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: TabBar(
                      controller: _tabCtrl,
                      isScrollable: true,
                      labelColor: const Color(0xFF2563EB),
                      unselectedLabelColor: const Color(0xFF64748B),
                      indicatorColor: const Color(0xFF2563EB),
                      indicatorWeight: 3,
                      onTap: (_) => setState(() {}),
                      tabs: [
                        Tab(text: 'Today ($todayCount)'),
                        const Tab(text: 'Upcoming'),
                        Tab(text: 'Overdue ($overdueCount)'),
                        Tab(text: 'Completed ($completedCount)'),
                        Tab(text: 'All Tasks (${_tasks.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─ 4. Tasks List ─
            _filteredTasks.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                          child: const Icon(Icons.task_alt_rounded, size: 40, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(height: 16),
                        const Text('No Tasks Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                        const SizedBox(height: 6),
                        const Text('You are all caught up! No pending follow-ups match the selected view.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      final isCompleted = task.status == TaskStatus.completed;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCompleted ? const Color(0xFFF8FAFC) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: task.isOverdue
                                ? const Color(0xFFFCA5A5)
                                : isCompleted
                                    ? const Color(0xFFE2E8F0)
                                    : const Color(0xFFE2E8F0),
                            width: task.isOverdue ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Checkbox
                            InkWell(
                              onTap: () => _toggleTaskStatus(task),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 2, right: 14),
                                decoration: BoxDecoration(
                                  color: isCompleted ? const Color(0xFF10B981) : Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                    width: 1.8,
                                  ),
                                ),
                                child: isCompleted ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                              ),
                            ),

                            // Main Task Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ),
                                      // Priority Chip
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: Color(task.priority.colorValue).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          task.priority.label,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(task.priority.colorValue),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (task.description != null && task.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      task.description!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isCompleted ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 10),

                                  // Metadata Row
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 6,
                                    children: [
                                      // Due Date Pill
                                      if (task.dueDate != null)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 13,
                                              color: task.isOverdue ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Due: ${task.dueDate!.day}/${task.dueDate!.month} at ${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: task.isOverdue ? FontWeight.w700 : FontWeight.w500,
                                                color: task.isOverdue ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),

                                      // Linked Customer
                                      if (task.customerName != null)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF2563EB)),
                                            const SizedBox(width: 4),
                                            Text(
                                              task.customerName!,
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                                            ),
                                          ],
                                        ),

                                      // Linked Ticket Number
                                      if (task.ticketNumber != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFBFDBFE)),
                                          ),
                                          child: Text(
                                            task.ticketNumber!,
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
                                          ),
                                        ),

                                      // Assignee
                                      if (task.assigneeName != null)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.assignment_ind_outlined, size: 13, color: Color(0xFF64748B)),
                                            const SizedBox(width: 4),
                                            Text(
                                              task.assigneeName!,
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Actions Popup
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF94A3B8)),
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showCreateTaskDialog(existingTask: task);
                                } else if (val == 'toggle') {
                                  _toggleTaskStatus(task);
                                } else if (val == 'delete') {
                                  _deleteTask(task.id);
                                }
                              },
                              itemBuilder: (ctx) => [
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Row(
                                    children: [
                                      Icon(isCompleted ? Icons.replay_rounded : Icons.check_circle_rounded, size: 16),
                                      const SizedBox(width: 8),
                                      Text(isCompleted ? 'Mark Incomplete' : 'Mark Completed'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 16),
                                      const SizedBox(width: 8),
                                      Text('Edit Task'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                                      const SizedBox(width: 8),
                                      Text('Delete Task', style: TextStyle(color: Color(0xFFEF4444))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
