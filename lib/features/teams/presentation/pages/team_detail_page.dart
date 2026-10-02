import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/services/mock_data.dart';

class TeamDetailPage extends StatelessWidget {
  final String teamId;
  const TeamDetailPage({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    final team = MockData.teams.firstWhere((t) => t.id == teamId, orElse: () => MockData.teams.first);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: Text(team.name),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Edit')),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(team.description ?? '', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl2),
          Row(children: [
            _StatCard('Open Tickets', '${team.openTickets}', AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            _StatCard('Resolved', '${team.resolvedTickets}', AppColors.success),
            const SizedBox(width: AppSpacing.md),
            _StatCard('SLA Compliance', '${team.slaCompliance?.toStringAsFixed(1) ?? '—'}%', AppColors.warning),
          ]),
          const SizedBox(height: AppSpacing.xl2),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Members (${team.members.length})', style: AppTypography.h5),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add_rounded, size: 16),
              label: const Text('Add Member'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 16)),
              onPressed: () {},
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          ...team.members.map((m) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
                child: Center(child: Text(m.initials, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.fullName, style: AppTypography.bodySmSemiBold),
                Text(m.email, style: AppTypography.bodyXs.copyWith(color: AppColors.textTertiary)),
              ])),
              Text('${m.openTickets} open', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.danger, size: 18),
                onPressed: () {},
                tooltip: 'Remove from team',
              ),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);
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
        Text(value, style: AppTypography.h4.copyWith(color: color)),
        Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
      ]),
    ),
  );
}
