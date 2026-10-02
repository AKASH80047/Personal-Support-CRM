import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/routing/app_router.dart';
import '../shared/services/user_profile_service.dart';
import '../shared/widgets/profile_dialog.dart';
import '../shared/widgets/app_modals.dart';

/// Breakpoints
class Breakpoints {
  static const double mobile = 768;
  static const double tablet = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobile && w < tablet;
  }
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}

/// App Shell — exact match to reference SaaS UI
class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _sidebarCollapsed = false;
  double _sidebarWidth = 236.0;
  static const double _sidebarMinWidth = 180.0;
  static const double _sidebarMaxWidth = 340.0;
  static const double _sidebarCollapsedWidth = 76.0;

  final List<_NavItem> _navItems = [
    _NavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Dashboard', AppRoutes.dashboard),
    _NavItem(Icons.confirmation_number_rounded, Icons.confirmation_number_outlined, 'Tickets', AppRoutes.tickets, badge: '64', badgeColor: Color(0xFFEF4444)),
    _NavItem(Icons.inbox_rounded, Icons.inbox_outlined, 'Inbox', AppRoutes.inbox, badge: '2', badgeColor: Color(0xFFEF4444)),
    _NavItem(Icons.people_alt_rounded, Icons.people_alt_outlined, 'Customers', AppRoutes.customers),
    _NavItem(Icons.task_alt_rounded, Icons.task_alt_outlined, 'Tasks & Follow-Ups', AppRoutes.tasks, badge: '3', badgeColor: Color(0xFF2563EB)),
    _NavItem(Icons.menu_book_rounded, Icons.menu_book_outlined, 'Knowledge Base', AppRoutes.knowledgeBase),
    _NavItem(Icons.support_agent_rounded, Icons.support_agent_outlined, 'Agents', AppRoutes.agents),
    _NavItem(Icons.groups_rounded, Icons.groups_outlined, 'Teams', AppRoutes.teams),
    _NavItem(Icons.analytics_rounded, Icons.analytics_outlined, 'Analytics', AppRoutes.analytics),
    _NavItem(Icons.bolt_rounded, Icons.bolt_outlined, 'Automations', AppRoutes.automations),
    _NavItem(Icons.settings_rounded, Icons.settings_outlined, 'Settings', AppRoutes.settings),
    _NavItem(Icons.help_outline_rounded, Icons.help_outline_rounded, 'Help & Support', '/help'),
  ];

  final List<_NavItem> _mobileNavItems = [
    _NavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Dashboard', AppRoutes.dashboard),
    _NavItem(Icons.confirmation_number_rounded, Icons.confirmation_number_outlined, 'Tickets', AppRoutes.tickets),
    _NavItem(Icons.inbox_rounded, Icons.inbox_outlined, 'Inbox', AppRoutes.inbox),
    _NavItem(Icons.task_alt_rounded, Icons.task_alt_outlined, 'Tasks', AppRoutes.tasks),
    _NavItem(Icons.more_horiz_rounded, Icons.more_horiz_rounded, 'More', '/more'),
  ];

  void _onMobileNavTap(int index) {
    if (index < _mobileNavItems.length - 1) {
      context.go(_mobileNavItems[index].route);
    } else {
      _showMoreBottomSheet();
    }
  }

  void _showMoreBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Navigation & Tools', style: AppTypography.h5),
              const SizedBox(height: 8),
              ...[
                _NavItem(Icons.people_alt_rounded, Icons.people_alt_outlined, 'Customers', AppRoutes.customers),
                _NavItem(Icons.menu_book_rounded, Icons.menu_book_outlined, 'Knowledge Base', AppRoutes.knowledgeBase),
                _NavItem(Icons.support_agent_rounded, Icons.support_agent_outlined, 'Agents', AppRoutes.agents),
                _NavItem(Icons.groups_rounded, Icons.groups_outlined, 'Teams', AppRoutes.teams),
                _NavItem(Icons.analytics_rounded, Icons.analytics_outlined, 'Analytics', AppRoutes.analytics),
                _NavItem(Icons.bolt_rounded, Icons.bolt_outlined, 'Automations', AppRoutes.automations),
                _NavItem(Icons.settings_rounded, Icons.settings_outlined, 'Settings', AppRoutes.settings),
              ].map((item) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, color: AppColors.primary, size: 20),
                ),
                title: Text(item.label, style: AppTypography.bodySmSemiBold),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go(item.route);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isTablet = Breakpoints.isTablet(context);

    if (isMobile) return _buildMobileLayout();
    if (isTablet) return _buildTabletLayout();
    return _buildDesktopLayout();
  }

  Widget _buildDesktopLayout() {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final effectiveWidth = _sidebarCollapsed ? _sidebarCollapsedWidth : _sidebarWidth;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar + drag handle wrapped together
          SizedBox(
            width: effectiveWidth,
            child: Stack(
              children: [
                _AppSidebar(
                  navItems: _navItems,
                  collapsed: _sidebarCollapsed,
                  width: effectiveWidth,
                  onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                  onItemTap: (route) {
                    if (route != '/help') {
                      context.go(route);
                    } else {
                      context.go(AppRoutes.knowledgeBase);
                    }
                  },
                  currentRoute: currentRoute,
                ),
                // Drag handle on right edge — always visible
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: _SidebarResizeHandle(
                    onDrag: (dx) {
                      setState(() {
                        if (_sidebarCollapsed && dx > 4) {
                          // Collapsed se drag right → expand
                          _sidebarCollapsed = false;
                          _sidebarWidth = _sidebarMinWidth;
                        } else if (!_sidebarCollapsed) {
                          final newW = _sidebarWidth + dx;
                          if (newW < _sidebarMinWidth - 20) {
                            // Bahut chota kar diya → auto collapse
                            _sidebarCollapsed = true;
                          } else {
                            _sidebarWidth = newW.clamp(_sidebarMinWidth, _sidebarMaxWidth);
                          }
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _AppHeader(
                  onNotificationTap: () => context.go(AppRoutes.notifications),
                  onSearchTap: () => showGlobalSearchDialog(context),
                  onNewTicketTap: () => context.go(AppRoutes.createTicket),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          _AppSidebar(
            navItems: _navItems,
            collapsed: true,
            width: _sidebarCollapsedWidth,
            onToggle: () {},
            onItemTap: (route) => context.go(route),
            currentRoute: currentRoute,
          ),
          Expanded(
            child: Column(
              children: [
                _AppHeader(
                  onNotificationTap: () => context.go(AppRoutes.notifications),
                  onSearchTap: () {},
                  onNewTicketTap: () => context.go(AppRoutes.createTicket),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    int selectedIndex = _mobileNavItems
        .indexWhere((item) => currentRoute.startsWith(item.route));
    if (selectedIndex == -1) selectedIndex = 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.createTicket),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: AppColors.white,
        elevation: 6,
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_mobileNavItems.length, (index) {
                final item = _mobileNavItems[index];
                final isSelected = index == selectedIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => _onMobileNavTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.icon : item.iconOutlined,
                          size: 22,
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : AppColors.neutral400,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTypography.labelSm.copyWith(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : AppColors.neutral400,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Resize Handle ────────────────────────────────────────────────────────────
class _SidebarResizeHandle extends StatefulWidget {
  final void Function(double dx) onDrag;
  const _SidebarResizeHandle({required this.onDrag});

  @override
  State<_SidebarResizeHandle> createState() => _SidebarResizeHandleState();
}

class _SidebarResizeHandleState extends State<_SidebarResizeHandle> {
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _isHovered || _isDragging;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => setState(() => _isDragging = true),
        onHorizontalDragUpdate: (details) => widget.onDrag(details.delta.dx),
        onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
        child: SizedBox(
          width: 8,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isActive ? 3 : 1,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF2563EB).withOpacity(0.8)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(4),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sidebar ─────────────────────────────────────────────────────────────────
class _AppSidebar extends StatefulWidget {
  final List<_NavItem> navItems;
  final bool collapsed;
  final double width;
  final VoidCallback onToggle;
  final void Function(String) onItemTap;
  final String currentRoute;

  const _AppSidebar({
    required this.navItems,
    required this.collapsed,
    required this.width,
    required this.onToggle,
    required this.onItemTap,
    required this.currentRoute,
  });

  @override
  State<_AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<_AppSidebar> {
  bool _newTicketHovered = false;

  @override
  Widget build(BuildContext context) {
    final width = widget.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: width,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Deep rich slate/navy
        border: Border(
          right: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ 1. Brand Logo Header with Workspace Glow ─
          Container(
            height: 72,
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 16 : 18,
            ),
            child: Row(
              children: [
                // Logo Icon with animated glow
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.headset_mic_rounded, color: Colors.white, size: 22),
                  ),
                ),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'SupportCRM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'Support Made Simple',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Mini Toggle button
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF64748B), size: 18),
                    onPressed: widget.onToggle,
                    tooltip: 'Collapse sidebar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ],
            ),
          ),

          // ─ 2. "+ New Ticket" Button with Hover & Shortcut Badge ─
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 12 : 14,
              vertical: 6,
            ),
            child: MouseRegion(
              onEnter: (_) => setState(() => _newTicketHovered = true),
              onExit: (_) => setState(() => _newTicketHovered = false),
              child: InkWell(
                onTap: () => widget.onItemTap(AppRoutes.createTicket),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.collapsed ? 10 : 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _newTicketHovered ? const Color(0xFF1E293B) : const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _newTicketHovered ? const Color(0xFF38BDF8).withOpacity(0.6) : const Color(0xFF334155),
                      width: 1,
                    ),
                    boxShadow: _newTicketHovered
                        ? [
                            BoxShadow(
                              color: const Color(0xFF38BDF8).withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: widget.collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: _newTicketHovered ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
                        size: 19,
                      ),
                      if (!widget.collapsed) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'New Ticket',
                            style: TextStyle(
                              color: _newTicketHovered ? Colors.white : const Color(0xFFE2E8F0),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: const Text(
                            'C',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ─ 3. Nav Items List ─
          Expanded(
            child: ListView.builder(
              itemCount: widget.navItems.length,
              padding: EdgeInsets.symmetric(
                horizontal: widget.collapsed ? 10 : 12,
              ),
              itemBuilder: (context, index) {
                final item = widget.navItems[index];
                final isDashboard = item.route == AppRoutes.dashboard;
                final isActive = isDashboard
                    ? widget.currentRoute == AppRoutes.dashboard
                    : widget.currentRoute.startsWith(item.route);

                return _SidebarNavItem(
                  item: item,
                  isActive: isActive,
                  collapsed: widget.collapsed,
                  onTap: () => widget.onItemTap(item.route),
                );
              },
            ),
          ),

          // ─ 4. Pinned Bottom Operational Status Pill ─
          if (!widget.collapsed)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Systems 100% Operational',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isActive = widget.isActive;
    final collapsed = widget.collapsed;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: (!isActive && _isHovered) ? const Color(0xFF1E293B) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 10 : 12,
              vertical: 9.5,
            ),
            child: Row(
              mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  isActive ? item.icon : item.iconOutlined,
                  size: 19,
                  color: isActive
                      ? Colors.white
                      : (_isHovered ? const Color(0xFFF1F5F9) : const Color(0xFF94A3B8)),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : (_isHovered ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8)),
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  if (item.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: item.badgeColor ?? const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: (item.badgeColor ?? const Color(0xFFEF4444)).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _AppHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onSearchTap;
  final VoidCallback onNewTicketTap;

  const _AppHeader({
    required this.onNotificationTap,
    required this.onSearchTap,
    required this.onNewTicketTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: userProfileService,
      builder: (context, _) {
        return Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: Row(
            children: [
              // ─ Search Box ─
              Expanded(
                child: InkWell(
                  onTap: onSearchTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 40,
                    constraints: const BoxConstraints(maxWidth: 460),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Search tickets, customers, or anything...',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Ctrl  K',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // ─ Notifications ─
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF475569), size: 22),
                    onPressed: onNotificationTap,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),

              // ─ Help Icon ─
              IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF475569), size: 21),
                onPressed: () => context.go(AppRoutes.knowledgeBase),
              ),

              const SizedBox(width: 12),
              Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 12),

              // ─ User Profile with Image Picker Dialog Trigger ─
              InkWell(
                onTap: () => showUserProfileDialog(context),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
                        ),
                        child: ClipOval(
                          child: userProfileService.avatarBytes != null
                              ? Image.memory(userProfileService.avatarBytes!, fit: BoxFit.cover)
                              : (userProfileService.avatarUrl != null
                                  ? Image.network(
                                      userProfileService.avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFF2563EB),
                                        child: const Center(
                                          child: Text('AP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: const Color(0xFF2563EB),
                                      child: const Center(
                                        child: Text('AP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                      ),
                                    )),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfileService.name,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            userProfileService.role,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final String route;
  final String? badge;
  final Color? badgeColor;

  const _NavItem(this.icon, this.iconOutlined, this.label, this.route,
      {this.badge, this.badgeColor});
}
