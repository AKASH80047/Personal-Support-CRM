import '../models/ticket.dart';
import '../models/customer.dart';
import '../models/agent.dart';
import '../models/conversation.dart';
import '../models/knowledge_article.dart';
import '../models/notification.dart';
import '../models/task.dart';

/// SupportCRM — Mock Data Service
/// Provides realistic dummy data for all features.
class MockData {
  MockData._();

  // ─── Tasks & Follow-ups ───────────────────────────────────────────────
  static final List<SupportTask> tasks = [
    SupportTask(
      id: 'task-1',
      title: 'Call John Smith regarding payment gateway webhook failure',
      description: 'Follow up on TK-10452 resolution and verify if Stripe webhooks are processing successfully.',
      customerId: 'cust-1',
      customerName: 'John Smith',
      ticketId: 'ticket-1',
      ticketNumber: 'TK-10452',
      assigneeId: 'agent-1',
      assigneeName: 'Rahul Sharma',
      priority: TaskPriority.urgent,
      status: TaskStatus.todo,
      dueDate: DateTime.now().add(const Duration(hours: 2)),
      reminder: DateTime.now().add(const Duration(hours: 1)),
      notes: 'Customer requested direct callback after 3 PM IST.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    SupportTask(
      id: 'task-2',
      title: 'Review custom SSL certificate configuration for Enterprise client',
      description: 'Audit Cloudflare reverse proxy headers for Acme SaaS custom subdomain setup.',
      customerId: 'cust-2',
      customerName: 'Sarah Connor',
      ticketId: 'ticket-2',
      ticketNumber: 'TK-10449',
      assigneeId: 'agent-3',
      assigneeName: 'Aman Verma',
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(hours: 5)),
      reminder: DateTime.now().add(const Duration(hours: 3)),
      notes: 'Check SAN certificates on origin load balancer.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    SupportTask(
      id: 'task-3',
      title: 'Send refund receipt and revised invoice PDF',
      description: 'Processed 50% pro-rated refund for accidental plan upgrade. Need to dispatch updated invoice.',
      customerId: 'cust-3',
      customerName: 'Michael Chang',
      ticketId: 'ticket-3',
      ticketNumber: 'TK-10446',
      assigneeId: 'agent-2',
      assigneeName: 'Priya Patel',
      priority: TaskPriority.medium,
      status: TaskStatus.completed,
      dueDate: DateTime.now().subtract(const Duration(hours: 1)),
      completedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      notes: 'Refund transaction ID: ref_98481726354.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SupportTask(
      id: 'task-4',
      title: 'Investigate iOS 18 Push Notification APNs delivery failure',
      description: 'Replicate mobile app background badge refresh crash reported on TestFlight build #448.',
      customerId: 'cust-4',
      customerName: 'Emily Watson',
      ticketId: 'ticket-4',
      ticketNumber: 'TK-10440',
      assigneeId: 'agent-1',
      assigneeName: 'Rahul Sharma',
      priority: TaskPriority.urgent,
      status: TaskStatus.todo,
      dueDate: DateTime.now().subtract(const Duration(hours: 4)), // Overdue
      reminder: DateTime.now().subtract(const Duration(hours: 5)),
      notes: 'Needs iOS sandbox token verification.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SupportTask(
      id: 'task-5',
      title: 'Quarterly Executive Business Review check-in',
      description: 'Schedule CSAT alignment video call with VP of Operations at Global Logistics Ltd.',
      customerId: 'cust-5',
      customerName: 'David Miller',
      assigneeId: 'agent-4',
      assigneeName: 'Sara Khan',
      priority: TaskPriority.high,
      status: TaskStatus.todo,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      reminder: DateTime.now().add(const Duration(days: 1)),
      notes: 'Prepare analytics slide deck before call.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SupportTask(
      id: 'task-6',
      title: 'Update SAML 2.0 Okta SSO integration tutorial',
      description: 'Add step-by-step screenshots for Azure AD & Okta SCIM directory synchronization.',
      assigneeId: 'agent-3',
      assigneeName: 'Aman Verma',
      priority: TaskPriority.low,
      status: TaskStatus.todo,
      dueDate: DateTime.now().add(const Duration(days: 4)),
      notes: 'Link to new Knowledge Base section.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // ─── Agents ──────────────────────────────────────────────────────────
  static final List<Agent> agents = [
    Agent(
      id: 'agent-1',
      fullName: 'Rahul Sharma',
      email: 'rahul@supportcrm.app',
      status: AgentStatus.online,
      role: 'agent',
      teamIds: ['team-1'],
      teamNames: ['Technical Support'],
      openTickets: 14,
      resolvedTickets: 128,
      avgResponseMinutes: 18.5,
      csatScore: 4.7,
      slaCompliance: 91.2,
      workloadPercent: 82,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
    Agent(
      id: 'agent-2',
      fullName: 'Priya Patel',
      email: 'priya@supportcrm.app',
      status: AgentStatus.online,
      role: 'agent',
      teamIds: ['team-2'],
      teamNames: ['Billing Support'],
      openTickets: 8,
      resolvedTickets: 97,
      avgResponseMinutes: 24.3,
      csatScore: 4.9,
      slaCompliance: 96.8,
      workloadPercent: 51,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
    Agent(
      id: 'agent-3',
      fullName: 'Aman Verma',
      email: 'aman@supportcrm.app',
      status: AgentStatus.busy,
      role: 'agent',
      teamIds: ['team-1', 'team-3'],
      teamNames: ['Technical Support', 'Customer Success'],
      openTickets: 19,
      resolvedTickets: 154,
      avgResponseMinutes: 12.1,
      csatScore: 4.5,
      slaCompliance: 87.4,
      workloadPercent: 91,
      createdAt: DateTime.now().subtract(const Duration(days: 220)),
    ),
    Agent(
      id: 'agent-4',
      fullName: 'Sara Khan',
      email: 'sara@supportcrm.app',
      status: AgentStatus.away,
      role: 'manager',
      teamIds: ['team-2', 'team-4'],
      teamNames: ['Billing Support', 'General Support'],
      openTickets: 5,
      resolvedTickets: 203,
      avgResponseMinutes: 32.0,
      csatScore: 4.8,
      slaCompliance: 94.1,
      workloadPercent: 35,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Agent(
      id: 'agent-5',
      fullName: 'Vikram Singh',
      email: 'vikram@supportcrm.app',
      status: AgentStatus.offline,
      role: 'agent',
      teamIds: ['team-3'],
      teamNames: ['Customer Success'],
      openTickets: 3,
      resolvedTickets: 56,
      avgResponseMinutes: 41.5,
      csatScore: 4.3,
      slaCompliance: 82.0,
      workloadPercent: 22,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  // ─── Teams ───────────────────────────────────────────────────────────
  static final List<Team> teams = [
    Team(
      id: 'team-1',
      name: 'Technical Support',
      description: 'Handles all technical issues and bugs',
      color: '#3B5BDB',
      members: [agents[0], agents[2]],
      openTickets: 33,
      resolvedTickets: 282,
      slaCompliance: 89.3,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Team(
      id: 'team-2',
      name: 'Billing Support',
      description: 'Handles payment, refund, and subscription queries',
      color: '#16A34A',
      members: [agents[1], agents[3]],
      openTickets: 13,
      resolvedTickets: 300,
      slaCompliance: 95.6,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Team(
      id: 'team-3',
      name: 'Customer Success',
      description: 'Proactive customer engagement and retention',
      color: '#7C3AED',
      members: [agents[2], agents[4]],
      openTickets: 22,
      resolvedTickets: 210,
      slaCompliance: 85.0,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    Team(
      id: 'team-4',
      name: 'General Support',
      description: 'First-line support for all incoming queries',
      color: '#D97706',
      members: [agents[3]],
      openTickets: 8,
      resolvedTickets: 180,
      slaCompliance: 93.2,
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
    ),
  ];

  // ─── Customers ───────────────────────────────────────────────────────
  static final List<Customer> customers = [
    Customer(
      id: 'cust-1',
      fullName: 'John Smith',
      email: 'john.smith@acmecorp.com',
      phone: '+1 (555) 234-5678',
      company: 'Acme Corp',
      tags: ['VIP', 'Enterprise'],
      csatAvg: 4.2,
      totalTickets: 14,
      openTickets: 2,
      lastInteractionAt: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 240)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Customer(
      id: 'cust-2',
      fullName: 'Sarah Williams',
      email: 'sarah.w@techventures.io',
      phone: '+1 (555) 345-6789',
      company: 'Tech Ventures',
      tags: ['Pro'],
      csatAvg: 4.8,
      totalTickets: 7,
      openTickets: 1,
      lastInteractionAt: DateTime.now().subtract(const Duration(hours: 8)),
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Customer(
      id: 'cust-3',
      fullName: 'Rahul Sharma',
      email: 'rahul.sharma@startup.in',
      phone: '+91 98765 43210',
      company: 'Startup.in',
      tags: ['Starter'],
      csatAvg: 3.9,
      totalTickets: 22,
      openTickets: 4,
      lastInteractionAt: DateTime.now().subtract(const Duration(minutes: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Customer(
      id: 'cust-4',
      fullName: 'Emma Johnson',
      email: 'emma.j@globex.com',
      phone: '+44 20 7946 0958',
      company: 'Globex Ltd',
      tags: ['Enterprise', 'VIP'],
      csatAvg: 4.6,
      totalTickets: 9,
      openTickets: 0,
      lastInteractionAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Customer(
      id: 'cust-5',
      fullName: 'Michael Brown',
      email: 'm.brown@initech.com',
      phone: '+1 (555) 456-7890',
      company: 'Initech Inc',
      tags: ['Pro'],
      csatAvg: 4.1,
      totalTickets: 5,
      openTickets: 1,
      lastInteractionAt: DateTime.now().subtract(const Duration(hours: 24)),
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 24)),
    ),
    Customer(
      id: 'cust-6',
      fullName: 'Ananya Iyer',
      email: 'ananya@finflow.app',
      phone: '+91 99001 23456',
      company: 'FinFlow App',
      tags: ['Starter'],
      csatAvg: 4.4,
      totalTickets: 3,
      openTickets: 1,
      lastInteractionAt: DateTime.now().subtract(const Duration(hours: 6)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  // ─── Tickets ─────────────────────────────────────────────────────────
  static List<Ticket> get tickets => [
    Ticket(
      id: 'tk-1',
      ticketNumber: 'TK-10452',
      subject: 'Unable to login to the dashboard',
      description:
          'I have been trying to log in since yesterday but keep getting "Invalid credentials" error even though my password is correct. I tried resetting the password but still facing the same issue.',
      status: TicketStatus.open,
      priority: TicketPriority.high,
      category: 'Account',
      channel: TicketChannel.web,
      customerId: 'cust-1',
      customerName: 'John Smith',
      customerEmail: 'john.smith@acmecorp.com',
      assignedAgentId: 'agent-1',
      assignedAgentName: 'Rahul Sharma',
      assignedTeamId: 'team-1',
      assignedTeamName: 'Technical Support',
      slaDueAt: DateTime.now().add(const Duration(minutes: 32)),
      tags: ['login', 'authentication'],
      messages: _ticketMessages('tk-1', 'John Smith', 'Rahul Sharma'),
      activities: _ticketActivities('tk-1', 'Rahul Sharma'),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    Ticket(
      id: 'tk-2',
      ticketNumber: 'TK-10451',
      subject: 'Payment failed - charged twice',
      description:
          'My card was charged twice for the monthly subscription. I need a refund for the duplicate charge immediately.',
      status: TicketStatus.pending,
      priority: TicketPriority.critical,
      category: 'Billing',
      channel: TicketChannel.email,
      customerId: 'cust-2',
      customerName: 'Sarah Williams',
      customerEmail: 'sarah.w@techventures.io',
      assignedAgentId: 'agent-2',
      assignedAgentName: 'Priya Patel',
      assignedTeamId: 'team-2',
      assignedTeamName: 'Billing Support',
      slaDueAt: DateTime.now().subtract(const Duration(minutes: 15)),
      slaBreached: true,
      tags: ['billing', 'refund', 'urgent'],
      messages: _ticketMessages('tk-2', 'Sarah Williams', 'Priya Patel'),
      activities: _ticketActivities('tk-2', 'Priya Patel'),
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Ticket(
      id: 'tk-3',
      ticketNumber: 'TK-10450',
      subject: 'Account verification email not received',
      description:
          'I registered 2 days ago but never received the verification email. I checked spam folder as well.',
      status: TicketStatus.open,
      priority: TicketPriority.medium,
      category: 'Account',
      channel: TicketChannel.chat,
      customerId: 'cust-3',
      customerName: 'Rahul Sharma',
      customerEmail: 'rahul.sharma@startup.in',
      assignedAgentId: 'agent-3',
      assignedAgentName: 'Aman Verma',
      assignedTeamId: 'team-1',
      assignedTeamName: 'Technical Support',
      slaDueAt: DateTime.now().add(const Duration(hours: 2)),
      tags: ['email', 'verification'],
      messages: [],
      activities: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Ticket(
      id: 'tk-4',
      ticketNumber: 'TK-10449',
      subject: 'Mobile app crashing on startup',
      description:
          'The iOS app crashes immediately after the splash screen. I am on iPhone 14 Pro running iOS 17.4.',
      status: TicketStatus.open,
      priority: TicketPriority.high,
      category: 'Mobile App',
      channel: TicketChannel.phone,
      customerId: 'cust-4',
      customerName: 'Emma Johnson',
      customerEmail: 'emma.j@globex.com',
      assignedAgentId: 'agent-1',
      assignedAgentName: 'Rahul Sharma',
      assignedTeamId: 'team-1',
      assignedTeamName: 'Technical Support',
      slaDueAt: DateTime.now().add(const Duration(hours: 1, minutes: 15)),
      tags: ['mobile', 'crash', 'ios'],
      messages: [],
      activities: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Ticket(
      id: 'tk-5',
      ticketNumber: 'TK-10448',
      subject: 'Subscription plan change request',
      description:
          'I want to upgrade from Starter to Pro plan. Please guide me through the process.',
      status: TicketStatus.resolved,
      priority: TicketPriority.low,
      category: 'Billing',
      channel: TicketChannel.email,
      customerId: 'cust-5',
      customerName: 'Michael Brown',
      customerEmail: 'm.brown@initech.com',
      assignedAgentId: 'agent-2',
      assignedAgentName: 'Priya Patel',
      assignedTeamId: 'team-2',
      assignedTeamName: 'Billing Support',
      tags: ['subscription', 'upgrade'],
      resolvedAt: DateTime.now().subtract(const Duration(hours: 4)),
      messages: [],
      activities: [],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Ticket(
      id: 'tk-6',
      ticketNumber: 'TK-10447',
      subject: 'Password reset link expired',
      description:
          'The password reset link I received is showing expired. Please send a new one.',
      status: TicketStatus.pending,
      priority: TicketPriority.medium,
      category: 'Account',
      channel: TicketChannel.web,
      customerId: 'cust-6',
      customerName: 'Ananya Iyer',
      customerEmail: 'ananya@finflow.app',
      assignedAgentId: 'agent-3',
      assignedAgentName: 'Aman Verma',
      assignedTeamId: 'team-1',
      assignedTeamName: 'Technical Support',
      slaDueAt: DateTime.now().add(const Duration(hours: 3)),
      tags: ['password', 'reset'],
      messages: [],
      activities: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Ticket(
      id: 'tk-7',
      ticketNumber: 'TK-10446',
      subject: 'Refund request for cancelled subscription',
      description:
          'I cancelled my subscription 3 days ago but have not received the prorated refund yet.',
      status: TicketStatus.open,
      priority: TicketPriority.high,
      category: 'Billing',
      channel: TicketChannel.email,
      customerId: 'cust-1',
      customerName: 'John Smith',
      customerEmail: 'john.smith@acmecorp.com',
      assignedAgentId: 'agent-2',
      assignedAgentName: 'Priya Patel',
      assignedTeamId: 'team-2',
      assignedTeamName: 'Billing Support',
      slaDueAt: DateTime.now().add(const Duration(minutes: 45)),
      tags: ['refund', 'cancellation'],
      messages: [],
      activities: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Ticket(
      id: 'tk-8',
      ticketNumber: 'TK-10445',
      subject: 'Feature request: Dark mode support',
      description:
          'Could you add dark mode support to the web dashboard? It would be great for late-night work sessions.',
      status: TicketStatus.closed,
      priority: TicketPriority.low,
      category: 'Feature Request',
      channel: TicketChannel.web,
      customerId: 'cust-3',
      customerName: 'Rahul Sharma',
      customerEmail: 'rahul.sharma@startup.in',
      assignedAgentId: 'agent-4',
      assignedAgentName: 'Sara Khan',
      assignedTeamId: 'team-3',
      assignedTeamName: 'Customer Success',
      tags: ['feature-request', 'ui'],
      resolvedAt: DateTime.now().subtract(const Duration(days: 1)),
      closedAt: DateTime.now().subtract(const Duration(days: 1)),
      messages: [],
      activities: [],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // ─── Conversations ────────────────────────────────────────────────────
  static List<Conversation> get conversations => [
    Conversation(
      id: 'conv-1',
      customerId: 'cust-1',
      customerName: 'John Smith',
      customerEmail: 'john.smith@acmecorp.com',
      assignedAgentId: 'agent-1',
      assignedAgentName: 'Rahul Sharma',
      channel: ConversationChannel.chat,
      status: ConversationStatus.open,
      unreadCount: 3,
      lastMessage: 'Can you please help me resolve this quickly?',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
      messages: _conversationMessages('conv-1', 'John Smith', 'Rahul Sharma'),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Conversation(
      id: 'conv-2',
      customerId: 'cust-2',
      customerName: 'Sarah Williams',
      customerEmail: 'sarah.w@techventures.io',
      assignedAgentId: 'agent-2',
      assignedAgentName: 'Priya Patel',
      channel: ConversationChannel.email,
      status: ConversationStatus.open,
      unreadCount: 1,
      lastMessage: 'I am still waiting for the refund confirmation.',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
      messages: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Conversation(
      id: 'conv-3',
      customerId: 'cust-3',
      customerName: 'Rahul Sharma',
      customerEmail: 'rahul.sharma@startup.in',
      assignedAgentId: 'agent-3',
      assignedAgentName: 'Aman Verma',
      channel: ConversationChannel.whatsapp,
      status: ConversationStatus.open,
      unreadCount: 0,
      lastMessage: 'Thank you for the quick response!',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
      messages: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Conversation(
      id: 'conv-4',
      customerId: 'cust-4',
      customerName: 'Emma Johnson',
      customerEmail: 'emma.j@globex.com',
      channel: ConversationChannel.chat,
      status: ConversationStatus.resolved,
      unreadCount: 0,
      lastMessage: 'Issue has been resolved. Thank you!',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      messages: [],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // ─── Knowledge Articles ───────────────────────────────────────────────
  static final List<KnowledgeArticle> articles = [
    KnowledgeArticle(
      id: 'art-1',
      title: 'Getting Started with SupportCRM',
      slug: 'getting-started',
      content: '''
# Getting Started with SupportCRM

Welcome to SupportCRM! This guide will help you set up your workspace and start handling customer support tickets efficiently.

## Step 1: Set Up Your Profile

First, complete your profile by adding your name, profile picture, and contact information.

## Step 2: Configure Your Team

Invite your team members and assign them to support queues.

## Step 3: Create Your First Ticket

Navigate to **Tickets** and click **New Ticket** to create your first support ticket.

## Step 4: Explore the Dashboard

Your dashboard gives you a real-time overview of your support performance including:
- Open ticket count
- SLA compliance
- Agent workload
- CSAT scores
      ''',
      category: 'Getting Started',
      authorId: 'agent-4',
      authorName: 'Sara Khan',
      status: 'published',
      views: 1284,
      helpfulCount: 342,
      notHelpfulCount: 18,
      tags: ['onboarding', 'setup', 'beginner'],
      publishedAt: DateTime.now().subtract(const Duration(days: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    KnowledgeArticle(
      id: 'art-2',
      title: 'How to Reset Your Password',
      slug: 'how-to-reset-password',
      content: '''
# How to Reset Your Password

If you have forgotten your password, follow these simple steps:

## Method 1: From the Login Screen

1. Go to the login page
2. Click "Forgot Password?"
3. Enter your email address
4. Check your email for the reset link
5. Click the link and set a new password

## Method 2: From Account Settings

If you are logged in:
1. Go to **Settings > Security**
2. Click **Change Password**
3. Enter your current and new password

## Troubleshooting

If you didn't receive the reset email, check your spam folder or contact support.
      ''',
      category: 'Account',
      authorId: 'agent-1',
      authorName: 'Rahul Sharma',
      status: 'published',
      views: 3412,
      helpfulCount: 891,
      notHelpfulCount: 42,
      tags: ['password', 'account', 'security'],
      publishedAt: DateTime.now().subtract(const Duration(days: 60)),
      createdAt: DateTime.now().subtract(const Duration(days: 65)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    KnowledgeArticle(
      id: 'art-3',
      title: 'Understanding SLA Policies',
      slug: 'understanding-sla-policies',
      content: '''
# Understanding SLA Policies

Service Level Agreements (SLAs) define the expected response and resolution times for tickets.

## Default SLA Policies

| Priority | First Response | Resolution |
|----------|---------------|------------|
| Critical | 30 minutes | 2 hours |
| High | 1 hour | 8 hours |
| Medium | 4 hours | 24 hours |
| Low | 24 hours | 72 hours |

## SLA Indicators

- 🟢 **On Track**: Ticket within SLA window
- 🟡 **Warning**: Less than 25% time remaining
- 🔴 **Breached**: SLA deadline passed
      ''',
      category: 'Technical Support',
      authorId: 'agent-4',
      authorName: 'Sara Khan',
      status: 'published',
      views: 876,
      helpfulCount: 234,
      notHelpfulCount: 12,
      tags: ['sla', 'policy', 'tickets'],
      publishedAt: DateTime.now().subtract(const Duration(days: 20)),
      createdAt: DateTime.now().subtract(const Duration(days: 22)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    KnowledgeArticle(
      id: 'art-4',
      title: 'Billing & Subscription FAQ',
      slug: 'billing-subscription-faq',
      content: '''
# Billing & Subscription FAQ

## When will I be charged?

Subscriptions are billed on the same day each month from the date you signed up.

## Can I get a refund?

Yes, we offer a 14-day money-back guarantee for new subscriptions.

## How do I cancel my subscription?

Go to **Settings > Billing** and click **Cancel Subscription**.

## What payment methods do you accept?

We accept Visa, Mastercard, American Express, and PayPal.
      ''',
      category: 'Billing',
      authorId: 'agent-2',
      authorName: 'Priya Patel',
      status: 'published',
      views: 2103,
      helpfulCount: 567,
      notHelpfulCount: 89,
      tags: ['billing', 'payment', 'subscription', 'refund'],
      publishedAt: DateTime.now().subtract(const Duration(days: 45)),
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    KnowledgeArticle(
      id: 'art-5',
      title: 'Mobile App Troubleshooting Guide',
      slug: 'mobile-app-troubleshooting',
      content: '''
# Mobile App Troubleshooting Guide

## App is Crashing

1. Force close the app and reopen it
2. Check for app updates in the App Store / Play Store
3. Restart your device
4. Reinstall the app if the issue persists

## Can't Log In on Mobile

Ensure you are using the correct credentials. Try resetting your password.

## Slow Performance

Clear the app cache in your device settings.
      ''',
      category: 'Mobile App',
      authorId: 'agent-3',
      authorName: 'Aman Verma',
      status: 'published',
      views: 1567,
      helpfulCount: 423,
      notHelpfulCount: 55,
      tags: ['mobile', 'crash', 'troubleshooting', 'ios', 'android'],
      publishedAt: DateTime.now().subtract(const Duration(days: 15)),
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // ─── Notifications ────────────────────────────────────────────────────
  static List<NotificationItem> get notifications => [
    NotificationItem(
      id: 'notif-1',
      title: 'Ticket #TK-1001 Assigned',
      message: 'Urgent: Unable to process credit card payment has been assigned to you.',
      type: NotificationType.ticketAssigned,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: false,
      actionRoute: '/tickets/tk-1001',
    ),
    NotificationItem(
      id: 'notif-2',
      title: 'SLA Warning: Ticket #TK-1003',
      message: 'First response target breached for Enterprise SSO Integration issue.',
      type: NotificationType.slaBreached,
      createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
      isRead: false,
      actionRoute: '/tickets/tk-1003',
    ),
    NotificationItem(
      id: 'notif-3',
      title: 'Rahul Sharma mentioned you',
      message: '"@Akash can you verify this refund request on Stripe dashboard?"',
      type: NotificationType.mention,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      actionRoute: '/tickets/tk-1002',
    ),
    NotificationItem(
      id: 'notif-4',
      title: 'Ticket #TK-1005 Updated',
      message: 'Priya Patel changed priority from Medium to High.',
      type: NotificationType.ticketUpdated,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: true,
      actionRoute: '/tickets/tk-1005',
    ),
    NotificationItem(
      id: 'notif-5',
      title: 'System Maintenance Scheduled',
      message: 'Scheduled database migration on Sunday 02:00 UTC (Estimated downtime 15m).',
      type: NotificationType.system,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  // ─── Dashboard Stats ──────────────────────────────────────────────────
  static Map<String, dynamic> get dashboardStats => {
    'totalTickets': 248,
    'totalTicketsGrowth': 12.0,
    'openTickets': 64,
    'pendingTickets': 11,
    'resolvedTickets': 173,
    'slaBreached': 4,
    'avgResponseMinutes': 22.4,
    'avgResolutionHours': 6.8,
    'csatScore': 94.2,
    'csatGrowth': 2.1,
    'slaCompliance': 91.3,
  };

  static List<Map<String, dynamic>> get ticketTrendData => [
    {'date': '2026-09-05', 'new': 28, 'resolved': 22, 'pending': 6},
    {'date': '2026-09-06', 'new': 34, 'resolved': 31, 'pending': 3},
    {'date': '2026-09-07', 'new': 19, 'resolved': 24, 'pending': 8},
    {'date': '2026-09-08', 'new': 42, 'resolved': 38, 'pending': 4},
    {'date': '2026-09-09', 'new': 31, 'resolved': 27, 'pending': 4},
    {'date': '2026-09-10', 'new': 38, 'resolved': 35, 'pending': 3},
    {'date': '2026-09-11', 'new': 26, 'resolved': 18, 'pending': 8},
  ];

  // ─── Private helpers ──────────────────────────────────────────────────
  static List<TicketMessage> _ticketMessages(
    String ticketId,
    String customerName,
    String agentName,
  ) {
    return [
      TicketMessage(
        id: '${ticketId}_msg1',
        ticketId: ticketId,
        senderType: 'customer',
        senderName: customerName,
        content:
            'Hi, I am facing an issue and need urgent help. Please assist me as soon as possible.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      TicketMessage(
        id: '${ticketId}_msg2',
        ticketId: ticketId,
        senderType: 'agent',
        senderName: agentName,
        content:
            'Hello! Thank you for reaching out to SupportCRM. I am happy to help you resolve this issue. Could you please provide more details about the problem you are experiencing?',
        createdAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
      ),
      TicketMessage(
        id: '${ticketId}_msg3',
        ticketId: ticketId,
        senderType: 'customer',
        senderName: customerName,
        content:
            'Sure, I have been trying since yesterday and the error message says "Invalid credentials". I already reset my password twice but still the same issue.',
        createdAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 20)),
      ),
      TicketMessage(
        id: '${ticketId}_msg4',
        ticketId: ticketId,
        senderType: 'agent',
        senderName: agentName,
        content:
            'I can see your account in our system. It looks like there may be a caching issue. Please try clearing your browser cookies and try again. If this doesn\'t work, I will escalate this to our technical team.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      TicketMessage(
        id: '${ticketId}_msg5',
        ticketId: ticketId,
        senderType: 'agent',
        senderName: agentName,
        content:
            'Also, can you try using a different browser like Chrome or Firefox?',
        isInternalNote: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TicketMessage(
        id: '${ticketId}_note1',
        ticketId: ticketId,
        senderType: 'agent',
        senderName: agentName,
        content:
            'Internal: Checked the database — user account is active. Might be a session conflict. Monitoring.',
        isInternalNote: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      TicketMessage(
        id: '${ticketId}_msg6',
        ticketId: ticketId,
        senderType: 'customer',
        senderName: customerName,
        content:
            'Can you please help me resolve this quickly? I need access urgently for a client presentation.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ];
  }

  static List<TicketActivity> _ticketActivities(
    String ticketId,
    String agentName,
  ) {
    return [
      TicketActivity(
        id: '${ticketId}_act1',
        ticketId: ticketId,
        actorName: 'System',
        action: 'created',
        newValue: 'open',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      TicketActivity(
        id: '${ticketId}_act2',
        ticketId: ticketId,
        actorName: agentName,
        action: 'assigned',
        newValue: agentName,
        createdAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 50)),
      ),
      TicketActivity(
        id: '${ticketId}_act3',
        ticketId: ticketId,
        actorName: agentName,
        action: 'priority_changed',
        oldValue: 'medium',
        newValue: 'high',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  static List<ConversationMessage> _conversationMessages(
    String convId,
    String customerName,
    String agentName,
  ) {
    return [
      ConversationMessage(
        id: '${convId}_m1',
        conversationId: convId,
        senderType: 'customer',
        senderName: customerName,
        content: 'Hi, I need help with my account.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ConversationMessage(
        id: '${convId}_m2',
        conversationId: convId,
        senderType: 'agent',
        senderName: agentName,
        content:
            'Hello! I\'m $agentName from SupportCRM. How can I assist you today?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
        readAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 54)),
      ),
      ConversationMessage(
        id: '${convId}_m3',
        conversationId: convId,
        senderType: 'customer',
        senderName: customerName,
        content: 'I cannot log in to my account. It keeps saying invalid password.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
      ConversationMessage(
        id: '${convId}_m4',
        conversationId: convId,
        senderType: 'agent',
        senderName: agentName,
        content:
            'I\'m sorry about that. Let me check your account right away. Could you share the email address you used to register?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        readAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 28)),
      ),
      ConversationMessage(
        id: '${convId}_m5',
        conversationId: convId,
        senderType: 'customer',
        senderName: customerName,
        content: 'Can you please help me resolve this quickly?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }
}

typedef MockDataService = MockData;
