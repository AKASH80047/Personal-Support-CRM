import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/services/mock_data.dart';
import '../../../../shared/widgets/app_modals.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _period = '7 Days';
  final List<String> _periods = ['Today', '7 Days', '30 Days', '90 Days', 'Custom'];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Analytics', style: AppTypography.h4),
              Text('Performance insights for your support team',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
            ])),
            _PeriodPicker(periods: _periods, selected: _period, onChanged: (v) => setState(() => _period = v)),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton.icon(
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Export Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => showExportDataDialog(
                context,
                title: 'Export Analytics Report',
                countText: '248 Performance Records',
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.xl2),
          // Overview KPIs
          Row(children: [
            _KpiBox('248', 'Total Tickets', '+12%', true),
            const SizedBox(width: AppSpacing.md),
            _KpiBox('91.3%', 'SLA Compliance', '+2.1%', true),
            const SizedBox(width: AppSpacing.md),
            _KpiBox('22.4 min', 'Avg Response', '-5 min', true),
            const SizedBox(width: AppSpacing.md),
            _KpiBox('94.2%', 'CSAT Score', '+1.8%', true),
          ]),
          const SizedBox(height: AppSpacing.xl2),
          // Charts
          if (isDesktop)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: _buildVolumeChart()),
              const SizedBox(width: AppSpacing.xl2),
              Expanded(child: _buildCategoryDonut()),
            ])
          else ...[
            _buildVolumeChart(),
            const SizedBox(height: AppSpacing.xl2),
            _buildCategoryDonut(),
          ],
          const SizedBox(height: AppSpacing.xl2),
          if (isDesktop)
            Row(children: [
              Expanded(child: _buildAgentPerfChart()),
              const SizedBox(width: AppSpacing.xl2),
              Expanded(child: _buildChannelChart()),
            ])
          else ...[
            _buildAgentPerfChart(),
            const SizedBox(height: AppSpacing.xl2),
            _buildChannelChart(),
          ],
          const SizedBox(height: AppSpacing.xl4),
        ]),
      ),
    );
  }

  Widget _buildVolumeChart() {
    return _ChartCard('Ticket Volume', 'New vs resolved tickets over time',
      SizedBox(
        height: 240,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(width: 0),
            labelStyle: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          primaryYAxis: const NumericAxis(
            majorGridLines: MajorGridLines(width: 1, color: AppColors.borderLight, dashArray: [4, 4]),
            axisLine: AxisLine(width: 0),
            labelStyle: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          legend: const Legend(isVisible: true, position: LegendPosition.bottom,
              textStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            ColumnSeries<Map<String, dynamic>, String>(
              name: 'New',
              dataSource: MockData.ticketTrendData,
              xValueMapper: (d, _) => d['date'].toString().substring(5),
              yValueMapper: (d, _) => d['new'],
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            ColumnSeries<Map<String, dynamic>, String>(
              name: 'Resolved',
              dataSource: MockData.ticketTrendData,
              xValueMapper: (d, _) => d['date'].toString().substring(5),
              yValueMapper: (d, _) => d['resolved'],
              color: AppColors.success,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDonut() {
    final data = [
      {'cat': 'Technical', 'count': 89},
      {'cat': 'Billing', 'count': 54},
      {'cat': 'Account', 'count': 42},
      {'cat': 'Mobile', 'count': 31},
      {'cat': 'Other', 'count': 32},
    ];
    return _ChartCard('Ticket Categories', 'Distribution by category',
      SizedBox(
        height: 240,
        child: SfCircularChart(
          legend: const Legend(isVisible: true, position: LegendPosition.right,
              textStyle: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            DoughnutSeries<Map<String, dynamic>, String>(
              dataSource: data,
              xValueMapper: (d, _) => d['cat'] as String,
              yValueMapper: (d, _) => d['count'],
              innerRadius: '60%',
              pointColorMapper: (_, i) => AppColors.chartPalette[i % AppColors.chartPalette.length],
              dataLabelSettings: const DataLabelSettings(isVisible: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentPerfChart() {
    return _ChartCard('Agent Performance', 'Tickets resolved per agent',
      SizedBox(
        height: 220,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(width: 0),
            labelStyle: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          primaryYAxis: const NumericAxis(
            majorGridLines: MajorGridLines(width: 1, color: AppColors.borderLight, dashArray: [4, 4]),
            axisLine: AxisLine(width: 0),
            labelStyle: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            BarSeries<Map<String, dynamic>, String>(
              dataSource: MockData.agents.map((a) => {'name': a.fullName.split(' ').first, 'count': a.resolvedTickets}).toList(),
              xValueMapper: (d, _) => d['name'] as String,
              yValueMapper: (d, _) => d['count'],
              color: AppColors.primary,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
              dataLabelSettings: const DataLabelSettings(isVisible: true,
                  textStyle: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelChart() {
    final data = [
      {'ch': 'Web', 'pct': 40.0},
      {'ch': 'Email', 'pct': 28.0},
      {'ch': 'Chat', 'pct': 18.0},
      {'ch': 'WhatsApp', 'pct': 9.0},
      {'ch': 'Phone', 'pct': 5.0},
    ];
    return _ChartCard('Channel Distribution', 'Tickets by support channel',
      SizedBox(
        height: 220,
        child: SfCircularChart(
          legend: const Legend(isVisible: true, position: LegendPosition.bottom,
              textStyle: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            PieSeries<Map<String, dynamic>, String>(
              dataSource: data,
              xValueMapper: (d, _) => d['ch'] as String,
              yValueMapper: (d, _) => d['pct'],
              pointColorMapper: (_, i) => AppColors.chartPalette[i % AppColors.chartPalette.length],
              dataLabelSettings: const DataLabelSettings(isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget chart;
  const _ChartCard(this.title, this.subtitle, this.chart);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTypography.h5),
        Text(subtitle, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.lg),
        chart,
      ]),
    );
  }
}

class _KpiBox extends StatelessWidget {
  final String value;
  final String label;
  final String change;
  final bool positive;
  const _KpiBox(this.value, this.label, this.change, this.positive);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: AppTypography.h4),
          Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                size: 14, color: positive ? AppColors.success : AppColors.danger),
            const SizedBox(width: 3),
            Text(change, style: AppTypography.labelSm.copyWith(
                color: positive ? AppColors.success : AppColors.danger)),
          ]),
        ]),
      ),
    );
  }
}

class _PeriodPicker extends StatelessWidget {
  final List<String> periods;
  final String selected;
  final void Function(String) onChanged;
  const _PeriodPicker({required this.periods, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((p) {
          final isSelected = p == selected;
          return InkWell(
            onTap: () {
              if (p == 'Custom') {
                showDateRangeFilterDialog(context, onSelected: (range) {
                  onChanged(range);
                });
              } else {
                onChanged(p);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                p,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

