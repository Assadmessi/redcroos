import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
// DATE & TIME FORMATTERS
// ─────────────────────────────────────────────
class AppFormatters {
  AppFormatters._();

  static String date(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  static String dateShort(DateTime date) => DateFormat('dd MMM').format(date);
  static String dateTime(DateTime date) => DateFormat('dd MMM yyyy, HH:mm').format(date);
  static String monthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);
  static String time(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  static String timeRange(int sh, int sm, int? eh, int? em) =>
      (eh != null && em != null) ? '${time(sh, sm)} — ${time(eh, em)}' : time(sh, sm);
  static String dayOfWeek(DateTime date) => DateFormat('EEEE').format(date);
  static String fullDate(DateTime date) => DateFormat('EEEE, dd MMMM yyyy').format(date);
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return AppFormatters.date(date);
  }

  static String currency(double amount) =>
      '${NumberFormat('#,##0', 'en_US').format(amount)} MMK';

  static String number(int n) => NumberFormat('#,##0').format(n);
}

// ─────────────────────────────────────────────
// STATUS HELPERS
// ─────────────────────────────────────────────
class AppStatusHelper {
  AppStatusHelper._();

  static Color memberStatusColor(MemberStatus s) {
    switch (s) {
      case MemberStatus.active: return AppColors.success;
      case MemberStatus.inactive: return AppColors.grey600;
      case MemberStatus.suspended: return AppColors.warning;
      case MemberStatus.dismissed: return AppColors.error;
    }
  }

  static String memberStatusLabel(MemberStatus s) {
    switch (s) {
      case MemberStatus.active: return 'Active';
      case MemberStatus.inactive: return 'Inactive';
      case MemberStatus.suspended: return 'Suspended';
      case MemberStatus.dismissed: return 'Dismissed';
    }
  }

  static Color dutyStatusColor(DutyStatus s) {
    switch (s) {
      case DutyStatus.upcoming: return AppColors.info;
      case DutyStatus.ongoing: return AppColors.warning;
      case DutyStatus.completed: return AppColors.success;
      case DutyStatus.cancelled: return AppColors.grey600;
    }
  }

  static String dutyStatusLabel(DutyStatus s) {
    switch (s) {
      case DutyStatus.upcoming: return 'Upcoming';
      case DutyStatus.ongoing: return 'Ongoing';
      case DutyStatus.completed: return 'Completed';
      case DutyStatus.cancelled: return 'Cancelled';
    }
  }

  static Color assignmentStatusColor(DutyAssignmentStatus s) {
    switch (s) {
      case DutyAssignmentStatus.pending: return AppColors.warning;
      case DutyAssignmentStatus.accepted: return AppColors.success;
      case DutyAssignmentStatus.rejected: return AppColors.error;
      case DutyAssignmentStatus.completed: return AppColors.grey600;
    }
  }

  static String assignmentStatusLabel(DutyAssignmentStatus s) {
    switch (s) {
      case DutyAssignmentStatus.pending: return 'Pending';
      case DutyAssignmentStatus.accepted: return 'Accepted';
      case DutyAssignmentStatus.rejected: return 'Rejected';
      case DutyAssignmentStatus.completed: return 'Completed';
    }
  }

  static Color classStatusColor(ClassStatus s) {
    switch (s) {
      case ClassStatus.draft: return AppColors.grey600;
      case ClassStatus.open: return AppColors.info;
      case ClassStatus.full: return AppColors.error;
      case ClassStatus.ongoing: return AppColors.warning;
      case ClassStatus.completed: return AppColors.success;
      case ClassStatus.archived: return AppColors.grey500;
    }
  }

  static String classStatusLabel(ClassStatus s) {
    switch (s) {
      case ClassStatus.draft: return 'Draft';
      case ClassStatus.open: return 'Open';
      case ClassStatus.full: return 'Full';
      case ClassStatus.ongoing: return 'Ongoing';
      case ClassStatus.completed: return 'Completed';
      case ClassStatus.archived: return 'Archived';
    }
  }

  static Color meetingStatusColor(MeetingStatus s) {
    switch (s) {
      case MeetingStatus.scheduled: return AppColors.info;
      case MeetingStatus.inProgress: return AppColors.warning;
      case MeetingStatus.minutesDrafted: return AppColors.warning;
      case MeetingStatus.signed: return AppColors.success;
      case MeetingStatus.published: return AppColors.success;
    }
  }

  static String meetingStatusLabel(MeetingStatus s) {
    switch (s) {
      case MeetingStatus.scheduled: return 'Scheduled';
      case MeetingStatus.inProgress: return 'In Progress';
      case MeetingStatus.minutesDrafted: return 'Minutes Draft';
      case MeetingStatus.signed: return 'Signed';
      case MeetingStatus.published: return 'Published';
    }
  }

  static Color availabilityColor(AvailabilityStatus s) {
    switch (s) {
      case AvailabilityStatus.free: return AppColors.success;
      case AvailabilityStatus.busy: return AppColors.error;
      case AvailabilityStatus.maybe: return AppColors.warning;
      case AvailabilityStatus.notSet: return AppColors.grey400;
    }
  }

  static String availabilityLabel(AvailabilityStatus s) {
    switch (s) {
      case AvailabilityStatus.free: return 'Free';
      case AvailabilityStatus.busy: return 'Busy';
      case AvailabilityStatus.maybe: return 'Maybe';
      case AvailabilityStatus.notSet: return 'Not Set';
    }
  }

  static Color notificationTypeColor(NotificationType t) {
    switch (t) {
      case NotificationType.duty: return AppColors.info;
      case NotificationType.meeting: return AppColors.info;
      case NotificationType.classEvent: return AppColors.success;
      case NotificationType.blood: return AppColors.error;
      case NotificationType.task: return AppColors.warning;
      case NotificationType.investigation: return AppColors.warning;
      case NotificationType.punishment: return AppColors.error;
      case NotificationType.system: return AppColors.grey600;
      case NotificationType.emergency: return AppColors.error;
    }
  }

  static IconData notificationTypeIcon(NotificationType t) {
    switch (t) {
      case NotificationType.duty: return Icons.calendar_today_rounded;
      case NotificationType.meeting: return Icons.groups_rounded;
      case NotificationType.classEvent: return Icons.school_rounded;
      case NotificationType.blood: return Icons.bloodtype_rounded;
      case NotificationType.task: return Icons.task_alt_rounded;
      case NotificationType.investigation: return Icons.search_rounded;
      case NotificationType.punishment: return Icons.gavel_rounded;
      case NotificationType.system: return Icons.settings_rounded;
      case NotificationType.emergency: return Icons.emergency_rounded;
    }
  }

  static Color investigationStatusColor(InvestigationStatus s) {
    switch (s) {
      case InvestigationStatus.opened: return AppColors.info;
      case InvestigationStatus.underInvestigation: return AppColors.warning;
      case InvestigationStatus.hearingScheduled: return AppColors.warning;
      case InvestigationStatus.hearingConducted: return AppColors.warning;
      case InvestigationStatus.deliberation: return AppColors.warning;
      case InvestigationStatus.concluded: return AppColors.success;
      case InvestigationStatus.closed: return AppColors.grey600;
      case InvestigationStatus.appealed: return AppColors.error;
      case InvestigationStatus.appealReview: return AppColors.warning;
      case InvestigationStatus.appealConcluded: return AppColors.grey600;
    }
  }

  static String investigationStatusLabel(InvestigationStatus s) {
    switch (s) {
      case InvestigationStatus.opened: return 'Opened';
      case InvestigationStatus.underInvestigation: return 'Under Investigation';
      case InvestigationStatus.hearingScheduled: return 'Hearing Scheduled';
      case InvestigationStatus.hearingConducted: return 'Hearing Conducted';
      case InvestigationStatus.deliberation: return 'Deliberation';
      case InvestigationStatus.concluded: return 'Concluded';
      case InvestigationStatus.closed: return 'Closed';
      case InvestigationStatus.appealed: return 'Appealed';
      case InvestigationStatus.appealReview: return 'Appeal Review';
      case InvestigationStatus.appealConcluded: return 'Appeal Concluded';
    }
  }

  static Color positionTypeColor(EventPositionType t) {
    switch (t) {
      case EventPositionType.base: return AppColors.error;
      case EventPositionType.point: return AppColors.info;
      case EventPositionType.patrol: return AppColors.warning;
      case EventPositionType.standby: return AppColors.success;
      case EventPositionType.command: return AppColors.primary;
      case EventPositionType.liaison: return AppColors.grey600;
    }
  }

  static IconData positionTypeIcon(EventPositionType t) {
    switch (t) {
      case EventPositionType.base: return Icons.local_hospital_rounded;
      case EventPositionType.point: return Icons.location_on_rounded;
      case EventPositionType.patrol: return Icons.directions_walk_rounded;
      case EventPositionType.standby: return Icons.pause_circle_rounded;
      case EventPositionType.command: return Icons.star_rounded;
      case EventPositionType.liaison: return Icons.link_rounded;
    }
  }
}

// ─────────────────────────────────────────────
// AVATAR COLOR GENERATOR
// ─────────────────────────────────────────────
class AvatarColorGen {
  static final List<Color> _colors = [
    const Color(0xFFC8102E),
    const Color(0xFF2B6CB0),
    const Color(0xFF276749),
    const Color(0xFFB7791F),
    const Color(0xFF6B46C1),
    const Color(0xFF2C7A7B),
    const Color(0xFFC05621),
    const Color(0xFF97266D),
  ];

  static Color fromString(String s) {
    final index = s.codeUnits.fold(0, (sum, c) => sum + c) % _colors.length;
    return _colors[index];
  }
}

// ─────────────────────────────────────────────
// RESPONSIVE HELPERS
// ─────────────────────────────────────────────
class AppResponsive {
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static double sidebarWidth(BuildContext context) =>
      isDesktop(context) ? AppDimensions.sidebarWidth : 0;

  static int gridColumns(BuildContext context,
      {int desktop = 4, int tablet = 2, int mobile = 1}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}

// ─────────────────────────────────────────────
// VALIDATORS
// ─────────────────────────────────────────────
class AppValidators {
  AppValidators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    if (value.length < 9) return 'Invalid phone number';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Invalid email address';
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.length < min) {
      return 'Minimum $min characters required';
    }
    return null;
  }
}
