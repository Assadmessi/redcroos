// ─────────────────────────────────────────────────────────────
// ROUTE CONSTANTS
// ─────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String splash        = '/';
  static const String login         = '/login';
  static const String dashboard     = '/dashboard';
  static const String members       = '/members';
  static const String memberDetail  = '/members/:id';
  static const String memberAdd     = '/members/add';
  static const String memberEdit    = '/members/:id/edit';
  static const String duties        = '/duties';
  static const String dutyDetail    = '/duties/:id';
  static const String dutyAdd       = '/duties/add';
  static const String dutyReport    = '/duties/:id/report';
  static const String myDuties      = '/duties/mine';
  static const String mySchedule    = '/duties/schedule';
  static const String events        = '/events';
  static const String eventDetail   = '/events/:id';
  static const String eventAdd      = '/events/add';
  static const String eventMap      = '/events/:id/map';
  static const String meetings      = '/meetings';
  static const String meetingDetail = '/meetings/:id';
  static const String meetingAdd    = '/meetings/add';
  static const String classes       = '/classes';
  static const String classDetail   = '/classes/:id';
  static const String classAdd      = '/classes/add';
  static const String classBudget   = '/classes/:id/budget';
  static const String dispatch      = '/classes/dispatch';
  static const String blood         = '/blood';
  static const String bloodSearch   = '/blood/search';
  static const String donorDetail   = '/blood/:id';
  static const String reports       = '/reports';
  static const String investigations     = '/investigations';
  static const String investigationDetail = '/investigations/:id';
  static const String punishments       = '/punishments';
  static const String punishmentDetail  = '/punishments/:id';
  static const String youth            = '/youth';
  static const String library          = '/library';
  static const String certificates     = '/certificates';
  static const String serviceBook      = '/service-book/:memberId';
  static const String fund             = '/fund';
  static const String equipment        = '/equipment';
  static const String archive          = '/archive';
  static const String settings         = '/settings';
}

// ─────────────────────────────────────────────────────────────
// APP STRINGS
// ─────────────────────────────────────────────────────────────
class AppStrings {
  AppStrings._();

  static const String appName        = 'Botahtaung Red Cross Brigade';
  static const String appNameMM      = 'ဗိုလ်တထောင် ကြက်ခြေနီ တပ်ဖွဲ့';
  static const String appTagline     = 'Brigade Management System';
  static const String appTaglineMM   = 'တပ်ဖွဲ့ စီမံခန့်ခွဲမှု စနစ်';
  static const String organization   = 'Myanmar Red Cross Society';
  static const String organizationMM = 'မြန်မာနိုင်ငံကြက်ခြေနီအသင်း';

  // Auth
  static const String login          = 'Sign In';
  static const String loginMM        = 'ဝင်ရောက်ရန်';
  static const String logout         = 'Sign Out';
  static const String logoutMM       = 'ထွက်ရန်';

  // Nav labels
  static const String dashboard      = 'Dashboard';
  static const String dashboardMM    = 'ဒက်ရှ်ဘုတ်';
  static const String members        = 'Members';
  static const String membersMM      = 'အဖွဲ့ဝင်များ';
  static const String duties         = 'Duties';
  static const String dutiesMM       = 'တာဝန်များ';
  static const String meetings       = 'Meetings';
  static const String meetingsMM     = 'အစည်းအဝေးများ';
  static const String classes        = 'Classes';
  static const String classesMM      = 'သင်တန်းများ';
  static const String blood          = 'Blood Donations';
  static const String bloodMM        = 'သွေးလှူဒါန်းမှု';
  static const String reports        = 'Reports';
  static const String reportsMM      = 'အစီရင်ခံစာများ';
  static const String investigations = 'Investigations';
  static const String investigationsMM = 'စုံစမ်းစစ်ဆေးမှု';
  static const String punishments    = 'Punishments';
  static const String punishmentsMM  = 'ဒဏ်ခတ်မှုများ';
  static const String youth          = 'Youth Wing';
  static const String youthMM        = 'လူငယ်အဖွဲ့';
  static const String library        = 'Library';
  static const String libraryMM      = 'စာကြည့်တိုက်';
  static const String certificates   = 'Certificates';
  static const String certificatesMM = 'လက်မှတ်များ';
  static const String fund           = 'Fund Ledger';
  static const String fundMM         = 'ရန်ပုံငွေ';
  static const String equipment      = 'Equipment';
  static const String equipmentMM    = 'ပစ္စည်းများ';
  static const String archive        = 'Archive';
  static const String archiveMM      = 'မှတ်တမ်း';
  static const String settings       = 'Settings';
  static const String settingsMM     = 'ဆက်တင်';

  // Common
  static const String save           = 'Save';
  static const String cancel         = 'Cancel';
  static const String delete         = 'Delete';
  static const String edit           = 'Edit';
  static const String add            = 'Add';
  static const String approve        = 'Approve';
  static const String reject         = 'Reject';
  static const String submit         = 'Submit';
  static const String confirm        = 'Confirm';
  static const String search         = 'Search...';
  static const String exportPdf      = 'Export PDF';
  static const String exportExcel    = 'Export Excel';

  // Error
  static const String errorGeneral      = 'Something went wrong. Please try again.';
  static const String errorNetwork      = 'No internet connection. Working offline.';
  static const String errorUnauthorized = 'You do not have permission to view this.';
  static const String errorRequired     = 'This field is required.';
}

// ─────────────────────────────────────────────────────────────
// LANGUAGE
// ─────────────────────────────────────────────────────────────
enum AppLanguage { english, burmese }

// ─────────────────────────────────────────────────────────────
// RANKS
// Full rank system for Botahtaung Red Cross Brigade
// ─────────────────────────────────────────────────────────────
enum MemberRank {
  // ── Officer Ranks (အရာရှိများ) ──
  brigadeCommander,
  deputyBrigadeCommander,
  companyCommander,
  deputyCompanyCommander,
  platoonLeader,

  // ── Other Ranks (အခြားအဆင့်များ) ──
  warrantOfficer,
  sergeantClerk,
  companySergeantMajor,
  platoonSergeant,
  sectionLeader,
  deputySectionLeader,
  private,
}

// Chairperson is a special external role
enum ChairpersonRole { chairperson }

// ─────────────────────────────────────────────────────────────
// UNIT TYPES
// ─────────────────────────────────────────────────────────────
enum UnitType {
  brigadeOffice,
  companyOffice,
  platoonOffice,
  company,
  platoon,
  section,
}

// ─────────────────────────────────────────────────────────────
// APP ROLE (simplified for permission checks)
// ─────────────────────────────────────────────────────────────
enum AppRole {
  chairperson,
  masterAccess,
  brigadeOffice,
  officerField,
  otherRankField,
  private,
}

// ─────────────────────────────────────────────────────────────
// UNIT SCOPE (for permission checks)
// ─────────────────────────────────────────────────────────────
enum UnitScope {
  brigadWide,
  companyWide,
  platoonWide,
  sectionWide,
  ownOnly,
}

// ─────────────────────────────────────────────────────────────
// MEMBER STATUS
// ─────────────────────────────────────────────────────────────
enum MemberStatus { active, inactive, suspended, dismissed }

// ─────────────────────────────────────────────────────────────
// MODULE 4 ADDITIONS — Gender + Membership Type
// ─────────────────────────────────────────────────────────────
enum Gender { male, female }

/// Probation flow: သာမန်အသင်းဝင် (RCOM) → တပ်ဖွဲ့ဝင်အသင်းဝင် (RCBM)
enum MembershipType {
  pendingApplication, // form submitted, not yet approved
  probationer,        // သာမန်အသင်းဝင် — RCOM approved, သမ number assigned
  official,           // တပ်ဖွဲ့ဝင် — RCBM approved, တဖ number assigned
}

extension MembershipTypeDisplay on MembershipType {
  String get nameEn {
    switch (this) {
      case MembershipType.pendingApplication: return 'Pending Application';
      case MembershipType.probationer: return 'Probationer';
      case MembershipType.official: return 'Official Member';
    }
  }

  String get nameMm {
    switch (this) {
      case MembershipType.pendingApplication: return 'လျှောက်ထားဆဲ';
      case MembershipType.probationer: return 'သာမန်အသင်းဝင်';
      case MembershipType.official: return 'တပ်ဖွဲ့ဝင်';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// DUTY ENUMS
// ─────────────────────────────────────────────────────────────
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

enum DutyScale {
  regular,
  largeScale,
}

enum DutyStatus { upcoming, ongoing, completed, cancelled }

enum DutyAssignmentStatus { pending, accepted, rejected, completed }

enum DutyRoleInDuty {
  commander,
  officer,
  member,
}

enum AvailabilityStatus { free, busy, maybe, notSet }

// ─────────────────────────────────────────────────────────────
// MODULE 5 ADDITIONS — Calendar day-level availability status
// Deliberately a SEPARATE enum from AvailabilityStatus above, which
// is used for duty-response style free/busy/maybe and is unrelated.
// This one represents a single calendar day's status on a member's
// monthly availability calendar.
// ─────────────────────────────────────────────────────────────
enum DayAvailabilityStatus { available, notAvailable, onLeave }

// ─────────────────────────────────────────────────────────────
// EVENT POSITION TYPES
// ─────────────────────────────────────────────────────────────
enum EventPositionType { base, point, patrol, standby, command, liaison }

// ─────────────────────────────────────────────────────────────
// MEETING ENUMS
// ─────────────────────────────────────────────────────────────
enum MeetingType {
  general,
  officer,
  committee,
  investigation,
  youthLeaders,
  youthGroup,
  custom,
}

enum MeetingStatus {
  scheduled,
  inProgress,
  minutesDrafted,
  signed,
  published,
}

// ─────────────────────────────────────────────────────────────
// CLASS ENUMS
// ─────────────────────────────────────────────────────────────
enum ClassType { classRoom, workshop, seminar, drill, other }

enum ClassStatus { draft, open, full, ongoing, completed, archived }

// ─────────────────────────────────────────────────────────────
// INVESTIGATION ENUMS
// ─────────────────────────────────────────────────────────────
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

enum InvestigationMemberRole {
  committee,
  accused,
  witness,
  appealCommittee,
}

// ─────────────────────────────────────────────────────────────
// PUNISHMENT ENUMS
// ─────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────
// BLOOD DONATION ENUMS
// ─────────────────────────────────────────────────────────────
enum BloodType { OP, OM, AP, AM, BP, BM, ABP, ABM }

enum DonorType { internal, external }

enum DonationSource { organization, selfReported, priorManual }

// ─────────────────────────────────────────────────────────────
// TRANSFER ENUMS
// ─────────────────────────────────────────────────────────────
enum TransferType { promotion, demotion, transfer, reinstatement }

// ─────────────────────────────────────────────────────────────
// FINANCIAL ENUMS
// ─────────────────────────────────────────────────────────────
enum FundingSource { organizationFund, externalGrant, jointFunding, custom }

enum ExpenseStatus { pending, approved, rejected }

enum PaymentStatus { unpaid, initiated, paid, verified }

enum ReimbursementStatus { claimed, underReview, approved, reimbursed, rejected }

// ─────────────────────────────────────────────────────────────
// NOTIFICATION ENUMS
// ─────────────────────────────────────────────────────────────
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
  standby,
  availability,
}

enum NotificationPriority { normal, high, emergency }

// ─────────────────────────────────────────────────────────────
// YOUTH WING ENUMS
// ─────────────────────────────────────────────────────────────
enum YouthGroup {
  firstAid,
  disasterManagement,
  bloodDonations,
  infoAndCommunications,
  youthGroup,
}

enum YouthGroupRole { leader, member }

// ─────────────────────────────────────────────────────────────
// ARCHIVE VISIBILITY
// ─────────────────────────────────────────────────────────────
enum ArchiveVisibility {
  defaultAccess,
  brigadeOfficeOnly,
  specificRanks,
  custom,
}

// ─────────────────────────────────────────────────────────────
// SIGNATURE STATUS
// ─────────────────────────────────────────────────────────────
enum SignatureStatus { pending, signed }

// ─────────────────────────────────────────────────────────────
// REPORT STATUS
// ─────────────────────────────────────────────────────────────
enum ReportStatus { draft, underReview, finalized, published }

// ─────────────────────────────────────────────────────────────
// DISPATCH STATUS
// ─────────────────────────────────────────────────────────────
enum DispatchStatus {
  created,
  membersSelected,
  confirmed,
  dispatched,
  returned,
}

// ─────────────────────────────────────────────────────────────
// RANK DISPLAY HELPERS
// ─────────────────────────────────────────────────────────────
class RankHelper {
  RankHelper._();

  static String nameEn(MemberRank rank) {
    switch (rank) {
      case MemberRank.brigadeCommander:       return 'Brigade Commander';
      case MemberRank.deputyBrigadeCommander: return 'Deputy Brigade Commander';
      case MemberRank.companyCommander:       return 'Company Commander';
      case MemberRank.deputyCompanyCommander: return 'Deputy Company Commander';
      case MemberRank.platoonLeader:          return 'Platoon Leader';
      case MemberRank.warrantOfficer:         return 'Warrant Officer';
      case MemberRank.sergeantClerk:          return 'Sergeant Clerk';
      case MemberRank.companySergeantMajor:   return 'Company Sergeant Major';
      case MemberRank.platoonSergeant:        return 'Platoon Sergeant';
      case MemberRank.sectionLeader:          return 'Section Leader';
      case MemberRank.deputySectionLeader:    return 'Deputy Section Leader';
      case MemberRank.private:                return 'Private';
    }
  }

  static String nameMm(MemberRank rank) {
    switch (rank) {
      case MemberRank.brigadeCommander:       return 'မြို့နယ်တပ်ဖွဲ့မှူး';
      case MemberRank.deputyBrigadeCommander: return 'ဒုတိယမြို့နယ်တပ်ဖွဲ့မှူး';
      case MemberRank.companyCommander:       return 'တပ်ခွဲမှူး';
      case MemberRank.deputyCompanyCommander: return 'ဒုတိယတပ်ခွဲမှူး';
      case MemberRank.platoonLeader:          return 'တပ်စုမှူး';
      case MemberRank.warrantOfficer:         return 'အရာခံဗိုလ်';
      case MemberRank.sergeantClerk:          return 'တပ်ကြပ်ကြီးစာရေး';
      case MemberRank.companySergeantMajor:   return 'တပ်ခွဲတပ်ကြပ်ကြီး';
      case MemberRank.platoonSergeant:        return 'တပ်စုတပ်ကြပ်ကြီး';
      case MemberRank.sectionLeader:          return 'တပ်စိတ်မှူး';
      case MemberRank.deputySectionLeader:    return 'ဒုတပ်စိတ်မှူး';
      case MemberRank.private:                return 'ကြက်ခြေနီတပ်သား';
    }
  }

  static bool isOfficerRank(MemberRank rank) {
    return [
      MemberRank.brigadeCommander,
      MemberRank.deputyBrigadeCommander,
      MemberRank.companyCommander,
      MemberRank.deputyCompanyCommander,
      MemberRank.platoonLeader,
    ].contains(rank);
  }

  static int rankOrder(MemberRank rank) {
    switch (rank) {
      case MemberRank.brigadeCommander:       return 1;
      case MemberRank.deputyBrigadeCommander: return 2;
      case MemberRank.companyCommander:       return 3;
      case MemberRank.deputyCompanyCommander: return 4;
      case MemberRank.platoonLeader:          return 5;
      case MemberRank.warrantOfficer:         return 6;
      case MemberRank.sergeantClerk:          return 7;
      case MemberRank.companySergeantMajor:   return 8;
      case MemberRank.platoonSergeant:        return 9;
      case MemberRank.sectionLeader:          return 10;
      case MemberRank.deputySectionLeader:    return 11;
      case MemberRank.private:                return 12;
    }
  }

  /// Returns true if rankA is higher than rankB
  static bool isHigherThan(MemberRank rankA, MemberRank rankB) {
    return rankOrder(rankA) < rankOrder(rankB);
  }
}

// Legacy UserRole kept for backward compatibility
enum UserRole {
  admin,
  topBrass,
  seniorOfficer,
  officer,
  dutyOfficer,
  member,
}