import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/agent.dart';
import '../../../../shared/services/mock_data.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All Teams';

  List<Team> get _filteredTeams {
    return MockData.teams.where((team) {
      final matchesSearch = team.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (team.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesSearch;
    }).toList();
  }

  void _showCreateTeamDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String strategy = 'Round Robin';

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
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.group_add_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Create Support Pod / Team'),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Team / Pod Name', style: AppTypography.bodySmSemiBold),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. VIP Priority Escalate',
                      prefixIcon: Icon(Icons.badge_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Description & Scope', style: AppTypography.bodySmSemiBold),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Handles high-priority enterprise customer issues',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Ticket Routing Strategy', style: AppTypography.bodySmSemiBold),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: strategy,
                    items: ['Round Robin', 'Least Busy Agent', 'Skill-Based Matrix', 'Manual Dispatch']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => strategy = val!),
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
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Team "${nameCtrl.text.isEmpty ? 'New Team' : nameCtrl.text}" created successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Create Pod'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teams = _filteredTeams;
    final totalMembers = MockData.teams.fold<int>(0, (sum, t) => sum + t.members.length);
    final totalOpen = MockData.teams.fold<int>(0, (sum, t) => sum + t.openTickets);
    final avgSla = (MockData.teams.fold<double>(0, (sum, t) => sum + (t.slaCompliance ?? 0)) / MockData.teams.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ Top Header ─
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Support Teams & Pods', style: AppTypography.h3),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${MockData.teams.length} Active Pods',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage tier routing, agent capacity, and pod SLA performance in real-time.',
                        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Create Team Pod'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onPressed: _showCreateTeamDialog,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ─ KPI Summary Cards ─
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              return GridView.count(
                crossAxisCount: isNarrow ? 2 : 4,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isNarrow ? 2.2 : 2.5,
                children: [
                  _buildHeaderKpi('Active Pods', '${MockData.teams.length}', Icons.groups_rounded, AppColors.primary, '+1 this month', onTap: () => setState(() => _searchQuery = '')),
                  _buildHeaderKpi('On-Duty Staff', '$totalMembers Engineers', Icons.engineering_rounded, AppColors.secondary, '100% capacity', onTap: () => context.go(AppRoutes.agents)),
                  _buildHeaderKpi('Queued Tickets', '$totalOpen Active', Icons.confirmation_number_rounded, AppColors.warning, 'Normal load', onTap: () => context.go(AppRoutes.tickets)),
                  _buildHeaderKpi('Average SLA', '${avgSla.toStringAsFixed(1)}%', Icons.verified_rounded, AppColors.success, 'Target > 92%', onTap: () => context.go(AppRoutes.analytics)),
                ],
              );
            }),
            const SizedBox(height: AppSpacing.xl2),

            // ─ Filter & Search Bar ─
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: const InputDecoration(
                          hintText: 'Filter by pod name, role, or keywords...',
                          prefixIcon: Icon(Icons.search_rounded, size: 18, color: AppColors.neutral400),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ...['All Teams', 'Tier 1', 'Tier 2 & 3', 'Billing'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedFilter = filter),
                        selectedColor: AppColors.primarySurface,
                        labelStyle: AppTypography.labelSm.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.neutral600,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl2),

            // ─ Team Cards Grid ─
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth > 1100 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: teams.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: AppSpacing.xl,
                  mainAxisSpacing: AppSpacing.xl,
                  mainAxisExtent: 310,
                ),
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return _buildTeamCard(context, team);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderKpi(String title, String value, IconData icon, Color color, String subtitle, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: AppTypography.labelSm.copyWith(color: AppColors.neutral500)),
                  const SizedBox(height: 2),
                  Text(value, style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700)),
                  Text(subtitle, style: AppTypography.bodyXs.copyWith(color: AppColors.success, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, Team team) {
    final teamColor = Color(int.parse((team.color ?? '#4F46E5').replaceFirst('#', 'FF'), radix: 16));
    final workloadPercent = ((team.openTickets / (team.members.isEmpty ? 1 : team.members.length * 8)) * 100).clamp(10, 100).toDouble();

    return InkWell(
      onTap: () => context.go('${AppRoutes.teams}/${team.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // ─ Card Header ─
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [teamColor, teamColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: teamColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.groups_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(team.name, style: AppTypography.h5.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Active Pod',
                            style: AppTypography.labelSm.copyWith(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      team.description ?? 'Specialized customer escalation and technical support queue.',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.neutral500),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'manage', child: Text('Manage Members')),
                  const PopupMenuItem(value: 'rules', child: Text('Routing Rules')),
                  const PopupMenuItem(value: 'stats', child: Text('Export SLA Report')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─ Team Metrics Row ─
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metricItem('Members', '${team.members.length}', Icons.person_outline_rounded, AppColors.primary),
                _divider(),
                _metricItem('Open Queue', '${team.openTickets}', Icons.confirmation_number_outlined, AppColors.warning),
                _divider(),
                _metricItem('Resolved', '${team.resolvedTickets}', Icons.check_circle_outline_rounded, AppColors.success),
                _divider(),
                _metricItem('SLA Compliance', '${team.slaCompliance?.toStringAsFixed(1) ?? '95.0'}%', Icons.verified_outlined, AppColors.secondary),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ─ Workload Capacity Bar ─
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Workload Capacity', style: AppTypography.labelSm.copyWith(color: AppColors.neutral500)),
              Text('${workloadPercent.toInt()}% Capacity',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: workloadPercent > 80 ? AppColors.danger : AppColors.primary,
                  )),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: workloadPercent / 100,
              minHeight: 6,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(
                workloadPercent > 80 ? AppColors.danger : teamColor,
              ),
            ),
          ),
          const Spacer(),

          // ─ Card Footer ─
          Row(
            children: [
              // Overlapping avatars
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    ...team.members.take(4).map((m) => Container(
                      width: 28, height: 28,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(m.initials, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    )),
                    if (team.members.length > 4)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('+${team.members.length - 4}', style: AppTypography.labelSm.copyWith(fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => context.go('${AppRoutes.teams}/${team.id}'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                label: const Text('Open Pod Workspace'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _metricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(value, style: AppTypography.bodySmSemiBold.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.neutral500, fontSize: 10)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 24, color: AppColors.neutral200);
  }
}
