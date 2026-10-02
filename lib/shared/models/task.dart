enum TaskPriority {
  low('Low', 0xFF64748B),
  medium('Medium', 0xFFD97706),
  high('High', 0xFFEA580C),
  urgent('Urgent', 0xFFEF4444);

  final String label;
  final int colorValue;
  const TaskPriority(this.label, this.colorValue);
}

enum TaskStatus {
  todo('To Do'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const TaskStatus(this.label);
}

class SupportTask {
  final String id;
  final String title;
  final String? description;
  final String? customerId;
  final String? customerName;
  final String? ticketId;
  final String? ticketNumber;
  final String? assigneeId;
  final String? assigneeName;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? reminder;
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;

  const SupportTask({
    required this.id,
    required this.title,
    this.description,
    this.customerId,
    this.customerName,
    this.ticketId,
    this.ticketNumber,
    this.assigneeId,
    this.assigneeName,
    required this.priority,
    required this.status,
    this.dueDate,
    this.reminder,
    this.notes,
    required this.createdAt,
    this.completedAt,
    String? assignedAgentName,
  });

  bool get isOverdue =>
      status != TaskStatus.completed &&
      dueDate != null &&
      dueDate!.isBefore(DateTime.now());

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isToday => isDueToday;

  String? get assignedAgentName => assigneeName;

  SupportTask copyWith({
    String? id,
    String? title,
    String? description,
    String? customerId,
    String? customerName,
    String? ticketId,
    String? ticketNumber,
    String? assigneeId,
    String? assigneeName,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? reminder,
    String? notes,
    DateTime? createdAt,
    DateTime? completedAt,
    String? assignedAgentName,
  }) {
    return SupportTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      ticketId: ticketId ?? this.ticketId,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? assignedAgentName ?? this.assigneeName,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      reminder: reminder ?? this.reminder,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
