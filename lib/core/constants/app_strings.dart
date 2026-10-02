/// SupportCRM — App Strings
class AppStrings {
  AppStrings._();

  static const String appName = 'SupportCRM';
  static const String tagline = 'Powerful support. Happier customers.';

  // Auth
  static const String login = 'Sign In';
  static const String register = 'Create Account';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String logout = 'Sign Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String continueWith = 'Continue with';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String tickets = 'Tickets';
  static const String inbox = 'Inbox';
  static const String customers = 'Customers';
  static const String knowledgeBase = 'Knowledge Base';
  static const String agents = 'Agents';
  static const String teams = 'Teams';
  static const String analytics = 'Analytics';
  static const String automations = 'Automations';
  static const String aiCopilot = 'AI Copilot';
  static const String notifications = 'Notifications';
  static const String settings = 'Settings';
  static const String help = 'Help & Support';

  // Tickets
  static const String newTicket = 'New Ticket';
  static const String createTicket = 'Create Ticket';
  static const String ticketId = 'Ticket ID';
  static const String subject = 'Subject';
  static const String description = 'Description';
  static const String priority = 'Priority';
  static const String status = 'Status';
  static const String category = 'Category';
  static const String assignedAgent = 'Assigned Agent';
  static const String assignedTeam = 'Team';
  static const String channel = 'Channel';
  static const String tags = 'Tags';
  static const String attachments = 'Attachments';
  static const String replyComposer = 'Write a reply...';
  static const String internalNote = 'Internal Note';
  static const String aiSuggestReply = '✨ AI Suggest Reply';

  // Status labels
  static const String open = 'Open';
  static const String pending = 'Pending';
  static const String onHold = 'On Hold';
  static const String resolved = 'Resolved';
  static const String closed = 'Closed';
  static const String slaBreached = 'SLA Breached';

  // Priority labels
  static const String critical = 'Critical';
  static const String high = 'High';
  static const String medium = 'Medium';
  static const String low = 'Low';

  // Dashboard
  static const String goodMorning = 'Good morning';
  static const String dashboardSubtitle =
      "Here's your support performance overview";
  static const String totalTickets = 'Total Tickets';
  static const String openTickets = 'Open Tickets';
  static const String pendingTickets = 'Pending';
  static const String resolvedTickets = 'Resolved';
  static const String avgResponseTime = 'Avg Response Time';
  static const String avgResolutionTime = 'Avg Resolution Time';
  static const String csatScore = 'CSAT Score';
  static const String slaCompliance = 'SLA Compliance';

  // Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String assign = 'Assign';
  static const String close = 'Close';
  static const String merge = 'Merge';
  static const String escalate = 'Escalate';
  static const String reply = 'Reply';
  static const String send = 'Send';
  static const String export = 'Export';
  static const String search = 'Search...';
  static const String filter = 'Filter';
  static const String clearAll = 'Clear All';

  // Empty states
  static const String noTickets = 'No tickets found';
  static const String noTicketsSubtitle =
      'Create your first ticket to get started.';
  static const String noCustomers = 'No customers yet';
  static const String noCustomersSubtitle =
      'Add your first customer to get started.';
  static const String noConversations = 'No conversations';
  static const String noConversationsSubtitle =
      'New conversations will appear here.';
  static const String noNotifications = 'All caught up!';
  static const String noNotificationsSubtitle =
      'No new notifications at the moment.';
  static const String noArticles = 'No articles found';
  static const String noArticlesSubtitle =
      'Start building your knowledge base.';

  // Errors
  static const String genericError = 'Something went wrong.';
  static const String networkError = 'No internet connection.';
  static const String serverError = 'Server error. Please try again.';
  static const String notFound = 'Page not found';
  static const String permissionDenied = 'Access denied';
  static const String sessionExpired = 'Session expired. Please sign in again.';
  static const String retry = 'Retry';
  static const String goBack = 'Go Back';
  static const String goHome = 'Go to Dashboard';

  // Validation
  static const String fieldRequired = 'This field is required';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  // Confirmations
  static const String confirmCloseTicket =
      'Are you sure you want to close this ticket?';
  static const String confirmDeleteCustomer =
      'Are you sure you want to delete this customer? This action cannot be undone.';
  static const String confirmLogout = 'Are you sure you want to sign out?';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String confirm = 'Confirm';

  // Success messages
  static const String ticketCreated = 'Ticket created successfully.';
  static const String ticketUpdated = 'Ticket updated successfully.';
  static const String ticketClosed = 'Ticket closed.';
  static const String ticketAssigned = 'Ticket assigned.';
  static const String customerAdded = 'Customer added successfully.';
  static const String customerUpdated = 'Customer updated.';
  static const String replySent = 'Reply sent.';
  static const String settingsSaved = 'Settings saved.';
}
