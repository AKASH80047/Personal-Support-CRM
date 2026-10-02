import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _activeSubSection = 0; // 0: Org Profile, 1: Workspace, 2: Email, 3: Localization, 4: Branding

  // Form Controllers
  final _orgNameCtrl = TextEditingController(text: 'Acme SaaS Corp');
  final _emailCtrl = TextEditingController(text: 'support@acmesaas.com');
  final _websiteCtrl = TextEditingController(text: 'https://www.acmesaas.com');
  final _taglineCtrl = TextEditingController(text: 'Support Made Simple');
  final _descCtrl = TextEditingController(
      text: 'We provide innovative SaaS solutions to help businesses grow with better customer support.');
  final _portalSubdomainCtrl = TextEditingController(text: 'acme.supportcrm.io');
  final _emailSignatureCtrl = TextEditingController(text: 'Best regards,\nAcme Support Team\nsupport@acmesaas.com');

  // Logo & Branding State
  String _brandLogoType = 'icon'; // 'icon' or 'image'
  IconData _selectedLogoIcon = Icons.business_rounded;
  Color _selectedBrandColor = const Color(0xFF2563EB);
  String _customLogoUrl = '';

  // Workspace & Preferences State
  String _selectedTimezone = 'UTC+05:30 (IST - India)';
  String _selectedLanguage = 'English (US)';
  String _selectedCompanySize = '11 - 50 employees';
  String _selectedDateFormat = 'MM/DD/YYYY';
  String _selectedCurrency = 'USD (\$)';
  bool _autoAssign = true;
  bool _emailNotify = true;
  bool _slaAlerts = true;
  bool _satisfactionSurvey = true;
  bool _aiAssistedReplies = true;
  double _aiConfidenceThreshold = 0.85;
  String _selectedLlmEngine = 'GPT-4o (Fine-Tuned Customer Support)';

  // SLAs state
  final List<Map<String, dynamic>> _slas = [
    {'priority': 'Critical', 'first': '15 min', 'resolution': '2 hours', 'color': const Color(0xFFEF4444)},
    {'priority': 'High', 'first': '30 min', 'resolution': '6 hours', 'color': const Color(0xFFEA580C)},
    {'priority': 'Medium', 'first': '2 hours', 'resolution': '24 hours', 'color': const Color(0xFFD97706)},
    {'priority': 'Low', 'first': '4 hours', 'resolution': '48 hours', 'color': const Color(0xFF64748B)},
  ];

  // Integrations state
  final List<Map<String, dynamic>> _integrations = [
    {'id': 'slack', 'name': 'Slack Channel Alerts', 'sub': 'Notify agents on critical SLA breach in #support-triage', 'icon': Icons.chat_rounded, 'connected': true, 'config': '#support-triage'},
    {'id': 'whatsapp', 'name': 'WhatsApp Business Cloud API', 'sub': 'Receive and reply to WhatsApp messages directly in tickets', 'icon': Icons.send_rounded, 'connected': true, 'config': '+1 (555) 019-2834'},
    {'id': 'email', 'name': 'Email Ingestion (IMAP / SMTP)', 'sub': 'Automatically convert incoming emails into tracked tickets', 'icon': Icons.mail_rounded, 'connected': true, 'config': 'mail.acmesaas.com:993'},
    {'id': 'webhook', 'name': 'Custom Webhook Dispatcher', 'sub': 'Broadcast real-time events to your backend REST endpoints', 'icon': Icons.webhook_rounded, 'connected': false, 'config': 'https://api.acmesaas.com/webhooks/crm'},
  ];

  // Preset Icons for Logo Studio
  final List<Map<String, dynamic>> _presetIcons = [
    {'icon': Icons.business_rounded, 'label': 'Enterprise'},
    {'icon': Icons.bolt_rounded, 'label': 'Lightning'},
    {'icon': Icons.shield_rounded, 'label': 'Shield'},
    {'icon': Icons.hub_rounded, 'label': 'Hub'},
    {'icon': Icons.cloud_done_rounded, 'label': 'Cloud'},
    {'icon': Icons.rocket_launch_rounded, 'label': 'Rocket'},
    {'icon': Icons.auto_awesome_rounded, 'label': 'AI Smart'},
    {'icon': Icons.diamond_rounded, 'label': 'Diamond'},
    {'icon': Icons.headset_mic_rounded, 'label': 'Support'},
    {'icon': Icons.layers_rounded, 'label': 'Platform'},
    {'icon': Icons.insights_rounded, 'label': 'Analytics'},
    {'icon': Icons.verified_user_rounded, 'label': 'Secure'},
  ];

  // Preset Colors for Logo Studio
  final List<Map<String, dynamic>> _presetColors = [
    {'color': const Color(0xFF2563EB), 'label': 'Sapphire Blue'},
    {'color': const Color(0xFF4F46E5), 'label': 'Indigo'},
    {'color': const Color(0xFF7C3AED), 'label': 'Royal Violet'},
    {'color': const Color(0xFF0D9488), 'label': 'Teal'},
    {'color': const Color(0xFF10B981), 'label': 'Emerald'},
    {'color': const Color(0xFFEA580C), 'label': 'Sunset Orange'},
    {'color': const Color(0xFFE11D48), 'label': 'Rose Crimson'},
    {'color': const Color(0xFF0F172A), 'label': 'Midnight Slate'},
  ];

  // Preset Brand Sample Images
  final List<Map<String, String>> _sampleLogos = [
    {'name': 'Stripe Style', 'url': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150&auto=format&fit=crop&q=80'},
    {'name': 'Tech Neon', 'url': 'https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?w=150&auto=format&fit=crop&q=80'},
    {'name': 'Gradient Wave', 'url': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150&auto=format&fit=crop&q=80'},
  ];

  final List<String> _timezones = [
    'UTC+05:30 (IST - India)',
    'UTC+00:00 (GMT / London)',
    'UTC-05:00 (EST - New York)',
    'UTC-08:00 (PST - San Francisco)',
    'UTC+08:00 (SGT - Singapore)',
    'UTC+09:00 (JST - Tokyo)',
  ];

  final List<String> _languages = [
    'English (US)',
    'English (UK)',
    'Hindi (हिन्दी)',
    'Spanish (Español)',
    'French (Français)',
    'German (Deutsch)',
  ];

  final List<String> _companySizes = [
    '1 - 10 employees',
    '11 - 50 employees',
    '51 - 200 employees',
    '201 - 1000 employees',
    '1000+ employees',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _orgNameCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _taglineCtrl.dispose();
    _descCtrl.dispose();
    _portalSubdomainCtrl.dispose();
    _emailSignatureCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Settings and organization preferences saved successfully!'),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LOGO PICKER & BRAND STUDIO DIALOG
  // ───────────────────────────────────────────────────────────────────────────
  void _showLogoCustomizerDialog() {
    IconData tempIcon = _selectedLogoIcon;
    Color tempColor = _selectedBrandColor;
    String tempLogoType = _brandLogoType;
    String tempCustomUrl = _customLogoUrl;
    final urlCtrl = TextEditingController(text: _customLogoUrl);
    final taglineModalCtrl = TextEditingController(text: _taglineCtrl.text);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 580,
                constraints: const BoxConstraints(maxHeight: 700),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Modal Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tempColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.palette_rounded, color: tempColor, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Organization Logo & Brand Studio',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Upload a custom image, choose vector icons, or select brand colors.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 20),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),

                    // Modal Body (Scrollable)
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─ 1. Live Interactive Preview inside Modal ─
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    tempColor.withOpacity(0.06),
                                    const Color(0xFFF8FAFC),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: tempColor.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: tempColor,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: tempColor.withOpacity(0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: (tempLogoType == 'image' && tempCustomUrl.isNotEmpty)
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(14),
                                              child: Image.network(
                                                tempCustomUrl,
                                                fit: BoxFit.cover,
                                                width: 58,
                                                height: 58,
                                                errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image_rounded, color: Colors.white, size: 28),
                                              ),
                                            )
                                          : Icon(tempIcon, color: Colors.white, size: 30),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _orgNameCtrl.text.isEmpty ? 'Acme SaaS Corp' : _orgNameCtrl.text,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDCFCE7),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text('Live Preview', style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.w700)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          taglineModalCtrl.text.isEmpty ? 'Support Made Simple' : taglineModalCtrl.text,
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ─ 2. Logo Mode Switcher ─
                            const Text('Logo Source Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setModalState(() => tempLogoType = 'icon'),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: tempLogoType == 'icon' ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: tempLogoType == 'icon' ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                          width: tempLogoType == 'icon' ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.category_rounded, size: 16, color: tempLogoType == 'icon' ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Vector Brand Icon',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: tempLogoType == 'icon' ? const Color(0xFF2563EB) : const Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setModalState(() => tempLogoType = 'image'),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: tempLogoType == 'image' ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: tempLogoType == 'image' ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                          width: tempLogoType == 'image' ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image_outlined, size: 16, color: tempLogoType == 'image' ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Image File / URL',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: tempLogoType == 'image' ? const Color(0xFF2563EB) : const Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Mode-specific options
                            if (tempLogoType == 'icon') ...[
                              // Select Icon Grid
                              const Text('Choose Brand Icon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _presetIcons.map((item) {
                                  final icon = item['icon'] as IconData;
                                  final label = item['label'] as String;
                                  final isSelected = tempIcon == icon;

                                  return InkWell(
                                    onTap: () => setModalState(() => tempIcon = icon),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Tooltip(
                                      message: label,
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: isSelected ? tempColor.withOpacity(0.12) : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected ? tempColor : const Color(0xFFE2E8F0),
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Icon(
                                          icon,
                                          size: 24,
                                          color: isSelected ? tempColor : const Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),

                              // Select Brand Color
                              const Text('Select Brand Accent Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _presetColors.map((item) {
                                  final c = item['color'] as Color;
                                  final label = item['label'] as String;
                                  final isSelected = tempColor == c;

                                  return InkWell(
                                    onTap: () => setModalState(() => tempColor = c),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Tooltip(
                                      message: label,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: c,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? Colors.white : Colors.transparent,
                                            width: 2.5,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: c.withOpacity(0.5),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ] else ...[
                              // Image File Simulation / URL input
                              const Text('Upload Custom Logo File or Enter URL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                                ),
                                child: Column(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Simulate quick local file selection
                                        setModalState(() {
                                          tempCustomUrl = 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150&auto=format&fit=crop&q=80';
                                          urlCtrl.text = tempCustomUrl;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Selected acme_logo_retina.png (340KB)'), behavior: SnackBarBehavior.floating),
                                        );
                                      },
                                      icon: const Icon(Icons.folder_open_rounded, size: 16, color: Colors.white),
                                      label: const Text('Browse Files on Device', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('PNG, JPG, WebP, SVG (Max 2MB, recommended 512x512px)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text('Or Direct Image URL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: urlCtrl,
                                onChanged: (v) => setModalState(() => tempCustomUrl = v),
                                decoration: InputDecoration(
                                  hintText: 'https://example.com/logo.png',
                                  prefixIcon: const Icon(Icons.link_rounded, size: 18, color: Color(0xFF94A3B8)),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 16),
                                    onPressed: () {
                                      urlCtrl.clear();
                                      setModalState(() => tempCustomUrl = '');
                                    },
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              const Text('Sample Presets:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                              const SizedBox(height: 6),
                              Row(
                                children: _sampleLogos.map((s) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ActionChip(
                                      label: Text(s['name']!, style: const TextStyle(fontSize: 11)),
                                      avatar: const Icon(Icons.auto_awesome, size: 12, color: Color(0xFF2563EB)),
                                      backgroundColor: const Color(0xFFEFF6FF),
                                      onPressed: () {
                                        setModalState(() {
                                          tempCustomUrl = s['url']!;
                                          urlCtrl.text = tempCustomUrl;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            const SizedBox(height: 20),
                            // Tagline input
                            const Text('Company Tagline / Slogan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            TextField(
                              controller: taglineModalCtrl,
                              onChanged: (_) => setModalState(() {}),
                              decoration: InputDecoration(
                                hintText: 'e.g. Support Made Simple',
                                prefixIcon: const Icon(Icons.short_text_rounded, size: 18, color: Color(0xFF94A3B8)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Modal Actions Footer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedLogoIcon = tempIcon;
                                _selectedBrandColor = tempColor;
                                _brandLogoType = tempLogoType;
                                _customLogoUrl = tempCustomUrl;
                                _taglineCtrl.text = taglineModalCtrl.text;
                              });
                              Navigator.of(dialogCtx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text('Organization logo and brand styling updated successfully!'),
                                    ],
                                  ),
                                  backgroundColor: Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                            label: const Text('Apply Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SLA EDIT DIALOG
  // ───────────────────────────────────────────────────────────────────────────
  void _showEditSlaDialog(Map<String, dynamic> slaItem) {
    final firstCtrl = TextEditingController(text: slaItem['first'] as String);
    final resCtrl = TextEditingController(text: slaItem['resolution'] as String);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (slaItem['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(slaItem['priority'] as String, style: TextStyle(color: slaItem['color'] as Color, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              const Text('Edit SLA Targets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstCtrl,
                decoration: const InputDecoration(
                  labelText: 'First Response Target Time',
                  hintText: 'e.g. 15 min, 1 hour',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: resCtrl,
                decoration: const InputDecoration(
                  labelText: 'Target Resolution Duration',
                  hintText: 'e.g. 2 hours, 24 hours',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  slaItem['first'] = firstCtrl.text;
                  slaItem['resolution'] = resCtrl.text;
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated SLA rule for ${slaItem['priority']}'), backgroundColor: const Color(0xFF10B981), behavior: SnackBarBehavior.floating),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              child: const Text('Save Target', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // INTEGRATION CONFIG DIALOG
  // ───────────────────────────────────────────────────────────────────────────
  void _showIntegrationConfigDialog(Map<String, dynamic> item) {
    final configCtrl = TextEditingController(text: item['config'] as String);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              Icon(item['icon'] as IconData, color: const Color(0xFF2563EB)),
              const SizedBox(width: 10),
              Expanded(
                child: Text('${item['name']} Settings', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['sub'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              TextField(
                controller: configCtrl,
                decoration: const InputDecoration(
                  labelText: 'Endpoint / Channel Target / API Route',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Testing ping connection... 200 OK Response!'), backgroundColor: Color(0xFF10B981), behavior: SnackBarBehavior.floating),
                  );
                },
                icon: const Icon(Icons.network_check_rounded, size: 16),
                label: const Text('Test Connection Ping'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  item['config'] = configCtrl.text;
                  item['connected'] = true;
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item['name']} configured & connected!'), backgroundColor: const Color(0xFF10B981), behavior: SnackBarBehavior.floating),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              child: const Text('Save & Connect', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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
            // ─ 1. Header (Settings + Subtitle + Save Changes Button) ─
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage your workspace preferences, teams, SLA policies, and integrations.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                  label: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
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

            // ─ 2. Top Navigation Tabs ─
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                labelColor: const Color(0xFF2563EB),
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: const Color(0xFF2563EB),
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.settings_outlined, size: 18), text: 'General & Organization'),
                  Tab(icon: Icon(Icons.access_time_rounded, size: 18), text: 'SLA Policies'),
                  Tab(icon: Icon(Icons.link_rounded, size: 18), text: 'Channels & Integrations'),
                  Tab(icon: Icon(Icons.auto_awesome_rounded, size: 18), text: 'AI Configuration'),
                  Tab(icon: Icon(Icons.shield_outlined, size: 18), text: 'Security & API Keys'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─ 3. Main Body Tabs ─
            AnimatedBuilder(
              animation: _tabCtrl,
              builder: (context, _) {
                switch (_tabCtrl.index) {
                  case 0:
                    return _buildGeneralAndOrgView();
                  case 1:
                    return _buildSlaPoliciesView();
                  case 2:
                    return _buildIntegrationsView();
                  case 3:
                    return _buildAiConfigView();
                  case 4:
                    return _buildSecurityView();
                  default:
                    return _buildGeneralAndOrgView();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GENERAL & ORGANIZATION TAB (Exact 3-Column layout matching screenshot)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildGeneralAndOrgView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 1050;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubNavSidebar(isFullWidth: true),
              const SizedBox(height: 16),
              _buildActiveSubSectionContent(),
              const SizedBox(height: 16),
              _buildRightSidebar(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Sub-nav column (240px)
            SizedBox(
              width: 240,
              child: _buildSubNavSidebar(),
            ),
            const SizedBox(width: 20),

            // Center Main Form Content (Expanded)
            Expanded(
              child: _buildActiveSubSectionContent(),
            ),
            const SizedBox(width: 20),

            // Right Logo & Preview column (260px)
            SizedBox(
              width: 260,
              child: _buildRightSidebar(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubNavSidebar({bool isFullWidth = false}) {
    final subNavItems = [
      {'title': 'Organization Profile', 'sub': 'Basic details about your company', 'icon': Icons.business_rounded},
      {'title': 'Workspace Preferences', 'sub': 'Customize your workspace', 'icon': Icons.settings_suggest_rounded},
      {'title': 'Email Preferences', 'sub': 'Notification settings', 'icon': Icons.mail_outline_rounded},
      {'title': 'Localization', 'sub': 'Timezone, language, date format', 'icon': Icons.language_rounded},
      {'title': 'Branding', 'sub': 'Logo, colors and appearance', 'icon': Icons.palette_outlined},
    ];

    return Column(
      children: List.generate(subNavItems.length, (idx) {
        final item = subNavItems[idx];
        final isActive = _activeSubSection == idx;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
            ),
          ),
          child: InkWell(
            onTap: () => setState(() => _activeSubSection = idx),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: isActive ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                            color: isActive ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['sub'] as String,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActiveSubSectionContent() {
    switch (_activeSubSection) {
      case 0:
        return _buildOrgProfileForm();
      case 1:
        return _buildWorkspacePrefForm();
      case 2:
        return _buildEmailPrefForm();
      case 3:
        return _buildLocalizationForm();
      case 4:
        return _buildBrandingForm();
      default:
        return _buildOrgProfileForm();
    }
  }

  // ─ Sub-Section 0: Organization Profile ─
  Widget _buildOrgProfileForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business_rounded, color: Color(0xFF2563EB), size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Organization Profile',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Basic information visible across your support tickets and communications.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Row 1: Org Name & Support Email
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Company / Organization Name',
                  controller: _orgNameCtrl,
                  icon: Icons.business_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Primary Support Email',
                  controller: _emailCtrl,
                  icon: Icons.mail_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: Timezone & Default Language
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Timezone',
                  value: _selectedTimezone,
                  icon: Icons.language_rounded,
                  items: _timezones,
                  onChanged: (v) => setState(() => _selectedTimezone = v!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Default Language',
                  value: _selectedLanguage,
                  icon: Icons.translate_rounded,
                  items: _languages,
                  onChanged: (v) => setState(() => _selectedLanguage = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 3: Website & Company Size
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Company Website (Optional)',
                  controller: _websiteCtrl,
                  icon: Icons.link_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Company Size (Optional)',
                  value: _selectedCompanySize,
                  icon: Icons.people_outline_rounded,
                  items: _companySizes,
                  onChanged: (v) => setState(() => _selectedCompanySize = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 4: Company Description (Multiline textarea with counter)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Company Description (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Briefly describe your company or support operations...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text('${_descCtrl.text.length}/500', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Callout Alert Box at bottom
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This information will be visible to your team members and may be included in customer communications (depending on your settings).',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─ Sub-Section 1: Workspace Preferences ─
  Widget _buildWorkspacePrefForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Workspace & Ticket Routing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Configure ticket assignment, business operating hours, and queue limits.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Automatic Ticket Assignment (Round Robin)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: const Text('Automatically route unassigned incoming tickets to online agents with lowest workload.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            value: _autoAssign,
            activeColor: const Color(0xFF2563EB),
            onChanged: (v) {
              setState(() => _autoAssign = v);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(v ? 'Round Robin auto-assignment enabled' : 'Round Robin disabled'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)),
              );
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Enforce SLA Breach Warnings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: const Text('Send alerts when SLA due timer is within 30 minutes of breach.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            value: _slaAlerts,
            activeColor: const Color(0xFF2563EB),
            onChanged: (v) {
              setState(() => _slaAlerts = v);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(v ? 'SLA breach warnings active' : 'SLA alerts muted'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)),
              );
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('CSAT Customer Feedback Survey', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: const Text('Send rating survey automatically whenever a ticket status transitions to Resolved.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            value: _satisfactionSurvey,
            activeColor: const Color(0xFF2563EB),
            onChanged: (v) => setState(() => _satisfactionSurvey = v),
          ),
        ],
      ),
    );
  }

  // ─ Sub-Section 2: Email Preferences ─
  Widget _buildEmailPrefForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Email Notifications & Templates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Configure email piping, customer notification emails, and agent CC lists.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Send Confirmation Email to Customer on New Ticket', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: const Text('Customers receive instant ticket ID confirmation and link to track status.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            value: _emailNotify,
            activeColor: const Color(0xFF2563EB),
            onChanged: (v) => setState(() => _emailNotify = v),
          ),
          const SizedBox(height: 16),
          const Text('Default Agent Email Signature', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          TextField(
            controller: _emailSignatureCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test email dispatched to support@acmesaas.com'), backgroundColor: Color(0xFF10B981), behavior: SnackBarBehavior.floating),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 14, color: Colors.white),
            label: const Text('Send Test Email', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }

  // ─ Sub-Section 3: Localization ─
  Widget _buildLocalizationForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Localization & Formats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Set default date formatting, currency indicators, and number separators.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Date Format',
                  value: _selectedDateFormat,
                  icon: Icons.calendar_today_outlined,
                  items: const ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'],
                  onChanged: (v) => setState(() => _selectedDateFormat = v!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Currency',
                  value: _selectedCurrency,
                  icon: Icons.attach_money_rounded,
                  items: const ['USD (\$)', 'INR (₹)', 'EUR (€)', 'GBP (£)'],
                  onChanged: (v) => setState(() => _selectedCurrency = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.preview_rounded, size: 18, color: Color(0xFF2563EB)),
                const SizedBox(width: 10),
                Text(
                  'Format Preview: ${_selectedDateFormat == 'DD/MM/YYYY' ? '11/09/2026' : _selectedDateFormat == 'YYYY-MM-DD' ? '2026-09-11' : '09/11/2026'} • ${_selectedCurrency.contains('INR') ? '₹ 4,500.00' : _selectedCurrency.contains('EUR') ? '€ 4.500,00' : '\$ 4,500.00'}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─ Sub-Section 4: Branding ─
  Widget _buildBrandingForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Brand Identity & Portal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Configure custom portal subdomain, primary theme colors, and email signatures.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          _buildFormField(
            label: 'Custom Portal Subdomain',
            controller: _portalSubdomainCtrl,
            icon: Icons.domain_rounded,
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Brand Tagline',
            controller: _taglineCtrl,
            icon: Icons.short_text_rounded,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showLogoCustomizerDialog,
            icon: const Icon(Icons.palette_rounded, size: 16, color: Colors.white),
            label: const Text('Open Logo & Brand Color Studio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ─ Right Column: Organization Logo & Preview Cards ─
  Widget _buildRightSidebar() {
    return Column(
      children: [
        // Card 1: Organization Logo Upload Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Organization Logo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Active', style: TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _showLogoCustomizerDialog,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedBrandColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.file_upload_outlined, color: _selectedBrandColor, size: 24),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Upload Logo',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _selectedBrandColor),
                      ),
                      const SizedBox(height: 4),
                      const Text('PNG, JPG or SVG (max 2MB)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Click to customize', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Card 2: Preview Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Preview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    InkWell(
                      onTap: _showLogoCustomizerDialog,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: _selectedBrandColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedBrandColor.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: (_brandLogoType == 'image' && _customLogoUrl.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    _customLogoUrl,
                                    fit: BoxFit.cover,
                                    width: 58,
                                    height: 58,
                                    errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image_rounded, color: Colors.white, size: 28),
                                  ),
                                )
                              : Icon(_selectedLogoIcon, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _orgNameCtrl.text.isEmpty ? 'Acme SaaS Corp' : _orgNameCtrl.text,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _taglineCtrl.text.isEmpty ? 'Support Made Simple' : _taglineCtrl.text,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showLogoCustomizerDialog,
                  icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF2563EB)),
                  label: const Text('Change Logo', style: TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    backgroundColor: const Color(0xFFEFF6FF),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SLA POLICIES TAB
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSlaPoliciesView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Service Level Agreements (SLA)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Define response and resolution targets based on ticket priority tier.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showEditSlaDialog(_slas.first);
                },
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: const Text('New SLA Policy', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._slas.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (s['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(s['priority'] as String, style: TextStyle(color: s['color'] as Color, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                const SizedBox(width: 24),
                Text('First Response: ${s['first']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                const SizedBox(width: 24),
                Text('Target Resolution: ${s['resolution']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _showEditSlaDialog(s),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit Target', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CHANNELS & INTEGRATIONS TAB
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildIntegrationsView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Omnichannel & Third-Party Integrations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Connect your communication channels and external developer webhooks.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showIntegrationConfigDialog(_integrations.last);
                },
                icon: const Icon(Icons.add_link_rounded, size: 16, color: Colors.white),
                label: const Text('Add Integration', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._integrations.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                  child: Icon(item['icon'] as IconData, color: const Color(0xFF2563EB), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text(item['sub'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      if ((item['config'] as String).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Target: ${item['config']}', style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                (item['connected'] as bool)
                    ? Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                            child: const Text('Connected', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, size: 18, color: Color(0xFF64748B)),
                            onPressed: () => _showIntegrationConfigDialog(item),
                            tooltip: 'Configure',
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () => _showIntegrationConfigDialog(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Connect', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // AI CONFIGURATION TAB
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildAiConfigView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Copilot & Smart Assistance Models', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Tune generative intelligence prompts, automatic sentiment extraction, and canned suggestions.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          _buildDropdownField(
            label: 'Primary LLM Engine',
            value: _selectedLlmEngine,
            icon: Icons.memory_rounded,
            items: const [
              'GPT-4o (Fine-Tuned Customer Support)',
              'Claude 3.5 Sonnet (Anthropic)',
              'Gemini 1.5 Pro (Google)',
            ],
            onChanged: (v) => setState(() => _selectedLlmEngine = v!),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Enable AI Auto-Drafted Replies', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: const Text('Generate context-aware reply drafts using knowledge articles and previous ticket history.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            value: _aiAssistedReplies,
            activeColor: const Color(0xFF2563EB),
            onChanged: (v) => setState(() => _aiAssistedReplies = v),
          ),
          const SizedBox(height: 16),
          Text(
            'AI Confidence Match Threshold: ${(_aiConfidenceThreshold * 100).toInt()}%',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
          ),
          Slider(
            value: _aiConfidenceThreshold,
            min: 0.5,
            max: 0.99,
            divisions: 50,
            activeColor: const Color(0xFF2563EB),
            label: '${(_aiConfidenceThreshold * 100).toInt()}%',
            onChanged: (v) => setState(() => _aiConfidenceThreshold = v),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SECURITY & API KEYS TAB
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSecurityView() {
    final apiKeyCtrl = TextEditingController(text: 'scrm_live_99a8b7c6d5e4f3a2b1c0d9e8');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Security, Two-Factor Authentication & API Tokens', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Manage enterprise encryption keys, SSO authorization, and active REST API tokens.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          _buildFormField(
            label: 'Production Secret API Key',
            controller: apiKeyCtrl,
            icon: Icons.vpn_key_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API Key copied to clipboard!'), backgroundColor: Color(0xFF10B981), behavior: SnackBarBehavior.floating),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                label: const Text('Copy API Key', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New Secret Token regenerated!'), backgroundColor: Color(0xFF10B981), behavior: SnackBarBehavior.floating),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Roll / Regenerate Key', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SHARED FORM FIELD HELPERS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: items.contains(value) ? value : items.first,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF94A3B8)),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                    items: items.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
