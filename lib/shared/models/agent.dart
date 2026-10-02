import 'package:equatable/equatable.dart';

enum AgentStatus { online, busy, away, offline }

extension AgentStatusExt on AgentStatus {
  String get label {
    switch (this) {
      case AgentStatus.online: return 'Online';
      case AgentStatus.busy: return 'Busy';
      case AgentStatus.away: return 'Away';
      case AgentStatus.offline: return 'Offline';
    }
  }
}

class Agent extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final AgentStatus status;
  final String role; // super_admin | admin | manager | agent | viewer
  final List<String> teamIds;
  final List<String> teamNames;
  final int openTickets;
  final int resolvedTickets;
  final double? avgResponseMinutes;
  final double? csatScore;
  final double? slaCompliance;
  final double workloadPercent;
  final DateTime? lastSeenAt;
  final DateTime createdAt;

  const Agent({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.status = AgentStatus.offline,
    this.role = 'agent',
    this.teamIds = const [],
    this.teamNames = const [],
    this.openTickets = 0,
    this.resolvedTickets = 0,
    this.avgResponseMinutes,
    this.csatScore,
    this.slaCompliance,
    this.workloadPercent = 0,
    this.lastSeenAt,
    required this.createdAt,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [id, fullName, email, status];
}

class Team extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final List<Agent> members;
  final int openTickets;
  final int resolvedTickets;
  final double? slaCompliance;
  final DateTime createdAt;

  const Team({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.members = const [],
    this.openTickets = 0,
    this.resolvedTickets = 0,
    this.slaCompliance,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name];
}
