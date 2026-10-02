import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  String name = 'Akash Pandey';
  String email = 'akash.pandey@supportcrm.app';
  String role = 'Admin';
  String department = 'Support Engineering';
  String? avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80';
  Uint8List? avatarBytes;

  final List<String> presetAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
  ];

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400, imageQuality: 85);
    if (image != null) {
      avatarBytes = await image.readAsBytes();
      avatarUrl = null;
      notifyListeners();
    }
  }

  void selectPresetAvatar(String url) {
    avatarUrl = url;
    avatarBytes = null;
    notifyListeners();
  }

  void updateProfile({required String newName, required String newEmail, required String newRole, required String newDept}) {
    name = newName;
    email = newEmail;
    role = newRole;
    department = newDept;
    notifyListeners();
  }
}

final userProfileService = UserProfileService();
