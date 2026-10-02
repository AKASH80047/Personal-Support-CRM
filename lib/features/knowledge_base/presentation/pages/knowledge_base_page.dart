import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/knowledge_article.dart';
import '../../../../shared/services/mock_data.dart';

class KnowledgeBasePage extends StatefulWidget {
  const KnowledgeBasePage({super.key});
  @override
  State<KnowledgeBasePage> createState() => _KnowledgeBasePageState();
}

class _KnowledgeBasePageState extends State<KnowledgeBasePage> {
  final _search = TextEditingController();
  String _query = '';
  String? _selectedCategory;

  final List<String> _categories = [
    'All', 'Getting Started', 'Account', 'Billing',
    'Technical Support', 'Mobile App', 'FAQ',
  ];

  List<KnowledgeArticle> get _filtered => MockData.articles.where((a) {
    final matchesSearch = _query.isEmpty ||
        a.title.toLowerCase().contains(_query.toLowerCase()) ||
        a.category.toLowerCase().contains(_query.toLowerCase());
    final matchesCat = _selectedCategory == null ||
        _selectedCategory == 'All' ||
        a.category == _selectedCategory;
    return matchesSearch && matchesCat;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Hero search bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 80 : AppSpacing.lg,
              vertical: isDesktop ? 48 : 32,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(children: [
              Text('How can we help?',
                  style: (isDesktop ? AppTypography.h2 : AppTypography.h4)
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Search our knowledge base or browse categories below.',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.neutral400),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search articles...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () { _search.clear(); setState(() => _query = ''); })
                        : null,
                  ),
                ),
              ),
            ]),
          ),
          // Category filters
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? AppSpacing.pageHorizontal : AppSpacing.lg,
                vertical: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: _categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat == 'All' ? null : cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: (_selectedCategory == cat || (cat == 'All' && _selectedCategory == null))
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: (_selectedCategory == cat || (cat == 'All' && _selectedCategory == null))
                                ? AppColors.primary
                                : AppColors.border),
                        ),
                        child: Text(cat, style: AppTypography.bodySmMedium.copyWith(
                          color: (_selectedCategory == cat || (cat == 'All' && _selectedCategory == null))
                              ? Colors.white
                              : AppColors.textSecondary)),
                      ),
                    ),
                  )).toList()),
                )),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New Article'),
                  onPressed: () {},
                ),
              ]),
              const SizedBox(height: AppSpacing.xl2),
              if (_filtered.isEmpty)
                Center(child: Column(children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.article_outlined, size: 64, color: AppColors.neutral300),
                  const SizedBox(height: 16),
                  Text('No articles found', style: AppTypography.h5),
                  const SizedBox(height: 8),
                  Text('Try a different search term or category.',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                ]))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.lg,
                    childAspectRatio: isDesktop ? 1.4 : 1.2,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _ArticleCard(
                    article: _filtered[i],
                    onTap: () => context.go('${AppRoutes.knowledgeBase}/${_filtered[i].id}'),
                  ),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ArticleCard extends StatefulWidget {
  final KnowledgeArticle article;
  final VoidCallback onTap;
  const _ArticleCard({required this.article, required this.onTap});
  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? AppColors.primary.withOpacity(0.4) : AppColors.border),
            boxShadow: _hovered ? [BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 16, offset: const Offset(0, 4))] : [],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(widget.article.category,
                  style: AppTypography.labelSm.copyWith(color: AppColors.primary)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(widget.article.title,
                style: AppTypography.bodySmSemiBold,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(children: [
              Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text('${widget.article.views}',
                  style: AppTypography.bodyXs.copyWith(color: AppColors.textTertiary)),
              const SizedBox(width: 12),
              Icon(Icons.thumb_up_outlined, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text('${widget.article.helpfulCount}',
                  style: AppTypography.bodyXs.copyWith(color: AppColors.textTertiary)),
              const Spacer(),
              Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
            ]),
          ]),
        ),
      ),
    );
  }
}
