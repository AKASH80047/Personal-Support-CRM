import 'package:equatable/equatable.dart';

class KnowledgeArticle extends Equatable {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String category;
  final String? authorId;
  final String? authorName;
  final String? authorAvatar;
  final String status; // draft | published | archived
  final int views;
  final int helpfulCount;
  final int notHelpfulCount;
  final List<String> tags;
  final String? metaDescription;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.category,
    this.authorId,
    this.authorName,
    this.authorAvatar,
    this.status = 'published',
    this.views = 0,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    this.tags = const [],
    this.metaDescription,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  double get helpfulPercent {
    final total = helpfulCount + notHelpfulCount;
    if (total == 0) return 0;
    return (helpfulCount / total) * 100;
  }

  @override
  List<Object?> get props => [id, title, slug, status];
}
