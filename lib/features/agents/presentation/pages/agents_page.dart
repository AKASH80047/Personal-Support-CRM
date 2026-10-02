import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/agent.dart';
import '../../../../shared/services/mock_data.dart';
import '../../../../shared/widgets/app_modals.dart';

class AgentsPage extends StatefulWidget {
  const AgentsPage({super.key});
  @override
  State<AgentsPage> createState() => _AgentsPageState();
}

class _AgentsPageState extends State<AgentsPage> {
  final _search = TextEditingController();
  String _query = '';
  String _selectedTeam = 'All Teams';
  String _selectedStatus = 'All Status';
  String _sortBy = 'Sort by: Performance';
  bool _isGridView = true;

  late List<Agent> _agentList;

  @override
  void initState() {
    super.initState();
    _agentList = List.from(MockData.agents);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Agent> get _filtered {
    var list = _agentList;

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((a) =>
          a.fullName.toLowerCase().contains(q) ||
          a.email.toLowerCase().contains(q) ||
          a.role.toLowerCase().contains(q)).toList();
    }

    if (_selectedTeam != 'All Teams') {
      list = list.where((a) => a.teamNames.contains(_selectedTeam)).toList();
    }

    if (_selectedStatus != 'All Status') {
      final st = _selectedStatus.toLowerCase();
      list = list.where((a) => a.status.name.toLowerCase() == st).toList();
    }

    if (_sortBy.contains('Workload')) {
      list.sort((a, b) => b.workloadPercent.compareTo(a.workloadPercent));
    } else if (_sortBy.contains('CSAT')) {
      list.sort((a, b) => (b.csatScore ?? 0).compareTo(a.csatScore ?? 0));
    }

    return list;
  }

  void _showInviteModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+91 98765 43215');
    String selectedRole = 'Technical Support';
    String selectedTeam = 'Technical Support';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.person_add_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text('Invite New Agent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Agent Full Name *', prefixIcon: Icon(Icons.badge_outlined, size: 18)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Work Email *', prefixIcon: Icon(Icons.mail_outline_rounded, size: 18)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role / Specialization', prefixIcon: Icon(Icons.work_outline_rounded, size: 18)),
                  items: ['Technical Support', 'Billing Support', 'Customer Success', 'Tier 2 Escalation', 'Team Lead']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedRole = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTeam,
                  decoration: const InputDecoration(labelText: 'Assign to Pod', prefixIcon: Icon(Icons.groups_outlined, size: 18)),
                  items: ['Technical Support', 'Billing Support', 'Customer Success']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedTeam = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;
                final initials = nameCtrl.text.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();
                setState(() {
                  _agentList.add(
                    Agent(
                      id: 'agent-${DateTime.now().millisecondsSinceEpoch}',
                      fullName: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim().isEmpty ? 'agent@support.com' : emailCtrl.text.trim(),
                      role: selectedRole,
                      status: AgentStatus.online,
                      openTickets: 4,
                      resolvedTickets: 45,
                      csatScore: 4.8,
                      workloadPercent: 40.0,
                      teamNames: [selectedTeam],
                      createdAt: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 Agent invited and added to team successfully.'), behavior: SnackBarBehavior.floating),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              child: const Text('Send Invitation'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onlineCount = _agentList.where((a) => a.status == AgentStatus.online).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ 1. Header (Agents + All Agents Dropdown + Invite Agent) ─
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agents',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                      ),
                      SizedBox(height: 4),
                      Text('Manage your support team and track performance.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                // All Agents Dropdown
                PopupMenuButton<String>(
                  onSelected: (v) {},
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'all', child: Text('All Agents')),
                    const PopupMenuItem(value: 'online', child: Text('Active On-Duty')),
                    const PopupMenuItem(value: 'leads', child: Text('Team Leads')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        Text('All Agents', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                        SizedBox(width: 6),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _showInviteModal,
                  icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  label: const Text('Invite Agent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
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

            // ─ 2. 4 Stat KPI Cards (Exact match to Image 3) ─
            Row(
              children: [
                _buildKpiCard(
                  icon: Icons.people_alt_rounded,
                  iconColor: const Color(0xFF2563EB),
                  value: '${_agentList.length}',
                  title: 'Total Agents',
                  trend: '+25% this month',
                  trendUp: true,
                  onTap: () => setState(() {
                    _selectedTeam = 'All Teams';
                    _selectedStatus = 'All Status';
                  }),
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFF10B981),
                  value: '$onlineCount',
                  title: 'Online',
                  trend: 'Active on queue',
                  trendUp: true,
                  isDot: true,
                  onTap: () => setState(() => _selectedStatus = 'Online'),
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  icon: Icons.access_time_filled_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  value: '248',
                  title: 'Tickets Handled',
                  trend: '+18% this month',
                  trendUp: true,
                  onTap: () => context.go(AppRoutes.tickets),
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  value: '4.5',
                  title: 'Average CSAT',
                  trend: '+0.3 this month',
                  trendUp: true,
                  onTap: () => context.go(AppRoutes.analytics),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─ 3. Toolbar (Search + All Teams Dropdown + All Status Dropdown + Sort By + View Toggle) ─
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search_rounded, size: 19, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _search,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: const InputDecoration(
                              hintText: 'Search agents by name, role, or email...',
                              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // All Teams Dropdown
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() => _selectedTeam = val),
                  itemBuilder: (ctx) => [
                    'All Teams',
                    'Technical Support',
                    'Billing Support',
                    'Customer Success',
                  ].map((t) => PopupMenuItem(value: t, child: Text(t))).toList(),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Text(_selectedTeam, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // All Status Dropdown
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() => _selectedStatus = val),
                  itemBuilder: (ctx) => [
                    'All Status',
                    'Online',
                    'Away',
                    'Offline',
                  ].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Text(_selectedStatus, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Sort By Dropdown
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() => _sortBy = val),
                  itemBuilder: (ctx) => [
                    'Sort by: Performance',
                    'Sort by: Workload',
                    'Sort by: CSAT',
                  ].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Text(_sortBy, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // View Toggle (Grid / List)
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.grid_view_rounded, size: 18, color: _isGridView ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                        onPressed: () => setState(() => _isGridView = true),
                      ),
                      Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                      IconButton(
                        icon: Icon(Icons.format_list_bulleted_rounded, size: 18, color: !_isGridView ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                        onPressed: () => setState(() => _isGridView = false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─ 4. Agent Cards Grid + Add New Agent Card (Exact match to Image 3) ─
            _buildAgentsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String title,
    required String trend,
    required bool trendUp,
    bool isDot = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        const SizedBox(width: 6),
                        Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (isDot) ...[
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                        ] else ...[
                          Icon(trendUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: const Color(0xFF16A34A)),
                          const SizedBox(width: 2),
                        ],
                        Text(trend, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
                      ],
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

  Widget _buildAgentsGrid(BuildContext context) {
    final agents = _filtered;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: agents.length + 1, // +1 for the "Add New Agent" card
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (ctx, index) {
        if (index < agents.length) {
          return _buildAgentCard(agents[index]);
        } else {
          return _buildAddAgentCard();
        }
      },
    );
  }

  Widget _buildAgentCard(Agent a) {
    final workloadColor = a.workloadPercent > 80
        ? const Color(0xFFEF4444)
        : (a.workloadPercent > 50 ? const Color(0xFF10B981) : const Color(0xFF10B981));

    return InkWell(
      onTap: () => context.go('${AppRoutes.agents}/${a.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
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
          // Row 1: Avatar + Name + Status Badge + 3-dots
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _getAgentAvatarColor(a.fullName),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(a.initials, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            a.fullName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildAgentStatusPill(a.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(a.role, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded, size: 18, color: Color(0xFF94A3B8)),
                onSelected: (v) {
                  if (v == 'details') {
                    context.go('${AppRoutes.agents}/${a.id}');
                  } else if (v == 'toggle_status') {
                    setState(() {
                      final idx = _agentList.indexWhere((agent) => agent.id == a.id);
                      if (idx != -1) {
                        final newStatus = a.status == AgentStatus.online ? AgentStatus.away : AgentStatus.online;
                        _agentList[idx] = Agent(
                          id: a.id,
                          fullName: a.fullName,
                          email: a.email,
                          avatarUrl: a.avatarUrl,
                          status: newStatus,
                          role: a.role,
                          teamIds: a.teamIds,
                          teamNames: a.teamNames,
                          openTickets: a.openTickets,
                          resolvedTickets: a.resolvedTickets,
                          avgResponseMinutes: a.avgResponseMinutes,
                          csatScore: a.csatScore,
                          slaCompliance: a.slaCompliance,
                          workloadPercent: a.workloadPercent,
                          lastSeenAt: DateTime.now(),
                          createdAt: a.createdAt,
                        );
                      }
                    });
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'details', child: Text('View Performance Profile')),
                  const PopupMenuItem(value: 'toggle_status', child: Text('Toggle Status (Online/Away)')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Email & Phone
          Row(
            children: [
              const Icon(Icons.mail_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(child: Text(a.email, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 2),
          const Row(
            children: [
              Icon(Icons.phone_outlined, size: 13, color: Color(0xFF94A3B8)),
              SizedBox(width: 4),
              Text('+91 98765 43210', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const Spacer(),

          // Stats: Tickets, Resolved, CSAT
          Row(
            children: [
              _buildMiniMetric('Tickets', '${a.openTickets}'),
              _buildMiniMetric('Resolved', '${a.resolvedTickets}'),
              _buildMiniMetric('CSAT', '★ ${a.csatScore?.toStringAsFixed(1) ?? "4.7"}'),
            ],
          ),
          const SizedBox(height: 8),

          // Workload Progress Bar
          Row(
            children: [
              const Text('Workload', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const Spacer(),
              Text('${a.workloadPercent.toInt()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: workloadColor)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: a.workloadPercent / 100,
              minHeight: 4,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(workloadColor),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildAddAgentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(height: 10),
          const Text('Add New Agent', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Invite a new team member to your support team and start collaborating.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _showInviteModal,
            icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
            label: const Text('Invite Agent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildAgentStatusPill(AgentStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case AgentStatus.online:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        label = 'Online';
        break;
      case AgentStatus.away:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'Away';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        label = 'Offline';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 10)),
    );
  }

  Color _getAgentAvatarColor(String name) {
    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFF3B82F6),
      const Color(0xFFEF4444),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}
