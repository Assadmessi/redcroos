// ─────────────────────────────────────────────
// ROUTE CONSTANTS
// ─────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String splash        = '/';
  static const String login         = '/login';
  static const String dashboard     = '/dashboard';

  // Members
  static const String members       = '/members';
  static const String memberDetail  = '/members/:id';
  static const String memberAdd     = '/members/add';
  static const String memberEdit    = '/members/:id/edit';

  // Duties
  static const String duties        = '/duties';
  static const String dutyDetail    = '/duties/:id';
  static const String dutyAdd       = '/duties/add';
  static const String dutyReport    = '/duties/:id/report';
  static const String myDuties      = '/duties/mine';
  static const String mySchedule    = '/duties/schedule';

  // Events
  static const String events        = '/events';
  static const String eventDetail   = '/events/:id';
  static const String eventAdd      = '/events/add';
  static const String eventMap      = '/events/:id/map';

  // Meetings
  static const String meetings      = '/meetings';
  static const String meetingDetail = '/meetings/:id';
  static const String meetingAdd    = '/meetings/add';
  static const String meetingMinutes = '/meetings/:id/minutes';

  // Classes
  static const String classes       = '/classes';
  static const String classDetail   = '/classes/:id';
  static const String classAdd      = '/classes/add';
  static const String classBudget   = '/classes/:id/budget';
  static const String classExpenses = '/classes/:id/expenses';
  static const String classClosure  = '/classes/:id/closure';
  static const String dispatch      = '/classes/dispatch';

  // Blood Donations
  static const String blood         = '/blood';
  static const String bloodSearch   = '/blood/search';
  static const String donorDetail   = '/blood/:id';
  static const String donorAdd      = '/blood/add';

  // Reports
  static const String reports       = '/reports';
  static const String reportMonthly = '/reports/monthly';
  static const String reportYearly  = '/reports/yearly';

  // Investigation
  static const String investigations     = '/investigations';
  static const String investigationDetail = '/investigations/:id';
  static const String investigationAdd   = '/investigations/add';

  // Punishment
  static const String punishments       = '/punishments';
  static const String punishmentDetail  = '/punishments/:id';

  // Youth Wing
  static const String youth            = '/youth';
  static const String youthGroup       = '/youth/:group';

  // Library
  static const String library          = '/library';
  static const String libraryDocument  = '/library/:id';

  // Certificates
  static const String certificates     = '/certificates';
  static const String certificateIssue = '/certificates/issue';

  // Service Book
  static const String serviceBook      = '/service-book/:memberId';

  // Fund
  static const String fund             = '/fund';
  static const String fundEntry        = '/fund/entry';

  // Equipment
  static const String equipment        = '/equipment';

  // Archive
  static const String archive          = '/archive';

  // Settings
  static const String settings         = '/settings';
  static const String settingsRoles    = '/settings/roles';
  static const String settingsBackup   = '/settings/backup';
  static const String settingsLanguage = '/settings/language';
}

// ─────────────────────────────────────────────
// APP STRINGS
// ─────────────────────────────────────────────
class AppStrings {
  AppStrings._();

  // App
  static const String appName           = 'Botahtaung Township Red Cross Brigade';
  static const String appNameMM         = 'ဗိုလ်တထောင်မြို့နယ် ကြက်ခြေနီ တပ်ဖွဲ့ခွဲ';
  static const String appTagline        = 'Brigade Management System';
  static const String appTaglineMM      = 'တပ်ဖွဲ့ခွဲ စီမံခန့်ခွဲမှု စနစ်';
  static const String organization      = 'Myanmar Red Cross Society';
  static const String organizationMM    = 'မြန်မာနိုင်ငံကြက်ခြေနီအသင်း';
      // Replace with real branch name MM

  // Auth
  static const String login             = 'Sign In';
  static const String loginMM           = 'ဝင်ရောက်ရန်';
  static const String logout            = 'Sign Out';
  static const String memberIdHint      = 'Member ID';
  static const String passwordHint      = 'Password';
  static const String forgotPassword    = 'Forgot Password?';

  // Nav
  static const String dashboard         = 'Dashboard';
  static const String dashboardMM       = 'ဒက်ရှ်ဘုတ်';
  static const String members           = 'Members';
  static const String membersMM         = 'အဖွဲ့ဝင်များ';
  static const String duties            = 'Duties';
  static const String dutiesMM          = 'တာဝန်များ';
  static const String meetings          = 'Meetings';
  static const String meetingsMM        = 'အစည်းအဝေးများ';
  static const String classes           = 'Classes';
  static const String classesMM         = 'သင်တန်းများ';
  static const String blood             = 'Blood Donations';
  static const String bloodMM           = 'သွေးလှူဒါန်း';
  static const String reports           = 'Reports';
  static const String reportsMM         = 'အစီရင်ခံစာများ';
  static const String investigations    = 'Investigations';
  static const String investigationsMM  = 'စုံစမ်းစစ်ဆေးမှု';
  static const String punishments       = 'Punishments';
  static const String punishmentsMM     = 'ဒဏ်ခတ်မှုများ';
  static const String youth             = 'Youth Wing';
  static const String youthMM          = 'လူငယ်အဖွဲ့';
  static const String library           = 'Library';
  static const String libraryMM         = 'စာကြည့်တိုက်';
  static const String certificates      = 'Certificates';
  static const String certificatesMM    = 'လက်မှတ်များ';
  static const String fund              = 'Fund Ledger';
  static const String fundMM            = 'ရန်ပုံငွေ';
  static const String equipment         = 'Equipment';
  static const String equipmentMM       = 'ပစ္စည်းများ';
  static const String archive           = 'Archive';
  static const String archiveMM         = 'မှတ်တမ်း';
  static const String settings          = 'Settings';
  static const String settingsMM        = 'ဆက်တင်';

  // Common actions
  static const String save              = 'Save';
  static const String cancel            = 'Cancel';
  static const String delete            = 'Delete';
  static const String edit              = 'Edit';
  static const String add               = 'Add';
  static const String view              = 'View';
  static const String print             = 'Print';
  static const String export            = 'Export';
  static const String exportPdf         = 'Export PDF';
  static const String exportExcel       = 'Export Excel';
  static const String search            = 'Search...';
  static const String filter            = 'Filter';
  static const String confirm           = 'Confirm';
  static const String approve           = 'Approve';
  static const String reject            = 'Reject';
  static const String submit            = 'Submit';
  static const String accept            = 'Accept';
  static const String close             = 'Close';
  static const String back              = 'Back';
  static const String next              = 'Next';
  static const String done              = 'Done';
  static const String yes               = 'Yes';
  static const String no                = 'No';

  // Status
  static const String active            = 'Active';
  static const String inactive          = 'Inactive';
  static const String pending           = 'Pending';
  static const String approved          = 'Approved';
  static const String rejected          = 'Rejected';
  static const String completed         = 'Completed';
  static const String draft             = 'Draft';
  static const String published         = 'Published';
  static const String scheduled         = 'Scheduled';
  static const String open              = 'Open';
  static const String closed            = 'Closed';
  static const String eligible          = 'Eligible';
  static const String coolingOff        = 'Cooling Off';
  static const String restricted        = 'Restricted Access';

  // Error messages
  static const String errorGeneral      = 'Something went wrong. Please try again.';
  static const String errorNetwork      = 'No internet connection. Working offline.';
  static const String errorNotFound     = 'Record not found.';
  static const String errorUnauthorized = 'You do not have permission to view this.';
  static const String errorRequired     = 'This field is required.';
}

// ─────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────

enum AppLanguage { english, burmese }

enum UserRole {
  admin,
  topBrass,
  seniorOfficer,
  officer,
  dutyOfficer,
  member,
  // More roles added when ranks are finalized
}

enum MemberStatus { active, inactive, suspended, dismissed }

enum DutyType {
  firstAid,
  bloodDonation,
  training,
  patrol,
  eventMedical,
  disaster,
  administrative,
  other,
}

enum DutyStatus { upcoming, ongoing, completed, cancelled }

enum DutyAssignmentStatus { pending, accepted, rejected, completed }

enum MeetingType {
  general,
  officer,
  committee,
  investigation,
  youthLeaders,
  youthGroup,
  custom,
}

enum MeetingStatus { scheduled, inProgress, minutesDrafted, signed, published }

enum ClassType { classRoom, workshop, seminar, drill, other }

enum ClassStatus { draft, open, full, ongoing, completed, archived }

enum InvestigationStatus {
  opened,
  underInvestigation,
  hearingScheduled,
  hearingConducted,
  deliberation,
  concluded,
  closed,
  appealed,
  appealReview,
  appealConcluded,
}

enum PunishmentType {
  verbalWarning,
  writtenWarning,
  fine,
  suspension,
  demotion,
  dismissal,
  other,
}

enum PunishmentStatus { active, completed, lifted, underAppeal, overturned }

enum BloodType { OP, OM, AP, AM, BP, BM, ABP, ABM }

enum DonorType { internal, external }

enum DonationSource { organization, selfReported, priorManual }

enum AvailabilityStatus { free, busy, maybe, notSet }

enum EventPositionType { base, point, patrol, standby, command, liaison }

enum FundingSource { organizationFund, externalGrant, jointFunding, custom }

enum ExpenseStatus { pending, approved, rejected }

enum PaymentStatus { unpaid, initiated, paid, verified }

enum ReimbursementStatus { claimed, underReview, approved, reimbursed, rejected }

enum DocumentType { report, minutes, certificate, serviceBook, other }

enum YouthGroup {
  firstAid,
  disasterManagement,
  bloodDonations,
  infoAndCommunications,
  youthGroup,
}

enum TransferType { promotion, demotion, transfer, reinstatement }

enum SignatureStatus { pending, signed }

enum NotificationType {
  duty,
  meeting,
  classEvent,
  blood,
  task,
  investigation,
  punishment,
  system,
  emergency,
}

enum NotificationPriority { normal, high, emergency }
