import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/app_router.dart';
import '../models/ticket.dart';
import '../models/task.dart';
import '../services/mock_data.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// 1. GLOBAL SEARCH SPOTLIGHT (Ctrl + K)
/// ─────────────────────────────────────────────────────────────────────────────
void showGlobalSearchDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (ctx) => const _GlobalSearchDialog(),
  );
}

class _GlobalSearchDialog extends StatefulWidget {
  const _GlobalSearchDialog();
  @override
  State<_GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<_GlobalSearchDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Tickets', 'Customers', 'Tasks', 'Articles', 'Agents', 'Shortcuts'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tickets = MockData.tickets.where((t) {
      if (_query.isEmpty) return true;
      return t.ticketNumber.toLowerCase().contains(_query.toLowerCase()) ||
          t.subject.toLowerCase().contains(_query.toLowerCase()) ||
          (t.customerName?.toLowerCase().contains(_query.toLowerCase()) ?? false);
    }).take(4).toList();

    final customers = MockData.customers.where((c) {
      if (_query.isEmpty) return true;
      return c.fullName.toLowerCase().contains(_query.toLowerCase()) ||
          (c.company?.toLowerCase().contains(_query.toLowerCase()) ?? false) ||
          (c.email?.toLowerCase().contains(_query.toLowerCase()) ?? false);
    }).take(3).toList();

    final tasks = MockData.tasks.where((task) {
      if (_query.isEmpty) return true;
      return task.title.toLowerCase().contains(_query.toLowerCase()) ||
          (task.description?.toLowerCase().contains(_query.toLowerCase()) ?? false) ||
          (task.customerName?.toLowerCase().contains(_query.toLowerCase()) ?? false) ||
          (task.ticketNumber?.toLowerCase().contains(_query.toLowerCase()) ?? false);
    }).take(4).toList();

    final articles = MockData.articles.where((a) {
      if (_query.isEmpty) return true;
      return a.title.toLowerCase().contains(_query.toLowerCase()) ||
          a.category.toLowerCase().contains(_query.toLowerCase());
    }).take(3).toList();

    final agents = MockData.agents.where((a) {
      if (_query.isEmpty) return true;
      return a.fullName.toLowerCase().contains(_query.toLowerCase()) ||
          a.role.toLowerCase().contains(_query.toLowerCase());
    }).take(3).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 580),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─ Search Header Input ─
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF2563EB), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: const InputDecoration(
                          hintText: 'Search tickets, customers, articles, agents...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: const Text('ESC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                    ),
                  ],
                ),
              ),

              // ─ Filter Chips ─
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFF8FAFC),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final selected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => setState(() => _selectedCategory = cat),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF2563EB) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                                color: selected ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ─ Results List ─
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Shortcuts Section
                    if (_selectedCategory == 'All' || _selectedCategory == 'Shortcuts') ...[
                      _buildSectionHeader('QUICK NAVIGATION'),
                      _buildShortcutItem(
                        icon: Icons.grid_view_rounded,
                        title: 'Dashboard Overview',
                        subtitle: 'Go to main metrics & sparklines',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(AppRoutes.dashboard);
                        },
                      ),
                      _buildShortcutItem(
                        icon: Icons.confirmation_number_rounded,
                        title: 'All Tickets (64)',
                        subtitle: 'View queue, SLA timers, and agent assignments',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(AppRoutes.tickets);
                        },
                      ),
                      _buildShortcutItem(
                        icon: Icons.add_circle_outline_rounded,
                        title: 'Create New Ticket',
                        subtitle: 'Open new ticket dispatch composer',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(AppRoutes.createTicket);
                        },
                      ),
                      _buildShortcutItem(
                        icon: Icons.checklist_rounded,
                        title: 'Tasks & Follow-Ups (${MockData.tasks.where((k) => k.status != TaskStatus.completed).length})',
                        subtitle: 'View SLA follow-up queue, customer reminders, and to-dos',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(AppRoutes.tasks);
                        },
                      ),
                      _buildShortcutItem(
                        icon: Icons.bolt_rounded,
                        title: 'Automations & SLA Rules',
                        subtitle: 'Manage triage triggers and routing',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(AppRoutes.automations);
                        },
                      ),
                    ],

                    // Tasks Section
                    if (_selectedCategory == 'All' || _selectedCategory == 'Tasks') ...[
                      if (tasks.isNotEmpty) ...[
                        _buildSectionHeader('TASKS & FOLLOW-UPS'),
                        ...tasks.map((task) => _buildResultItem(
                          icon: Icons.task_alt_rounded,
                          iconColor: const Color(0xFF0D9488),
                          title: task.title,
                          subtitle: '${task.customerName ?? "General"} · Priority: ${task.priority.label} · Status: ${task.status.label}',
                          onTap: () {
                            Navigator.pop(context);
                            context.go(AppRoutes.tasks);
                          },
                        )),
                      ],
                    ],

                    // Tickets Section
                    if (_selectedCategory == 'All' || _selectedCategory == 'Tickets') ...[
                      if (tickets.isNotEmpty) ...[
                        _buildSectionHeader('TICKETS'),
                        ...tickets.map((t) => _buildResultItem(
                          icon: Icons.confirmation_number_outlined,
                          iconColor: const Color(0xFF2563EB),
                          title: '${t.ticketNumber}: ${t.subject}',
                          subtitle: '${t.customerName ?? "Guest"} · ${t.status.label} · ${t.priority.label}',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('${AppRoutes.tickets}/${t.id}');
                          },
                        )),
                      ],
                    ],

                    // Customers Section
                    if (_selectedCategory == 'All' || _selectedCategory == 'Customers') ...[
                      if (customers.isNotEmpty) ...[
                        _buildSectionHeader('CUSTOMERS'),
                        ...customers.map((c) => _buildResultItem(
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: c.fullName,
                          subtitle: '${c.company ?? "Individual"} · ${c.email ?? ""} · ${c.totalTickets} tickets',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('${AppRoutes.customers}/${c.id}');
                          },
                        )),
                      ],
                    ],

                    // Knowledge Articles Section
                    if (_selectedCategory == 'All' || _selectedCategory == 'Articles') ...[
                      if (articles.isNotEmpty) ...[
                        _buildSectionHeader('KNOWLEDGE BASE'),
                        ...articles.map((a) => _buildResultItem(
                          icon: Icons.menu_book_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: a.title,
                          subtitle: '${a.category} · ${a.views} views · ${a.helpfulCount} helpful',
                          onTap: () {
                            Navigator.pop(context);
                            context.go(AppRoutes.knowledgeBase);
                          },
                        )),
                      ],
                    ],

                    // Agents Section
                    if (_selectedCategory == 'All' || _selectedCategory == 'Agents') ...[
                      if (agents.isNotEmpty) ...[
                        _buildSectionHeader('AGENTS & TEAMS'),
                        ...agents.map((a) => _buildResultItem(
                          icon: Icons.support_agent_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: a.fullName,
                          subtitle: '${a.role} · ${a.workloadPercent.toInt()}% Workload · ${a.status.name.toUpperCase()}',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('${AppRoutes.agents}/${a.id}');
                          },
                        )),
                      ],
                    ],
                  ],
                ),
              ),

              // ─ Footer with keyboard helpers ─
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: const Row(
                  children: [
                    Text('Navigate', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    SizedBox(width: 4),
                    Text('↑↓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    SizedBox(width: 14),
                    Text('Select', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    SizedBox(width: 4),
                    Text('↵', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    Spacer(),
                    Text('SupportCRM Enterprise Search', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildShortcutItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: const Color(0xFFF1F5F9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 2. UPGRADE TO PRO MODAL (Exact match with Pricing & AI Features)
/// ─────────────────────────────────────────────────────────────────────────────
void showUpgradeToProDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (ctx) => const _UpgradeToProDialog(),
  );
}

class _UpgradeToProDialog extends StatefulWidget {
  const _UpgradeToProDialog();
  @override
  State<_UpgradeToProDialog> createState() => _UpgradeToProDialogState();
}

class _UpgradeToProDialogState extends State<_UpgradeToProDialog> {
  bool _isAnnual = true;
  bool _upgrading = false;

  @override
  Widget build(BuildContext context) {
    final price = _isAnnual ? 24 : 29;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B28CC).withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─ Header Banner with Gradient ─
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B28CC), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text('POWERED BY ADVANCED AI', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Upgrade to SupportCRM Pro',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Supercharge your customer support with AI automation, omnichannel triage, and unlimited tier pods.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),

                    // Billing Cycle Toggle
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildToggleOption('Monthly', !_isAnnual, () => setState(() => _isAnnual = false)),
                          _buildToggleOption('Annual (Save 20%)', _isAnnual, () => setState(() => _isAnnual = true)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─ Features & Price Body ─
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('\$$price', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        const Text('/agent / month', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text('14-day free trial', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    _buildProFeature(Icons.auto_awesome_rounded, 'AI Copilot Unlimited', 'Instant AI drafted replies, sentiment analysis & thread summaries'),
                    _buildProFeature(Icons.hub_rounded, 'Multi-tier Support Pods', 'Automatic smart routing with workload balancing & tier escalations'),
                    _buildProFeature(Icons.timer_outlined, 'Custom SLA Management', 'Tiered SLA rules with instant automated breach prevention warnings'),
                    _buildProFeature(Icons.insights_rounded, 'Real-time CSAT & Analytics', 'Exportable executive PDF/Excel reports & agent performance heatmaps'),
                    _buildProFeature(Icons.security_rounded, 'SOC2 & HIPAA Compliant', 'Enterprise data encryption, audit logs, and priority 24/7 phone support'),

                    const SizedBox(height: 24),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _upgrading ? null : _handleUpgrade,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _upgrading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Start 14-Day Free Pro Trial', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? const Color(0xFF3B28CC) : Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildProFeature(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                Text(description, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpgrade() async {
    setState(() => _upgrading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _upgrading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Congratulations! SupportCRM Pro 14-day trial activated successfully.'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 3. EXPORT DATA DIALOG
/// ─────────────────────────────────────────────────────────────────────────────
void showExportDataDialog(BuildContext context, {required String title, required String countText}) {
  showDialog(
    context: context,
    builder: (ctx) => _ExportDialog(title: title, countText: countText),
  );
}

class _ExportDialog extends StatefulWidget {
  final String title;
  final String countText;
  const _ExportDialog({required this.title, required this.countText});

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  String _format = 'CSV';
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.file_download_outlined, color: Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Text('Export ${widget.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Exporting ${widget.countText} according to your active filters.', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          const Text('Select Export Format:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Row(
            children: ['CSV', 'Excel (.xlsx)', 'PDF Report', 'JSON'].map((fmt) {
              final sel = _format == fmt;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(fmt),
                  selected: sel,
                  onSelected: (v) => setState(() => _format = fmt),
                  selectedColor: const Color(0xFF2563EB),
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : const Color(0xFF475569),
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (_exporting) ...[
            const LinearProgressIndicator(color: Color(0xFF2563EB)),
            const SizedBox(height: 8),
            const Text('Generating export payload...', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _exporting
              ? null
              : () async {
                  setState(() => _exporting = true);
                  await Future.delayed(const Duration(milliseconds: 1000));
                  if (mounted) {
                    setState(() => _exporting = false);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📥 ${widget.title} exported as $_format successfully!'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
          icon: const Icon(Icons.download_rounded, size: 16),
          label: const Text('Download Export'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 4. DATE RANGE FILTER DIALOG
/// ─────────────────────────────────────────────────────────────────────────────
/// Enterprise Date Range Filter Dialog (Desktop & Mobile Optimized)
/// ─────────────────────────────────────────────────────────────────────────────
void showDateRangeFilterDialog(BuildContext context, {required Function(String) onSelected}) {
  final isDesktop = MediaQuery.of(context).size.width >= 700;

  if (isDesktop) {
    showDialog(
      context: context,
      builder: (ctx) => _DesktopDateRangeDialog(onSelected: onSelected),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _MobileDateRangeSheet(onSelected: onSelected),
    );
  }
}

class _DesktopDateRangeDialog extends StatefulWidget {
  final Function(String) onSelected;
  const _DesktopDateRangeDialog({required this.onSelected});

  @override
  State<_DesktopDateRangeDialog> createState() => _DesktopDateRangeDialogState();
}

class _DesktopDateRangeDialogState extends State<_DesktopDateRangeDialog> {
  String _selectedPreset = 'Last 7 Days';
  DateTimeRange? _customRange;

  final List<Map<String, String>> _presets = [
    {'title': 'Today', 'range': 'Sep 11, 2026 (Today)'},
    {'title': 'Yesterday', 'range': 'Sep 10, 2026'},
    {'title': 'Last 7 Days', 'range': 'Sep 5, 2026 - Sep 11, 2026'},
    {'title': 'Last 30 Days', 'range': 'Aug 12, 2026 - Sep 11, 2026'},
    {'title': 'This Month', 'range': 'Sep 1, 2026 - Sep 30, 2026'},
    {'title': 'Last Month', 'range': 'Aug 1, 2026 - Aug 31, 2026'},
    {'title': 'Last 90 Days', 'range': 'Jun 12, 2026 - Sep 11, 2026'},
    {'title': 'Year to Date (2026)', 'range': 'Jan 1, 2026 - Sep 11, 2026'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.date_range_rounded, color: Color(0xFF2563EB), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Filter by Date Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      Text('Select a predefined timeframe or pick custom calendar dates', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),

            // Presets Grid
            const Text('QUICK PRESETS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFF94A3B8))),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((preset) {
                final isSelected = _selectedPreset == preset['title'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPreset = preset['title']!;
                      _customRange = null;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check_rounded, size: 14, color: Color(0xFF2563EB)),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          preset['title']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),

            // Custom Range Picker Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CUSTOM CALENDAR RANGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 4),
                    Text(
                      _customRange != null
                          ? '${_customRange!.start.month}/${_customRange!.start.day}/${_customRange!.start.year} - ${_customRange!.end.month}/${_customRange!.end.day}/${_customRange!.end.year}'
                          : 'No custom date range selected',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _customRange != null ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF2563EB)),
                  label: const Text('Open Calendar', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    backgroundColor: const Color(0xFFF0FDF4).withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2027),
                      initialDateRange: _customRange ?? DateTimeRange(start: DateTime(2026, 9, 5), end: DateTime(2026, 9, 11)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF2563EB),
                              onPrimary: Colors.white,
                              onSurface: Color(0xFF0F172A),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _customRange = picked;
                        _selectedPreset = 'Custom';
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    String selectedRangeStr;
                    if (_customRange != null) {
                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                      selectedRangeStr = '${months[_customRange!.start.month - 1]} ${_customRange!.start.day}, ${_customRange!.start.year} - ${months[_customRange!.end.month - 1]} ${_customRange!.end.day}, ${_customRange!.end.year}';
                    } else {
                      final found = _presets.firstWhere((p) => p['title'] == _selectedPreset, orElse: () => _presets[2]);
                      selectedRangeStr = found['range']!;
                    }
                    Navigator.pop(context);
                    widget.onSelected(selectedRangeStr);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            Text('Date range applied: $selectedRangeStr'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF2563EB),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(milliseconds: 1800),
                      ),
                    );
                  },
                  child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileDateRangeSheet extends StatelessWidget {
  final Function(String) onSelected;
  const _MobileDateRangeSheet({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Date Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),
            ...[
              'Today (Sep 11, 2026)',
              'Yesterday (Sep 10, 2026)',
              'Last 7 Days (Sep 5, 2026 - Sep 11, 2026)',
              'Last 30 Days (Aug 12 - Sep 11, 2026)',
              'This Month (September 2026)',
              'Last Quarter (Q2 2026)',
              'All Time',
            ].map((range) => ListTile(
              title: Text(range, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
              onTap: () {
                Navigator.pop(context);
                onSelected(range);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('📅 Filter applied: $range'), behavior: SnackBarBehavior.floating),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}

