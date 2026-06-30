import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../../../core/theme/app_theme.dart';

/// Shows a member's photo if `photoUrl` is set, otherwise a generic
/// person-silhouette placeholder — used everywhere a member's photo
/// appears (list rows, ID card, detail screen) so there's one
/// consistent placeholder rather than colored initials in some
/// places and something else elsewhere. `photoUrl` is the single
/// source of truth; every call site should read it from the same
/// Member object, never a separate image source.
class MemberAvatar extends StatelessWidget {
  final Member member;
  final double size; // used as both width and height unless overridden below
  final double? width;
  final double? height;
  final BoxShape shape;
  final BorderRadius? borderRadius; // only used when shape == rectangle
  final Border? border;

  const MemberAvatar({
    super.key,
    required this.member,
    this.size = 40,
    this.width,
    this.height,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = member.photoUrl != null && member.photoUrl!.isNotEmpty;
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;
    final effectiveBorderRadius = shape == BoxShape.rectangle
        ? (borderRadius ?? BorderRadius.circular(6))
        : null;

    final placeholder = Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: AppColors.grey50.withValues(alpha: 0.3),
        shape: shape,
        borderRadius: effectiveBorderRadius,
        border: border,
      ),
      child: Icon(
        Icons.person,
        size: (effectiveWidth < effectiveHeight ? effectiveWidth : effectiveHeight) * 0.6,
        color: AppColors.grey500,
      ),
    );

    if (!hasPhoto) return placeholder;

    final clipRadius = shape == BoxShape.circle
        ? BorderRadius.circular(effectiveWidth / 2)
        : (effectiveBorderRadius ?? BorderRadius.zero);

    return Container(
      decoration: BoxDecoration(shape: shape, borderRadius: effectiveBorderRadius, border: border),
      child: ClipRRect(
        borderRadius: clipRadius,
        child: Image.network(
          member.photoUrl!,
          width: effectiveWidth,
          height: effectiveHeight,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => placeholder,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: effectiveWidth,
              height: effectiveHeight,
              child: Center(
                child: SizedBox(
                  width: (effectiveWidth < effectiveHeight ? effectiveWidth : effectiveHeight) * 0.4,
                  height: (effectiveWidth < effectiveHeight ? effectiveWidth : effectiveHeight) * 0.4,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}