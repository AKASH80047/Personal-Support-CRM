import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AiCopilotPage extends StatefulWidget {
  const AiCopilotPage({super.key});
  @override
  State<AiCopilotPage> createState() => _AiCopilotPageState();
}

class _AiCopilotPageState extends State<AiCopilotPage> {
  final _promptCtrl = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(isAi: true, text:
      '👋 Hi! I\'m your AI Copilot powered by GPT-4o.\n\n'
      'Here\'s today\'s support summary:\n'
      '• **12 high-priority tickets** need attention today\n'
      '• **4 tickets** are approaching SLA breach in < 1 hour\n'
      '• Customer sentiment is **down 8%** vs last week\n'
      '• **Rahul** is at 91% workload — consider redistributing\n\n'
      'How can I help you today?'),
  ];
  bool _thinking = false;

  final List<String> _quickPrompts = [
    '📊 Daily support summary',
    '🚨 Show SLA at-risk tickets',
    '📈 Agent performance analysis',
    '😊 Customer sentiment report',
    '🔄 Suggest ticket redistribution',
    '💡 Top trending issues this week',
  ];

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(isAi: false, text: text));
      _thinking = true;
      _promptCtrl.clear();
    });
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
    if (mounted) {
      setState(() {
        _thinking = false;
        _messages.add(_ChatMessage(isAi: true, text: _getAiResponse(text)));
      });
    }
  }

  String _getAiResponse(String input) {
    final l = input.toLowerCase();
    if (l.contains('sla')) return '⚠️ **SLA At-Risk Tickets:**\n\n• **TK-10452** (John Smith) — 32 min remaining\n• **TK-10449** (Emma Johnson) — 1h 15m remaining\n• **TK-10446** (John Smith) — 45 min remaining\n\nRecommendation: Prioritize TK-10452 immediately.';
    if (l.contains('sentiment')) return '📊 **Customer Sentiment Analysis:**\n\nThis week: 72% positive (-8% vs last week)\n\nMain drivers:\n• Billing issues taking longer to resolve\n• Mobile app crash reports increasing\n• Good feedback on chat response speed\n\nRecommendation: Focus on billing queue SLA.';
    if (l.contains('agent') || l.contains('performance')) return '📈 **Agent Performance Summary:**\n\n| Agent | Open | CSAT | Workload |\n|---|---|---|---|\n| Priya | 8 | 4.9★ | 51% |\n| Rahul | 14 | 4.7★ | 82% |\n| Sara | 5 | 4.8★ | 35% |\n| Aman | 19 | 4.5★ | 91% |\n\n⚠️ Aman is overloaded. Suggest reassigning 4 tickets.';
    return '🤖 I\'ve analyzed the support data for your query: **"$input"**\n\nBased on current patterns:\n• Ticket volume is 12% above average\n• Response times are within SLA for 91.3% of tickets\n• Top recurring issue this week: Login & auth problems (28%)\n\nWould you like me to draft a response template or create a knowledge article?';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1428),
      body: isDesktop
          ? Row(children: [
              Expanded(child: _buildChat()),
              Container(width: 1, color: const Color(0xFF1E2A50)),
              SizedBox(width: 300, child: _buildInsightsPanel()),
            ])
          : _buildChat(),
    );
  }

  Widget _buildChat() {
    return Column(children: [
      // AI Header
      Container(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF1E2A50))),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Copilot', style: AppTypography.h5.copyWith(color: Colors.white)),
            Text('Powered by GPT-4o', style: AppTypography.bodyXs.copyWith(color: const Color(0xFF6B7CC4))),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('Online', style: AppTypography.labelSm.copyWith(color: AppColors.success)),
            ]),
          ),
        ]),
      ),
      // Quick prompts
      if (_messages.length <= 1)
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Wrap(spacing: 8, runSpacing: 8, children: _quickPrompts.map((p) =>
            GestureDetector(
              onTap: () => _sendMessage(p),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2445),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0xFF2A3A6A)),
                ),
                child: Text(p, style: AppTypography.bodySmMedium.copyWith(color: const Color(0xFFB0C0E8))),
              ),
            )).toList(),
          ),
        ),
      // Messages
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.xl2),
          itemCount: _messages.length + (_thinking ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (_, i) {
            if (_thinking && i == _messages.length) return _ThinkingBubble();
            return _AiChatBubble(message: _messages[i]);
          },
        ),
      ),
      // Composer
      Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1E2A50))),
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _promptCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask AI anything about your support...',
                hintStyle: const TextStyle(color: Color(0xFF4A5A8A)),
                filled: true,
                fillColor: const Color(0xFF1A2445),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A3A6A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A3A6A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              onPressed: () => _sendMessage(_promptCtrl.text),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildInsightsPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('AI Insights', style: AppTypography.h5.copyWith(color: Colors.white)),
        const SizedBox(height: AppSpacing.lg),
        _insightCard(Icons.warning_rounded, AppColors.danger, 'SLA Risk',
            '4 tickets approaching SLA breach in the next hour'),
        const SizedBox(height: AppSpacing.md),
        _insightCard(Icons.sentiment_dissatisfied_rounded, AppColors.warning, 'Sentiment Alert',
            'Customer satisfaction down 8% this week'),
        const SizedBox(height: AppSpacing.md),
        _insightCard(Icons.person_rounded, AppColors.primary, 'Workload',
            'Aman is at 91% — redistribute 3-4 tickets'),
        const SizedBox(height: AppSpacing.md),
        _insightCard(Icons.trending_up_rounded, AppColors.success, 'Trending Issue',
            'Login/auth tickets up 28% — consider KB article'),
        const SizedBox(height: AppSpacing.xl2),
        Text('AI Actions', style: AppTypography.h5.copyWith(color: Colors.white)),
        const SizedBox(height: AppSpacing.md),
        ...[
          ('✍️ Draft reply templates', Icons.draw_outlined),
          ('📝 Generate KB article', Icons.article_outlined),
          ('📊 Create weekly report', Icons.bar_chart_rounded),
          ('🔄 Auto-assign tickets', Icons.assignment_ind_outlined),
        ].map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => _sendMessage(item.$1),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2445),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A3A6A)),
              ),
              child: Row(children: [
                Icon(item.$2, size: 16, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Expanded(child: Text(item.$1,
                    style: AppTypography.bodySmMedium.copyWith(color: const Color(0xFFB0C0E8)))),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF4A5A8A)),
              ]),
            ),
          ),
        )),
      ]),
    );
  }

  Widget _insightCard(IconData icon, Color color, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTypography.bodyXsMedium.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(body, style: AppTypography.bodyXs.copyWith(color: const Color(0xFF8B9CC4), height: 1.5)),
        ])),
      ]),
    );
  }
}

class _ChatMessage {
  final bool isAi;
  final String text;
  _ChatMessage({required this.isAi, required this.text});
}

class _AiChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _AiChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: message.isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (message.isAi) ...[
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: message.isAi ? const Color(0xFF1A2445) : AppColors.primary.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12).copyWith(
                topLeft: message.isAi ? Radius.zero : const Radius.circular(12),
                topRight: message.isAi ? const Radius.circular(12) : Radius.zero,
              ),
              border: Border.all(
                color: message.isAi ? const Color(0xFF2A3A6A) : Colors.transparent),
            ),
            child: Text(message.text,
                style: AppTypography.bodySm.copyWith(color: const Color(0xFFD0DCF4), height: 1.7)),
          ),
        ),
        if (!message.isAi) ...[
          const SizedBox(width: 10),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('AK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
          ),
        ],
      ],
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
      ),
      const SizedBox(width: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2445),
          borderRadius: BorderRadius.circular(12).copyWith(topLeft: Radius.zero),
          border: Border.all(color: const Color(0xFF2A3A6A)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _Dot(delay: 0),
          const SizedBox(width: 4),
          _Dot(delay: 200),
          const SizedBox(width: 4),
          _Dot(delay: 400),
        ]),
      ),
    ]);
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6, height: 6,
        decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
      ),
    );
  }
}
