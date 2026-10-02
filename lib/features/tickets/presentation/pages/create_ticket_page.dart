import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/ticket.dart';
import '../../../../shared/models/customer.dart';
import '../../../../shared/models/agent.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/services/mock_data.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();

  TicketPriority _priority = TicketPriority.high;
  TicketChannel _channel = TicketChannel.web;
  String? _selectedCustomerId;
  String? _selectedAgentId;
  String? _selectedTeamId;
  String _selectedCategory = 'Technical Support';
  String? _selectedTemplate;
  bool _loading = false;

  // Linked Task options
  bool _createLinkedTask = true;
  String _followUpDueOption = 'In 24 Hours';

  final List<String> _tags = ['Enterprise', 'API', 'v2.4-Migration'];
  final List<Map<String, String>> _attachments = [
    {'name': 'console_error_log.txt', 'size': '142 KB', 'type': 'LOG'},
    {'name': 'dashboard_screenshot.png', 'size': '1.8 MB', 'type': 'PNG'},
  ];

  final List<String> _categories = [
    'Technical Support',
    'Account & Access',
    'Billing & Invoices',
    'Feature Request',
    'Security & Privacy',
    'General Inquiry',
  ];

  final Map<String, Map<String, String>> _templates = {
    'Bug Report': {
      'subject': 'Bug: Unexpected 500 error on checkout flow',
      'desc': '### Steps to Reproduce:\n1. Navigate to billing checkout.\n2. Enter corporate card details.\n3. Click "Complete Subscription".\n\n### Expected Result:\nSuccess modal & invoice generated.\n\n### Actual Result:\nServer returns 500 Internal Server Error.',
      'category': 'Technical Support',
      'priority': 'critical',
    },
    'Billing Dispute': {
      'subject': 'Billing: Duplicate invoice charge for September cycle',
      'desc': 'Customer was billed twice for the Enterprise Annual Plan on invoice #INV-2026-881. Requesting credit note or refund.',
      'category': 'Billing & Invoices',
      'priority': 'high',
    },
    'Feature Request': {
      'subject': 'Feature: Custom Webhook triggers for SLA breach alerts',
      'desc': 'Customer requests outbound webhook payload whenever ticket SLA breach warning (15m remaining) fires.',
      'category': 'Feature Request',
      'priority': 'medium',
    },
    'Account Recovery': {
      'subject': 'Access: 2FA reset request for admin user',
      'desc': 'Primary admin lost authenticator app access. Identity verified via corporate domain DNS TXT record.',
      'category': 'Account & Access',
      'priority': 'high',
    },
  };

  @override
  void initState() {
    super.initState();
    if (MockData.customers.isNotEmpty) {
      _selectedCustomerId = MockData.customers.first.id;
    }
    if (MockData.agents.isNotEmpty) {
      _selectedAgentId = MockData.agents.first.id;
    }
    if (MockData.teams.isNotEmpty) {
      _selectedTeamId = MockData.teams.first.id;
    }
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  Customer? get _selectedCustomer {
    if (_selectedCustomerId == null) return null;
    return MockData.customers.firstWhere(
      (c) => c.id == _selectedCustomerId,
      orElse: () => MockData.customers.first,
    );
  }

  Agent? get _selectedAgent {
    if (_selectedAgentId == null) return null;
    return MockData.agents.firstWhere(
      (a) => a.id == _selectedAgentId,
      orElse: () => MockData.agents.first,
    );
  }

  void _applyTemplate(String templateKey) {
    final tpl = _templates[templateKey];
    if (tpl != null) {
      setState(() {
        _selectedTemplate = templateKey;
        _subjectCtrl.text = tpl['subject']!;
        _descCtrl.text = tpl['desc']!;
        _selectedCategory = tpl['category']!;
        _priority = switch (tpl['priority']) {
          'critical' => TicketPriority.critical,
          'high' => TicketPriority.high,
          'low' => TicketPriority.low,
          _ => TicketPriority.medium,
        };
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Applied template: $templateKey'),
          backgroundColor: const Color(0xFF2563EB),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1400),
        ),
      );
    }
  }

  void _showFileAttachmentPickerModal() {
    final availableFiles = [
      {'name': 'system_trace_dump.har', 'size': '2.4 MB', 'type': 'HAR', 'desc': 'Browser network trace & headers'},
      {'name': 'checkout_500_screenshot.png', 'size': '1.8 MB', 'type': 'PNG', 'desc': 'Error dialog UI snapshot'},
      {'name': 'client_error_console.log', 'size': '340 KB', 'type': 'LOG', 'desc': 'JavaScript stacktrace dump'},
      {'name': 'tax_invoice_sept2026.pdf', 'size': '520 KB', 'type': 'PDF', 'desc': 'Original billing transaction receipt'},
      {'name': 'auth_token_payload.json', 'size': '45 KB', 'type': 'JSON', 'desc': 'SAML / OAuth response snippet'},
      {'name': 'diagnostic_bundle.zip', 'size': '8.2 MB', 'type': 'ZIP', 'desc': 'Full server & client diagnostic archive'},
    ];

    final customFileCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cloud_upload_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 10),
              Text('File Attachment Studio'),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select files to attach to this support ticket for agent evidence and diagnosis:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),
                  ...availableFiles.map((file) {
                    final isAlreadyAttached = _attachments.any((a) => a['name'] == file['name']);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isAlreadyAttached ? const Color(0xFFF1F5F9) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            file['type']!,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                          ),
                        ),
                        title: Text(
                          file['name']!,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        ),
                        subtitle: Text(
                          '${file['size']} · ${file['desc']}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        trailing: isAlreadyAttached
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                            : ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _attachments.add({'name': file['name']!, 'size': file['size']!, 'type': file['type']!});
                                  });
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('📎 Attached ${file['name']}'),
                                      backgroundColor: const Color(0xFF2563EB),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: const Size(0, 28),
                                ),
                                child: const Text('Attach', style: TextStyle(fontSize: 11)),
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Or attach custom file by name:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customFileCtrl,
                          decoration: const InputDecoration(
                            hintText: 'e.g. error_log_user49.txt',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (customFileCtrl.text.trim().isNotEmpty) {
                            final name = customFileCtrl.text.trim();
                            setState(() {
                              _attachments.add({'name': name, 'size': '512 KB', 'type': name.split('.').last.toUpperCase()});
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('📎 Attached $name'),
                                backgroundColor: const Color(0xFF2563EB),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: const Text('Add File'),
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
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _addTag(String tag) {
    final clean = tag.trim().replaceAll('#', '');
    if (clean.isNotEmpty && !_tags.contains(clean)) {
      setState(() {
        _tags.add(clean);
        _tagInputCtrl.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _createTicket() async {
    if (_subjectCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter a ticket subject title'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please provide a ticket description'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final customer = _selectedCustomer;
    final agent = _selectedAgent;
    final newId = 'tk_${DateTime.now().millisecondsSinceEpoch}';
    final ticketNum = 'TK-${MockData.tickets.length + 101}';

    final newTicket = Ticket(
      id: newId,
      ticketNumber: ticketNum,
      subject: _subjectCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      customerId: customer?.id ?? 'cust_1',
      customerName: customer?.fullName ?? 'Enterprise Customer',
      customerEmail: customer?.email ?? 'contact@company.com',
      priority: _priority,
      status: TicketStatus.open,
      channel: _channel,
      assignedAgentId: agent?.id,
      assignedAgentName: agent?.fullName,
      assignedTeamId: _selectedTeamId,
      category: _selectedCategory,
      tags: List.from(_tags),
      slaBreached: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      slaDueAt: DateTime.now().add(
        _priority == TicketPriority.critical
            ? const Duration(hours: 1)
            : (_priority == TicketPriority.high ? const Duration(hours: 4) : const Duration(hours: 12)),
      ),
    );

    MockData.tickets.insert(0, newTicket);

    // Schedule Linked Follow-up Task if enabled
    if (_createLinkedTask) {
      final taskDueDate = switch (_followUpDueOption) {
        'In 4 Hours' => DateTime.now().add(const Duration(hours: 4)),
        'In 24 Hours' => DateTime.now().add(const Duration(days: 1)),
        'In 48 Hours' => DateTime.now().add(const Duration(days: 2)),
        _ => DateTime.now().add(const Duration(days: 3)),
      };

      final linkedTask = SupportTask(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Follow-up on ${newTicket.ticketNumber}: ${newTicket.subject}',
        description: 'Verify resolution with ${customer?.fullName ?? "customer"} for "${newTicket.subject}". Attachments: ${_attachments.length} files.',
        ticketId: newTicket.id,
        ticketNumber: newTicket.ticketNumber,
        customerId: customer?.id,
        customerName: customer?.fullName,
        assignedAgentName: agent?.fullName ?? 'Akash Pandey',
        priority: switch (_priority) {
          TicketPriority.critical => TaskPriority.urgent,
          TicketPriority.high => TaskPriority.high,
          TicketPriority.medium => TaskPriority.medium,
          TicketPriority.low => TaskPriority.low,
        },
        status: TaskStatus.todo,
        dueDate: taskDueDate,
        createdAt: DateTime.now(),
      );

      MockData.tasks.insert(0, linkedTask);
    }

    if (mounted) {
      setState(() => _loading = false);
      _showTicketCreatedSuccessDialog(ticketNum, newId);
    }
  }

  void _showTicketCreatedSuccessDialog(String ticketNum, String ticketId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 36),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ticket Dispatched Successfully!',
                style: AppTypography.h5.copyWith(color: const Color(0xFF0F172A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ticket $ticketNum has been assigned to ${_selectedAgent?.fullName ?? "team pod"} with ${_priority.label} priority SLA policy.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_createLinkedTask)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.task_alt_rounded, color: Color(0xFF2563EB), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Linked follow-up task scheduled for $_followUpDueOption.',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go(AppRoutes.tickets);
                      },
                      child: const Text('Ticket Queue'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('${AppRoutes.tickets}/$ticketId');
                      },
                      child: const Text('View Ticket'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1050;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─ 1. Modern Page Header & Breadcrumbs ─
            _buildPageHeader(),

            // ─ 2. Main Form Body ─
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 16,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Form(
                    key: _formKey,
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column: Core Ticket Details & Rich Description (65%)
                              Expanded(flex: 65, child: _buildLeftColumn()),
                              const SizedBox(width: 24),
                              // Right Column: Routing, Priority, SLA & Live Preview (35%)
                              Expanded(flex: 35, child: _buildRightColumn()),
                            ],
                          )
                        : Column(
                            children: [
                              _buildLeftColumn(),
                              const SizedBox(height: 24),
                              _buildRightColumn(),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Top Header Bar ────────────────────────────────────────────────────────
  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF334155)),
            ),
          ),
          const SizedBox(width: 16),

          // Title & Breadcrumb
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => context.go(AppRoutes.tickets),
                      child: const Text('Tickets', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    const Text('New Ticket', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Create Support Ticket',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Discard', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(width: 12),

          ElevatedButton.icon(
            onPressed: _loading ? null : _createTicket,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check_rounded, size: 18, color: Colors.white),
            label: Text(
              _loading ? 'Dispatching...' : 'Create Ticket',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Left Column (Main Form) ───────────────────────────────────────────────
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─ Quick Template Bar ─
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB), size: 18),
              const SizedBox(width: 10),
              const Text('Quick Templates:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF))),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _templates.keys.map((key) {
                      final isSelected = _selectedTemplate == key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => _applyTemplate(key),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1)),
                            ),
                            child: Text(
                              key,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ─ Card 1: Customer & Subject ─
        _buildCard(
          title: 'Ticket Overview',
          subtitle: 'Identify the customer and define the core problem summary.',
          icon: Icons.assignment_outlined,
          children: [
            // Customer Selector Row
            const Text('Requester / Customer *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCustomerId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  items: MockData.customers.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                c.initials,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(c.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                Text('${c.company ?? "Individual"} · ${c.email ?? ""}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCustomerId = v),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Subject Line
            const Text('Subject *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. Unable to authenticate via SSO on staging cluster',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.title_rounded, size: 18, color: Color(0xFF64748B)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
              ),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 18),

            // Ingestion Channel Pills
            const Text('Ingestion Channel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: TicketChannel.values.map((ch) {
                final isSelected = _channel == ch;
                final (icon, label) = switch (ch) {
                  TicketChannel.email => (Icons.email_outlined, 'Email Inbound'),
                  TicketChannel.web => (Icons.language_rounded, 'Web Portal'),
                  TicketChannel.chat => (Icons.chat_bubble_outline_rounded, 'Live Chat'),
                  TicketChannel.whatsapp => (Icons.phone_android_rounded, 'WhatsApp'),
                  TicketChannel.phone => (Icons.phone_in_talk_rounded, 'Phone Call'),
                  TicketChannel.api => (Icons.code_rounded, 'API Trigger'),
                };
                return InkWell(
                  onTap: () => setState(() => _channel = ch),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ─ Card 2: Description & Rich Toolbar ─
        _buildCard(
          title: 'Ticket Description & Details',
          subtitle: 'Include complete context, logs, reproduction steps, or error traces.',
          icon: Icons.notes_rounded,
          children: [
            // Mini Markdown Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0)),
                  left: BorderSide(color: Color(0xFFE2E8F0)),
                  right: BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Row(
                children: [
                  _editorButton(Icons.format_bold_rounded, 'Bold', () => _insertText('**', '**')),
                  _editorButton(Icons.format_italic_rounded, 'Italic', () => _insertText('*', '*')),
                  _editorButton(Icons.code_rounded, 'Code block', () => _insertText('```\n', '\n```')),
                  _editorButton(Icons.format_list_bulleted_rounded, 'Bullet list', () => _insertText('\n- ', '')),
                  _editorButton(Icons.link_rounded, 'Insert link', () => _insertText('[Link Title](', ')')),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      _insertText('\n\n> [!NOTE]\n> Customer reported high business impact.', '');
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, size: 13, color: Color(0xFF2563EB)),
                          SizedBox(width: 4),
                          Text('Insert Callout', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text Area
            TextFormField(
              controller: _descCtrl,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Describe the issue comprehensively...\n\n- What is happening?\n- What did the user expect?\n- Any error messages or affected account IDs?',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.5),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                  borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                  borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                  borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), height: 1.5),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ─ Card 3: Attachments & Evidence Dropzone ─
        _buildCard(
          title: 'Evidence & Attachments',
          subtitle: 'Attach screenshots, diagnostic archives, network traces, or receipts.',
          icon: Icons.attach_file_rounded,
          children: [
            // Interactive Dropzone Box
            InkWell(
              onTap: _showFileAttachmentPickerModal,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_upload_outlined, size: 28, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(height: 10),
                      const Text('Drop files here to upload, or browse', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      const Text('PNG, JPG, PDF, TXT, HAR, ZIP up to 25 MB each', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _showFileAttachmentPickerModal,
                        icon: const Icon(Icons.file_open_outlined, size: 15),
                        label: const Text('Browse Files'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: _attachments.map((file) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            file['type'] ?? 'FILE',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(file['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                        const SizedBox(width: 4),
                        Text('(${file['size']})', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => setState(() => _attachments.remove(file)),
                          child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ─── Right Column (Metadata & SLA Routing) ─────────────────────────────────
  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─ SLA Response Target Banner ─
        _buildSlaBanner(),
        const SizedBox(height: 20),

        // ─ Card 4: Priority & Classification ─
        _buildCard(
          title: 'Classification & Priority',
          subtitle: 'Define severity and organizational queue.',
          icon: Icons.flag_rounded,
          children: [
            const Text('Priority Level *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 10),
            // 4-Pill Segmented Priority Buttons
            Column(
              children: TicketPriority.values.map((p) {
                final isSelected = _priority == p;
                final (color, slaText) = switch (p) {
                  TicketPriority.critical => (const Color(0xFFEF4444), '15 Min First Response SLA'),
                  TicketPriority.high => (const Color(0xFFF97316), '1 Hour First Response SLA'),
                  TicketPriority.medium => (const Color(0xFFF59E0B), '4 Hours First Response SLA'),
                  TicketPriority.low => (const Color(0xFF10B981), '12 Hours First Response SLA'),
                };

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _priority = p),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            p.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? color : const Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            slaText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? color : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Category Selector
            const Text('Category *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          const Icon(Icons.label_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                          const SizedBox(width: 10),
                          Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tags Adder
            const Text('Tags', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ..._tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('#$tag', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => _removeTag(tag),
                            child: const Icon(Icons.close_rounded, size: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagInputCtrl,
                    onSubmitted: _addTag,
                    decoration: InputDecoration(
                      hintText: 'Add tag (e.g. VIP, iOS, Checkout)',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF2563EB)),
                  onPressed: () => _addTag(_tagInputCtrl.text),
                  tooltip: 'Add Tag',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ─ Card 5: Assignment, Routing & Linked Tasks ─
        _buildCard(
          title: 'Routing & Assignment',
          subtitle: 'Dispatch ticket to team pod or dedicated support engineer.',
          icon: Icons.supervised_user_circle_rounded,
          children: [
            // Team Pod Selector
            const Text('Assign Team Pod', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTeamId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  items: MockData.teams.map((t) {
                    return DropdownMenuItem(
                      value: t.id,
                      child: Row(
                        children: [
                          const Icon(Icons.groups_rounded, size: 16, color: Color(0xFF2563EB)),
                          const SizedBox(width: 10),
                          Text(t.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedTeamId = v),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Agent Assignee Selector
            const Text('Assign Agent', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAgentId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  items: MockData.agents.map((a) {
                    return DropdownMenuItem(
                      value: a.id,
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                a.initials,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${a.fullName} (${a.role})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: a.status == AgentStatus.online ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedAgentId = v),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),

            // Automatic Linked Follow-Up Task Switch
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _createLinkedTask,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (val) => setState(() => _createLinkedTask = val ?? true),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Schedule Linked Follow-Up Task',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Automatically add an SLA reminder task in the Tasks Queue upon ticket creation.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      if (_createLinkedTask) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _followUpDueOption,
                          isDense: true,
                          decoration: const InputDecoration(
                            labelText: 'Task Due Window',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: ['In 4 Hours', 'In 24 Hours', 'In 48 Hours', 'In 72 Hours']
                              .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _followUpDueOption = v);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ─── SLA Banner ────────────────────────────────────────────────────────────
  Widget _buildSlaBanner() {
    final (bg, border, fg, timeStr) = switch (_priority) {
      TicketPriority.critical => (const Color(0xFFFEF2F2), const Color(0xFFFECACA), const Color(0xFFDC2626), '15 Minutes Target'),
      TicketPriority.high => (const Color(0xFFFFF7ED), const Color(0xFFFFEDD5), const Color(0xFFEA580C), '1 Hour Target'),
      TicketPriority.medium => (const Color(0xFFFFFBEB), const Color(0xFFFEF3C7), const Color(0xFFD97706), '4 Hours Target'),
      TicketPriority.low => (const Color(0xFFF0FDF4), const Color(0xFFDCFCE7), const Color(0xFF16A34A), '12 Hours Target'),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.timer_outlined, color: fg, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SLA Policy: ${_priority.label} Severity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg)),
                const SizedBox(height: 2),
                Text('First response guaranteed within $timeStr', style: TextStyle(fontSize: 11, color: fg.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reusable Styled Card Container ────────────────────────────────────────
  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _editorButton(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 16, color: const Color(0xFF475569)),
      tooltip: tooltip,
      onPressed: onTap,
      splashRadius: 18,
    );
  }

  void _insertText(String prefix, String suffix) {
    final text = _descCtrl.text;
    final sel = _descCtrl.selection;
    if (sel.isValid && sel.start != -1 && sel.end != -1) {
      final selectedText = text.substring(sel.start, sel.end);
      final newText = text.replaceRange(sel.start, sel.end, '$prefix$selectedText$suffix');
      _descCtrl.text = newText;
      _descCtrl.selection = TextSelection.collapsed(offset: sel.start + prefix.length + selectedText.length + suffix.length);
    } else {
      _descCtrl.text = '$text$prefix$suffix';
    }
  }
}
