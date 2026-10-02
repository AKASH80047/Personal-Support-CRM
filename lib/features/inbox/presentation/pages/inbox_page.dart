import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/conversation.dart';
import '../../../../shared/models/ticket.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/services/mock_data.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});
  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  Conversation? _selected;
  String _filter = 'All';
  final _msgCtrl = TextEditingController();
  final List<String> _filters = ['All', 'Unread', 'Live Chat', 'WhatsApp', 'Email'];
  String? _attachedFileName;

  @override
  void initState() {
    super.initState();
    if (MockData.conversations.isNotEmpty) {
      _selected = MockData.conversations.first;
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  List<Conversation> get _filtered {
    if (_filter == 'Unread') return MockData.conversations.where((c) => c.unreadCount > 0).toList();
    if (_filter == 'Live Chat') return MockData.conversations.where((c) => c.channel == ConversationChannel.chat).toList();
    if (_filter == 'WhatsApp') return MockData.conversations.where((c) => c.channel == ConversationChannel.whatsapp).toList();
    if (_filter == 'Email') return MockData.conversations.where((c) => c.channel == ConversationChannel.email).toList();
    return MockData.conversations;
  }

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty && _attachedFileName == null) return;
    if (_selected == null) return;

    final content = _msgCtrl.text.trim().isNotEmpty
        ? _msgCtrl.text.trim()
        : 'Attached file: $_attachedFileName';

    setState(() {
      final msgs = List<ConversationMessage>.from(_selected!.messages)
        ..add(ConversationMessage(
          id: 'new_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: _selected!.id,
          senderType: 'agent',
          senderName: 'Akash Pandey',
          content: content,
          createdAt: DateTime.now(),
        ));

      final updated = Conversation(
        id: _selected!.id,
        customerId: _selected!.customerId,
        customerName: _selected!.customerName,
        customerEmail: _selected!.customerEmail,
        channel: _selected!.channel,
        status: _selected!.status,
        messages: msgs,
        createdAt: _selected!.createdAt,
        lastMessage: content,
        lastMessageAt: DateTime.now(),
        unreadCount: 0,
      );

      final idx = MockData.conversations.indexWhere((c) => c.id == _selected!.id);
      if (idx != -1) {
        MockData.conversations[idx] = updated;
      }
      _selected = updated;
      _msgCtrl.clear();
      _attachedFileName = null;
    });
  }

  void _showCannedMacrosDialog() {
    final macros = [
      ('Instant Greeting', 'Hello! Thanks for reaching out to Support. How can I assist you today?'),
      ('Verification Request', 'Could you please confirm your registered account email and order ID so I can look into this for you?'),
      ('Resolution Notification', 'I have updated your settings and verified the resolution. Please refresh and let me know if it works!'),
      ('Closing Note', 'It was a pleasure assisting you! Feel free to reach back out anytime if you need further help. Have a great day!'),
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Quick Chat Macros'),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: macros.map((m) => ListTile(
              title: Text(m.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text(m.$2, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              onTap: () {
                _msgCtrl.text = m.$2;
                Navigator.pop(ctx);
              },
            )).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      ),
    );
  }

  void _showAssignAgentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transfer / Assign Chat'),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: MockData.agents.map((a) => ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(a.initials, style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
              title: Text(a.fullName),
              subtitle: Text(a.role, style: const TextStyle(fontSize: 11)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Conversation transferred to ${a.fullName}'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            )).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      ),
    );
  }

  void _showAttachFileDialog() {
    final sampleFiles = ['screenshot_issue.png', 'payment_invoice.pdf', 'system_spec.txt'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Attach File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sampleFiles.map((f) => ListTile(
            leading: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary),
            title: Text(f),
            onTap: () {
              setState(() => _attachedFileName = f);
              Navigator.pop(ctx);
            },
          )).toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      ),
    );
  }

  void _showScheduleTaskDialog() {
    if (_selected == null) return;
    final titleCtrl = TextEditingController(text: 'Chat follow-up for ${_selected!.customerName ?? "Customer"}');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_task_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Schedule Follow-Up Task'),
          ],
        ),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(labelText: 'Task Title *', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              final newTask = SupportTask(
                id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                title: titleCtrl.text.trim(),
                customerId: _selected!.customerId,
                customerName: _selected!.customerName,
                assignedAgentName: 'Akash Pandey',
                priority: TaskPriority.medium,
                status: TaskStatus.todo,
                dueDate: DateTime.now().add(const Duration(days: 1)),
                createdAt: DateTime.now(),
              );
              MockData.tasks.insert(0, newTask);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Follow-up task added.'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Save Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    if (isDesktop) return _buildDesktop();
    return _buildMobile();
  }

  Widget _buildDesktop() {
    return Row(
      children: [
        // Left panel — conversation list
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: _buildConvList(),
        ),
        // Center — conversation
        Expanded(child: _selected != null ? _buildConversation() : _buildNoSelection()),
        // Right — customer info
        if (_selected != null)
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(left: BorderSide(color: AppColors.border)),
            ),
            child: _buildCustomerInfo(),
          ),
      ],
    );
  }

  Widget _buildMobile() {
    if (_selected != null) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) setState(() => _selected = null);
        },
        child: _buildConversation(),
      );
    }
    return _buildConvList();
  }

  Widget _buildConvList() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Inbox Messages', style: AppTypography.h5),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${MockData.conversations.where((c) => c.unreadCount > 0).length} Unread',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _filter == f ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: _filter == f ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(
                          f,
                          style: AppTypography.labelSm.copyWith(
                            color: _filter == f ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = _filtered[i];
              final isSelected = _selected?.id == c.id;
              return InkWell(
                onTap: () => setState(() => _selected = c),
                child: Container(
                  color: isSelected ? AppColors.primarySurface : null,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          _ConvAvatar(name: c.customerName ?? '?'),
                          if (c.unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    c.customerName ?? '?',
                                    style: AppTypography.bodySmSemiBold.copyWith(
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  c.lastMessageAt != null ? _timeAgo(c.lastMessageAt!) : '',
                                  style: AppTypography.bodyXs.copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              c.lastMessage ?? '',
                              style: AppTypography.bodyXs.copyWith(
                                color: c.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                                fontWeight: c.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _ChannelChip(channel: c.channel),
                                if (c.unreadCount > 0) ...[
                                  const Spacer(),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                    child: Center(
                                      child: Text(
                                        '${c.unreadCount}',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: AppColors.neutral300),
          const SizedBox(height: 16),
          Text('Select a conversation from the left', style: AppTypography.h5.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildConversation() {
    final conv = _selected!;
    return Scaffold(
      appBar: AppBar(
        leading: MediaQuery.of(context).size.width < 1100
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _selected = null),
              )
            : null,
        title: Row(
          children: [
            _ConvAvatar(name: conv.customerName ?? '?'),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conv.customerName ?? '?', style: AppTypography.bodySmSemiBold),
                Text(
                  'Active on ${conv.channel.name.toUpperCase()}',
                  style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: _showAssignAgentDialog,
            tooltip: 'Assign Agent',
          ),
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            onPressed: _showScheduleTaskDialog,
            tooltip: 'Schedule Task',
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation resolved.'), behavior: SnackBarBehavior.floating),
              );
            },
            tooltip: 'Resolve Conversation',
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: conv.messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.xl2),
                    itemCount: conv.messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (_, i) => _ConvMsgBubble(message: conv.messages[i]),
                  ),
          ),
          if (_attachedFileName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: const Color(0xFFEFF6FF),
              child: Row(
                children: [
                  const Icon(Icons.attach_file_rounded, size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  Text('Attachment: $_attachedFileName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF))),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    onPressed: () => setState(() => _attachedFileName = null),
                  ),
                ],
              ),
            ),
          // Composer
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.bolt_rounded, color: AppColors.primary),
                  tooltip: 'Quick Macros',
                  onPressed: _showCannedMacrosDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file_rounded, color: AppColors.iconDefault),
                  tooltip: 'Attach File',
                  onPressed: _showAttachFileDialog,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    maxLines: 3,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Type a message to the customer...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    if (_selected == null) return const SizedBox.shrink();
    final conv = _selected!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer Profile', style: AppTypography.h6),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                _ConvAvatar(name: conv.customerName ?? '?', size: 56),
                const SizedBox(height: 8),
                Text(conv.customerName ?? '?', style: AppTypography.bodySmSemiBold),
                Text(conv.customerEmail ?? '', style: AppTypography.bodyXs.copyWith(color: AppColors.textTertiary)),
                const SizedBox(height: 8),
                if (conv.customerId != null)
                  OutlinedButton(
                    onPressed: () => context.push('${AppRoutes.customers}/${conv.customerId}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: const Size(0, 28),
                    ),
                    child: const Text('Open Customer Profile', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Text('Linked Tickets', style: AppTypography.h6),
          const SizedBox(height: 8),
          ...MockData.tickets.where((t) => t.customerId == conv.customerId).take(3).map((t) =>
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.confirmation_number_outlined, size: 18, color: AppColors.primary),
              title: Text(t.subject, style: AppTypography.bodyXsMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${t.ticketNumber} · ${t.status.label}', style: AppTypography.bodyXs.copyWith(color: AppColors.textTertiary)),
              trailing: const Icon(Icons.chevron_right_rounded, size: 16),
              onTap: () => context.push('${AppRoutes.tickets}/${t.id}'),
            )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 14),
              label: const Text('Create Ticket from Chat', style: TextStyle(fontSize: 12)),
              onPressed: () => context.push(AppRoutes.createTicket),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConvAvatar extends StatelessWidget {
  final String name;
  final double size;
  const _ConvAvatar({required this.name, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.accent, AppColors.secondary]),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(color: Colors.white, fontSize: size * 0.33, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ConvMsgBubble extends StatelessWidget {
  final ConversationMessage message;
  const _ConvMsgBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAgent = message.senderType == 'agent';
    return Row(
      mainAxisAlignment: isAgent ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isAgent) ...[
          _ConvAvatar(name: message.senderName ?? '?', size: 28),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isAgent ? AppColors.primarySurface : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: isAgent ? const Radius.circular(16) : Radius.zero,
                bottomRight: isAgent ? Radius.zero : const Radius.circular(16),
              ),
              border: Border.all(
                color: isAgent ? AppColors.primary.withOpacity(0.2) : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: isAgent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(message.content, style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary, height: 1.6)),
                const SizedBox(height: 4),
                Text(
                  _timeAgo(message.createdAt),
                  style: AppTypography.bodyXs.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
        if (isAgent) ...[
          const SizedBox(width: 8),
          _ConvAvatar(name: 'AP', size: 28),
        ],
      ],
    );
  }
}

class _ChannelChip extends StatelessWidget {
  final ConversationChannel channel;
  const _ChannelChip({required this.channel});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (channel) {
      ConversationChannel.chat => (Icons.chat_rounded, AppColors.primary),
      ConversationChannel.email => (Icons.email_rounded, AppColors.info),
      ConversationChannel.whatsapp => (Icons.chat_bubble_outline_rounded, AppColors.success),
      ConversationChannel.phone => (Icons.phone_rounded, AppColors.warning),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(channel.name, style: AppTypography.labelSm.copyWith(color: color)),
      ],
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
