import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/customer.dart';
import '../../../../shared/models/ticket.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/services/mock_data.dart';

class CustomerDetailPage extends StatefulWidget {
  final String customerId;
  const CustomerDetailPage({super.key, required this.customerId});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage>
    with SingleTickerProviderStateMixin {
  late Customer _customer;
  late TabController _tabCtrl;
  final _noteCtrl = TextEditingController();
  final List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _customer = MockData.customers.firstWhere(
      (c) => c.id == widget.customerId,
      orElse: () => MockData.customers.first,
    );
    _tabCtrl = TabController(length: 5, vsync: this);

    if (_customer.notes != null && _customer.notes!.isNotEmpty) {
      _notes.add({
        'author': 'System / Triage',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'text': _customer.notes!,
      });
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  List<Ticket> get _customerTickets =>
      MockData.tickets.where((t) => t.customerId == _customer.id).toList();

  List<SupportTask> get _customerTasks =>
      MockData.tasks.where((t) => t.customerId == _customer.id).toList();

  void _showEditCustomerDialog() {
    final nameCtrl = TextEditingController(text: _customer.fullName);
    final emailCtrl = TextEditingController(text: _customer.email ?? '');
    final phoneCtrl = TextEditingController(text: _customer.phone ?? '');
    final companyCtrl = TextEditingController(text: _customer.company ?? '');
    final tagsCtrl = TextEditingController(text: _customer.tags.join(', '));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Edit Customer Profile'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: companyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Company / Organization',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'VIP, Enterprise, High Value',
                    border: OutlineInputBorder(),
                  ),
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
              if (nameCtrl.text.trim().isEmpty) return;
              final newTags = tagsCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              setState(() {
                _customer = _customer.copyWith(
                  fullName: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                  company: companyCtrl.text.trim().isEmpty ? null : companyCtrl.text.trim(),
                  tags: newTags,
                  updatedAt: DateTime.now(),
                );
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Customer profile updated successfully!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showCreateTaskDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    TaskPriority priority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_task_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Schedule Follow-Up Task'),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Task Title *',
                    hintText: 'e.g., Follow up on license renewal',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description / Notes',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskPriority>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskPriority.values
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDlgState(() => priority = v);
                  },
                ),
              ],
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
                final newTask = SupportTask(
                  id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  customerId: _customer.id,
                  customerName: _customer.fullName,
                  assignedAgentName: 'Akash Pandey',
                  priority: priority,
                  status: TaskStatus.todo,
                  dueDate: DateTime.now().add(const Duration(days: 2)),
                  createdAt: DateTime.now(),
                );
                setState(() {
                  MockData.tasks.insert(0, newTask);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Follow-up task scheduled.'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Schedule Task'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Text(_customer.fullName),
            const SizedBox(width: 8),
            if (_customer.tags.contains('VIP'))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('New Ticket'),
            onPressed: () => context.push(AppRoutes.createTicket),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: _showEditCustomerDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? AppSpacing.pageHorizontal : AppSpacing.lg),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildMain()),
                  const SizedBox(width: AppSpacing.xl2),
                  SizedBox(width: 320, child: _buildSidebar()),
                ],
              )
            : Column(
                children: [
                  _buildSidebar(),
                  const SizedBox(height: AppSpacing.xl2),
                  _buildMain(),
                ],
              ),
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Cards
        Row(
          children: [
            _KpiMini('Total Tickets', '${_customer.totalTickets}', AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            _KpiMini('Open', '${_customer.openTickets}', AppColors.statusOpen),
            const SizedBox(width: AppSpacing.md),
            _KpiMini('Active Tasks', '${_customerTasks.where((t) => t.status != TaskStatus.completed).length}', const Color(0xFF0D9488)),
            const SizedBox(width: AppSpacing.md),
            _KpiMini(
              'CSAT Score',
              _customer.csatAvg != null ? '${_customer.csatAvg!.toStringAsFixed(1)} ★' : '4.9 ★',
              AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl2),

        // Tabs
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: 'Tickets (${_customerTickets.length})'),
                  const Tab(text: 'Conversations'),
                  Tab(text: 'Tasks & Follow-Ups (${_customerTasks.length})'),
                  const Tab(text: 'Activity Timeline'),
                  Tab(text: 'Internal Notes (${_notes.length})'),
                ],
              ),
              SizedBox(
                height: 440,
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildTicketsTab(),
                    _buildConversationsTab(),
                    _buildTasksTab(),
                    _buildActivityTab(),
                    _buildNotesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsTab() {
    final tickets = _customerTickets;
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.confirmation_number_outlined, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              'No tickets found for this customer',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Create First Ticket'),
              onPressed: () => context.push(AppRoutes.createTicket),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final t = tickets[i];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.confirmation_number_rounded, color: AppColors.primary, size: 20),
          ),
          title: Text(t.subject, style: AppTypography.bodySmMedium),
          subtitle: Text(
            '${t.ticketNumber} · ${t.priority.label} · Created ${_timeAgo(t.createdAt)}',
            style: AppTypography.bodyXs.copyWith(color: AppColors.textTertiary),
          ),
          trailing: _StatusChip(t.status.label),
          onTap: () => context.push('${AppRoutes.tickets}/${t.id}'),
        );
      },
    );
  }

  Widget _buildConversationsTab() {
    final convs = MockData.conversations.where((c) => c.customerId == _customer.id).toList();
    if (convs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              'No active conversations',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_rounded, size: 16),
              label: const Text('Start Chat in Inbox'),
              onPressed: () => context.go(AppRoutes.inbox),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: convs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final c = convs[i];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary, size: 20),
          ),
          title: Text(
            c.lastMessage ?? 'No messages',
            style: AppTypography.bodySmMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            'Channel: ${c.channel.name.toUpperCase()} · Unread: ${c.unreadCount}',
            style: AppTypography.bodyXs.copyWith(color: AppColors.textTertiary),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          onTap: () => context.go(AppRoutes.inbox),
        );
      },
    );
  }

  Widget _buildTasksTab() {
    final tasks = _customerTasks;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Text(
                'Follow-Ups & Action Items',
                style: AppTypography.bodySmSemiBold.copyWith(color: const Color(0xFF0F172A)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 14),
                label: const Text('Schedule Follow-Up', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
                onPressed: _showCreateTaskDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.checklist_rounded, size: 44, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 8),
                      Text(
                        'No follow-up tasks scheduled',
                        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final t = tasks[i];
                    final isDone = t.status == TaskStatus.completed;
                    return CheckboxListTile(
                      value: isDone,
                      activeColor: AppColors.success,
                      title: Text(
                        t.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        'Due: ${t.dueDate != null ? _timeAgo(t.dueDate!) : "Soon"} · Assignee: ${t.assignedAgentName ?? "Unassigned"}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: switch (t.priority) {
                            TaskPriority.urgent => const Color(0xFFFEE2E2),
                            TaskPriority.high => const Color(0xFFFEF3C7),
                            TaskPriority.medium => const Color(0xFFE0E7FF),
                            TaskPriority.low => const Color(0xFFF1F5F9),
                          },
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          t.priority.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: switch (t.priority) {
                              TaskPriority.urgent => const Color(0xFFDC2626),
                              TaskPriority.high => const Color(0xFFD97706),
                              TaskPriority.medium => const Color(0xFF4F46E5),
                              TaskPriority.low => const Color(0xFF64748B),
                            },
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          final idx = MockData.tasks.indexWhere((k) => k.id == t.id);
                          if (idx != -1) {
                            MockData.tasks[idx] = t.copyWith(
                              status: val == true ? TaskStatus.completed : TaskStatus.inProgress,
                            );
                          }
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActivityTab() {
    final timeline = [
      ('Today, 10:30 AM', 'Ticket #10452 escalated by Akash Pandey'),
      ('Yesterday, 4:15 PM', 'Customer submitted feedback: 5 Stars ★★★★★'),
      ('Sep 8, 2026', 'Customer initiated Live Chat inquiry'),
      ('Sep 5, 2026', 'Subscription tier upgraded to Enterprise'),
      ('Aug 30, 2026', 'Customer account created and verified'),
    ];
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: timeline.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
                Container(width: 1, height: 40, color: AppColors.border),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$1, style: AppTypography.labelSm.copyWith(color: AppColors.textTertiary)),
                  const SizedBox(height: 2),
                  Text(item.$2, style: AppTypography.bodySmMedium),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: Text(
                      'No internal notes yet. Add one below.',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: _notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final n = _notes[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.sticky_note_2_rounded, size: 14, color: Color(0xFFD97706)),
                                const SizedBox(width: 6),
                                Text(
                                  n['author'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _timeAgo(n['date'] as DateTime),
                                  style: const TextStyle(fontSize: 10, color: Color(0xFFB45309)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              n['text'] as String,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF78350F), height: 1.4),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Add an internal note about this customer...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded, size: 14),
                label: const Text('Save Note'),
                onPressed: () {
                  if (_noteCtrl.text.trim().isEmpty) return;
                  setState(() {
                    _notes.insert(0, {
                      'author': 'Akash Pandey',
                      'date': DateTime.now(),
                      'text': _noteCtrl.text.trim(),
                    });
                    _noteCtrl.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Internal note added.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.accent]),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Center(
                    child: Text(
                      _customer.initials,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(_customer.fullName, style: AppTypography.h6, textAlign: TextAlign.center),
                if (_customer.company != null)
                  Text(
                    _customer.company!,
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                if (_customer.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: _customer.tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(t, style: AppTypography.labelSm.copyWith(color: AppColors.primary)),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Quick Communication Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickActionCircle(
                icon: Icons.email_outlined,
                tooltip: 'Send Email',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening mail composer to ${_customer.email ?? "customer"}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _QuickActionCircle(
                icon: Icons.phone_outlined,
                tooltip: 'Call Phone',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${_customer.phone ?? "registered number"}...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _QuickActionCircle(
                icon: Icons.chat_bubble_outline_rounded,
                tooltip: 'Open Live Chat',
                onTap: () => context.go(AppRoutes.inbox),
              ),
              _QuickActionCircle(
                icon: Icons.add_task_rounded,
                tooltip: 'Schedule Task',
                onTap: _showCreateTaskDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _InfoRow('Email', _customer.email ?? '—'),
          _InfoRow('Phone', _customer.phone ?? '—'),
          _InfoRow('Company', _customer.company ?? '—'),
          if (_customer.lastInteractionAt != null)
            _InfoRow('Last Seen', _timeAgo(_customer.lastInteractionAt!)),
        ],
      ),
    );
  }
}

class _QuickActionCircle extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _QuickActionCircle({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF475569)),
        ),
      ),
    );
  }
}

class _KpiMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _KpiMini(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.h5.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip(this.label);
  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'Open' => AppColors.statusOpen,
      'Pending' => AppColors.statusPending,
      'Resolved' => AppColors.statusResolved,
      _ => AppColors.statusClosed,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: AppTypography.labelSm.copyWith(color: color)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: AppTypography.bodyXsMedium.copyWith(color: AppColors.textTertiary)),
          ),
          Expanded(child: Text(value, style: AppTypography.bodySmMedium)),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
