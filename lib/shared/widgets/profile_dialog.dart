import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../services/user_profile_service.dart';

void showUserProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => const _ProfileModalDialog(),
  );
}

class _ProfileModalDialog extends StatefulWidget {
  const _ProfileModalDialog();

  @override
  State<_ProfileModalDialog> createState() => _ProfileModalDialogState();
}

class _ProfileModalDialogState extends State<_ProfileModalDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _deptCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: userProfileService.name);
    _emailCtrl = TextEditingController(text: userProfileService.email);
    _roleCtrl = TextEditingController(text: userProfileService.role);
    _deptCtrl = TextEditingController(text: userProfileService.department);
    userProfileService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    userProfileService.removeListener(_onServiceUpdate);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _roleCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 680),
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_circle_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Admin Profile & Avatar', style: AppTypography.h4),
                        const SizedBox(height: 2),
                        Text('Update your display picture, identity and support bio',
                            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.neutral400),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar preview & upload banner
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: userProfileService.avatarBytes != null
                                ? Image.memory(userProfileService.avatarBytes!, fit: BoxFit.cover)
                                : (userProfileService.avatarUrl != null
                                    ? Image.network(
                                        userProfileService.avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Text('AP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                                        ),
                                      )
                                    : const Center(
                                        child: Text('AP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                                      )),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () async {
                              await userProfileService.pickImageFromGallery();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await userProfileService.pickImageFromGallery();
                      },
                      icon: const Icon(Icons.upload_file_rounded, size: 16),
                      label: const Text('Upload Photo from Computer / Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primarySurface,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Preset Avatars Gallery
              Text('Or choose a preset avatar:', style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700, color: AppColors.neutral600)),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: userProfileService.presetAvatars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final url = userProfileService.presetAvatars[i];
                    final isSelected = userProfileService.avatarUrl == url && userProfileService.avatarBytes == null;
                    return GestureDetector(
                      onTap: () => userProfileService.selectPresetAvatar(url),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.person),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Form fields
              _buildField('Full Name', _nameCtrl, Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _buildField('Email Address', _emailCtrl, Icons.email_outlined),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildField('Role', _roleCtrl, Icons.security_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('Department', _deptCtrl, Icons.business_rounded)),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      userProfileService.updateProfile(
                        newName: _nameCtrl.text,
                        newEmail: _emailCtrl.text,
                        newRole: _roleCtrl.text,
                        newDept: _deptCtrl.text,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile & Avatar updated successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save Profile Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmSemiBold),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.neutral400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
