import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/services/mock_data.dart';

class ArticleDetailPage extends StatefulWidget {
  final String articleId;
  const ArticleDetailPage({super.key, required this.articleId});
  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  bool? _helpful;

  @override
  Widget build(BuildContext context) {
    final article = MockData.articles.firstWhere((a) => a.id == widget.articleId,
        orElse: () => MockData.articles.first);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: const Text('Knowledge Base'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}, tooltip: 'Edit'),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 80 : AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Breadcrumb
              Text('${article.category} → ${article.title}',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: AppSpacing.xl2),
              Text(article.title, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                _ConvAvatar(name: article.authorName ?? 'A'),
                const SizedBox(width: 8),
                Text('By ${article.authorName ?? 'SupportCRM Team'}',
                    style: AppTypography.bodySmMedium),
                const SizedBox(width: 12),
                Text('·', style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary)),
                const SizedBox(width: 12),
                Text('Updated ${_timeAgo(article.updatedAt)}',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary)),
                const Spacer(),
                Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text('${article.views} views',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary)),
              ]),
              const SizedBox(height: AppSpacing.xl2),
              const Divider(),
              const SizedBox(height: AppSpacing.xl2),
              // Content
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(article.content,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary, height: 1.8)),
              ),
              const SizedBox(height: AppSpacing.xl3),
              // Tags
              if (article.tags.isNotEmpty) ...[
                Text('Tags', style: AppTypography.h6),
                const SizedBox(height: AppSpacing.sm),
                Wrap(spacing: 6, runSpacing: 6, children: article.tags.map((t) =>
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(t, style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                  )).toList()),
                const SizedBox(height: AppSpacing.xl3),
              ],
              // Helpful?
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  Text('Was this article helpful?', style: AppTypography.h5, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.lg),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _HelpfulButton(
                      icon: Icons.thumb_up_outlined,
                      label: 'Yes, helpful',
                      selected: _helpful == true,
                      color: AppColors.success,
                      count: article.helpfulCount + (_helpful == true ? 1 : 0),
                      onTap: () => setState(() => _helpful = true),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _HelpfulButton(
                      icon: Icons.thumb_down_outlined,
                      label: 'Not helpful',
                      selected: _helpful == false,
                      color: AppColors.danger,
                      count: article.notHelpfulCount + (_helpful == false ? 1 : 0),
                      onTap: () => setState(() => _helpful = false),
                    ),
                  ]),
                  if (_helpful != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _helpful! ? 'Thank you for your feedback! 🎉' : 'Thanks! We\'ll work on improving this article.',
                      style: AppTypography.bodySmMedium.copyWith(
                        color: _helpful! ? AppColors.success : AppColors.danger),
                    ),
                  ],
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _HelpfulButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final int count;
  final VoidCallback onTap;
  const _HelpfulButton({required this.icon, required this.label, required this.selected,
      required this.color, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: selected ? color : AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.bodySmMedium.copyWith(
            color: selected ? color : AppColors.textSecondary)),
          const SizedBox(width: 8),
          Text('$count', style: AppTypography.labelMd.copyWith(color: AppColors.textTertiary)),
        ]),
      ),
    );
  }
}

class _ConvAvatar extends StatelessWidget {
  final String name;
  const _ConvAvatar({required this.name});
  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
      child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
