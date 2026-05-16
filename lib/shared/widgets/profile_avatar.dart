import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/user_profile.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.profile,
    super.key,
    this.radius = 26,
  });

  final UserProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final path = profile.avatarPath;
    if (path == null || path.trim().isEmpty) {
      return _LetterAvatar(profile: profile, radius: radius);
    }

    final size = radius * 2;
    return ClipOval(
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _LetterAvatar(profile: profile, radius: radius);
        },
      ),
    );
  }
}

class _LetterAvatar extends StatelessWidget {
  const _LetterAvatar({required this.profile, required this.radius});

  final UserProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: DreamColors.primaryLight,
      child: Text(
        profile.initial,
        style: TextStyle(
          color: DreamColors.textPrimary,
          fontSize: radius * 0.78,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
