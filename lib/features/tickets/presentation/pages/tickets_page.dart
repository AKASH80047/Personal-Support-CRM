import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/ticket.dart';
import '../../../../shared/services/mock_data.dart';
import '../../../../shared/widgets/app_modals.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});
  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final _search = TextEditingController();
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Open', 'Pending', 'Resolved', 'Closed', 'SLA Breached'];
  List<String> _selectedIds = [];
  String _searchQuery = '';
  String _dateRange = 'Sep 5, 2026 - Sep 11, 2026';
  String _sortBy = 'Sort by';
  bool _isKanbanView = false;
  int _currentPage = 1;
  final int _itemsPerPage = 8;

  // Local mutable copy of tickets so inline edits and actions take immediate effect
  late List<Ticket> _ticketList;

  @override
  void initState() {
    super.initState();
    _ticketList = List.from(MockData.tickets);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  int _getCountForTab(int index) {
    if (index == 0) return _ticketList.length;
    final tabName = _tabs[index];
    if (tabName == 'SLA Breached') {
      return _ticketList.where((t) => t.slaBreached).length;
    }
    return _ticketList.where((t) => t.status.label.toLowerCase() == tabName.toLowerCase()).length;
  }

  List<Ticket> get _filteredTickets {
    var list = _ticketList;

    // Tab Filter
    if (_selectedTabIndex > 0) {
      final tabLabel = _tabs[_selectedTabIndex];
      if (tabLabel == 'SLA Breached') {
        list = list.where((t) => t.slaBreached).toList();
      } else {
        list = list.where((t) => t.status.label.toLowerCase() == tabLabel.toLowerCase()).toList();
      }
    }

    // Search Query Filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) =>
          t.subject.toLowerCase().contains(q) ||
          t.ticketNumber.toLowerCase().contains(q) ||
          (t.customerName?.toLowerCase().contains(q) ?? false) ||
          (t.customerEmail?.toLowerCase().contains(q) ?? false) ||
          (t.category?.toLowerCase().contains(q) ?? false)).toList();
    }

    // Sorting
    if (_sortBy == 'Priority') {
      list.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    } else if (_sortBy == 'SLA') {
      list.sort((a, b) {
        if (a.slaDueAt == null) return 1;
        if (b.slaDueAt == null) return -1;
        return a.slaDueAt!.compareTo(b.slaDueAt!);
      });
    } else if (_sortBy == 'Recent') {
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    return list;
  }

  List<Ticket> get _pagedTickets {
    final all = _filteredTickets;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= all.length) return all;
    return all.skip(startIndex).take(_itemsPerPage).toList();
  }

  void _updateTicketStatus(String ticketId, TicketStatus newStatus) {
    setState(() {
      final idx = _ticketList.indexWhere((t) => t.id == ticketId);
      if (idx != -1) {
        _ticketList[idx] = _ticketList[idx].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated ticket status to ${newStatus.label}'),
        backgroundColor: const Color(0xFF2563EB),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filter Tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedTabIndex = 0;
                          _searchQuery = '';
                          _search.clear();
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('By Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TicketPriority.values.map((p) => ActionChip(
                    label: Text(p.label),
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _searchQuery = p.label;
                        _search.text = p.label;
                      });
                    },
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Text('By Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Account', 'Billing', 'Mobile App', 'Technical', 'Reports'].map((cat) => ActionChip(
                    label: Text(cat),
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _searchQuery = cat;
                        _search.text = cat;
                      });
                    },
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
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
            // ─ 1. TOP HEADER (Tickets + Export + New Ticket) ─
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tickets',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Manage and respond to support tickets efficiently.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Export Button
                OutlinedButton.icon(
                  onPressed: () => showExportDataDialog(
                    context,
                    title: 'Tickets',
                    countText: '${_filteredTickets.length} tickets',
                  ),
                  icon: const Icon(Icons.file_download_outlined, size: 17, color: Color(0xFF475569)),
                  label: const Text('Export', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                // New Ticket Button
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.createTicket),
                  icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  label: const Text('New Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
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

            // ─ 2. TABS ROW (All 64, Open 28, Pending 11, Resolved 20, Closed 3, SLA Breached 4) ─
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (idx) {
                  final label = _tabs[idx];
                  final count = _getCountForTab(idx);
                  final isSelected = _selectedTabIndex == idx;
                  final isBreached = label == 'SLA Breached';

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() {
                        _selectedTabIndex = idx;
                        _currentPage = 1;
                      }),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isBreached ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF))
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? (isBreached ? const Color(0xFFEF4444) : const Color(0xFF2563EB))
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? (isBreached ? const Color(0xFFDC2626) : const Color(0xFF2563EB))
                                    : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isBreached ? const Color(0xFFEF4444) : const Color(0xFF2563EB))
                                    : (isBreached ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : (isBreached ? const Color(0xFFDC2626) : const Color(0xFF64748B)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // ─ 3. TOOLBAR ROW (Search + Date Range + Filter + Sort by + Layout Toggle) ─
            Row(
              children: [
                // Search Input
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _search,
                            onChanged: (v) => setState(() {
                              _searchQuery = v;
                              _currentPage = 1;
                            }),
                            decoration: const InputDecoration(
                              hintText: 'Search tickets by ID, subject, customer, or agent...',
                              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w400),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              _search.clear();
                              setState(() {
                                _searchQuery = '';
                                _currentPage = 1;
                              });
                            },
                          ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Date Range Button
                InkWell(
                  onTap: () => showDateRangeFilterDialog(
                    context,
                    onSelected: (val) => setState(() => _dateRange = val),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(
                          _dateRange,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Filter Button
                OutlinedButton.icon(
                  onPressed: _showFilterModal,
                  icon: const Icon(Icons.filter_list_rounded, size: 17, color: Color(0xFF475569)),
                  label: const Text('Filter', style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 10),

                // Sort By Dropdown
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() => _sortBy = val),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'Sort by', child: Text('Default Order')),
                    const PopupMenuItem(value: 'Priority', child: Text('Highest Priority First')),
                    const PopupMenuItem(value: 'SLA', child: Text('SLA Nearest Breach')),
                    const PopupMenuItem(value: 'Recent', child: Text('Recently Updated')),
                  ],
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sort_rounded, size: 17, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          _sortBy,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Layout Toggles (Table / Kanban)
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.table_rows_rounded,
                          size: 19,
                          color: !_isKanbanView ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                        ),
                        tooltip: 'Table view',
                        onPressed: () => setState(() => _isKanbanView = false),
                      ),
                      Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                      IconButton(
                        icon: Icon(
                          Icons.grid_view_rounded,
                          size: 19,
                          color: _isKanbanView ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                        ),
                        tooltip: 'Kanban view',
                        onPressed: () => setState(() => _isKanbanView = true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bulk actions indicator if items selected
            if (_selectedIds.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Text('${_selectedIds.length} tickets selected', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2563EB), fontSize: 13)),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                      label: const Text('Mark as Resolved', style: TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        for (final id in _selectedIds) {
                          _updateTicketStatus(id, TicketStatus.resolved);
                        }
                        setState(() => _selectedIds = []);
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                      label: const Text('Delete Selected', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600)),
                      onPressed: () {
                        setState(() {
                          _ticketList.removeWhere((t) => _selectedIds.contains(t.id));
                          _selectedIds = [];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selected tickets removed.'), behavior: SnackBarBehavior.floating),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],

            // ─ 4. TICKETS TABLE OR KANBAN ─
            if (_filteredTickets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFCBD5E1)),
                    SizedBox(height: 12),
                    Text('No matching tickets found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    SizedBox(height: 4),
                    Text('Try adjusting your search keywords or clear tab filters.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              )
            else if (_isKanbanView)
              _buildKanbanView()
            else
              _buildTableView(context),

            const SizedBox(height: 16),

            // ─ 5. BOTTOM PAGINATION (Showing 1 to 8 of 64 tickets | < 1 2 3 4 5 ... 8 >) ─
            _buildPaginationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableView(BuildContext context) {
    final tickets = _pagedTickets;
    final allSelected = tickets.isNotEmpty && tickets.every((t) => _selectedIds.contains(t.id));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1050),
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
                          _selectedIds = tickets.map((t) => t.id).toList();
                        } else {
                          _selectedIds.clear();
                        }
                      });
                    },
                    activeColor: const Color(0xFF2563EB),
                  ),
                ),
                const DataColumn(label: Text('ID', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Subject', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Customer', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Priority', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Status', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Agent', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('SLA', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Updated', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
                const DataColumn(label: Text('Actions', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12))),
              ],
              rows: tickets.map((ticket) {
                final isSelected = _selectedIds.contains(ticket.id);
                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedIds.add(ticket.id);
                      } else {
                        _selectedIds.remove(ticket.id);
                      }
                    });
                  },
                  cells: [
                    // Checkbox cell
                    DataCell(
                      Checkbox(
                        value: isSelected,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selectedIds.add(ticket.id);
                            } else {
                              _selectedIds.remove(ticket.id);
                            }
                          });
                        },
                        activeColor: const Color(0xFF2563EB),
                      ),
                    ),
                    // Ticket ID
                    DataCell(
                      InkWell(
                        onTap: () => context.go('${AppRoutes.tickets}/${ticket.id}'),
                        child: Text(
                          ticket.ticketNumber,
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    // Subject + Category
                    DataCell(
                      InkWell(
                        onTap: () => context.go('${AppRoutes.tickets}/${ticket.id}'),
                        child: SizedBox(
                          width: 220,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.subject,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ticket.category ?? 'General',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Customer
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF94A3B8).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (ticket.customerName != null && ticket.customerName!.isNotEmpty)
                                    ? ticket.customerName![0].toUpperCase()
                                    : 'C',
                                style: const TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 130,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ticket.customerName ?? 'Guest', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(ticket.customerEmail ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Priority Badge
                    DataCell(_buildPriorityPill(ticket.priority)),
                    // Status Dropdown / Badge
                    DataCell(
                      PopupMenuButton<TicketStatus>(
                        onSelected: (st) => _updateTicketStatus(ticket.id, st),
                        itemBuilder: (ctx) => TicketStatus.values.map((s) => PopupMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: _getStatusColor(s), shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text(s.label),
                            ],
                          ),
                        )).toList(),
                        child: _buildStatusPill(ticket.status),
                      ),
                    ),
                    // Agent
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.person, size: 14, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ticket.assignedAgentName ?? 'Unassigned',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                          ),
                        ],
                      ),
                    ),
                    // SLA
                    DataCell(_buildSlaPill(ticket)),
                    // Updated
                    DataCell(
                      Text(
                        _timeAgo(ticket.updatedAt),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                    // Actions Menu
                    DataCell(
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF64748B)),
                        onSelected: (action) {
                          if (action == 'view') {
                            context.go('${AppRoutes.tickets}/${ticket.id}');
                          } else if (action == 'resolve') {
                            _updateTicketStatus(ticket.id, TicketStatus.resolved);
                          } else if (action == 'delete') {
                            setState(() => _ticketList.removeWhere((t) => t.id == ticket.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ticket deleted.'), behavior: SnackBarBehavior.floating),
                            );
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'view', child: Text('View Details')),
                          const PopupMenuItem(value: 'resolve', child: Text('Mark as Resolved')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete Ticket', style: TextStyle(color: Colors.red))),
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

  Widget _buildPriorityPill(TicketPriority p) {
    Color bg;
    Color fg;
    String icon;

    switch (p) {
      case TicketPriority.critical:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        icon = '⇡ ';
        break;
      case TicketPriority.high:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFEA580C);
        icon = '↑ ';
        break;
      case TicketPriority.medium:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        icon = '';
        break;
      case TicketPriority.low:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        icon = '';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        '$icon${p.label}',
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }

  Color _getStatusColor(TicketStatus s) {
    switch (s) {
      case TicketStatus.open: return const Color(0xFF2563EB);
      case TicketStatus.pending: return const Color(0xFFD97706);
      case TicketStatus.resolved: return const Color(0xFF16A34A);
      case TicketStatus.closed: return const Color(0xFF64748B);
      case TicketStatus.slaBreached: return const Color(0xFFDC2626);
      default: return const Color(0xFF64748B);
    }
  }

  Widget _buildStatusPill(TicketStatus s) {
    Color bg;
    Color fg;

    switch (s) {
      case TicketStatus.open:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        break;
      case TicketStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case TicketStatus.resolved:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        break;
      case TicketStatus.closed:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        break;
      case TicketStatus.slaBreached:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 11)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 13, color: fg),
        ],
      ),
    );
  }

  Widget _buildSlaPill(Ticket ticket) {
    if (ticket.slaBreached) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFDC2626)),
            SizedBox(width: 4),
            Text('Breached', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700, fontSize: 11)),
          ],
        ),
      );
    }
    if (ticket.slaDueAt == null) {
      return const Text('—', style: TextStyle(color: Color(0xFF94A3B8)));
    }
    final diff = ticket.slaDueAt!.difference(DateTime.now());
    final isUrgent = diff.inMinutes < 45;
    final text = diff.inHours >= 1 ? '${diff.inHours}h ${diff.inMinutes.remainder(60)}m' : '${diff.inMinutes}m';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 13, color: isUrgent ? const Color(0xFFD97706) : const Color(0xFF16A34A)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isUrgent ? const Color(0xFFD97706) : const Color(0xFF16A34A),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildKanbanView() {
    final statuses = [TicketStatus.open, TicketStatus.pending, TicketStatus.resolved];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statuses.map((st) {
        final groupTickets = _filteredTickets.where((t) => t.status == st).toList();
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(st.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Text('${groupTickets.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...groupTickets.map((ticket) => InkWell(
                  onTap: () => context.go('${AppRoutes.tickets}/${ticket.id}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(ticket.ticketNumber, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                            _buildPriorityPill(ticket.priority),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(ticket.subject, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(ticket.customerName ?? 'Guest', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            const Spacer(),
                            _buildSlaPill(ticket),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaginationBar() {
    final total = _filteredTickets.length;
    final totalPages = (total / _itemsPerPage).ceil().clamp(1, 99);
    final start = total == 0 ? 0 : (_currentPage - 1) * _itemsPerPage + 1;
    final end = (_currentPage * _itemsPerPage).clamp(0, total);

    return Row(
      children: [
        Text(
          'Showing $start to $end of $total tickets',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const Spacer(),
        // Prev Page
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 20),
          onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
          color: const Color(0xFF64748B),
        ),
        ...List.generate(totalPages.clamp(1, 5), (i) {
          final pageNum = i + 1;
          final isCurr = pageNum == _currentPage;
          return InkWell(
            onTap: () => setState(() => _currentPage = pageNum),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isCurr ? const Color(0xFF2563EB) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$pageNum',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurr ? FontWeight.w700 : FontWeight.w500,
                  color: isCurr ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          );
        }),
        // Next Page
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, size: 20),
          onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
          color: const Color(0xFF64748B),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
