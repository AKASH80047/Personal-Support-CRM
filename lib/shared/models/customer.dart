import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? company;
  final String? avatarUrl;
  final List<String> tags;
  final String? notes;
  final double? csatAvg;
  final int totalTickets;
  final int openTickets;
  final DateTime? lastInteractionAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.company,
    this.avatarUrl,
    this.tags = const [],
    this.notes,
    this.csatAvg,
    this.totalTickets = 0,
    this.openTickets = 0,
    this.lastInteractionAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  Customer copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? company,
    String? avatarUrl,
    List<String>? tags,
    String? notes,
    double? csatAvg,
    int? totalTickets,
    int? openTickets,
    DateTime? lastInteractionAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      csatAvg: csatAvg ?? this.csatAvg,
      totalTickets: totalTickets ?? this.totalTickets,
      openTickets: openTickets ?? this.openTickets,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, updatedAt];
}
