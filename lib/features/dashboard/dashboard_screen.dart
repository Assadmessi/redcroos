import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../auth/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final member = auth.currentMember;
    final isEN = auth.language == AppLanguage.english;
    final isDesktop = AppResponsive.isDesktop(context);

    // Mock data
    final upcomingDuties = MockDuties.all
        .where((d) => d.status == DutyStatus.upcoming)
        .take(3)
        .toList();
    final recentMeetings = MockMeetings.all.take(2).toList();
    final notifications = MockNotifications.forMember(member?.id ?? 'm1')
        .take(5)
        .toList();
    final unreadCount = notifications.where((n) => !n.isRead).length;
    final eligibleDonors =
        MockBloodDonors.all.where((d) => d.isEligible).length;
    final activeCases = MockInvestigations.all
        .where((i) => i.status != InvestigationStatus.closed)
        .length;

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 28 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            _GreetingHeader(member: member, isEN: isEN),
            SizedBox(height: isDesktop ? 24 : 16),

            // Stats grid
            _StatsGrid(
              isDesktop: isDesktop,
              eligibleDonors: eligibleDonors,
              activeCases: activeCases,
              upcomingDuties: upcomingDuties.length,
            ),
            SizedBox(height: isDesktop ? 24 : 16),

            // Main content
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _UpcomingDutiesCard(duties: upcomingDuties, isEN: isEN),
                            const SizedBox(height: 20),
                            _RecentMeetingsCard(meetings: recentMeetings, isEN: isEN),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _NotificationsCard(
                              notifications: notifications,
                              unread: unreadCount,
                              isEN: isEN,
                            ),
                            const SizedBox(height: 20),
                            _QuickActionsCard(isEN: isEN, auth: auth),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _UpcomingDutiesCard(duties: upcomingDuties, isEN: isEN),
                      const SizedBox(height: 16),
                      _NotificationsCard(
                        notifications: notifications,
                        unread: unreadCount,
                        isEN: isEN,
                      ),
                      const SizedBox(height: 16),
                      _RecentMeetingsCard(meetings: recentMeetings, isEN: isEN),
                      const SizedBox(height: 16),
                      _QuickActionsCard(isEN: isEN, auth: auth),
                    ],
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GREETING HEADER
// ─────────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  final dynamic member;
  final bool isEN;

  const _GreetingHeader({required this.member, required this.isEN});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return isEN ? 'Good Morning' : 'မင်္ဂလာနံနက်ခင်းပါ';
    if (hour < 17) return isEN ? 'Good Afternoon' : 'မင်္ဂလာနေ့လည်ခင်းပါ';
    return isEN ? 'Good Evening' : 'မင်္ဂလာညနေခင်းပါ';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greeting()}, ${isEN ? (member?.nameEn ?? '') : (member?.nameMm ?? member?.nameEn ?? '')} 👋',
          style: AppTextStyles.displaySmall.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 4),
        Text(
          isEN
              ? '${AppStrings.appName} — ${AppFormatters.fullDate(DateTime.now())}'
              : '${AppStrings.appNameMM} — ${AppFormatters.fullDate(DateTime.now())}',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// STATS GRID
// ─────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final bool isDesktop;
  final int eligibleDonors;
  final int activeCases;
  final int upcomingDuties;

  const _StatsGrid({
    required this.isDesktop,
    required this.eligibleDonors,
    required this.activeCases,
    required this.upcomingDuties,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData(
        label: 'Total Members',
        labelMm: 'အဖွဲ့ဝင် စုစုပေါင်း',
        value: MockMembers.all.length.toString(),
        sub: '+2 this month',
        icon: Icons.group_rounded,
        color: AppColors.primary,
      ),
      _StatData(
        label: 'Upcoming Duties',
        labelMm: 'လာမည့် တာဝန်များ',
        value: upcomingDuties.toString(),
        sub: '2 pending acceptance',
        icon: Icons.calendar_today_rounded,
        color: AppColors.info,
      ),
      _StatData(
        label: 'Eligible Donors',
        labelMm: 'လှူနိုင်သူများ',
        value: eligibleDonors.toString(),
        sub: 'Ready to donate',
        icon: Icons.bloodtype_rounded,
        color: AppColors.error,
      ),
      _StatData(
        label: 'Active Cases',
        labelMm: 'တက်ကြွသော အမှုများ',
        value: activeCases.toString(),
        sub: 'Under investigation',
        icon: Icons.search_rounded,
        color: AppColors.warning,
      ),
    ];

    final cols = isDesktop ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.8 : 1.1,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => _StatCard(data: stats[i]),
    );
  }
}

class _StatData {
  final String label;
  final String labelMm;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;

  const _StatData({
    required this.label,
    required this.labelMm,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isEN = context.watch<AuthProvider>().language == AppLanguage.english;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  isEN ? data.label : data.labelMm,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.grey600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 18, color: data.color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: AppTextStyles.numeric,
              ),
              Text(
                data.sub,
                style: AppTextStyles.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UPCOMING DUTIES CARD
// ─────────────────────────────────────────────
class _UpcomingDutiesCard extends StatelessWidget {
  final List<Duty> duties;
  final bool isEN;

  const _UpcomingDutiesCard({required this.duties, required this.isEN});

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: isEN ? 'Upcoming Duties' : 'လာမည့် တာဝန်များ',
      actionLabel: isEN ? 'View All' : 'အားလုံးကြည့်',
      onAction: () {},
      child: duties.isEmpty
          ? _EmptyState(
              icon: Icons.calendar_today_rounded,
              message: isEN ? 'No upcoming duties' : 'လာမည့် တာဝန် မရှိပါ',
            )
          : Column(
              children: duties
                  .map((d) => _DutyTile(duty: d, isEN: isEN))
                  .toList(),
            ),
    );
  }
}

class _DutyTile extends StatelessWidget {
  final Duty duty;
  final bool isEN;

  const _DutyTile({required this.duty, required this.isEN});

  Color get _typeColor {
    switch (duty.type) {
      case DutyType.firstAid: return AppColors.error;
      case DutyType.bloodDonation: return AppColors.error;
      case DutyType.training: return AppColors.info;
      case DutyType.eventMedical: return AppColors.warning;
      default: return AppColors.grey600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final assignment = MockDutyAssignments.forDutyAndMember(
        duty.id, auth.currentMember?.id ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          // Date box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppFormatters.dateShort(duty.date).split(' ')[0],
                  style: AppTextStyles.numericSmall.copyWith(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  AppFormatters.dateShort(duty.date).split(' ')[1],
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.primary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEN ? duty.title : duty.titleMm,
                  style: AppTextStyles.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${duty.startTimeDisplay} · ${duty.location}',
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Assignment status
          if (assignment != null)
            _StatusChip(
              label: AppStatusHelper.assignmentStatusLabel(assignment.status),
              color: AppStatusHelper.assignmentStatusColor(assignment.status),
            )
          else
            _StatusChip(
              label: isEN ? 'Upcoming' : 'လာမည်',
              color: AppColors.info,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RECENT MEETINGS CARD
// ─────────────────────────────────────────────
class _RecentMeetingsCard extends StatelessWidget {
  final List<Meeting> meetings;
  final bool isEN;

  const _RecentMeetingsCard({required this.meetings, required this.isEN});

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: isEN ? 'Recent Meetings' : 'မကြာသေးမီ အစည်းအဝေးများ',
      actionLabel: isEN ? 'View All' : 'အားလုံးကြည့်',
      onAction: () {},
      child: Column(
        children: meetings.map((m) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.groups_rounded,
                      size: 20, color: AppColors.info),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEN ? m.title : m.titleMm,
                        style: AppTextStyles.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${m.typeDisplay} · ${AppFormatters.date(m.date)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  label: AppStatusHelper.meetingStatusLabel(m.status),
                  color: AppStatusHelper.meetingStatusColor(m.status),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NOTIFICATIONS CARD
// ─────────────────────────────────────────────
class _NotificationsCard extends StatelessWidget {
  final List<AppNotification> notifications;
  final int unread;
  final bool isEN;

  const _NotificationsCard({
    required this.notifications,
    required this.unread,
    required this.isEN,
  });

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: isEN ? 'Notifications' : 'အကြောင်းကြားချက်',
      badge: unread > 0 ? unread.toString() : null,
      child: notifications.isEmpty
          ? _EmptyState(
              icon: Icons.notifications_outlined,
              message: isEN ? 'No notifications' : 'အကြောင်းကြားချက် မရှိပါ',
            )
          : Column(
              children: notifications
                  .map((n) => _NotificationTile(notif: n))
                  .toList(),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notif;

  const _NotificationTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    final color =
        AppStatusHelper.notificationTypeColor(notif.type);
    return Opacity(
      opacity: notif.isRead ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notif.isRead ? AppColors.grey300 : color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: notif.isRead
                          ? FontWeight.w400
                          : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(notif.body,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.timeAgo(notif.createdAt),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.grey400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QUICK ACTIONS CARD
// ─────────────────────────────────────────────
class _QuickActionsCard extends StatelessWidget {
  final bool isEN;
  final AuthProvider auth;

  const _QuickActionsCard({required this.isEN, required this.auth});

  @override
  Widget build(BuildContext context) {
    final actions = [
      if (auth.canAssignDuties)
        _QuickAction(
          label: isEN ? 'Assign Duty' : 'တာဝန်ပေးရန်',
          icon: Icons.add_task_rounded,
          color: AppColors.info,
        ),
      _QuickAction(
        label: isEN ? 'My Schedule' : 'ကျွန်တော့်ဇယား',
        icon: Icons.event_rounded,
        color: AppColors.success,
      ),
      _QuickAction(
        label: isEN ? 'Blood Search' : 'သွေးရှာဖွေ',
        icon: Icons.bloodtype_rounded,
        color: AppColors.error,
      ),
      if (auth.canAssignDuties)
        _QuickAction(
          label: isEN ? 'New Meeting' : 'အစည်းအဝေးသစ်',
          icon: Icons.add_comment_rounded,
          color: AppColors.warning,
        ),
    ];

    return _DashCard(
      title: isEN ? 'Quick Actions' : 'မြန်ဆန်သောလုပ်ဆောင်ချက်',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: actions
            .map((a) => _QuickActionButton(action: a))
            .toList(),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickAction(
      {required this.label, required this.icon, required this.color});
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: action.color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, size: 16, color: action.color),
            const SizedBox(width: 6),
            Text(
              action.label,
              style: AppTextStyles.labelSmall.copyWith(color: action.color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED CARD WRAPPER
// ─────────────────────────────────────────────
class _DashCard extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? badge;
  final Widget child;

  const _DashCard({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.badge,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.grey200),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTextStyles.headingSmall),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge!,
                      style: AppTextStyles.badge
                          .copyWith(color: AppColors.white)),
                ),
              ],
              const Spacer(),
              if (actionLabel != null && onAction != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(actionLabel!,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primary)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATUS CHIP
// ─────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.grey300),
          const SizedBox(height: 8),
          Text(message,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.grey400)),
        ],
      ),
    );
  }
}
