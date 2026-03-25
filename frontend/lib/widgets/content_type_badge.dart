import 'package:flutter/material.dart';
import '../models/item.dart';
import '../theme/app_theme.dart';

class ContentTypeBadge extends StatelessWidget {
  const ContentTypeBadge({super.key, required this.type, this.small = false});

  final ContentType type;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = _data(type);
    final fontSize = small ? 10.0 : 12.0;
    final iconSize = small ? 11.0 : 13.0;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8, vertical: small ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.2)),
        ],
      ),
    );
  }

  static (String, IconData, Color) _data(ContentType type) => switch (type) {
        ContentType.youtube => ('YouTube', Icons.play_circle_outline_rounded, AppColors.youtube),
        ContentType.instagram => ('Instagram', Icons.camera_alt_outlined, AppColors.instagram),
        ContentType.linkedin => ('LinkedIn', Icons.work_outline_rounded, AppColors.linkedin),
        ContentType.github => ('GitHub', Icons.code_rounded, AppColors.github),
        ContentType.facebook => ('Facebook', Icons.people_outline_rounded, AppColors.facebook),
        ContentType.tiktok => ('TikTok', Icons.music_note_outlined, AppColors.tiktok),
        ContentType.reddit => ('Reddit', Icons.forum_outlined, AppColors.reddit),
        ContentType.other => ('Other', Icons.link_rounded, AppColors.other),
      };

  static Color colorFor(ContentType type) => _data(type).$3;
}
