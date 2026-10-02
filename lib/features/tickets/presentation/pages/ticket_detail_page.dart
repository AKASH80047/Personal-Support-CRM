import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/ticket.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/services/mock_data.dart';

class TicketDetailPage extends StatefulWidget {
  final String ticketId;
  const TicketDetailPage({super.key, required this.ticketId});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage>
    with SingleTickerProviderStateMixin {
  late Ticket _ticket;
  final _replyCtrl = TextEditingController();
  bool _isNote = false;
  bool _showAiPanel = false;
  late TabController _tabCtrl;
  String? _attachedFileName;

  @override
  void initState() {
    super.initState();
    _ticket = MockData.tickets.firstWhere(
      (t) => t.id == widget.ticketId,
      orElse: () => MockData.tickets.first,
    );
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  void _sendReply({TicketStatus? setStatus}) {
    if (_replyCtrl.text.trim().isEmpty && _attachedFileName == null) return;
    
    final content = _replyCtrl.text.trim().isNotEmpty
        ? _replyCtrl.text.trim()
        : 'Attached file: $_attachedFileName';
        
    final msg = TicketMessage(
      id: 'msg_new_${DateTime.now().millisecondsSinceEpoch}',
      ticketId: _ticket.id,
      senderType: 'agent',
      senderName: 'Akash Pandey',
      content: content,
      isInternalNote: _isNote,
      createdAt: DateTime.now(),
    );

    final newStatus = setStatus ?? _ticket.status;

    setState(() {
      _ticket = _ticket.copyWith(
        status: newStatus,
        messages: [..._ticket.messages, msg],
        updatedAt: DateTime.now(),
      );
      _replyCtrl.clear();
      _attachedFileName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isNote ? 'Internal note added.' : 'Reply sent successfully.'),
        backgroundColor: _isNote ? const Color(0xFFD97706) : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCannedResponsesDialog() {
    final templates = [
      (
        'Request Diagnostic Logs',
        'Thank you for reaching out. To assist you faster, could you please provide your application error logs and system environment details?',
        Icons.bug_report_rounded,
      ),
      (
        'Password / Auth Reset',
        'We have initiated a secure password reset link to your registered email address. Please follow the instructions within 15 minutes to reset your credentials.',
        Icons.lock_reset_rounded,
      ),
      (
        'Engineering Escalation',
        'I have escalated this issue directly to our core engineering team (Ticket Reference: Tier-3). We will provide an update as soon as the patch is verified.',
        Icons.engineering_rounded,
      ),
      (
        'Resolution Confirmation',
        'The reported issue has now been resolved on our servers. Please verify from your side and let us know if everything is working smoothly.',
        Icons.verified_rounded,
      ),
      (
        'Refund & Billing Policy',
        'Your refund request has been processed. Depending on your financial institution, the funds will reflect on your statement within 3 to 5 business days.',
        Icons.receipt_long_rounded,
      ),
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Insert Canned Response (Macro)'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 420),
          child: ListView.separated(
            itemCount: templates.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final t = templates[i];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(t.$3, color: AppColors.primary, size: 20),
                ),
                title: Text(t.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                  t.$2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                onTap: () {
                  setState(() {
                    _replyCtrl.text = t.$2;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Macro "${t.$1}" inserted.'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAttachmentPicker() {
    final sampleFiles = [
      ('server_error_log.txt', '124 KB · Plain Text', Icons.description_outlined),
      ('screenshot_checkout_bug.png', '1.8 MB · PNG Image', Icons.image_outlined),
      ('invoice_receipt_sept2026.pdf', '450 KB · PDF Document', Icons.picture_as_pdf_outlined),
      ('system_diagnostics.json', '88 KB · JSON Data', Icons.code_rounded),
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.attach_file_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Attach File or Asset'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sampleFiles.map((file) => ListTile(
            leading: Icon(file.$3, color: AppColors.primary),
            title: Text(file.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text(file.$2, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            onTap: () {
              setState(() => _attachedFileName = file.$1);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Attached ${file.$1}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          )).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showEmojiPicker() {
    final emojis = ['👍', '🙏', '😊', '✅', '🚀', '👋', '🎉', '⏳', '💡', '⚠️', '🔥', '❤️'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quick Emoji Reaction'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: emojis.map((e) => InkWell(
            onTap: () {
              setState(() {
                _replyCtrl.text += ' $e';
              });
              Navigator.pop(ctx);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(e, style: const TextStyle(fontSize: 22)),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showCreateTaskDialog() {
    final titleCtrl = TextEditingController(text: 'Follow-up on ${_ticket.ticketNumber}');
    final descCtrl = TextEditingController(text: 'Check if customer verified fix for "${_ticket.subject}"');
    TaskPriority priority = TaskPriority.high;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_task_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Create Linked Follow-Up Task'),
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
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description / Instructions',
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
                  description: descCtrl.text.trim(),
                  ticketId: _ticket.id,
                  ticketNumber: _ticket.ticketNumber,
                  customerId: _ticket.customerId,
                  customerName: _ticket.customerName,
                  assignedAgentName: _ticket.assignedAgentName ?? 'Akash Pandey',
                  priority: priority,
                  status: TaskStatus.todo,
                  dueDate: DateTime.now().add(const Duration(days: 1)),
                  createdAt: DateTime.now(),
                );
                MockData.tasks.insert(0, newTask);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Linked Task created for ${_ticket.ticketNumber}'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTicketDialog() {
    final subjectCtrl = TextEditingController(text: _ticket.subject);
    final descCtrl = TextEditingController(text: _ticket.description);
    String category = _ticket.category ?? 'Billing';
    TicketPriority priority = _ticket.priority;
    TicketStatus status = _ticket.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit_document, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Edit Ticket Details'),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: subjectCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Subject *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<TicketPriority>(
                          value: priority,
                          decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                          items: TicketPriority.values
                              .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setDlgState(() => priority = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<TicketStatus>(
                          value: status,
                          decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                          items: TicketStatus.values
                              .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setDlgState(() => status = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: ['Billing', 'Technical', 'Account', 'Security', 'Feature Request']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDlgState(() => category = v);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (subjectCtrl.text.trim().isEmpty) return;
                setState(() {
                  _ticket = _ticket.copyWith(
                    subject: subjectCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    priority: priority,
                    status: status,
                    category: category,
                    updatedAt: DateTime.now(),
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ticket updated successfully.'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMergeDialog() {
    final otherTickets = MockData.tickets.where((t) => t.id != _ticket.id).take(5).toList();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.merge_type_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Merge Ticket with Existing'),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a target ticket to merge ${_ticket.ticketNumber} into. Messages and history will be consolidated.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              ...otherTickets.map((t) => ListTile(
                title: Text(t.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('${t.ticketNumber} · ${t.customerName ?? "Guest"}', style: const TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_rounded, size: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Merged ${_ticket.ticketNumber} into ${t.ticketNumber}'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(_ticket.ticketNumber, style: AppTypography.h5),
                const SizedBox(width: 8),
                _StatusChip(_ticket.status.label),
              ],
            ),
            Text(
              _ticket.subject,
              style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          _ActionButton(Icons.person_add_outlined, 'Assign Agent', () => _showAssignDialog()),
          _ActionButton(Icons.merge_type_rounded, 'Merge Ticket', _showMergeDialog),
          _ActionButton(Icons.edit_outlined, 'Edit Details', _showEditTicketDialog),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded),
            onSelected: (v) {
              if (v == 'Close Ticket') {
                setState(() => _ticket = _ticket.copyWith(status: TicketStatus.closed));
              } else if (v == 'Schedule Task') {
                _showCreateTaskDialog();
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$v applied.'), behavior: SnackBarBehavior.floating),
              );
            },
            itemBuilder: (_) => [
              'Schedule Task',
              'Escalate to Tier 2',
              'Mark as Spam',
              'Close Ticket',
              'Archive',
            ].map((a) => PopupMenuItem(value: a, child: Text(a))).toList(),
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: _buildConversationPane()),
                Container(width: 1, color: AppColors.border),
                SizedBox(width: 320, child: _buildInfoPane()),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildConversationPane()),
              ],
            ),
    );
  }

  // ─── Conversation Pane ─────────────────────────────────────────────────
  Widget _buildConversationPane() {
    return Column(
      children: [
        // Tabs
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabCtrl,
            tabs: const [
              Tab(text: 'Conversation & Thread'),
              Tab(text: 'Audit Activity Log'),
              Tab(text: 'Internal Notes'),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildMessages(showAll: true, notesOnly: false),
              _buildActivityLog(),
              _buildMessages(showAll: true, notesOnly: true),
            ],
          ),
        ),
        // Reply composer
        _buildReplyComposer(),
      ],
    );
  }

  Widget _buildMessages({bool showAll = true, bool notesOnly = false}) {
    final msgs = _ticket.messages
        .where((m) => notesOnly ? m.isInternalNote : !m.isInternalNote || showAll)
        .toList();
    if (msgs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 48, color: AppColors.neutral300),
            const SizedBox(height: 12),
            Text(
              notesOnly ? 'No internal notes on this ticket' : 'No messages yet',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      itemCount: msgs.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (_, i) => _MessageBubble(message: msgs[i]),
    );
  }

  Widget _buildActivityLog() {
    final activities = _ticket.activities;
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      itemCount: activities.length,
      itemBuilder: (_, i) {
        final a = activities[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5, right: 12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
                        children: [
                          TextSpan(
                            text: '${a.actorName ?? 'System'} ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: a.action.replaceAll('_', ' ')),
                          if (a.newValue != null)
                            TextSpan(
                              text: ' → ${a.newValue}',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                    Text(_timeAgo(a.createdAt),
                        style: AppTypography.bodyXs.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReplyComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar
          Row(
            children: [
              _ComposerTab('Public Reply', !_isNote, () => setState(() => _isNote = false)),
              const SizedBox(width: AppSpacing.sm),
              _ComposerTab('Internal Note (Private)', _isNote, () => setState(() => _isNote = true)),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
                label: const Text('Canned Macros', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                onPressed: _showCannedResponsesDialog,
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.secondary),
                label: const Text('AI Suggest', style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                onPressed: () => setState(() => _showAiPanel = !_showAiPanel),
              ),
            ],
          ),
          if (_showAiPanel) _buildAiPanel(),
          if (_attachedFileName != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.attach_file_rounded, size: 14, color: Color(0xFF2563EB)),
                  const SizedBox(width: 4),
                  Text(_attachedFileName!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF))),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => setState(() => _attachedFileName = null),
                    child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _replyCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: _isNote
                  ? 'Add an internal note (only team members can view)...'
                  : 'Write a reply to the customer...',
              filled: true,
              fillColor: _isNote
                  ? AppColors.warningSurface
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _isNote ? AppColors.warning : AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _isNote ? AppColors.warning.withOpacity(0.5) : AppColors.border,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file_rounded, size: 18, color: AppColors.iconDefault),
                onPressed: _showAttachmentPicker,
                tooltip: 'Attach file',
              ),
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined, size: 18, color: AppColors.iconDefault),
                onPressed: _showEmojiPicker,
                tooltip: 'Emoji reaction',
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  _replyCtrl.clear();
                  setState(() => _attachedFileName = null);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Discard'),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text(_isNote ? 'Add Note' : 'Send Reply'),
                onPressed: () => _sendReply(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiPanel() {
    const suggestions = [
      'Thank you for reaching out. I understand your concern and I\'m looking into this immediately.',
      'I\'ve checked your account and identified the issue. Let me guide you through the solution.',
      'I apologize for the inconvenience. I\'ve escalated this to our technical team for prioritized resolution.',
    ];
    const tones = ['Professional', 'Friendly', 'Concise', 'Apologetic'];

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(
                'AI Smart Reply Suggestions',
                style: AppTypography.bodySmMedium.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tones.map((t) => GestureDetector(
              onTap: () {
                _replyCtrl.text = suggestions[0];
                setState(() => _showAiPanel = false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(t, style: AppTypography.labelSm.copyWith(color: Colors.white)),
              ),
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...suggestions.map((s) => GestureDetector(
            onTap: () {
              _replyCtrl.text = s;
              setState(() => _showAiPanel = false);
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
              ),
              child: Text(
                s,
                style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ─── Info Pane ─────────────────────────────────────────────────────────
  Widget _buildInfoPane() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSection('Ticket Details', [
            _InfoRow('Status', _ticket.status.label),
            _InfoRow('Priority', _ticket.priority.label),
            _InfoRow('Category', _ticket.category ?? '—'),
            _InfoRow('Channel', _ticket.channel.label),
            if (_ticket.assignedTeamName != null)
              _InfoRow('Team', _ticket.assignedTeamName!),
            if (_ticket.tags.isNotEmpty)
              _InfoRow('Tags', _ticket.tags.join(', ')),
            _InfoRow('Created', _formatDateTime(_ticket.createdAt)),
            _InfoRow('Updated', _timeAgo(_ticket.updatedAt)),
          ]),
          const SizedBox(height: AppSpacing.xl2),

          // Customer Section with Clickable Link
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Customer Profile', style: AppTypography.h6),
                  if (_ticket.customerId != null)
                    InkWell(
                      onTap: () => context.push('${AppRoutes.customers}/${_ticket.customerId}'),
                      child: const Text(
                        'View Profile →',
                        style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.25)),
                ),
                child: Column(
                  children: [
                    _InfoRow('Name', _ticket.customerName ?? '—'),
                    _InfoRow('Email', _ticket.customerEmail ?? '—'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl2),

          _InfoSection('Assigned Agent', [
            if (_ticket.assignedAgentName != null)
              _InfoRow('Agent', _ticket.assignedAgentName!)
            else
              _InfoRow('Agent', 'Unassigned'),
          ]),
          const SizedBox(height: AppSpacing.xl2),

          if (_ticket.slaDueAt != null)
            _SlaInfoCard(ticket: _ticket),
          const SizedBox(height: AppSpacing.xl2),

          // Actions
          Text('Quick Actions', style: AppTypography.h6),
          const SizedBox(height: AppSpacing.sm),
          _actionBtn('Schedule Linked Follow-Up', const Color(0xFF0D9488), Icons.add_task_rounded, _showCreateTaskDialog),
          const SizedBox(height: AppSpacing.sm),
          _actionBtn('Resolve Ticket', AppColors.success, Icons.check_circle_rounded, () {
            setState(() {
              _ticket = _ticket.copyWith(status: TicketStatus.resolved);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket resolved.'), behavior: SnackBarBehavior.floating),
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          _actionBtn('Change Priority', AppColors.warning, Icons.flag_rounded, () => _showPriorityDialog()),
          const SizedBox(height: AppSpacing.sm),
          _actionBtn('Escalate to Tier 2', AppColors.danger, Icons.arrow_upward_rounded, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket escalated to Tier 2 Support.'), behavior: SnackBarBehavior.floating),
            );
          }),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          minimumSize: const Size(0, 40),
          alignment: Alignment.centerLeft,
        ),
        onPressed: onTap,
      ),
    );
  }

  void _showAssignDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Ticket to Agent'),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: MockData.agents
                .map((a) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(a.initials,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ),
                      title: Text(a.fullName),
                      subtitle: Text('${a.openTickets} open tickets · ${a.role}'),
                      onTap: () {
                        setState(() {
                          _ticket = _ticket.copyWith(
                            assignedAgentId: a.id,
                            assignedAgentName: a.fullName,
                          );
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ticket assigned to ${a.fullName}'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ))
                .toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      ),
    );
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TicketPriority.values
              .map((p) => ListTile(
                    title: Text(p.label),
                    trailing: _ticket.priority == p
                        ? const Icon(Icons.check_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _ticket = _ticket.copyWith(priority: p));
                      Navigator.pop(ctx);
                    },
                  ))
              .toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      ),
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final TicketMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAgent = message.senderType == 'agent';
    final isNote = message.isInternalNote;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isAgent ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isAgent) ...[
          _Avatar(name: message.senderName ?? '?', isAgent: false),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isAgent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: isAgent ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Text(
                    message.senderName ?? 'Customer',
                    style: AppTypography.bodyXsMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 6),
                  if (isNote)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.warningSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Internal Note',
                          style: AppTypography.labelSm.copyWith(color: AppColors.warning)),
                    ),
                  const SizedBox(width: 6),
                  Text(_timeAgo(message.createdAt),
                      style: AppTypography.bodyXs.copyWith(color: AppColors.textTertiary)),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isNote
                      ? AppColors.warningSurface
                      : isAgent
                          ? AppColors.primarySurface
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12).copyWith(
                    topLeft: isAgent ? const Radius.circular(12) : Radius.zero,
                    topRight: isAgent ? Radius.zero : const Radius.circular(12),
                  ),
                  border: Border.all(
                    color: isNote
                        ? AppColors.warning.withOpacity(0.3)
                        : isAgent
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.border,
                  ),
                ),
                child: Text(
                  message.content,
                  style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary, height: 1.6),
                ),
              ),
            ],
          ),
        ),
        if (isAgent) ...[
          const SizedBox(width: 10),
          _Avatar(name: message.senderName ?? 'A', isAgent: true),
        ],
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final bool isAgent;
  const _Avatar({required this.name, required this.isAgent});

  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isAgent ? AppColors.primaryGradient : const LinearGradient(
          colors: [AppColors.neutral300, AppColors.neutral400],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: IconButton(icon: Icon(icon), onPressed: onTap),
    );
  }
}

class _ComposerTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ComposerTab(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? AppColors.primary.withOpacity(0.4) : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmMedium.copyWith(
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoSection(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h6),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.25)),
          ),
          child: Column(children: children),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTypography.bodyXsMedium.copyWith(color: AppColors.textTertiary)),
          ),
          Expanded(
            child: Text(value, style: AppTypography.bodySmMedium.copyWith(color: AppColors.textPrimary)),
          ),
        ],
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
      'In Progress' => const Color(0xFF2563EB),
      'Pending' => AppColors.statusPending,
      'Resolved' => AppColors.statusResolved,
      _ => AppColors.statusClosed,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: AppTypography.labelSm.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _SlaInfoCard extends StatelessWidget {
  final Ticket ticket;
  const _SlaInfoCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final remaining = ticket.slaDueAt!.difference(DateTime.now());
    final isBreached = ticket.slaBreached || remaining.isNegative;
    final color = isBreached
        ? AppColors.danger
        : remaining.inHours < 1
            ? AppColors.warning
            : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(isBreached ? Icons.warning_rounded : Icons.timer_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isBreached ? 'SLA Breached' : 'SLA Target Window',
                    style: AppTypography.bodySmMedium.copyWith(color: color)),
                Text(
                  isBreached ? 'Response time exceeded' : _formatDateTime(ticket.slaDueAt!),
                  style: AppTypography.bodyXs.copyWith(color: color.withOpacity(0.8)),
                ),
              ],
            ),
          ),
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

String _formatDateTime(DateTime dt) {
  return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
