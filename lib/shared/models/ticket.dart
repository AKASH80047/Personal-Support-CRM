import 'package:equatable/equatable.dart';

enum TicketStatus { open, pending, onHold, resolved, closed, slaBreached }
enum TicketPriority { critical, high, medium, low }
enum TicketChannel { web, email, chat, whatsapp, phone, api }

extension TicketStatusExt on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.open: return 'Open';
      case TicketStatus.pending: return 'Pending';
      case TicketStatus.onHold: return 'On Hold';
      case TicketStatus.resolved: return 'Resolved';
      case TicketStatus.closed: return 'Closed';
      case TicketStatus.slaBreached: return 'SLA Breached';
    }
  }

  String get value {
    switch (this) {
      case TicketStatus.open: return 'open';
      case TicketStatus.pending: return 'pending';
      case TicketStatus.onHold: return 'on_hold';
      case TicketStatus.resolved: return 'resolved';
      case TicketStatus.closed: return 'closed';
      case TicketStatus.slaBreached: return 'sla_breached';
    }
  }
}

extension TicketPriorityExt on TicketPriority {
  String get label {
    switch (this) {
      case TicketPriority.critical: return 'Critical';
      case TicketPriority.high: return 'High';
      case TicketPriority.medium: return 'Medium';
      case TicketPriority.low: return 'Low';
    }
  }
}

extension TicketChannelExt on TicketChannel {
  String get label {
    switch (this) {
      case TicketChannel.web: return 'Web';
      case TicketChannel.email: return 'Email';
      case TicketChannel.chat: return 'Live Chat';
      case TicketChannel.whatsapp: return 'WhatsApp';
      case TicketChannel.phone: return 'Phone';
      case TicketChannel.api: return 'API';
    }
  }
}

class TicketMessage extends Equatable {
  final String id;
  final String ticketId;
  final String senderType; // agent | customer | system
  final String? senderId;
  final String? senderName;
  final String? senderAvatar;
  final String content;
  final bool isInternalNote;
  final bool aiGenerated;
  final String? aiTone;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime? readAt;

  const TicketMessage({
    required this.id,
    required this.ticketId,
    required this.senderType,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.content,
    this.isInternalNote = false,
    this.aiGenerated = false,
    this.aiTone,
    this.attachments = const [],
    required this.createdAt,
    this.readAt,
  });

  @override
  List<Object?> get props => [id, ticketId, content, createdAt];
}

class TicketActivity extends Equatable {
  final String id;
  final String ticketId;
  final String? actorId;
  final String? actorName;
  final String action;
  final String? oldValue;
  final String? newValue;
  final DateTime createdAt;

  const TicketActivity({
    required this.id,
    required this.ticketId,
    this.actorId,
    this.actorName,
    required this.action,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, action, createdAt];
}

class Ticket extends Equatable {
  final String id;
  final String ticketNumber;
  final String subject;
  final String? description;
  final TicketStatus status;
  final TicketPriority priority;
  final String? category;
  final TicketChannel channel;
  final String? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? customerAvatar;
  final String? assignedAgentId;
  final String? assignedAgentName;
  final String? assignedAgentAvatar;
  final String? assignedTeamId;
  final String? assignedTeamName;
  final DateTime? slaDueAt;
  final bool slaBreached;
  final DateTime? firstResponseAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final List<String> tags;
  final List<TicketMessage> messages;
  final List<TicketActivity> activities;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ticket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    this.description,
    required this.status,
    required this.priority,
    this.category,
    this.channel = TicketChannel.web,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerAvatar,
    this.assignedAgentId,
    this.assignedAgentName,
    this.assignedAgentAvatar,
    this.assignedTeamId,
    this.assignedTeamName,
    this.slaDueAt,
    this.slaBreached = false,
    this.firstResponseAt,
    this.resolvedAt,
    this.closedAt,
    this.tags = const [],
    this.messages = const [],
    this.activities = const [],
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Ticket copyWith({
    String? subject,
    String? description,
    TicketStatus? status,
    TicketPriority? priority,
    String? category,
    String? assignedAgentId,
    String? assignedAgentName,
    String? assignedTeamId,
    String? assignedTeamName,
    List<String>? tags,
    List<TicketMessage>? messages,
    List<TicketActivity>? activities,
    DateTime? updatedAt,
    bool? slaBreached,
    DateTime? slaDueAt,
    DateTime? resolvedAt,
    DateTime? closedAt,
  }) {
    return Ticket(
      id: id,
      ticketNumber: ticketNumber,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      channel: channel,
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerAvatar: customerAvatar,
      assignedAgentId: assignedAgentId ?? this.assignedAgentId,
      assignedAgentName: assignedAgentName ?? this.assignedAgentName,
      assignedAgentAvatar: assignedAgentAvatar,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      assignedTeamName: assignedTeamName ?? this.assignedTeamName,
      slaDueAt: slaDueAt ?? this.slaDueAt,
      slaBreached: slaBreached ?? this.slaBreached,
      firstResponseAt: firstResponseAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      tags: tags ?? this.tags,
      messages: messages ?? this.messages,
      activities: activities ?? this.activities,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, ticketNumber, status, priority, updatedAt];
}
