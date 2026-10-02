import 'package:equatable/equatable.dart';

enum ConversationChannel { chat, email, whatsapp, phone }
enum ConversationStatus { open, resolved, archived }

class ConversationMessage extends Equatable {
  final String id;
  final String conversationId;
  final String senderType; // agent | customer
  final String? senderId;
  final String? senderName;
  final String? senderAvatar;
  final String content;
  final bool isInternalNote;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime? readAt;

  const ConversationMessage({
    required this.id,
    required this.conversationId,
    required this.senderType,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.content,
    this.isInternalNote = false,
    this.attachments = const [],
    required this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;

  @override
  List<Object?> get props => [id, content, createdAt];
}

class Conversation extends Equatable {
  final String id;
  final String? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? customerAvatar;
  final String? assignedAgentId;
  final String? assignedAgentName;
  final ConversationChannel channel;
  final ConversationStatus status;
  final String? linkedTicketId;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final List<ConversationMessage> messages;
  final DateTime createdAt;

  const Conversation({
    required this.id,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerAvatar,
    this.assignedAgentId,
    this.assignedAgentName,
    required this.channel,
    this.status = ConversationStatus.open,
    this.linkedTicketId,
    this.unreadCount = 0,
    this.lastMessage,
    this.lastMessageAt,
    this.messages = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, status, lastMessageAt];
}
