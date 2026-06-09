// ─────────────────────────────────────────────
// ROUTE CONSTANTS
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// APP STRINGS
// ─────────────────────────────────────────────
class AppStrings {
  AppStrings._();

  static const String appName        = 'Botahtaung Red Cross Brigade';
  static const String appNameMM      = 'ဗိုလ်တထောင် ကြက်ခြေနီ တပ်ခွဲ';
  static const String appTagline     = 'Brigade Management System';
  static const String appTaglineMM   = 'တပ်ခွဲ စီမံခန့်ခွဲမှု စနစ်';
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
  static const String bloodMM        = 'သွေးလှူဒါန်း';
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

// ─────────────────────────────────────────────
// LANGUAGE
// ─────────────────────────────────────────────
enum AppLanguage { english, burmese }

// ─────────────────────────────────────────────
// RANKS
// Full rank system for Botahtaung Red Cross Brigade
// ─────────────────────────────────────────────
enum MemberRank {
  // ─── Officer Ranks (အရာရှိများ) ───────────
  brigadeCommander,        // မြို့နယ်တပ်ဖွဲ့မှူး
  deputyBrigadeCommander,  // ဒုတိယမြို့နယ်တပ်ဖွဲ့မှူး
  companyCommander,        // တပ်ဖွဲ့ခွဲမှူး
  deputyCompanyCommander,  // ဒုတိယတပ်ဖွဲ့ခွဲမှူး
  platoonLeader,           // တပ်စုမှူး

  // ─── Other Ranks (အခြားအဆင့်များ) ────────
  warrantOfficer,          // အရာခံဗိုလ်
  sergeantClerk,           // တပ်ကြပ်ကြီးစာရေး
  companySergeantMajor,    // တပ်ခွဲတပ်ကြပ်ကြီး
  platoonSergeant,         // တပ်စုတပ်ကြပ်ကြီး
  sectionLeader,           // တပ်စိတ်မှူး
  deputySectionLeader,     // ဒုတပ်စိတ်မှူး
  private,                 // ကြက်ခြေနီတပ်သား
}

// Chairperson is a special external role
// tracked separately (not a rank in the brigade)
enum ChairpersonRole { chairperson }

// ─────────────────────────────────────────────
// UNIT TYPES
// ─────────────────────────────────────────────
enum UnitType {
  brigadeOffice,   // မြို့နယ်ကြက်ခြေနီသူနာပြုတပ်ဖွဲ့ရုံး
  companyOffice,   // တပ်ဖွဲ့ခွဲရုံး
  platoonOffice,   // တပ်စုရုံး
  company,         // တပ်ဖွဲ့ခွဲ (field)
  platoon,         // တပ်စု (field)
  section,         // တပ်စိတ် (field)
}

// ─────────────────────────────────────────────
// APP ROLE (simplified for permission checks)
// ─────────────────────────────────────────────
enum AppRole {
  chairperson,         // ဥက္ကဌ — full access
  masterAccess,        // Brigade Commander, Deputy, Brigade Office Chief — full access
  brigadeOffice,       // Any rank in Brigade Office — brigade-wide view
  officerField,        // Officer ranks in field — unit-based access
  otherRankField,      // Other ranks in field — unit-based restricted access
  private,             // Private — own profile only
}

// ─────────────────────────────────────────────
// UNIT SCOPE (for permission checks)
// ─────────────────────────────────────────────
enum UnitScope {
  brigadWide,     // Can see/manage entire brigade
  companyWide,    // Can see/manage own company
  platoonWide,    // Can see/manage own platoon
  sectionWide,    // Can see/manage own section
  ownOnly,        // Own profile/records only
}

// ─────────────────────────────────────────────
// MEMBER STATUS
// ─────────────────────────────────────────────
enum MemberStatus { active, inactive, suspended, dismissed }

// ─────────────────────────────────────────────
// DUTY ENUMS
// ─────────────────────────────────────────────
enum DutyType {
  firstAid,
  bloodDonation,
  training,
  patrol,
  eventMedical,   // Large scale — has Commander
  disaster,
  administrative,
  other,
}

enum DutyScale {
  regular,    // Has Duty Officer(s) only
  largeScale, // Has Duty Commander + Officers (marathon, festival etc.)
}

enum DutyStatus { upcoming, ongoing, completed, cancelled }

enum DutyAssignmentStatus { pending, accepted, rejected, completed }

enum DutyRoleInDuty {
  commander,  // Large scale only
  officer,    // All duties
  member,     // All duties
}

enum AvailabilityStatus { free, busy, maybe, notSet }

// ─────────────────────────────────────────────
// EVENT POSITION TYPES
// ─────────────────────────────────────────────
enum EventPositionType { base, point, patrol, standby, command, liaison }

// ─────────────────────────────────────────────
// MEETING ENUMS
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// CLASS ENUMS
// ─────────────────────────────────────────────
enum ClassType { classRoom, workshop, seminar, drill, other }

enum ClassStatus { draft, open, full, ongoing, completed, archived }

// ─────────────────────────────────────────────
// INVESTIGATION ENUMS
// ─────────────────────────────────────────────
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
  committee,  // Can manage if not related
  accused,    // Completely locked out
  witness,    // Completely locked out
  appealCommittee, // Can view + add appeal content only
}

// ─────────────────────────────────────────────
// PUNISHMENT ENUMS
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// BLOOD DONATION ENUMS
// ─────────────────────────────────────────────
enum BloodType { OP, OM, AP, AM, BP, BM, ABP, ABM }

enum DonorType { internal, external }

enum DonationSource { organization, selfReported, priorManual }

// ─────────────────────────────────────────────
// TRANSFER ENUMS
// ─────────────────────────────────────────────
enum TransferType { promotion, demotion, transfer, reinstatement }

// ─────────────────────────────────────────────
// FINANCIAL ENUMS
// ─────────────────────────────────────────────
enum FundingSource { organizationFund, externalGrant, jointFunding, custom }

enum ExpenseStatus { pending, approved, rejected }

enum PaymentStatus { unpaid, initiated, paid, verified }

enum ReimbursementStatus { claimed, underReview, approved, reimbursed, rejected }

// ─────────────────────────────────────────────
// NOTIFICATION ENUMS
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// YOUTH WING ENUMS
// ─────────────────────────────────────────────
enum YouthGroup {
  firstAid,
  disasterManagement,
  bloodDonations,
  infoAndCommunications,
  youthGroup,
}

enum YouthGroupRole { leader, member }

// ─────────────────────────────────────────────
// ARCHIVE VISIBILITY
// ─────────────────────────────────────────────
enum ArchiveVisibility {
  defaultAccess,    // Up to Company Commander
  brigadeOfficeOnly,
  specificRanks,
  custom,
}

// ─────────────────────────────────────────────
// SIGNATURE STATUS
// ─────────────────────────────────────────────
enum SignatureStatus { pending, signed }

// ─────────────────────────────────────────────
// REPORT STATUS
// ─────────────────────────────────────────────
enum ReportStatus { draft, underReview, finalized, published }

// ─────────────────────────────────────────────
// DISPATCH STATUS
// ─────────────────────────────────────────────
enum DispatchStatus {
  created,
  membersSelected,
  confirmed,
  dispatched,
  returned,
}

// ─────────────────────────────────────────────
// RANK DISPLAY HELPERS
// ─────────────────────────────────────────────
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
      case MemberRank.companyCommander:       return 'တပ်ဖွဲ့ခွဲမှူး';
      case MemberRank.deputyCompanyCommander: return 'ဒုတိယတပ်ဖွဲ့ခွဲမှူး';
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
// Will be replaced by MemberRank + UnitType system
enum UserRole {
  admin,
  topBrass,
  seniorOfficer,
  officer,
  dutyOfficer,
  member,
}
