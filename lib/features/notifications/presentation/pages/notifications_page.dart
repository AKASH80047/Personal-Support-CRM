import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/notification.dart' as model;
import '../../../../shared/services/mock_data.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<model.NotificationItem> _notifications;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notifications = List.from(MockDataService.notifications);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<model.NotificationItem> get _filteredNotifications {
    switch (_tabController.index) {
      case 1: // Unread
        return _notifications.where((n) => !n.isRead).toList();
      case 2: // Tickets
        return _notifications
            .where((n) => n.type == model.NotificationType.ticketAssigned ||
                n.type == model.NotificationType.ticketUpdated ||
                n.type == model.NotificationType.slaBreached)
            .toList();
      case 3: // System / Mention
        return _notifications
            .where((n) => n.type == model.NotificationType.mention ||
                n.type == model.NotificationType.system)
            .toList();
      case 0:
      default:
        return _notifications;
    }
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) {
        return model.NotificationItem(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          createdAt: n.createdAt,
          isRead: true,
          actionRoute: n.actionRoute,
        );
      }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final n = _notifications[index];
        _notifications[index] = model.NotificationItem(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          createdAt: n.createdAt,
          isRead: true,
          actionRoute: n.actionRoute,
        );
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _filteredNotifications;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // ─ Header ─
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text('Notifications', style: AppTypography.h3),
                          if (_unreadCount > 0) ...[
                            const SizedBox(width: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_unreadCount new',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_unreadCount > 0)
                      OutlinedButton.icon(
                        onPressed: _markAllAsRead,
                        icon: const Icon(Icons.done_all_rounded, size: 16),
                        label: const Text('Mark all as read'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  onTap: (_) => setState(() {}),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.neutral500,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    const Tab(text: 'All'),
                    Tab(
                      child: Row(
                        children: [
                          const Text('Unread'),
                          if (_unreadCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Tab(text: 'Tickets'),
                    const Tab(text: 'Mentions & System'),
                  ],
                ),
              ],
            ),
          ),

          // ─ Notification List ─
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.xl2),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildNotificationCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'All caught up!',
            style: AppTypography.h4.copyWith(color: AppColors.neutral700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'No notifications in this category right now.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(model.NotificationItem item) {
    final theme = Theme.of(context);
    final iconData = _getIconForType(item.type);
    final iconColor = _getColorForType(item.type);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      onDismissed: (_) => _deleteNotification(item.id),
      child: InkWell(
        onTap: () {
          if (!item.isRead) _markAsRead(item.id);
          if (item.actionRoute != null && item.actionRoute!.isNotEmpty) {
            context.go(item.actionRoute!);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: item.isRead
                ? theme.colorScheme.surface
                : AppColors.primary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.isRead
                  ? theme.colorScheme.outline.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTypography.bodySmSemiBold.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _formatTimeAgo(item.createdAt),
                          style: AppTypography.bodyXs.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: AppTypography.bodySm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Unread Indicator or Action
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(model.NotificationType type) {
    switch (type) {
      case model.NotificationType.ticketAssigned:
        return Icons.assignment_ind_rounded;
      case model.NotificationType.ticketUpdated:
        return Icons.update_rounded;
      case model.NotificationType.slaBreached:
        return Icons.timer_off_rounded;
      case model.NotificationType.mention:
        return Icons.alternate_email_rounded;
      case model.NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  Color _getColorForType(model.NotificationType type) {
    switch (type) {
      case model.NotificationType.ticketAssigned:
        return AppColors.primary;
      case model.NotificationType.ticketUpdated:
        return AppColors.secondary;
      case model.NotificationType.slaBreached:
        return AppColors.danger;
      case model.NotificationType.mention:
        return AppColors.accent;
      case model.NotificationType.system:
        return AppColors.neutral600;
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
