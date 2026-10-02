import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/agent.dart';
import '../../../../shared/services/mock_data.dart';

class AgentDetailPage extends StatelessWidget {
  final String agentId;
  const AgentDetailPage({super.key, required this.agentId});

  @override
  Widget build(BuildContext context) {
    final agent = MockData.agents.firstWhere((a) => a.id == agentId, orElse: () => MockData.agents.first);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: Text(agent.fullName),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Edit')),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(36)),
                child: Center(child: Text(agent.initials, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(agent.fullName, style: AppTypography.h4),
                Text(agent.email, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, children: [
                  _Chip(agent.role, AppColors.primary),
                  ...agent.teamNames.map((t) => _Chip(t, AppColors.secondary)),
                ]),
              ])),
              Column(children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: agent.status == AgentStatus.online ? AppColors.success : AppColors.neutral400,
                    shape: BoxShape.circle),
                ),
                const SizedBox(height: 4),
                Text(agent.status.label, style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
              ]),
            ]),
          ),
          const SizedBox(height: AppSpacing.xl2),
          // Performance KPIs
          Row(children: [
            _PerfCard('Open Tickets', '${agent.openTickets}', Icons.confirmation_number_rounded, AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            _PerfCard('Resolved', '${agent.resolvedTickets}', Icons.check_circle_rounded, AppColors.success),
            const SizedBox(width: AppSpacing.md),
            _PerfCard('CSAT', '${agent.csatScore?.toStringAsFixed(1) ?? '—'}★', Icons.star_rounded, AppColors.warning),
            const SizedBox(width: AppSpacing.md),
            _PerfCard('Avg Response', '${agent.avgResponseMinutes?.toStringAsFixed(0) ?? '—'} min', Icons.timer_rounded, AppColors.secondary),
          ]),
          const SizedBox(height: AppSpacing.xl2),
          // Workload
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Current Workload', style: AppTypography.h5),
              const SizedBox(height: AppSpacing.lg),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${agent.workloadPercent.toInt()}% capacity used',
                      style: AppTypography.bodySmMedium),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: agent.workloadPercent / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.neutral100,
                      valueColor: AlwaysStoppedAnimation(
                        agent.workloadPercent > 80 ? AppColors.danger : AppColors.primary),
                    ),
                  ),
                ])),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class AgentStatus {
  static get online => null;
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(99)),
    child: Text(label, style: AppTypography.labelSm.copyWith(color: color)),
  );
}

class _PerfCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _PerfCard(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Text(value, style: AppTypography.h5.copyWith(color: AppColors.textPrimary)),
        Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
      ]),
    ),
  );
}
