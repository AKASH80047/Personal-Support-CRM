import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/tickets/presentation/pages/tickets_page.dart';
import '../../features/tickets/presentation/pages/ticket_detail_page.dart';
import '../../features/tickets/presentation/pages/create_ticket_page.dart';
import '../../features/inbox/presentation/pages/inbox_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/knowledge_base/presentation/pages/knowledge_base_page.dart';
import '../../features/knowledge_base/presentation/pages/article_detail_page.dart';
import '../../features/agents/presentation/pages/agents_page.dart';
import '../../features/agents/presentation/pages/agent_detail_page.dart';
import '../../features/teams/presentation/pages/teams_page.dart';
import '../../features/teams/presentation/pages/team_detail_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/automations/presentation/pages/automations_page.dart';
import '../../features/ai/presentation/pages/ai_copilot_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shell/app_shell.dart';

/// Route name constants
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String tickets = '/tickets';
  static const String ticketDetail = '/tickets/:id';
  static const String createTicket = '/create-ticket';
  static const String inbox = '/inbox';
  static const String customers = '/customers';
  static const String customerDetail = '/customers/:id';
  static const String tasks = '/tasks';
  static const String knowledgeBase = '/knowledge-base';
  static const String articleDetail = '/knowledge-base/:id';
  static const String agents = '/agents';
  static const String agentDetail = '/agents/:id';
  static const String teams = '/teams';
  static const String teamDetail = '/teams/:id';
  static const String analytics = '/analytics';
  static const String automations = '/automations';
  static const String aiCopilot = '/ai';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Mock auth state
bool get _isAuthenticated => true;

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  redirect: (context, state) {
    final isAuthRoute = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register ||
        state.matchedLocation == AppRoutes.forgotPassword ||
        state.matchedLocation == AppRoutes.splash;

    if (!_isAuthenticated && !isAuthRoute) {
      return AppRoutes.login;
    }
    return null;
  },
  routes: [
    // ─ Auth routes (no shell) ───────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    // ─ App shell (sidebar + header + bottom nav) ────────────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.tickets,
          builder: (context, state) => const TicketsPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => TicketDetailPage(
                ticketId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.createTicket,
          builder: (context, state) => const CreateTicketPage(),
        ),
        GoRoute(
          path: AppRoutes.inbox,
          builder: (context, state) => const InboxPage(),
        ),
        GoRoute(
          path: AppRoutes.customers,
          builder: (context, state) => const CustomersPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => CustomerDetailPage(
                customerId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.tasks,
          builder: (context, state) => const TasksPage(),
        ),
        GoRoute(
          path: AppRoutes.knowledgeBase,
          builder: (context, state) => const KnowledgeBasePage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => ArticleDetailPage(
                articleId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.agents,
          builder: (context, state) => const AgentsPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => AgentDetailPage(
                agentId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.teams,
          builder: (context, state) => const TeamsPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => TeamDetailPage(
                teamId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.analytics,
          builder: (context, state) => const AnalyticsPage(),
        ),
        GoRoute(
          path: AppRoutes.automations,
          builder: (context, state) => const AutomationsPage(),
        ),
        GoRoute(
          path: AppRoutes.aiCopilot,
          builder: (context, state) => const AiCopilotPage(),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Page not found: ${state.uri}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.dashboard),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    ),
  ),
);
