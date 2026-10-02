import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/ticket.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/services/mock_data.dart';
import '../../../../shared/services/user_profile_service.dart';
import '../../../../shared/widgets/app_modals.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedPeriod = '7 Days';
  String _dateRangeStr = 'Sep 5, 2026 - Sep 11, 2026';
  bool _dateBtnHovered = false;
  final List<String> _periods = ['Today', '7 Days', '30 Days', '90 Days'];

  // Dynamic Trend Chart Data based on selected period
  List<_TrendPoint> get _chartData {
    switch (_selectedPeriod) {
      case 'Today':
        return [
          _TrendPoint('9 AM', 4, 3, 1),
          _TrendPoint('11 AM', 8, 6, 2),
          _TrendPoint('1 PM', 12, 10, 2),
          _TrendPoint('3 PM', 10, 9, 1),
          _TrendPoint('5 PM', 6, 5, 1),
          _TrendPoint('7 PM', 2, 2, 0),
        ];
      case '30 Days':
        return [
          _TrendPoint('Week 1', 180, 160, 20),
          _TrendPoint('Week 2', 240, 215, 25),
          _TrendPoint('Week 3', 310, 290, 20),
          _TrendPoint('Week 4', 280, 260, 20),
        ];
      case '90 Days':
        return [
          _TrendPoint('June', 750, 710, 40),
          _TrendPoint('July', 890, 830, 60),
          _TrendPoint('August', 980, 920, 60),
          _TrendPoint('September', 800, 750, 50),
        ];
      case '7 Days':
      default:
        return [
          _TrendPoint('Sep 5', 20, 15, 8),
          _TrendPoint('Sep 6', 32, 22, 14),
          _TrendPoint('Sep 7', 28, 26, 12),
          _TrendPoint('Sep 8', 45, 30, 18),
          _TrendPoint('Sep 9', 52, 38, 12),
          _TrendPoint('Sep 10', 48, 42, 16),
          _TrendPoint('Sep 11', 40, 35, 10),
        ];
    }
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case 'Today':
          _dateRangeStr = 'Sep 11, 2026 (Today)';
          break;
        case '7 Days':
          _dateRangeStr = 'Sep 5, 2026 - Sep 11, 2026';
          break;
        case '30 Days':
          _dateRangeStr = 'Aug 12, 2026 - Sep 11, 2026';
          break;
        case '90 Days':
          _dateRangeStr = 'Jun 12, 2026 - Sep 11, 2026';
          break;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📅 Analytics updated for $period overview'),
        backgroundColor: const Color(0xFF2563EB),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: userProfileService,
      builder: (context, _) {
        final isMobile = MediaQuery.of(context).size.width < 900;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─ Top Greeting & Date Range Bar ─
                _buildHeader(isMobile),
                const SizedBox(height: 24),

                // ─ 8 KPI Metric Cards Grid ─
                _buildKpiGrid(),
                const SizedBox(height: 24),

                // ─ Middle Row: Ticket Trend Chart ─
                _buildTicketTrendCard(),
                const SizedBox(height: 24),

                // ─ Today's Tasks & SLA Action Items ─
                _buildTasksAndActionItemsCard(),
                const SizedBox(height: 24),

                // ─ Bottom Row: Recent Tickets + Top Categories ─
                if (isMobile) ...[
                  _buildRecentTicketsCard(),
                  const SizedBox(height: 24),
                  _buildTopCategoriesCard(),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _buildRecentTicketsCard()),
                      const SizedBox(width: 24),
                      Expanded(flex: 4, child: _buildTopCategoriesCard()),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Header with Clickable Date Range & Animated Period Switcher ────────
  Widget _buildHeader(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, ${userProfileService.name.split(' ').first} 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Here's your support performance overview. Keep up the great work!",
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        if (!isMobile) ...[
          // ─ Clickable Date Range Dropdown with Hover ─
          MouseRegion(
            onEnter: (_) => setState(() => _dateBtnHovered = true),
            onExit: (_) => setState(() => _dateBtnHovered = false),
            child: InkWell(
              onTap: () => showDateRangeFilterDialog(
                context,
                onSelected: (val) => setState(() => _dateRangeStr = val),
              ),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: _dateBtnHovered
                      ? const Color(0xFFF8FAFC)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _dateBtnHovered
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: _dateBtnHovered
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: _dateBtnHovered
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _dateRangeStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _dateBtnHovered
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: _dateBtnHovered
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ─ Clickable Period Switcher Pills with Gradient & Glow ─
          Container(
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: _periods.map((p) {
                final isSelected = p == _selectedPeriod;
                return InkWell(
                  onTap: () => _onPeriodChanged(p),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6.5,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2563EB)
                                    .withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      p,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  // ─── 8 KPI Grid ────────────────────────────────────────────────────────
  Widget _buildKpiGrid() {
    final kpis = [
      _KpiModel(
        title: 'Total Tickets',
        value: '248',
        badgeText: '+12% this week',
        isPositive: true,
        icon: Icons.confirmation_number_outlined,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
        waveColor: const Color(0xFF3B82F6),
      ),
      _KpiModel(
        title: 'Open Tickets',
        value: '64',
        badgeText: '↑ 4 urgent',
        isPositive: false,
        icon: Icons.account_balance_wallet_outlined,
        iconBg: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF10B981),
        waveColor: const Color(0xFF10B981),
      ),
      _KpiModel(
        title: 'Pending',
        value: '11',
        badgeText: '3 awaiting reply',
        isPositive: null,
        icon: Icons.hourglass_empty_rounded,
        iconBg: const Color(0xFFFFFBEB),
        iconColor: const Color(0xFFF59E0B),
        waveColor: const Color(0xFFF59E0B),
      ),
      _KpiModel(
        title: 'Resolved',
        value: '173',
        badgeText: '+8% this week',
        isPositive: true,
        icon: Icons.check_circle_outline_rounded,
        iconBg: const Color(0xFFF5F3FF),
        iconColor: const Color(0xFF8B5CF6),
        waveColor: const Color(0xFF8B5CF6),
      ),
      _KpiModel(
        title: 'SLA Breached',
        value: '4',
        badgeText: '↓ 2 critical',
        isPositive: false,
        icon: Icons.warning_amber_rounded,
        iconBg: const Color(0xFFFEF2F2),
        iconColor: const Color(0xFFEF4444),
        waveColor: const Color(0xFFEF4444),
      ),
      _KpiModel(
        title: 'Avg Response Time',
        value: '22.4 min',
        badgeText: '↓ 5 min vs last week',
        isPositive: true,
        icon: Icons.access_time_rounded,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF0284C7),
        waveColor: const Color(0xFF0284C7),
      ),
      _KpiModel(
        title: 'Avg Resolution Time',
        value: '6.8 hrs',
        badgeText: '↓ 1.2 hrs vs last week',
        isPositive: true,
        icon: Icons.gps_fixed_rounded,
        iconBg: const Color(0xFFF5F3FF),
        iconColor: const Color(0xFF7C3AED),
        waveColor: const Color(0xFF7C3AED),
      ),
      _KpiModel(
        title: 'CSAT Score',
        value: '94.2%',
        badgeText: '+2.1% this week',
        isPositive: true,
        icon: Icons.sentiment_satisfied_alt_rounded,
        iconBg: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF059669),
        waveColor: const Color(0xFF059669),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int cols = 4;
        if (constraints.maxWidth < 650) {
          cols = 1;
        } else if (constraints.maxWidth < 1100) {
          cols = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kpis.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 125,
          ),
          itemBuilder: (context, i) => _buildKpiCard(kpis[i]),
        );
      },
    );
  }

  Widget _buildKpiCard(_KpiModel data) {
    return _InteractiveKpiCard(
      data: data,
      onTap: () {
        if (data.title.contains('Response') ||
            data.title.contains('Resolution') ||
            data.title.contains('CSAT')) {
          context.go(AppRoutes.analytics);
        } else {
          context.go(AppRoutes.tickets);
        }
      },
    );
  }

  // ─── Ticket Trend Chart ────────────────────────────────────────────────
  Widget _buildTicketTrendCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: Color(0xFF2563EB),
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Ticket Trend',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'New, resolved and pending tickets over time',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              // Period chips
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: _periods.map((p) {
                    final isSel = p == _selectedPeriod;
                    return InkWell(
                      onTap: () => _onPeriodChanged(p),
                      borderRadius: BorderRadius.circular(6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSel
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF1D4ED8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSel
                              ? const Color(0xFF2563EB)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB)
                                        .withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1.5),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSel
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSel
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Custom Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _legendDot('New Tickets', const Color(0xFF2563EB)),
              const SizedBox(width: 14),
              _legendDot('Resolved', const Color(0xFF10B981)),
              const SizedBox(width: 14),
              _legendDot('Pending', const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 10),

          // Syncfusion Chart
          SizedBox(
            height: 230,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: const CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 0),
                labelStyle: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              primaryYAxis: const NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Color(0xFFF1F5F9),
                ),
                axisLine: AxisLine(width: 0),
                labelStyle: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: 'Ticket Stats',
                canShowMarker: true,
              ),
              series: [
                SplineAreaSeries<_TrendPoint, String>(
                  name: 'New Tickets',
                  dataSource: _chartData,
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.newTickets,
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderColor: const Color(0xFF2563EB),
                  borderWidth: 2.5,
                ),
                SplineAreaSeries<_TrendPoint, String>(
                  name: 'Resolved',
                  dataSource: _chartData,
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.resolved,
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderColor: const Color(0xFF10B981),
                  borderWidth: 2.5,
                ),
                SplineAreaSeries<_TrendPoint, String>(
                  name: 'Pending',
                  dataSource: _chartData,
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.pending,
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderColor: const Color(0xFFF59E0B),
                  borderWidth: 2.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  // ─── AI Copilot Dark Card ──────────────────────────────────────────────
  Widget _buildAiCopilotCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark navy card from reference
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => context.go(AppRoutes.aiCopilot),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.smart_toy_rounded,
                      color: Color(0xFF60A5FA),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'AI Copilot',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your intelligent support assistant',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Items
          _aiActionItem(
            icon: Icons.error_rounded,
            iconColor: const Color(0xFFEF4444),
            bgColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
            text: '12 high-priority tickets need attention today.',
            onTap: () => context.go(AppRoutes.tickets),
          ),
          const SizedBox(height: 10),
          _aiActionItem(
            icon: Icons.access_time_filled_rounded,
            iconColor: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
            text: '4 tickets are approaching SLA breach in the next hour.',
            onTap: () => context.go(AppRoutes.tickets),
          ),
          const SizedBox(height: 10),
          _aiActionItem(
            icon: Icons.show_chart_rounded,
            iconColor: const Color(0xFF8B5CF6),
            bgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
            text: 'Customer sentiment decreased 8% compared to last week.',
            onTap: () => context.go(AppRoutes.analytics),
          ),
          const SizedBox(height: 10),
          _aiActionItem(
            icon: Icons.lightbulb_rounded,
            iconColor: const Color(0xFF06B6D4),
            bgColor: const Color(0xFF06B6D4).withValues(alpha: 0.15),
            text: 'Suggested reply templates available for common queries.',
            onTap: () => context.go(AppRoutes.aiCopilot),
          ),
        ],
      ),
    );
  }

  Widget _aiActionItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF334155).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF64748B),
              size: 10,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Today's Tasks & SLA Action Items ──────────────────────────────────
  Widget _buildTasksAndActionItemsCard() {
    final pendingTasks = MockData.tasks.where((t) => t.status != TaskStatus.completed).take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Today\'s Follow-Ups & SLA Action Items',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Text(
                          '${MockData.tasks.where((t) => t.status != TaskStatus.completed).length} Due',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'High priority customer reminders, escalations, and SLA follow-ups',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 14),
                label: const Text('Add Task', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
                onPressed: () => context.go(AppRoutes.tasks),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context.go(AppRoutes.tasks),
                child: const Text(
                  'View All Tasks →',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (pendingTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                '🎉 All follow-up tasks completed for today!',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
              ),
            )
          else
            ...pendingTasks.map((task) {
              final isDone = task.status == TaskStatus.completed;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isDone,
                      activeColor: const Color(0xFF16A34A),
                      onChanged: (val) {
                        setState(() {
                          final idx = MockData.tasks.indexWhere((k) => k.id == task.id);
                          if (idx != -1) {
                            MockData.tasks[idx] = task.copyWith(
                              status: val == true ? TaskStatus.completed : TaskStatus.inProgress,
                            );
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              color: isDone ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (task.customerName != null) ...[
                                const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(task.customerName!, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                const SizedBox(width: 10),
                              ],
                              if (task.ticketNumber != null) ...[
                                const Icon(Icons.confirmation_number_outlined, size: 12, color: Color(0xFF2563EB)),
                                const SizedBox(width: 4),
                                Text(task.ticketNumber!, style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                                const SizedBox(width: 10),
                              ],
                              const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                task.dueDate != null ? 'Due in ${_timeRemaining(task.dueDate!)}' : 'Due today',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: switch (task.priority) {
                          TaskPriority.urgent => const Color(0xFFFEE2E2),
                          TaskPriority.high => const Color(0xFFFEF3C7),
                          TaskPriority.medium => const Color(0xFFE0E7FF),
                          TaskPriority.low => const Color(0xFFF1F5F9),
                        },
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.priority.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: switch (task.priority) {
                            TaskPriority.urgent => const Color(0xFFDC2626),
                            TaskPriority.high => const Color(0xFFD97706),
                            TaskPriority.medium => const Color(0xFF4F46E5),
                            TaskPriority.low => const Color(0xFF64748B),
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _timeRemaining(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Overdue';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  // ─── Recent Tickets Table ──────────────────────────────────────────────
  Widget _buildRecentTicketsCard() {
    final recentTickets = MockData.tickets.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder_open_rounded,
                color: Color(0xFF2563EB),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Recent Tickets',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => context.go(AppRoutes.tickets),
                child: const Text(
                  'View all →',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: const [
                SizedBox(
                  width: 60,
                  child: Text(
                    '#',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Subject',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Customer',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Priority',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    'Created',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentTickets.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, i) {
              final t = recentTickets[i];
              return InkWell(
                onTap: () => context.go('${AppRoutes.tickets}/${t.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          t.ticketNumber,
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.subject,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              t.description ?? '',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFF64748B),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  t.customerName != null &&
                                          t.customerName!.length >= 2
                                      ? t.customerName!
                                            .substring(0, 2)
                                            .toUpperCase()
                                      : 'CU',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t.customerName ?? 'Customer',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF334155),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 80, child: _priorityBadge(t.priority)),
                      SizedBox(width: 80, child: _statusBadge(t.status)),
                      SizedBox(
                        width: 110,
                        child: Text(
                          '${t.createdAt.day} Sep 2026\n10:24 AM',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                          tooltip: 'Ticket Options',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onSelected: (val) {
                            if (val == 'view') {
                              context.go('${AppRoutes.tickets}/${t.id}');
                            } else if (val == 'resolve') {
                              setState(() {
                                final idx = MockData.tickets.indexWhere(
                                  (tk) => tk.id == t.id,
                                );
                                if (idx != -1) {
                                  MockData.tickets[idx] = MockData.tickets[idx]
                                      .copyWith(status: TicketStatus.resolved);
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Ticket ${t.ticketNumber} marked as Resolved',
                                  ),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            } else if (val == 'copy') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Copied ${t.ticketNumber} to clipboard',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.visibility_outlined,
                                    size: 16,
                                    color: Color(0xFF2563EB),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'View Details',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'resolve',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: Color(0xFF10B981),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Mark as Resolved',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'copy',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.copy_rounded,
                                    size: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Copy ID',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _priorityBadge(TicketPriority p) {
    final color = switch (p) {
      TicketPriority.critical => const Color(0xFFEF4444),
      TicketPriority.high => const Color(0xFFEF4444),
      TicketPriority.medium => const Color(0xFFF59E0B),
      TicketPriority.low => const Color(0xFF10B981),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          p.label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(TicketStatus s) {
    final (bg, fg) = switch (s) {
      TicketStatus.open => (const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
      TicketStatus.resolved => (
        const Color(0xFFECFDF5),
        const Color(0xFF10B981),
      ),
      TicketStatus.pending => (
        const Color(0xFFFFFBEB),
        const Color(0xFFF59E0B),
      ),
      TicketStatus.closed => (const Color(0xFFF1F5F9), const Color(0xFF64748B)),
      _ => (const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          s.label,
          style: TextStyle(
            color: fg,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ─── Top Categories Progress Bars ──────────────────────────────────────
  Widget _buildTopCategoriesCard() {
    final categories = [
      {
        'name': 'Account & Access',
        'percent': 0.32,
        'color': const Color(0xFF2563EB),
        'label': '32%',
      },
      {
        'name': 'Technical Issue',
        'percent': 0.24,
        'color': const Color(0xFF8B5CF6),
        'label': '24%',
      },
      {
        'name': 'Billing & Payments',
        'percent': 0.18,
        'color': const Color(0xFF10B981),
        'label': '18%',
      },
      {
        'name': 'Feature Request',
        'percent': 0.12,
        'color': const Color(0xFFF59E0B),
        'label': '12%',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pie_chart_outline_rounded,
                color: Color(0xFF2563EB),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Top Categories',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => context.go(AppRoutes.analytics),
                child: const Text(
                  'View all →',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ...categories.map(
            (c) => InkWell(
              onTap: () => context.go(AppRoutes.tickets),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: c['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Text(
                            c['name'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: c['percent'] as double,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                c['color'] as Color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 34,
                          child: Text(
                            c['label'] as String,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers & Models ────────────────────────────────────────────────────────
class _KpiModel {
  final String title;
  final String value;
  final String badgeText;
  final bool? isPositive;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color waveColor;

  _KpiModel({
    required this.title,
    required this.value,
    required this.badgeText,
    required this.isPositive,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.waveColor,
  });
}

class _TrendPoint {
  final String day;
  final double newTickets;
  final double resolved;
  final double pending;

  _TrendPoint(this.day, this.newTickets, this.resolved, this.pending);
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.85,
      size.width * 0.45,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.05,
      size.width,
      size.height * 0.2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InteractiveKpiCard extends StatefulWidget {
  final _KpiModel data;
  final VoidCallback onTap;
  const _InteractiveKpiCard({required this.data, required this.onTap});

  @override
  State<_InteractiveKpiCard> createState() => _InteractiveKpiCardState();
}

class _InteractiveKpiCardState extends State<_InteractiveKpiCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFF8FAFC) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF2563EB).withValues(alpha: 0.6)
                  : const Color(0xFFE2E8F0),
              width: _isHovered ? 1.4 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Box
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: data.iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(data.icon, color: data.iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.title,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.value,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (data.isPositive != null)
                              Icon(
                                data.isPositive!
                                    ? Icons.trending_up_rounded
                                    : Icons.arrow_upward_rounded,
                                size: 13,
                                color: data.isPositive!
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            if (data.isPositive != null)
                              const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                data.badgeText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: data.isPositive == true
                                      ? const Color(0xFF10B981)
                                      : (data.isPositive == false
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF64748B)),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Sparkline Wave on Bottom Right
              Positioned(
                right: 0,
                bottom: 0,
                width: 70,
                height: 32,
                child: CustomPaint(
                  painter: _SparklinePainter(color: data.waveColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
