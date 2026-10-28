import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';

import '../../domain/entities/user.dart';
import '../helpers/user_display.dart';

class UserAvatar extends StatelessWidget {
  static const _largeRadius = 32.0;

  final User? user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final user = this.user;
    final photoUrl = user?.photoUrl;
    final initialStyle = radius >= _largeRadius
        ? textTheme.headlineMedium
        : textTheme.titleMedium;

    return CircleAvatar(
      radius: radius,
      backgroundColor: palette.brandFill,
      foregroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      child: user != null
          ? Text(
              userInitial(user),
              style: initialStyle?.copyWith(color: palette.onBrandFill),
            )
          : Icon(PiconsRegular.user, color: palette.onBrandFill),
    );
  }
}
