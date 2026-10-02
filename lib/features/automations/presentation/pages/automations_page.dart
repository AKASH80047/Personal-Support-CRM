import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AutomationsPage extends StatefulWidget {
  const AutomationsPage({super.key});
  @override
  State<AutomationsPage> createState() => _AutomationsPageState();
}

class _AutomationsPageState extends State<AutomationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final List<_AutomationRule> _rules = [
    _AutomationRule(
      id: '1',
      name: 'Auto-assign Technical Tickets',
      description: 'Tickets with category "Technical" are assigned to Technical Support team',
      trigger: 'When: New ticket created',
      conditions: ['Category is "Technical Support" OR "Mobile App"'],
      actions: ['Assign to Team: Technical Support', 'Set Priority: High'],
      isActive: true,
      triggeredCount: 89,
      lastTriggered: '2 hours ago',
    ),
    _AutomationRule(
      id: '2',
      name: 'SLA Breach Warning Alert',
      description: 'Notify agent and manager when ticket SLA is < 30 min from breach',
      trigger: 'When: SLA timer < 30 min',
      conditions: ['Ticket status is Open or Pending', 'SLA not already breached'],
      actions: ['Send notification to assigned agent', 'Send notification to manager'],
      isActive: true,
      triggeredCount: 12,
      lastTriggered: '15 min ago',
    ),
    _AutomationRule(
      id: '3',
      name: 'Auto-close Resolved Tickets',
      description: 'Resolved tickets with no customer reply for 48 hours are automatically closed',
      trigger: 'When: Ticket is resolved for 48 hours',
      conditions: ['No customer reply in 48 hours', 'Status is Resolved'],
      actions: ['Change status to Closed', 'Send CSAT survey to customer'],
      isActive: true,
      triggeredCount: 34,
      lastTriggered: 'Yesterday',
    ),
    _AutomationRule(
      id: '4',
      name: 'Critical Priority Escalation',
      description: 'Critical tickets unresponsive for 15 min are escalated to manager',
      trigger: 'When: Critical ticket has no agent reply for 15 min',
      conditions: ['Priority is Critical', 'No agent reply in 15 min'],
      actions: ['Escalate ticket', 'Add internal note', 'Notify manager via email'],
      isActive: false,
      triggeredCount: 5,
      lastTriggered: '3 days ago',
    ),
    _AutomationRule(
      id: '5',
      name: 'VIP Customer Tag & Routing',
      description: 'Customers from Enterprise tier are automatically flagged and routed to Tier 2 Pod',
      trigger: 'When: New customer ticket created',
      conditions: ['Customer tier is Enterprise', 'CSAT > 4.5'],
      actions: ['Add tag: VIP Customer', 'Assign to Tier 2 Escalation Pod'],
      isActive: true,
      triggeredCount: 28,
      lastTriggered: '4 hours ago',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _showCreateAutomationModal({_AutomationRule? existingRule}) {
    final nameCtrl = TextEditingController(text: existingRule?.name);
    final descCtrl = TextEditingController(text: existingRule?.description);
    String trigger = existingRule?.trigger ?? 'When: New ticket created';
    String condition = existingRule?.conditions.firstOrNull ?? 'Category is "Technical Support"';
    String action = existingRule?.actions.firstOrNull ?? 'Assign to Team: Technical Support';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(existingRule == null ? 'Create Automation Rule' : 'Edit Automation Rule',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Rule Name *', hintText: 'e.g. VIP Priority Escalate'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description', hintText: 'Explain what this automation does'),
                  ),
                  const SizedBox(height: 16),
                  const Text('TRIGGER (WHEN)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: trigger,
                    items: [
                      'When: New ticket created',
                      'When: SLA timer < 30 min',
                      'When: Ticket is resolved for 48 hours',
                      'When: Critical ticket has no agent reply for 15 min',
                      'When: CSAT survey rating received',
                    ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setDialogState(() => trigger = v!),
                  ),
                  const SizedBox(height: 16),
                  const Text('CONDITIONS (IF)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                  const SizedBox(height: 6),
                  TextField(
                    decoration: const InputDecoration(hintText: 'e.g. Category is Technical Support OR Mobile App'),
                    controller: TextEditingController(text: condition),
                    onChanged: (v) => condition = v,
                  ),
                  const SizedBox(height: 16),
                  const Text('ACTIONS (THEN)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                  const SizedBox(height: 6),
                  TextField(
                    decoration: const InputDecoration(hintText: 'e.g. Assign to Team: Technical Support, Set Priority: High'),
                    controller: TextEditingController(text: action),
                    onChanged: (v) => action = v,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;
                setState(() {
                  if (existingRule != null) {
                    final idx = _rules.indexWhere((r) => r.id == existingRule.id);
                    if (idx != -1) {
                      _rules[idx] = _AutomationRule(
                        id: existingRule.id,
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        trigger: trigger,
                        conditions: [condition],
                        actions: [action],
                        isActive: existingRule.isActive,
                        triggeredCount: existingRule.triggeredCount,
                        lastTriggered: existingRule.lastTriggered,
                      );
                    }
                  } else {
                    _rules.insert(
                      0,
                      _AutomationRule(
                        id: 'rule-${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim().isEmpty ? 'Automated support triage workflow' : descCtrl.text.trim(),
                        trigger: trigger,
                        conditions: [condition],
                        actions: [action],
                        isActive: true,
                        triggeredCount: 0,
                        lastTriggered: 'Just now',
                      ),
                    );
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⚡ Automation rule saved successfully.'), behavior: SnackBarBehavior.floating),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              child: const Text('Save Rule'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _rules.where((r) => r.isActive).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ 1. Header (Automations + 4 active automations + Create Automation Button) ─
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Automations',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text('$activeCount active automations', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateAutomationModal(),
                  icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  label: const Text('Create Automation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─ 2. Tabs Row (All Rules, Active (4), Logs) ─
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
                tabs: [
                  const Tab(text: 'All Rules'),
                  Tab(text: 'Active ($activeCount)'),
                  const Tab(text: 'Logs'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─ 3. Rules List or Logs ─
            AnimatedBuilder(
              animation: _tabCtrl,
              builder: (context, _) {
                if (_tabCtrl.index == 2) {
                  return _buildLogsView();
                }
                final rulesToDisplay = _tabCtrl.index == 1 ? _rules.where((r) => r.isActive).toList() : _rules;
                return Column(
                  children: rulesToDisplay.map((rule) => _buildRuleCard(rule)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(_AutomationRule rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Indicator dot + Title + Description + Switch + 3-dots
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: rule.isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      rule.description,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              // Custom styled toggle switch
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: rule.isActive,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF4F46E5),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFCBD5E1),
                  onChanged: (val) {
                    setState(() => rule.isActive = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? '⚡ "${rule.name}" activated' : '⏸ "${rule.name}" paused'),
                        duration: const Duration(milliseconds: 1200),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF64748B)),
                onSelected: (act) {
                  if (act == 'edit') {
                    _showCreateAutomationModal(existingRule: rule);
                  } else if (act == 'test') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ Test run successful for "${rule.name}" (Matched 4 open tickets)'), behavior: SnackBarBehavior.floating),
                    );
                  } else if (act == 'delete') {
                    setState(() => _rules.removeWhere((r) => r.id == rule.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Automation rule deleted.'), behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Rule')),
                  const PopupMenuItem(value: 'test', child: Text('Test Run Simulation')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete Rule', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tag Pill rows (TRIGGER / CONDITIONS / ACTIONS - exact colors to Image 5)
          // Row 1: TRIGGER
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPillBadge('TRIGGER', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
              const SizedBox(width: 8),
              _buildPillContent(rule.trigger),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: CONDITIONS
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPillBadge('CONDITIONS', const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              ...rule.conditions.map((cond) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _buildPillContent(cond),
              )),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: ACTIONS
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPillBadge('ACTIONS', const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
              const SizedBox(width: 8),
              ...rule.actions.map((act) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _buildPillContent(act),
              )),
            ],
          ),
          const SizedBox(height: 14),

          // Footer info
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 5),
              Text(
                'Triggered ${rule.triggeredCount} times · Last: ${rule.lastTriggered}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    );
  }

  Widget _buildPillContent(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildLogsView() {
    final logs = [
      _AutomationLog('Auto-assign Technical Tickets', 'Triggered and assigned to Aman Verma', 'TK-10449', '2h ago', true),
      _AutomationLog('SLA Breach Warning Alert', 'Warning notification sent to Priya Patel', 'TK-10451', '15m ago', true),
      _AutomationLog('Auto-close Resolved Tickets', 'Closed inactive ticket with CSAT survey', 'TK-10445', 'Yesterday', true),
      _AutomationLog('Critical Priority Escalation', 'Skipped — agent responded within 12 min', 'TK-10440', '3d ago', false),
      _AutomationLog('VIP Customer Tag & Routing', 'VIP tag attached and routed to Tier 2', 'TK-10452', '4h ago', true),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (_, i) {
          final log = logs[i];
          return ListTile(
            leading: Icon(
              log.success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: log.success ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
            ),
            title: Text(log.ruleName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A))),
            subtitle: Text('${log.action} · ${log.ticketId}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            trailing: Text(log.time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          );
        },
      ),
    );
  }
}

class _AutomationRule {
  final String id;
  final String name;
  final String description;
  final String trigger;
  final List<String> conditions;
  final List<String> actions;
  bool isActive;
  final int triggeredCount;
  final String lastTriggered;

  _AutomationRule({
    required this.id,
    required this.name,
    required this.description,
    required this.trigger,
    required this.conditions,
    required this.actions,
    required this.isActive,
    required this.triggeredCount,
    required this.lastTriggered,
  });
}

class _AutomationLog {
  final String ruleName;
  final String action;
  final String ticketId;
  final String time;
  final bool success;

  _AutomationLog(this.ruleName, this.action, this.ticketId, this.time, this.success);
}
