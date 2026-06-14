import '../models/models.dart';
import '../../core/constants/app_constants.dart';

// ─────────────────────────────────────────────
// MOCK MEMBERS — Placeholder only
// Real member data to be entered via the app
// after completing all modules
// ─────────────────────────────────────────────
class MockMembers {
  static final List<Member> all = [

    // ── TEST ACCOUNTS ONLY ──────────────────
    // These are placeholder accounts for
    // development and testing purposes.
    // Real members will be added via the app.

    // Brigade Commander (full access)
    Member(
      id: 'm1', memberNo: 'RC-001',
      nameEn: 'Brigade Commander', nameMm: 'မြို့နယ်တပ်ဖွဲ့မှူး',
      rank: MemberRank.brigadeCommander,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2010, 1, 1),
      phone: '09 000 000 001',
      email: 'commander@redcross.mm',
      address: 'Botahtaung Township, Yangon',
      dateOfBirth: DateTime(1970, 1, 1),
      emergencyContact: 'Emergency Contact',
      emergencyPhone: '09 000 000 000',
      skillIds: [],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.admin,
    ),

    // Deputy Brigade Commander
    Member(
      id: 'm2', memberNo: 'RC-002',
      nameEn: 'Deputy Commander', nameMm: 'ဒုတိယမြို့နယ်တပ်ဖွဲ့မှူး',
      rank: MemberRank.deputyBrigadeCommander,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.AP,
      joinDate: DateTime(2012, 1, 1),
      phone: '09 000 000 002',
      email: 'deputy@redcross.mm',
      address: 'Botahtaung Township, Yangon',
      dateOfBirth: DateTime(1972, 1, 1),
      emergencyContact: 'Emergency Contact',
      emergencyPhone: '09 000 000 000',
      skillIds: [],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.admin,
    ),

    // Brigade Office Chief (Company Commander rank)
    Member(
      id: 'm3', memberNo: 'RC-003',
      nameEn: 'Office Chief', nameMm: 'ရုံးအဖွဲ့မှူး',
      rank: MemberRank.companyCommander,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2014, 1, 1),
      phone: '09 000 000 003',
      email: 'chief@redcross.mm',
      address: 'Botahtaung Township, Yangon',
      dateOfBirth: DateTime(1975, 1, 1),
      emergencyContact: 'Emergency Contact',
      emergencyPhone: '09 000 000 000',
      skillIds: [],
      isBrigadeOfficeChief: true,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.seniorOfficer,
    ),

    // Company 1 Commander (field)
    Member(
      id: 'm101', memberNo: 'RC-101',
      nameEn: 'Company 1 Commander', nameMm: 'တပ်ဖွဲ့ခွဲ(၁)မှူး',
      rank: MemberRank.companyCommander,
      unitType: UnitType.company,
      companyNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2015, 1, 1),
      phone: '09 000 001 001',
      email: 'c1@redcross.mm',
      address: 'Botahtaung Township, Yangon',
      dateOfBirth: DateTime(1980, 1, 1),
      emergencyContact: 'Emergency Contact',
      emergencyPhone: '09 000 000 000',
      skillIds: [],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.seniorOfficer,
    ),

    // Private (most restricted)
    Member(
      id: 'm105', memberNo: 'RC-105',
      nameEn: 'Test Private', nameMm: 'တပ်သား (စမ်းသပ်)',
      rank: MemberRank.private,
      unitType: UnitType.company,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OM,
      joinDate: DateTime(2022, 1, 1),
      phone: '09 000 001 005',
      email: 'private@redcross.mm',
      address: 'Botahtaung Township, Yangon',
      dateOfBirth: DateTime(2000, 1, 1),
      emergencyContact: 'Emergency Contact',
      emergencyPhone: '09 000 000 000',
      skillIds: [],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.member,
    ),
  ];

  static Member? findById(String id) {
    try { return all.firstWhere((m) => m.id == id); }
    catch (_) { return null; }
  }

  static List<Member> findByIds(List<String> ids) =>
      all.where((m) => ids.contains(m.id)).toList();

  static List<Member> get brigadeOffice =>
      all.where((m) => m.unitType == UnitType.brigadeOffice).toList();

  static List<Member> byCompany(int companyNo) =>
      all.where((m) => m.companyNo == companyNo).toList();

  static List<Member> byPlatoon(int companyNo, int platoonNo) =>
      all.where((m) =>
          m.companyNo == companyNo &&
          m.platoonNo == platoonNo).toList();

  static List<Member> bySection(int companyNo, int platoonNo, int sectionNo) =>
      all.where((m) =>
          m.companyNo == companyNo &&
          m.platoonNo == platoonNo &&
          m.sectionNo == sectionNo).toList();

  static List<Member> visibleTo(Member viewer) =>
      all.where((m) => _canView(viewer, m)).toList();

  static bool _canView(Member viewer, Member target) {
    if (viewer.id == target.id) return true;
    if (viewer.isBrigadeOfficeChief ||
        viewer.rank == MemberRank.brigadeCommander ||
        viewer.rank == MemberRank.deputyBrigadeCommander ||
        viewer.isChairperson ||
        viewer.hasBrigadeOfficeAuthority ||
        viewer.unitType == UnitType.brigadeOffice) return true;
    if (viewer.rank == MemberRank.companyCommander ||
        viewer.rank == MemberRank.deputyCompanyCommander) {
      return target.companyNo == viewer.companyNo;
    }
    if (viewer.rank == MemberRank.platoonLeader ||
        viewer.rank == MemberRank.companySergeantMajor ||
        viewer.rank == MemberRank.platoonSergeant) {
      return target.companyNo == viewer.companyNo &&
          target.platoonNo == viewer.platoonNo;
    }
    if (viewer.rank == MemberRank.sectionLeader ||
        viewer.rank == MemberRank.deputySectionLeader) {
      return target.companyNo == viewer.companyNo &&
          target.platoonNo == viewer.platoonNo &&
          target.sectionNo == viewer.sectionNo;
    }
    return false;
  }
}

// ─────────────────────────────────────────────
// MOCK SKILLS — kept for reference
// ─────────────────────────────────────────────
class MockSkills {
  static const List<Skill> all = [
    Skill(id: 'sk1', nameEn: 'First Aid Level 1', nameMm: 'အသက်ဆယ်ကယ် အဆင့် ၁', category: 'Medical', expiryMonths: 24),
    Skill(id: 'sk2', nameEn: 'First Aid Level 2', nameMm: 'အသက်ဆယ်ကယ် အဆင့် ၂', category: 'Medical', expiryMonths: 24),
    Skill(id: 'sk3', nameEn: 'CPR Certified', nameMm: 'CPR လက်မှတ်', category: 'Medical', expiryMonths: 12),
    Skill(id: 'sk4', nameEn: 'Disaster Management', nameMm: 'ဘေးအန္တရာယ် စီမံခန့်ခွဲမှု', category: 'Disaster'),
    Skill(id: 'sk5', nameEn: 'Leadership', nameMm: 'ခေါင်းဆောင်မှု', category: 'Administrative'),
  ];
}

// ─────────────────────────────────────────────
// MOCK DUTIES — empty until real data entered
// ─────────────────────────────────────────────
class MockDuties {
  static final List<Duty> all = [];

  static Duty? findById(String id) => null;
}

// ─────────────────────────────────────────────
// MOCK MEETINGS — empty until real data entered
// ─────────────────────────────────────────────
class MockMeetings {
  static final List<Meeting> all = [];

  static Meeting? findById(String id) => null;

  static List<Meeting> visibleTo(Member member) => [];
}

// ─────────────────────────────────────────────
// MOCK INVESTIGATIONS — empty
// ─────────────────────────────────────────────
class MockInvestigations {
  static final List<Investigation> all = [];

  static Investigation? findById(String id) => null;
}

// ─────────────────────────────────────────────
// MOCK BLOOD DONORS — empty
// ─────────────────────────────────────────────
class MockBloodDonors {
  static final List<BloodDonor> all = [];

  static List<BloodDonor> eligibleByBloodType(BloodType type) => [];
}

// ─────────────────────────────────────────────
// MOCK NOTIFICATIONS — empty
// ─────────────────────────────────────────────
class MockNotifications {
  static final List<AppNotification> all = [];

  static List<AppNotification> forMember(String memberId) => [];

  static int unreadCount(String memberId) => 0;
}

// ─────────────────────────────────────────────
// MOCK AVAILABILITY — empty
// ─────────────────────────────────────────────
class MockAvailability {
  static List<MemberAvailability> forMemberThisMonth(String memberId) => [];
}