import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import 'member_avatar.dart';

class MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback onTap;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVacant = member.nameEn.isEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: isVacant ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Avatar(member: member, isVacant: isVacant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isVacant ? '(Vacant Position)' : member.nameEn,
                            style: AppTextStyles.headingMedium.copyWith(
                              color: isVacant
                                  ? AppColors.grey50
                                  : AppColors.black,
                              fontStyle: isVacant
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (member.isAdminRole) _Badge(label: 'ADMIN', color: AppColors.error),
                        if (member.status == MemberStatus.inactive &&
                            member.inactiveReason != null)
                          _Badge(label: 'ON LEAVE', color: Colors.orange),
                        if (!member.isAvailable && !isVacant)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.event_busy, size: 16, color: Colors.orange),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.rankNameEn,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          member.memberNo,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isVacant) _StatusDot(status: member.status),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey50),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Member member;
  final bool isVacant;
  const _Avatar({required this.member, required this.isVacant});

  @override
  Widget build(BuildContext context) {
    if (isVacant) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.grey50.withValues(alpha: 0.3),
        child: const Icon(Icons.person_outline, color: AppColors.grey50),
      );
    }
    return MemberAvatar(member: member, size: 48);
  }
}

class _StatusDot extends StatelessWidget {
  final MemberStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MemberStatus.active => Colors.green,
      MemberStatus.inactive => Colors.grey,
      MemberStatus.suspended => Colors.orange,
      MemberStatus.dismissed => Colors.red,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}