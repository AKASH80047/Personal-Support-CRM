import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/customer.dart';
import '../../../../shared/services/mock_data.dart';
import '../../../../shared/widgets/app_modals.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});
  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final _search = TextEditingController();
  String _query = '';
  String _selectedCompany = 'All Companies';
  String _statusFilter = 'All';
  bool _isGridView = false;
  List<String> _selectedCustomerIds = [];
  late List<Customer> _customerList;

  @override
  void initState() {
    super.initState();
    _customerList = List.from(MockData.customers);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Customer> get _filtered {
    var list = _customerList;

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((c) =>
          c.fullName.toLowerCase().contains(q) ||
          (c.email?.toLowerCase().contains(q) ?? false) ||
          (c.company?.toLowerCase().contains(q) ?? false)).toList();
    }

    if (_selectedCompany != 'All Companies') {
      list = list.where((c) => c.company == _selectedCompany).toList();
    }

    if (_statusFilter != 'All') {
      list = list.where((c) {
        if (_statusFilter == 'Active') return c.openTickets > 0;
        if (_statusFilter == 'At Risk') return (c.csatAvg ?? 5.0) < 4.0;
        if (_statusFilter == 'Inactive') return c.openTickets == 0;
        return true;
      }).toList();
    }

    return list;
  }

  void _showAddCustomerModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add_rounded, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Add New Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline_rounded, size: 18)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email Address *', prefixIcon: Icon(Icons.mail_outline_rounded, size: 18)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: companyCtrl,
                decoration: const InputDecoration(labelText: 'Company / Organization', prefixIcon: Icon(Icons.business_rounded, size: 18)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined, size: 18)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              final initials = nameCtrl.text.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();
              setState(() {
                _customerList.insert(
                  0,
                  Customer(
                    id: 'cust-${DateTime.now().millisecondsSinceEpoch}',
                    fullName: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                    company: companyCtrl.text.trim().isEmpty ? 'Direct Client' : companyCtrl.text.trim(),
                    phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                    totalTickets: 0,
                    openTickets: 0,
                    csatAvg: 5.0,
                    lastInteractionAt: DateTime.now(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Customer created successfully.'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Customer'),
          ),
        ],
      ),
    );
  }

  void _showCustomer360Modal(Customer c) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                      child: Center(
                        child: Text(c.initials, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                          Text('${c.company ?? "Direct Client"} · ${c.email ?? "No email"}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatMini('Total Tickets', '${c.totalTickets}'),
                    _buildStatMini('Open Queue', '${c.openTickets}'),
                    _buildStatMini('CSAT Score', '${c.csatAvg?.toStringAsFixed(1) ?? "4.5"} ★'),
                    _buildStatMini('Status', c.openTickets > 0 ? 'Active' : 'Inactive'),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Contact & Quick Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.email_outlined, size: 16),
                        label: const Text('Send Email'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Email composer opened for ${c.email ?? c.fullName}'), behavior: SnackBarBehavior.floating),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('New Ticket'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.go(AppRoutes.createTicket);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatMini(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ 1. Header (Customers + Import + Add Customer) ─
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customers',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                      ),
                      SizedBox(height: 4),
                      Text('Manage your customers and build better relationships.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => showExportDataDialog(context, title: 'Customers', countText: '${_filtered.length} contacts'),
                  icon: const Icon(Icons.file_download_outlined, size: 16, color: Color(0xFF475569)),
                  label: const Text('Import', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _showAddCustomerModal,
                  icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  label: const Text('Add Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─ 2. 4 Stat KPI Cards (Exact match to Image 2) ─
            Row(
              children: [
                _buildKpiCard(
                  icon: Icons.people_alt_rounded,
                  iconColor: const Color(0xFF2563EB),
                  value: '6',
                  title: 'Total Customers',
                  trend: '+20% this month.',
                  trendUp: true,
                  onTap: () => setState(() => _statusFilter = 'All'),
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  icon: Icons.business_rounded,
                  iconColor: const Color(0xFF10B981),
                  value: '4',
                  title: 'Companies',
                  trend: '+33% this month.',
                  trendUp: true,
                  onTap: () => setState(() => _selectedCompany = 'All Companies'),
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  value: '2',
                  title: 'Active Customers',
                  trend: '+0% this month.',
                  trendUp: true,
                  onTap: () => setState(() => _statusFilter = 'Active'),
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  value: '4.3',
                  title: 'Average CSAT',
                  trend: '+12% this month.',
                  trendUp: true,
                  onTap: () => context.go(AppRoutes.analytics),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─ 3. Toolbar (Search, Company Dropdown, More Filters, Table/Grid Toggle) ─
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search_rounded, size: 19, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _search,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: const InputDecoration(
                              hintText: 'Search by name, email, company...',
                              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // All Companies Dropdown
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() => _selectedCompany = val),
                  itemBuilder: (ctx) => [
                    'All Companies',
                    'Acme Corp',
                    'Tech Ventures',
                    'Startup.in',
                    'Globex Ltd',
                    'Initech Inc',
                    'FinFlow App',
                  ].map((comp) => PopupMenuItem(value: comp, child: Text(comp))).toList(),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.business_outlined, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(_selectedCompany, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // More Filters Button
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() => _statusFilter = val),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'All', child: Text('All Statuses')),
                    const PopupMenuItem(value: 'Active', child: Text('Active (Has Open Tickets)')),
                    const PopupMenuItem(value: 'At Risk', child: Text('At Risk (CSAT < 4.0)')),
                    const PopupMenuItem(value: 'Inactive', child: Text('Inactive (0 Open Tickets)')),
                  ],
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.filter_list_rounded, size: 16, color: Color(0xFF475569)),
                        SizedBox(width: 8),
                        Text('More Filters', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // View Toggle (Table / Grid)
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.format_list_bulleted_rounded, size: 18, color: !_isGridView ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                        onPressed: () => setState(() => _isGridView = false),
                      ),
                      Container(width: 1, height: 20, color: const Color(0xFFE2E8F0)),
                      IconButton(
                        icon: Icon(Icons.grid_view_rounded, size: 18, color: _isGridView ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                        onPressed: () => setState(() => _isGridView = true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─ 4. Customers Table (Exact layout of Image 2) ─
            _buildCustomerTable(context),

            const SizedBox(height: 16),

            // ─ 5. Pagination (Showing 1 to 6 of 6 customers | < [1] >) ─
            Row(
              children: [
                Text('Showing 1 to ${_filtered.length} of ${_filtered.length} customers', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const Spacer(),
                IconButton(icon: const Icon(Icons.chevron_left_rounded, size: 20), onPressed: null, color: const Color(0xFF94A3B8)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6)),
                  child: const Text('1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                IconButton(icon: const Icon(Icons.chevron_right_rounded, size: 20), onPressed: null, color: const Color(0xFF94A3B8)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String title,
    required String trend,
    required bool trendUp,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        const SizedBox(width: 6),
                        Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(trendUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: const Color(0xFF16A34A)),
                        const SizedBox(width: 2),
                        Text(trend, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerTable(BuildContext context) {
    final customers = _filtered;
    final allSelected = customers.isNotEmpty && customers.every((c) => _selectedCustomerIds.contains(c.id));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1000),
            child: DataTable(
              showCheckboxColumn: false,
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
              headingRowHeight: 44,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 64,
              horizontalMargin: 16,
              columnSpacing: 20,
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: allSelected,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedCustomerIds = customers.map((c) => c.id).toList();
                        } else {
                          _selectedCustomerIds.clear();
                        }
                      });
                    },
                    activeColor: const Color(0xFF2563EB),
                  ),
                ),
                const DataColumn(label: Text('Customer', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Email', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Company', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Tickets', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Open', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('CSAT', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Last Seen', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Status', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Actions', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
              ],
              rows: customers.map((c) {
                final isSelected = _selectedCustomerIds.contains(c.id);
                final status = c.openTickets > 3 ? 'At Risk' : (c.openTickets > 0 ? 'Active' : 'Inactive');

                return DataRow(
                  selected: isSelected,
                  cells: [
                    DataCell(
                      Checkbox(
                        value: isSelected,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selectedCustomerIds.add(c.id);
                            } else {
                              _selectedCustomerIds.remove(c.id);
                            }
                          });
                        },
                        activeColor: const Color(0xFF2563EB),
                      ),
                    ),
                    // Customer (Avatar + Name + Company)
                    DataCell(
                      InkWell(
                        onTap: () => _showCustomer360Modal(c),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getAvatarColor(c.fullName),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(c.initials, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                Text(c.company ?? 'Direct', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Email
                    DataCell(
                      Text(c.email ?? '—', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ),
                    // Company with letter badge
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                (c.company?.isNotEmpty ?? false) ? c.company![0] : 'C',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(c.company ?? '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                        ],
                      ),
                    ),
                    // Tickets count
                    DataCell(Text('${c.totalTickets}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                    // Open count
                    DataCell(Text('${c.openTickets}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)))),
                    // CSAT
                    DataCell(
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          Text(c.csatAvg != null ? c.csatAvg!.toStringAsFixed(1) : '4.5', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    // Last Seen
                    DataCell(
                      Text(
                        c.lastInteractionAt != null ? _timeAgo(c.lastInteractionAt!) : 'Today',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                    // Status Badge
                    DataCell(_buildStatusBadge(status)),
                    // Actions
                    DataCell(
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF64748B)),
                        onSelected: (act) {
                          if (act == 'view') {
                            _showCustomer360Modal(c);
                          } else if (act == 'delete') {
                            setState(() => _customerList.removeWhere((item) => item.id == c.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Customer removed.'), behavior: SnackBarBehavior.floating),
                            );
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'view', child: Text('View 360 Profile')),
                          const PopupMenuItem(value: 'email', child: Text('Send Direct Email')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete Customer', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFF7C3AED),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFDB2777),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Active':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        break;
      case 'At Risk':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text('• $status', style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
