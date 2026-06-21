import '../models/models.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/permission_service.dart';

// ═══════════════════════════════════════════════════════════════
// MOCK MEMBER DATA
// Real Company 1 & 3 rosters from org chart files.
// Company 2 & 4: roles only, no names (blank positions).
// Brigade Office: roles only, except Commander (m1) and Deputy (m2)
// which carry real data per user instruction.
//
// Member IDs (m1, m2, m3, m101...) match the existing
// auth_provider.dart mock credentials exactly — login keeps working.
// ═══════════════════════════════════════════════════════════════
class MockMembers {
  MockMembers._();

  static Member? findById(String id) {
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Member> get all => [
    // ─────────────────────────────────────────────────────────
    // BRIGADE OFFICE
    // ─────────────────────────────────────────────────────────

    // m1 — Brigade Commander — ဒေါ်ခင်သန်းစိုး
    Member(
      id: 'm1',
      memberNo: 'RC-001',
      nameEn: 'Daw Khin Than Soe',
      nameMm: 'ဒေါ်ခင်သန်းစိုး',
      rank: MemberRank.brigadeCommander,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(1984, 10, 21),
      currentRankDate: DateTime(2017, 1, 1),
      phone: '09 442 527 816',
      email: '',
      address: 'ရန်ကုန်တိုင်းဒေသကြီး',
      dateOfBirth: DateTime(1973, 8, 28),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.admin,
      gender: Gender.female,
      nrc: '၁၂/ဗတထ(နိုင်)၀၂၃၉၈၁',
      membershipNo: 'ရက-၈၃၂၇',
      isAdminRole: true,
      membershipType: MembershipType.official,
    ),

    // m2 — Deputy Brigade Commander — ဦးရန်ပိုင်
    Member(
      id: 'm2',
      memberNo: 'RC-002',
      nameEn: 'U Yan Paing',
      nameMm: 'ဦးရန်ပိုင်',
      rank: MemberRank.deputyBrigadeCommander,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2000, 1, 1),
      currentRankDate: DateTime(2020, 1, 1),
      phone: '09 429 111 807',
      email: '',
      address: 'ရန်ကုန်တိုင်းဒေသကြီး',
      dateOfBirth: DateTime(1975, 1, 1),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.topBrass,
      gender: Gender.male,
      nrc: '၁၂/မတတ(နိုင်)၀၂၉၁၄၆',
      membershipNo: 'ရက-၉၂၂၂',
      membershipType: MembershipType.official,
    ),

    // m3 — Brigade Office Chief — role only, no name
    Member(
      id: 'm3',
      memberNo: 'RC-003',
      nameEn: '',
      nameMm: '',
      rank: MemberRank.companyCommander, // Brigade Office Chief uses Company Commander rank per Module 3 notes
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2020, 1, 1),
      dateOfBirth: DateTime(1980, 1, 1),
      phone: '',
      email: '',
      address: '',
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      isBrigadeOfficeChief: true,
      role: UserRole.seniorOfficer,
      gender: Gender.male,
    ),

    // m6 — Warrant Officer (Brigade Office) — role only
    Member(
      id: 'm6',
      memberNo: 'RC-006',
      nameEn: '',
      nameMm: '',
      rank: MemberRank.warrantOfficer,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2020, 1, 1),
      dateOfBirth: DateTime(1980, 1, 1),
      phone: '',
      email: '',
      address: '',
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.officer,
      gender: Gender.male,
    ),

    // m7 — Sergeant Clerk (Brigade Office) — role only
    Member(
      id: 'm7',
      memberNo: 'RC-007',
      nameEn: '',
      nameMm: '',
      rank: MemberRank.sergeantClerk,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2020, 1, 1),
      dateOfBirth: DateTime(1980, 1, 1),
      phone: '',
      email: '',
      address: '',
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.male,
    ),

    // ─────────────────────────────────────────────────────────
    // COMPANY 1 — Full data from C1_Organization_Chart.xlsx
    // ─────────────────────────────────────────────────────────

    // m101 — Company 1 Commander — ဦးစိုးမင်း
    Member(
      id: 'm101',
      memberNo: 'RC-101',
      nameEn: 'U Soe Minn',
      nameMm: 'ဦးစိုးမင်း',
      rank: MemberRank.companyCommander,
      unitType: UnitType.company,
      companyNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(1984, 10, 21),
      currentRankDate: DateTime(2017, 7, 1),
      phone: '09 254 127 176',
      email: '',
      address: 'အမှတ် (၄၃၄) ကုန်သည်လမ်း၊ အမှတ် (၈) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(1973, 8, 28),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.seniorOfficer,
      gender: Gender.male,
      nrc: '၁၂/ဗတထ(နိုင်)၀၀၁၅၄၀',
      ygnId: '13017/00024',
      membershipNo: 'တဖ-ရက/ဗတထ/၃',
      membershipType: MembershipType.official,
    ),

    // m102 — Company 1 Deputy Commander — ဦးအောင်ဝေထွန်း
    Member(
      id: 'm102',
      memberNo: 'RC-102',
      nameEn: 'U Aung Wai Htun',
      nameMm: 'ဦးအောင်ဝေထွန်း',
      rank: MemberRank.deputyCompanyCommander,
      unitType: UnitType.company,
      companyNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(1993, 6, 12),
      currentRankDate: DateTime(2020, 1, 8),
      phone: '09 510 1069',
      email: '',
      address: 'အမှတ် (၄၆၃/၁၂) ကုန်သည်လမ်း၊ အမှတ် (၇) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(1982, 6, 1),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.officer,
      gender: Gender.male,
      nrc: '၁၂/ဗတထ(နိုင်)၀၃၄၅၁၈',
      ygnId: '13017/00061',
      membershipNo: 'တဖ-ရက/ဗတထ/၉',
      membershipType: MembershipType.official,
    ),

    // m103 — C1 Platoon 1 Leader — ဦးလှမြင့်ဦး (used as Module 3 sample "Platoon Leader C1/P1")
    Member(
      id: 'm103',
      memberNo: 'RC-103',
      nameEn: 'U Hla Myint Oo',
      nameMm: 'ဦးလှမြင့်ဦး',
      rank: MemberRank.platoonLeader,
      unitType: UnitType.platoon,
      companyNo: 1,
      platoonNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2020, 2, 20),
      currentRankDate: DateTime(2026, 1, 1),
      phone: '09 784 854 886',
      email: '',
      address: 'အမှတ် (၁၄၅) (၄၇) လမ်း၊ အမှတ် (၁၀) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(1998, 8, 5),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.officer,
      gender: Gender.male,
      nrc: '၁၂/ဗတထ(နိုင်)၀၄၂၆၂၄',
      ygnId: '13017/00030',
      membershipNo: 'တဖ-ရက/ဗတထ/၃၀',
      membershipType: MembershipType.official,
    ),

    // m104 — C1/P1/S1 Section Leader — vacant in org chart, kept as test login per Module 3
    Member(
      id: 'm104',
      memberNo: 'RC-104',
      nameEn: '',
      nameMm: '',
      rank: MemberRank.sectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2020, 1, 1),
      dateOfBirth: DateTime(1990, 1, 1),
      phone: '',
      email: '',
      address: '',
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.male,
    ),

    // m105 — C1/P1/S1 Private — ကိုအောင်နန္ဒ (used as Module 3 sample "Private C1/P1/S1")
    Member(
      id: 'm105',
      memberNo: 'RC-105',
      nameEn: 'Ko Aung Nanda',
      nameMm: 'ကိုအောင်နန္ဒ',
      rank: MemberRank.private,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2024, 7, 15),
      currentRankDate: DateTime(2024, 7, 15),
      phone: '09 964 578 724',
      email: '',
      address: 'အခန်း (၅/J) မလိခဆောင်၊ ရဲရိပ်သာရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2005, 10, 2),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: '၁၂/မဂတ(နိုင်)၁၁၆၇၇၅',
      ygnId: '13017/02664',
      membershipNo: 'တဖ-ရက/ဗတထ/၆၂',
      membershipType: MembershipType.official,
    ),

    // m106 — C1 Sergeant Major (Office) — ကိုဝေဖြိုးပိုင်
    Member(
      id: 'm106',
      memberNo: 'RC-106',
      nameEn: 'Ko Wai Phyo Paing',
      nameMm: 'ကိုဝေဖြိုးပိုင်',
      rank: MemberRank.companySergeantMajor,
      unitType: UnitType.company,
      companyNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.ABP,
      joinDate: DateTime(2021, 8, 22),
      currentRankDate: DateTime(2024, 9, 1),
      phone: '09 683 396 936',
      email: '',
      address: 'အခန်း (၁)၊ (၆) ခန်းတွဲ၊ ရဲရိပ်သာရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2000, 1, 5),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.male,
      nrc: '၇/လပတ(နိုင်)၁၇၁၅၅၇',
      ygnId: '13017/02254',
      membershipNo: 'တဖ-ရက/ဗတထ/၄၆',
      membershipType: MembershipType.official,
    ),

    // m107 — C1 Platoon 1 Sergeant — ကိုအောင်ဘုန်းခန့်
    Member(
      id: 'm107',
      memberNo: 'RC-107',
      nameEn: 'Ko Aung Bhone Khant',
      nameMm: 'ကိုအောင်ဘုန်းခန့်',
      rank: MemberRank.platoonSergeant,
      unitType: UnitType.platoon,
      companyNo: 1,
      platoonNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.AP,
      joinDate: DateTime(2024, 8, 27),
      currentRankDate: DateTime(2025, 1, 1),
      phone: '09 679 952 011',
      email: '',
      address: 'COD အပေါ်ဝင်း၊ စန္ဒကူးလမ်း၊ အမှတ် (၃) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2008, 1, 27),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.male,
      nrc: '၁၂/ဗတထ(နိုင်)၀၅၀၂၄၈',
      ygnId: '13017/02485',
      membershipNo: 'တဖ-ရက/ဗတထ/၆၁',
      membershipType: MembershipType.official,
    ),

    // m108 — C1/P1/S2 Section Leader — ကိုဇော်လွင်ဝင်း
    Member(
      id: 'm108',
      memberNo: 'RC-108',
      nameEn: 'Ko Zaw Lwin Win',
      nameMm: 'ကိုဇော်လွင်ဝင်း',
      rank: MemberRank.sectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2020, 3, 26),
      currentRankDate: DateTime(2024, 9, 1),
      phone: '09 740 849 184',
      email: '',
      address: 'အမှတ် (၄၃၄) ကုန်သည်လမ်း၊ အမှတ် (၈) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2001, 6, 19),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.male,
      nrc: '၁၄/အမန(နိုင်)၂၁၀၈၄၄',
      ygnId: '13017/01342',
      membershipNo: 'တဖ-ရက/ဗတထ/၆၄',
      membershipType: MembershipType.official,
    ),

    // m109 — C1/P1/S1 Deputy Section Leader — ကိုထက်မြတ်အောင်
    Member(
      id: 'm109',
      memberNo: 'RC-109',
      nameEn: 'Ko Htet Myat Aung',
      nameMm: 'ကိုထက်မြတ်အောင်',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2024, 11, 21),
      currentRankDate: DateTime(2026, 1, 1),
      phone: '09 698 276 770',
      email: '',
      address: 'မီးပြဝင်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2009, 3, 8),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: '၁၂/ဆကန(နိုင်)၀၀၂၉၉၄',
      ygnId: '13017/02661',
      membershipNo: 'တဖ-ရက/ဗတထ/၉၉',
      membershipType: MembershipType.official,
    ),

    // m110 — C1/P1/S1 Deputy Section Leader — ကိုစေပိုင်
    Member(
      id: 'm110',
      memberNo: 'RC-110',
      nameEn: 'Ko Say Paing',
      nameMm: 'ကိုစေပိုင်',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2024, 11, 21),
      currentRankDate: DateTime(2026, 1, 1),
      phone: '09 458 590 534',
      email: '',
      address: 'COD အပေါ်ဝင်း၊ စန္ဒကူးလမ်း၊ အမှတ် (၃) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2010, 5, 25),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: 'လျှောက်ထားဆဲ',
      ygnId: '13017/02692',
      membershipNo: 'သမ-၃/ဗတထ/ရက',
      membershipType: MembershipType.probationer,
    ),

    // m111 — C1/P1/S2 Deputy Section Leader — ကိုဇေပိုင်
    Member(
      id: 'm111',
      memberNo: 'RC-111',
      nameEn: 'Ko Zay Paing',
      nameMm: 'ကိုဇေပိုင်',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2024, 11, 21),
      currentRankDate: DateTime(2026, 1, 1),
      phone: '09 677 450 369',
      email: '',
      address: 'COD အပေါ်ဝင်း၊ စန္ဒကူးလမ်း၊ အမှတ် (၃) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2010, 5, 25),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: 'လျှောက်ထားဆဲ',
      ygnId: '13017/02691',
      membershipNo: 'သမ-၂/ဗတထ/ရက',
      membershipType: MembershipType.probationer,
    ),

    // m112 — C1/P1/S2 Deputy Section Leader — ကိုဝေဖြိုးအောင်
    Member(
      id: 'm112',
      memberNo: 'RC-112',
      nameEn: 'Ko Wai Phyo Aung',
      nameMm: 'ကိုဝေဖြိုးအောင်',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2024, 11, 21),
      currentRankDate: DateTime(2026, 1, 1),
      phone: '09 683 896 019',
      email: '',
      address: 'COD အပေါ်ဝင်း၊ စန္ဒကူးလမ်း၊ အမှတ် (၃) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2010, 2, 23),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: 'လျှောက်ထားဆဲ',
      ygnId: '13017/02687',
      membershipNo: 'သမ-၁/ဗတထ/ရက',
      membershipType: MembershipType.probationer,
    ),

    // m113-m115 — C1/P1/S1 Privates
    Member(
      id: 'm113',
      memberNo: 'RC-113',
      nameEn: 'Ko Myo Myat Yan Naing Min',
      nameMm: 'ကိုမျိုးမြတ်ရန်နိုင်မင်း',
      rank: MemberRank.private,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2025, 8, 11),
      currentRankDate: DateTime(2025, 8, 11),
      phone: '09 661 812 574',
      email: '',
      address: 'သမတကမ်းခြေ၊ ဒလမြို့နယ်',
      dateOfBirth: DateTime(2009, 2, 5),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: 'လျှောက်ထားဆဲ',
      membershipNo: 'တဖ-ရက/ဗတထ/၁၂၃',
      membershipType: MembershipType.official,
    ),

    Member(
      id: 'm114',
      memberNo: 'RC-114',
      nameEn: 'Ko Kaung Htet Aung',
      nameMm: 'ကိုကောင်းထက်အောင်',
      rank: MemberRank.private,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2025, 4, 27),
      currentRankDate: DateTime(2025, 4, 27),
      phone: '09 775 108 143',
      email: '',
      address: 'အမှတ် (၃၉) (၆၁) လမ်း၊ အမှတ် (၃) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2012, 2, 13),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: 'လျှောက်ထားဆဲ',
      ygnId: '13017/02747',
      membershipNo: 'သမ-၁၅/ဗတထ/ရက',
      membershipType: MembershipType.probationer,
    ),

    // m115 — C1/P1/S2 Private
    Member(
      id: 'm115',
      memberNo: 'RC-115',
      nameEn: 'Ko Kyaw Lin Htut',
      nameMm: 'ကိုကျော်လင်းထွဋ်',
      rank: MemberRank.private,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2025, 1, 4),
      currentRankDate: DateTime(2025, 1, 4),
      phone: '09 758 264 726',
      email: '',
      address: 'COD အပေါ်ဝင်း၊ စန္ဒကူးလမ်း၊ အမှတ် (၃) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2010, 6, 11),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: 'လျှောက်ထားဆဲ',
      ygnId: '13017/02694',
      membershipNo: 'သမ-၁၃/ဗတထ/ရက',
      membershipType: MembershipType.probationer,
    ),

    Member(
      id: 'm116',
      memberNo: 'RC-116',
      nameEn: 'Ko Min Than Zin',
      nameMm: 'ကိုမင်းသံစဉ်',
      rank: MemberRank.private,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2025, 1, 1),
      currentRankDate: DateTime(2025, 1, 1),
      phone: '09956740007',
      email: '',
      address: 'တိုက် (ဒီ) အခန်း (၂၀၁) မင်္ဂလာဥယျာဉ်အိမ်ရာ၊ တာမွေမြို့နယ်',
      dateOfBirth: DateTime(2010, 7, 15),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: '၁၂/ဥကတ(နိုင်)၂၁၅၂၈၆',
      ygnId: '13017/02728',
      membershipNo: 'သမ-၁၄/ဗတထ/ရက',
      membershipType: MembershipType.probationer,
    ),

    Member(
      id: 'm117',
      memberNo: 'RC-117',
      nameEn: 'Ko Zwell Khant Ko Ko',
      nameMm: 'ကိုဇွဲခန့်ကိုကို',
      rank: MemberRank.private,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.AP,
      joinDate: DateTime(2020, 8, 19),
      currentRankDate: DateTime(2026, 1, 1),
      phone: '09 777 213 326',
      email: '',
      address: 'အနော်ရထာလမ်း၊ အံ့ကြီးရပ်ကွက်၊ ဒလမြို့နယ်',
      dateOfBirth: DateTime(1999, 11, 2),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: '၁၂/ဒလန(နိုင်)၂၇၀၃၁၅',
      ygnId: '13017/00066',
      membershipNo: 'တဖ-ရက/ဗတထ/၄၅',
      membershipType: MembershipType.official,
    ),

    // m118 — Company 1 Platoon 2 Leader — ဦးပြည့်ဖြိုးအောင်
    Member(
      id: 'm118',
      memberNo: 'RC-118',
      nameEn: 'U Pyae Phyo Aung',
      nameMm: 'ဦးပြည့်ဖြိုးအောင်',
      rank: MemberRank.platoonLeader,
      unitType: UnitType.platoon,
      companyNo: 1,
      platoonNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2020, 3, 31),
      currentRankDate: DateTime(2024, 9, 1),
      phone: '09 423 407 064',
      email: '',
      address: 'အမှတ် (၃၅) ရေတပ်စက်မှုလက်မှုတပ်၊ GE ဝင်း၊ သန်လျက်စွန်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2000, 1, 20),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.officer,
      gender: Gender.male,
      nrc: '၁၂/သကတ(နိုင်)၂၁၀၃၈၂',
      ygnId: '13017/00070',
      membershipNo: 'တဖ-ရက/ဗတထ/၄၄',
      membershipType: MembershipType.official,
    ),

    // m119 — Company 1 Platoon 2 Sergeant — ကိုနိုင်စစ်မှူး
    Member(
      id: 'm119',
      memberNo: 'RC-119',
      nameEn: 'Ko Naing Sitt Hmu',
      nameMm: 'ကိုနိုင်စစ်မှူး',
      rank: MemberRank.platoonSergeant,
      unitType: UnitType.platoon,
      companyNo: 1,
      platoonNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2021, 2, 17),
      currentRankDate: DateTime(2025, 4, 1),
      phone: '09 404 484 173',
      email: '',
      address: 'အမှတ် (၁၄၇) ဗိုလ်ချုပ်အောင်ဆန်းလမ်း၊ အမှတ် (၁၀) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2004, 10, 2),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.male,
      nrc: '၁၂/သလန(နိုင်)၁၆၂၉၀၃',
      ygnId: '13017/01296',
      membershipNo: 'တဖ-ရက/ဗတထ/၆၅',
      membershipType: MembershipType.official,
    ),

    // m120 — C1/P2/S1 Section Leader — ကိုပိုင်မျိုးသူ
    Member(
      id: 'm120',
      memberNo: 'RC-120',
      nameEn: 'Ko Paing Myo Thu',
      nameMm: 'ကိုပိုင်မျိုးသူ',
      rank: MemberRank.sectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 2,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2024, 6, 30),
      currentRankDate: DateTime(2025, 1, 1),
      phone: '09 976 493 268',
      email: '',
      address: 'အမှတ် (၂၈၆) ကုန်သည်လမ်း၊ အမှတ် (၄) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2007, 9, 20),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.male,
      nrc: '၁၂/ဗတထ(နိုင်)၀၄၉၄၁၉',
      ygnId: '13017/01318',
      membershipNo: 'တဖ-ရက/ဗတထ/၅၉',
      membershipType: MembershipType.official,
    ),

    // m121 — C1/P2/S2 Section Leader — ကိုဇော်ဌေးအောင်
    Member(
      id: 'm121',
      memberNo: 'RC-121',
      nameEn: 'Ko Zaw Htay Aung',
      nameMm: 'ကိုဇော်ဌေးအောင်',
      rank: MemberRank.sectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 2,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2020, 8, 19),
      currentRankDate: DateTime(2025, 4, 1),
      phone: '09 751 272 290',
      email: '',
      address: 'ပညာရာမိကမဟာ(A)တိုက် ဘုန်းကြီးကျောင်း၊ သိမ်ဖြူလမ်း၊ အမှတ် (၁၀) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2000, 2, 15),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.male,
      nrc: '၈/ပဖန(နိုင်)၁၇၇၂၉၉',
      ygnId: '13017/00072',
      membershipNo: 'တဖ-ရက/ဗတထ/၄၃',
      membershipType: MembershipType.official,
    ),

    // m122 — C1/P2/S1 Deputy Section Leader — ကိုစိုင်းသူရဇော်ဘွမ်ဦး
    Member(
      id: 'm122',
      memberNo: 'RC-122',
      nameEn: 'Ko Sai Thura Zaw Bwan Oo',
      nameMm: 'ကိုစိုင်းသူရဇော်ဘွမ်ဦး',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 2,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.AP,
      joinDate: DateTime(2021, 11, 17),
      currentRankDate: DateTime(2024, 9, 1),
      phone: '09 893 568 291',
      email: '',
      address: 'အမှတ် (၃၉) ဇီဇဝါလမ်း၊ ရေကျော်၊ ပုဇွန်တောင်မြို့နယ်',
      dateOfBirth: DateTime(2005, 8, 12),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: '၁၂/ပဇတ(နိုင်)၀၄၂၇၆၇',
      ygnId: '13017/02727',
      membershipNo: 'တဖ-ရက/ဗတထ/၅၈',
      membershipType: MembershipType.official,
    ),

    // m123 — C1/P2/S1 Deputy Section Leader — vacant
    Member(
      id: 'm123',
      memberNo: 'RC-123',
      nameEn: '',
      nameMm: '',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 2,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2020, 1, 1),
      dateOfBirth: DateTime(1990, 1, 1),
      phone: '',
      email: '',
      address: '',
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
    ),

    // m124 — C1/P2/S2 Deputy Section Leader — ကိုဝင်းမြတ်အောင်
    Member(
      id: 'm124',
      memberNo: 'RC-124',
      nameEn: 'Ko Win Myat Aung',
      nameMm: 'ကိုဝင်းမြတ်အောင်',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 2,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2025, 9, 6),
      currentRankDate: DateTime(2025, 9, 6),
      phone: '09 660 250 320',
      email: '',
      address: 'G-11 ရေနံလိုင်း၊ သန်လျက်စွန်းလမ်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2007, 1, 20),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: '၁၂/ဗတထ(နိုင်)၀၄၅၈၂၆',
      membershipNo: 'တဖ-ရက/ဗတထ/၁၂၁',
      membershipType: MembershipType.official,
    ),

    // m125 — C1/P2/S2 Deputy Section Leader — ကိုဇေယျာဝင်းထွဋ်
    Member(
      id: 'm125',
      memberNo: 'RC-125',
      nameEn: 'Ko Zayar Win Htut',
      nameMm: 'ကိုဇေယျာဝင်းထွဋ်',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 2,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2025, 4, 20),
      currentRankDate: DateTime(2025, 4, 20),
      phone: '09 776 219 946',
      email: '',
      address: 'ထော်အောက်ကျေးရွာ၊ ဒလမြို့နယ်',
      dateOfBirth: DateTime(1998, 5, 26),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: '၁၂/ဒလန(နိုင်)၀၆၂၆၄၉',
      ygnId: '13017/02694',
      membershipNo: 'တဖ-ရက/ဗတထ/၁၁၆',
      membershipType: MembershipType.official,
    ),

    // m126-m128 — C1/P2/S1 Privates
    Member(
      id: 'm126',
      memberNo: 'RC-126',
      nameEn: 'Ko Htet Win Aung',
      nameMm: 'ကိုထက်ဝင်းအောင်',
      rank: MemberRank.private,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 2,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2024, 12, 7),
      currentRankDate: DateTime(2024, 12, 7),
      phone: '09 694 076 944',
      email: '',
      address: 'အခန်း (၁၉) သဇင်လိုင်း၊ ဧရခ၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2008, 4, 5),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: '၁၂/တမန(နိုင်)၁၃၆၄၁၈',
      ygnId: '13017/02666',
      membershipNo: 'တဖ-ရက/ဗတထ/၁၀၅',
      membershipType: MembershipType.official,
    ),

    Member(
      id: 'm127',
      memberNo: 'RC-127',
      nameEn: 'Ko Htoo Ent Shein',
      nameMm: 'ကိုထူးအံ့ရှိန်',
      rank: MemberRank.private,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 2,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2025, 9, 6),
      currentRankDate: DateTime(2025, 9, 6),
      phone: '09 671 694 693',
      email: '',
      address: 'G-11 ရေနံလိုင်း၊ သန်လျက်စွန်းလမ်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2001, 4, 3),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
      nrc: '၁၂/ဗတထ(နိုင်)၀၄၃၅၃၉',
      membershipNo: '',
      membershipType: MembershipType.official,
    ),

    // m128 — C1/P2/S1 Private — vacant
    Member(
      id: 'm128',
      memberNo: 'RC-128',
      nameEn: '',
      nameMm: '',
      rank: MemberRank.private,
      unitType: UnitType.section,
      companyNo: 1,
      platoonNo: 2,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2020, 1, 1),
      dateOfBirth: DateTime(1990, 1, 1),
      phone: '',
      email: '',
      address: '',
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.male,
    ),

    // m129-m131 — C1/P2/S2 Privates — all vacant
    Member(
      id: 'm129', memberNo: 'RC-129', nameEn: '', nameMm: '',
      rank: MemberRank.private, unitType: UnitType.section,
      companyNo: 1, platoonNo: 2, sectionNo: 2,
      status: MemberStatus.active, bloodType: BloodType.OP,
      joinDate: DateTime(2020, 1, 1), dateOfBirth: DateTime(1990, 1, 1),
      phone: '', email: '', address: '', emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.male,
    ),
    Member(
      id: 'm130', memberNo: 'RC-130', nameEn: '', nameMm: '',
      rank: MemberRank.private, unitType: UnitType.section,
      companyNo: 1, platoonNo: 2, sectionNo: 2,
      status: MemberStatus.active, bloodType: BloodType.OP,
      joinDate: DateTime(2020, 1, 1), dateOfBirth: DateTime(1990, 1, 1),
      phone: '', email: '', address: '', emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.male,
    ),
    Member(
      id: 'm131', memberNo: 'RC-131', nameEn: '', nameMm: '',
      rank: MemberRank.private, unitType: UnitType.section,
      companyNo: 1, platoonNo: 2, sectionNo: 2,
      status: MemberStatus.active, bloodType: BloodType.OP,
      joinDate: DateTime(2020, 1, 1), dateOfBirth: DateTime(1990, 1, 1),
      phone: '', email: '', address: '', emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.male,
    ),

    // ─────────────────────────────────────────────────────────
    // COMPANY 2 — Intentionally empty for now.
    // No mock data entries. Structure, permissions, and rank/unit
    // logic (UnitType.company/platoon, companyNo: 2, the Company 2
    // filter option, permission scope rules, etc.) all remain fully
    // intact elsewhere in the app — only the placeholder data here
    // was removed. To re-add Company 2 later, copy the Company 1 or
    // Company 3 block's structure (Commander → Deputy → Sgt Major →
    // Platoons → Sections → Privates) with companyNo: 2.
    // ─────────────────────────────────────────────────────────

    // ─────────────────────────────────────────────────────────
    // COMPANY 3 — Full data from C3_Organization_Chart.xlsx
    // ─────────────────────────────────────────────────────────

    // m301 — Company 3 Commander — VACANT (unfilled in org chart)
    Member(
      id: 'm301', memberNo: 'RC-301', nameEn: '', nameMm: '',
      rank: MemberRank.companyCommander, unitType: UnitType.company,
      companyNo: 3, status: MemberStatus.active, bloodType: BloodType.OP,
      joinDate: DateTime(2020,1,1), dateOfBirth: DateTime(1980,1,1),
      phone: '', email: '', address: '', emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.seniorOfficer, gender: Gender.female,
    ),

    // m302 — Company 3 Deputy Commander — ဒေါ်လင်းလက်တာရာ
    Member(
      id: 'm302',
      memberNo: 'RC-302',
      nameEn: 'Daw Lin Let Tara Ya',
      nameMm: 'ဒေါ်လင်းလက်တာရာ',
      rank: MemberRank.deputyCompanyCommander,
      unitType: UnitType.company,
      companyNo: 3,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2020, 5, 15),
      currentRankDate: DateTime(2024, 9, 1),
      phone: '09 422 618 394',
      email: '',
      address: 'အမှတ် (ဘီ/၃) ကြာဖြူလမ်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2002, 11, 13),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.officer,
      gender: Gender.female,
      nrc: 'လျှောက်ထားဆဲ',
      ygnId: '13017/00065',
      membershipNo: 'တဖ-ရက/ဗတထ/၂၇',
      membershipType: MembershipType.official,
    ),

    // m303 — Company 3 Sergeant Major (Office) — မအင်ကြင်းအေး
    Member(
      id: 'm303',
      memberNo: 'RC-303',
      nameEn: 'Ma Ain Kying Aye',
      nameMm: 'မအင်ကြင်းအေး',
      rank: MemberRank.companySergeantMajor,
      unitType: UnitType.company,
      companyNo: 3,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2020, 1, 1),
      currentRankDate: DateTime(2026, 1, 1),
      phone: '09 968 130 953',
      email: '',
      address: '2H မလိခဆောင်၊ ဗိုလ်တထောင်ဘုရားဝန်ထမ်းလိုင်း၊ ရဲရိပ်သာရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2005, 3, 27),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.female,
      nrc: '၁၂/ဆကန(နိုင်)၀၀၂၉၁၉',
      ygnId: '13017/01315',
      membershipNo: 'တဖ-ရက/ဗတထ/၁၀၇',
      membershipType: MembershipType.official,
    ),

    // m304 — Company 3 Platoon 1 Leader — ဒေါ်သန်းသန်းစံ
    Member(
      id: 'm304',
      memberNo: 'RC-304',
      nameEn: 'Daw Than Than San',
      nameMm: 'ဒေါ်သန်းသန်းစံ',
      rank: MemberRank.platoonLeader,
      unitType: UnitType.platoon,
      companyNo: 3,
      platoonNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2014, 6, 30),
      currentRankDate: DateTime(2020, 1, 1),
      phone: '09 781 988 301',
      email: '',
      address: 'တိုက် (D)၊ အခန်း (၈)၊ ရေနံလိုင်း၊ သန်လျှက်စွန်းလမ်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2002, 5, 17),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.officer,
      gender: Gender.female,
      nrc: '၁၂/ဗတထ(နိုင်)၀၄၆၂၀၇',
      ygnId: '13017/01872',
      membershipNo: 'တဖ-ရက/ဗတထ/၁၇',
      membershipType: MembershipType.official,
    ),

    // m305 — Company 3 Platoon 1 Sergeant — မကေဇင်ဟန်
    Member(
      id: 'm305',
      memberNo: 'RC-305',
      nameEn: 'Ma Kay Zin Han',
      nameMm: 'မကေဇင်ဟန်',
      rank: MemberRank.platoonSergeant,
      unitType: UnitType.platoon,
      companyNo: 3,
      platoonNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.AP,
      joinDate: DateTime(2022, 1, 3),
      currentRankDate: DateTime(2024, 9, 1),
      phone: '09 424 891 200',
      email: '',
      address: 'F-12 ရေနံမိသားစုလိုင်း၊ သန်လျက်စွန်းလမ်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2009, 5, 28),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.female,
      nrc: '၁၂/ဗတထ(နိုင်)၀၄၇၉၁၃',
      ygnId: '13017/02259',
      membershipNo: 'တဖ-ရက/ဗတထ/၅၀',
      membershipType: MembershipType.official,
    ),

    // m306 — C3/P1/S1 Section Leader — မယုယဖြူ
    Member(
      id: 'm306',
      memberNo: 'RC-306',
      nameEn: 'Ma Yu Yu Phyu',
      nameMm: 'မယုယဖြူ',
      rank: MemberRank.sectionLeader,
      unitType: UnitType.section,
      companyNo: 3,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2024, 6, 29),
      currentRankDate: DateTime(2025, 1, 1),
      phone: '09 769 635 257',
      email: '',
      address: 'အမှတ် (၂) ဇင်ယော်လမ်း၊ အမှတ် (၂) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2009, 10, 21),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.female,
      nrc: '၁၂/ဗတထ(နိုင်)၀၄၈၀၉၅',
      ygnId: '13017/02671',
      membershipNo: 'သမ-၆/ဗတထ/ရက',
      membershipType: MembershipType.probationer,
    ),

    // m307 — C3/P1/S2 Section Leader — မအိမ့်လဝန်း
    Member(
      id: 'm307',
      memberNo: 'RC-307',
      nameEn: 'Ma Eaint La Wun',
      nameMm: 'မအိမ့်လဝန်း',
      rank: MemberRank.sectionLeader,
      unitType: UnitType.section,
      companyNo: 3,
      platoonNo: 1,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.AP,
      joinDate: DateTime(2023, 11, 30),
      currentRankDate: DateTime(2025, 1, 1),
      phone: '09 755 325 414',
      email: '',
      address: 'အခန်း (၄/D) တိုက် (၄၀) ရဲရိပ်သာရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2009, 8, 8),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.female,
      nrc: '၁၂/ဒဂတ(နိုင်)၁၃၄၉၃၅',
      ygnId: '13017/02657',
      membershipNo: 'သမ-၁၀/ဗတထ/ရက',
      membershipType: MembershipType.probationer,
    ),

    // m308 — C3/P1/S1 Deputy Section Leader — မယုနန္ဒာလင်း
    Member(
      id: 'm308',
      memberNo: 'RC-308',
      nameEn: 'Ma Yu Nanda Lin',
      nameMm: 'မယုနန္ဒာလင်း',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 3,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2024, 8, 27),
      currentRankDate: DateTime(2025, 1, 1),
      phone: '09 693 134 204',
      email: '',
      address: 'စည်ပင်ဝင်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2010, 7, 20),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.female,
      nrc: '၁၂/ဗတထ(နိုင်)၀၄၉၉၈၁',
      ygnId: '13017/02658',
      membershipNo: 'သမ-၇/ဗတထ/ရက',
      membershipType: MembershipType.probationer,
    ),

    // m309 — C3/P1/S1 Deputy Section Leader — မအိသဇင်နွယ်
    Member(
      id: 'm309',
      memberNo: 'RC-309',
      nameEn: 'Ma Eaint Thi Zin Nway',
      nameMm: 'မအိသဇင်နွယ်',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 3,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2004, 6, 6),
      currentRankDate: DateTime(2026, 1, 1),
      phone: '09 667 491 099',
      email: '',
      address: 'လင်းစဒေါင်း၊ အမှတ် (၂) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2004, 6, 6),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.female,
      nrc: '၁၄/ဖပန(နိုင်)၂၆၆၃၂၄',
      membershipNo: 'တဖ-ရက/ဗတထ/၁၁၉',
      membershipType: MembershipType.official,
    ),

    // m310 — C3/P1/S2 Deputy Section Leader — မအိမ့်ချမ်းမြေ့မေ
    Member(
      id: 'm310',
      memberNo: 'RC-310',
      nameEn: 'Ma Eaint Chan Myae May',
      nameMm: 'မအိမ့်ချမ်းမြေ့မေ',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 3,
      platoonNo: 1,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2024, 8, 25),
      currentRankDate: DateTime(2025, 1, 1),
      phone: '09 688 729 789',
      email: '',
      address: 'လိုင်း (၁) အခန်း (၂) ရေတပ်ဝင်း၊ သန်လျက်စွန်းလမ်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2010, 1, 13),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.female,
      nrc: 'လျှောက်ထားဆဲ',
      ygnId: '13017/02659',
      membershipNo: 'သမ-၈/ဗတထ/ရက',
      membershipType: MembershipType.probationer,
    ),

    // m311 — C3/P1/S2 Deputy Section Leader — မချိုသက်ခိုင်
    Member(
      id: 'm311',
      memberNo: 'RC-311',
      nameEn: 'Ma Cho Thet Khaing',
      nameMm: 'မချိုသက်ခိုင်',
      rank: MemberRank.deputySectionLeader,
      unitType: UnitType.section,
      companyNo: 3,
      platoonNo: 1,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2018, 3, 18),
      currentRankDate: DateTime(2026, 1, 1),
      phone: '09 782 378 485',
      email: '',
      address: 'အမှတ် (၉၄) မြောင်းကြီးလမ်း၊ အမှတ် (၉) ရပ်ကွက်၊ ပုဇွန်တောင်မြို့နယ်',
      dateOfBirth: DateTime(2006, 7, 24),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.member,
      gender: Gender.female,
      nrc: '၁၂/ပဇတ(နိုင်)၀၄၀၃၄၃',
      ygnId: '13016/00792',
      membershipNo: 'တဖ-ရက/ဗတထ/၁၂၀',
      membershipType: MembershipType.official,
    ),

    // m312-m314 — C3/P1/S1 Privates
    Member(
      id: 'm312', memberNo: 'RC-312',
      nameEn: 'Ma Hein Thet Su San', nameMm: 'မဟိန်းထက်စုစံ',
      rank: MemberRank.private, unitType: UnitType.section,
      companyNo: 3, platoonNo: 1, sectionNo: 1,
      status: MemberStatus.active, bloodType: BloodType.AP,
      joinDate: DateTime(2024,12,25), currentRankDate: DateTime(2024,12,25),
      phone: '09 769 968 721', email: '',
      address: 'အမှတ် (၆) အခန်း (၅) လင်းစတောင်းဈေးလမ်း၊ အမှတ် (၂) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2012,2,20), emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.female,
      nrc: '၁၂/ဗတထ(နိုင်)၀၄၉၃၀၆', ygnId: '13017/02689',
      membershipNo: 'သမ-၁၁/ဗတထ/ရက', membershipType: MembershipType.probationer,
    ),
    Member(
      id: 'm313', memberNo: 'RC-313',
      nameEn: 'Ma Mya Kay Khaing Aye', nameMm: 'မမြကေခိုင်အေး',
      rank: MemberRank.private, unitType: UnitType.section,
      companyNo: 3, platoonNo: 1, sectionNo: 1,
      status: MemberStatus.active, bloodType: BloodType.OP,
      joinDate: DateTime(2024,10,18), currentRankDate: DateTime(2024,10,18),
      phone: '09 650 897 934', email: '',
      address: 'အခန်း (၂၃) (၄၈) ခန်းတွဲလိုင်း၊ ရဲရိပ်သာရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2007,3,1), emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.female,
      nrc: '၁၂/ဆကန(နိုင်)၀၀၂၉၁၁', ygnId: '13017/02662',
      membershipNo: 'တဖ-ရက/ဗတထ/၈၂', membershipType: MembershipType.official,
    ),
    Member(
      id: 'm314', memberNo: 'RC-314',
      nameEn: 'Daw Wut Ye Zin', nameMm: 'ဒေါ်ဝတ်ရည်ဇင်',
      rank: MemberRank.private, unitType: UnitType.section,
      companyNo: 3, platoonNo: 1, sectionNo: 1,
      status: MemberStatus.active, bloodType: BloodType.BP,
      joinDate: DateTime(2017,6,1), currentRankDate: DateTime(2026,1,1),
      phone: '09 795 369 134', email: '',
      address: 'အမှတ် (၂၄၂) ဇမ္ဗူသီရိ (၈) လမ်း၊ အမှတ် (၆/အနောက်) ရပ်ကွက်၊ သာကေတမြို့နယ်',
      dateOfBirth: DateTime(1993,9,1), emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.female,
      nrc: '၁၂/သကတ(နိုင်)၁၈၃၁၁၅', ygnId: '13017/00071',
      membershipNo: 'တဖ-ရက/ဗတထ/၂၁', membershipType: MembershipType.official,
    ),

    // m315 — C3/P1/S2 Private — မနန်းမေ
    Member(
      id: 'm315', memberNo: 'RC-315',
      nameEn: 'Ma Nan May', nameMm: 'မနန်းမေ',
      rank: MemberRank.private, unitType: UnitType.section,
      companyNo: 3, platoonNo: 1, sectionNo: 2,
      status: MemberStatus.active, bloodType: BloodType.AP,
      joinDate: DateTime(2022,1,3), currentRankDate: DateTime(2026,1,1),
      phone: '09 675 621 747', email: '',
      address: 'F-6 ရေနံမိသားစုလိုင်း၊ သန်လျက်စွန်းလမ်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2007,12,22), emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.female,
      nrc: 'လျှောက်ထားဆဲ', ygnId: '13017/02486',
      membershipNo: 'တဖ-ရက/ဗတထ/၄၉', membershipType: MembershipType.official,
    ),

    // m316-m317 — C3/P1/S2 Privates — vacant
    Member(id: 'm316', memberNo: 'RC-316', nameEn: '', nameMm: '', rank: MemberRank.private, unitType: UnitType.section, companyNo: 3, platoonNo: 1, sectionNo: 2, status: MemberStatus.active, bloodType: BloodType.OP, joinDate: DateTime(2020,1,1), dateOfBirth: DateTime(1990,1,1), phone: '', email: '', address: '', emergencyContact: '', emergencyPhone: '', skillIds: const [], role: UserRole.member, gender: Gender.female),
    Member(id: 'm317', memberNo: 'RC-317', nameEn: '', nameMm: '', rank: MemberRank.private, unitType: UnitType.section, companyNo: 3, platoonNo: 1, sectionNo: 2, status: MemberStatus.active, bloodType: BloodType.OP, joinDate: DateTime(2020,1,1), dateOfBirth: DateTime(1990,1,1), phone: '', email: '', address: '', emergencyContact: '', emergencyPhone: '', skillIds: const [], role: UserRole.member, gender: Gender.female),

    // m318 — Company 3 Platoon 2 Leader — ဒေါ်နွေးအိကဗျာဖူး
    Member(
      id: 'm318',
      memberNo: 'RC-318',
      nameEn: 'Daw Nway Eaint Kabya Phu',
      nameMm: 'ဒေါ်နွေးအိကဗျာဖူး',
      rank: MemberRank.platoonLeader,
      unitType: UnitType.platoon,
      companyNo: 3,
      platoonNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2017, 12, 27),
      currentRankDate: DateTime(2024, 9, 1),
      phone: '09 965 586 110',
      email: '',
      address: 'အမှတ် (ဘီ/၃) ကြာဖြူလမ်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2005, 2, 12),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.officer,
      gender: Gender.female,
      nrc: 'လျှောက်ထားဆဲ',
      ygnId: '13017/00068',
      membershipNo: 'တဖ-ရက/ဗတထ/၄၂',
      membershipType: MembershipType.official,
    ),

    // m319 — Company 3 Platoon 2 Sergeant — မပန်းအိဇင်
    Member(
      id: 'm319',
      memberNo: 'RC-319',
      nameEn: 'Ma Pan Eaint Zin',
      nameMm: 'မပန်းအိဇင်',
      rank: MemberRank.platoonSergeant,
      unitType: UnitType.platoon,
      companyNo: 3,
      platoonNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2021, 11, 26),
      currentRankDate: DateTime(2026, 1, 1),
      phone: '09 781 566 983',
      email: '',
      address: 'လိုင်း (၃) အခန်း (၃၁) လိုင်းသစ်၊ မီးရထားဝင်း၊ အမှတ် (၆) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2007, 7, 5),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.female,
      nrc: '၉/ပဗသ(နိုင်)၀၃၁၂၀၀',
      ygnId: '13017/02487',
      membershipNo: 'တဖ-ရက/ဗတထ/၆၃',
      membershipType: MembershipType.official,
    ),

    // m320 — C3/P2/S1 Section Leader — မဆုဝေနှင်း
    Member(
      id: 'm320',
      memberNo: 'RC-320',
      nameEn: 'Ma Su Wai Hnin',
      nameMm: 'မဆုဝေနှင်း',
      rank: MemberRank.sectionLeader,
      unitType: UnitType.section,
      companyNo: 3,
      platoonNo: 2,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.AP,
      joinDate: DateTime(2021, 6, 1),
      currentRankDate: DateTime(2026, 1, 1),
      phone: '09 970 278 205',
      email: '',
      address: 'အမှတ် (၄၈) ဗိုလ်တေဇ (၁) လမ်း၊ တပင်ရွှေထီးရပ်ကွက်၊ ဒလမြို့နယ်',
      dateOfBirth: DateTime(1998, 9, 18),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.female,
      nrc: '၁၂/ဒလန(နိုင်)၀၈၆၄၁၃',
      ygnId: '13017/02735',
      membershipNo: 'တဖ-ရက/ဗတထ/၁၁၅',
      membershipType: MembershipType.official,
    ),

    // m321 — C3/P2/S2 Section Leader — မအေးပြည့်သဇင်
    Member(
      id: 'm321',
      memberNo: 'RC-321',
      nameEn: 'Ma Aye Pyint Thar Zin',
      nameMm: 'မအေးပြည့်သဇင်',
      rank: MemberRank.sectionLeader,
      unitType: UnitType.section,
      companyNo: 3,
      platoonNo: 2,
      sectionNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2021, 1, 24),
      currentRankDate: DateTime(2025, 1, 1),
      phone: '09 421 064 678',
      email: '',
      address: 'လိုင်း (၁) အခန်း (၇) ဗိုလ်တထောင်ဘုရားလိုင်း၊ ရဲရိပ်သာရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2008, 8, 24),
      emergencyContact: '',
      emergencyPhone: '',
      skillIds: const [],
      role: UserRole.dutyOfficer,
      gender: Gender.female,
      nrc: 'လျှောက်ထားဆဲ',
      ygnId: '13017/01455',
      membershipNo: 'တဖ-ရက/ဗတထ/၇၃',
      membershipType: MembershipType.official,
    ),

    // m322-m323 — C3/P2/S1 Deputy Section Leaders
    Member(
      id: 'm322', memberNo: 'RC-322',
      nameEn: 'Ma Pwint Yati Aung', nameMm: 'မပွင့်ရတီအောင်',
      rank: MemberRank.deputySectionLeader, unitType: UnitType.section,
      companyNo: 3, platoonNo: 2, sectionNo: 1,
      status: MemberStatus.active, bloodType: BloodType.OP,
      joinDate: DateTime(2022,4,1), currentRankDate: DateTime(2024,9,1),
      phone: '09 403 547 287', email: '',
      address: 'အမှတ် (၃၉) ဇီဇဝါလမ်း၊ ရေကျော်၊ ပုဇွန်တောင်မြို့နယ်',
      dateOfBirth: DateTime(2005,2,3), emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.female,
      nrc: '၁၂/ပဇတ(နိုင်)၀၃၈၇၉၆', ygnId: '13017/01467',
      membershipNo: 'တဖ-ရက/ဗတထ/၅၆', membershipType: MembershipType.official,
    ),
    Member(
      id: 'm323', memberNo: 'RC-323',
      nameEn: 'Ma Kway Sin Paing Soe', nameMm: 'မကြယ်စင်ပိုင်စိုး',
      rank: MemberRank.deputySectionLeader, unitType: UnitType.section,
      companyNo: 3, platoonNo: 2, sectionNo: 1,
      status: MemberStatus.active, bloodType: BloodType.OP,
      joinDate: DateTime(2017,12,27), currentRankDate: DateTime(2026,1,1),
      phone: '09 422 618 394', email: '',
      address: 'အမှတ် (ဘီ/၃) ကြာဖြူလမ်း၊ အမှတ် (၁) ရပ်ကွက်၊ ဗိုလ်တထောင်မြို့နယ်',
      dateOfBirth: DateTime(2007,1,15), emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.female,
      nrc: 'လျှောက်ထားဆဲ', ygnId: '13017/01355',
      membershipNo: 'တဖ-ရက/ဗတထ/၅၄', membershipType: MembershipType.official,
    ),

    // m324-m325 — C3/P2/S2 Deputy Section Leaders
    Member(
      id: 'm324', memberNo: 'RC-324',
      nameEn: 'Ma Hnin Eaint Shwe Sin', nameMm: 'မနှင်းအိရွှေစင်',
      rank: MemberRank.deputySectionLeader, unitType: UnitType.section,
      companyNo: 3, platoonNo: 2, sectionNo: 2,
      status: MemberStatus.active, bloodType: BloodType.BP,
      joinDate: DateTime(2021,1,24), currentRankDate: DateTime(2025,1,1),
      phone: '09 260 213 636', email: '',
      address: 'အမှတ် (၁၂၉၁) သဒ္ဒါရုံ (၁) လမ်း၊ အမှတ် (၂) ရပ်ကွက်၊ သာကေတမြို့နယ်',
      dateOfBirth: DateTime(2010,4,10), emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.female,
      nrc: '၁၂/သကတ(နိုင်)၂၃၆၉၀၂', ygnId: '13017/02660',
      membershipNo: 'သမ-၉/ဗတထ/ရက', membershipType: MembershipType.probationer,
    ),
    Member(id: 'm325', memberNo: 'RC-325', nameEn: '', nameMm: '', rank: MemberRank.deputySectionLeader, unitType: UnitType.section, companyNo: 3, platoonNo: 2, sectionNo: 2, status: MemberStatus.active, bloodType: BloodType.OP, joinDate: DateTime(2020,1,1), dateOfBirth: DateTime(1990,1,1), phone: '', email: '', address: '', emergencyContact: '', emergencyPhone: '', skillIds: const [], role: UserRole.member, gender: Gender.female),

    // m326-m327 — C3/P2/S1 Privates
    Member(
      id: 'm326', memberNo: 'RC-326',
      nameEn: 'Ma San Thar Win Pyint', nameMm: 'မသဉ္ဇာဝင်းပြည့်',
      rank: MemberRank.private, unitType: UnitType.section,
      companyNo: 3, platoonNo: 2, sectionNo: 1,
      status: MemberStatus.active, bloodType: BloodType.OP,
      joinDate: DateTime(2025,7,4), currentRankDate: DateTime(2025,7,4),
      phone: '09 964 065 725', email: '',
      address: 'ဇေယျာလမ်း၊ အမှတ် (၁၀) ရပ်ကွက်၊ တောင်ဥက္ကလာပမြို့နယ်',
      dateOfBirth: DateTime(2006,11,21), emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.female,
      nrc: '၁၃/လရန(နိုင်)၂၇၀၂၃၇', membershipNo: 'တဖ-ရက/ဗတထ/၁၁၈',
      membershipType: MembershipType.official,
    ),
    Member(
      id: 'm327', memberNo: 'RC-327',
      nameEn: 'Ma Khin Myat Phu', nameMm: 'မခင်မြတ်ဖူး',
      rank: MemberRank.private, unitType: UnitType.section,
      companyNo: 3, platoonNo: 2, sectionNo: 1,
      status: MemberStatus.active, bloodType: BloodType.AP,
      joinDate: DateTime(2025,7,4), currentRankDate: DateTime(2025,7,4),
      phone: '09 781 654 637', email: '',
      address: 'အမှတ် (၁၆၂/၂) ပထမသီရိရိပ်သာ၊ အောက်ကြည့်မြင်တိုင်လမ်း၊ အလုံမြို့နယ်',
      dateOfBirth: DateTime(2007,4,9), emergencyContact: '', emergencyPhone: '',
      skillIds: const [], role: UserRole.member, gender: Gender.female,
      nrc: 'လျှောက်ထားဆဲ', membershipNo: 'တဖ-ရက/ဗတထ/၁၁၇',
      membershipType: MembershipType.official,
    ),

    // m328 — C3/P2/S1 Private — vacant
    Member(id: 'm328', memberNo: 'RC-328', nameEn: '', nameMm: '', rank: MemberRank.private, unitType: UnitType.section, companyNo: 3, platoonNo: 2, sectionNo: 1, status: MemberStatus.active, bloodType: BloodType.OP, joinDate: DateTime(2020,1,1), dateOfBirth: DateTime(1990,1,1), phone: '', email: '', address: '', emergencyContact: '', emergencyPhone: '', skillIds: const [], role: UserRole.member, gender: Gender.female),

    // m329-m331 — C3/P2/S2 Privates — all vacant
    Member(id: 'm329', memberNo: 'RC-329', nameEn: '', nameMm: '', rank: MemberRank.private, unitType: UnitType.section, companyNo: 3, platoonNo: 2, sectionNo: 2, status: MemberStatus.active, bloodType: BloodType.OP, joinDate: DateTime(2020,1,1), dateOfBirth: DateTime(1990,1,1), phone: '', email: '', address: '', emergencyContact: '', emergencyPhone: '', skillIds: const [], role: UserRole.member, gender: Gender.female),
    Member(id: 'm330', memberNo: 'RC-330', nameEn: '', nameMm: '', rank: MemberRank.private, unitType: UnitType.section, companyNo: 3, platoonNo: 2, sectionNo: 2, status: MemberStatus.active, bloodType: BloodType.OP, joinDate: DateTime(2020,1,1), dateOfBirth: DateTime(1990,1,1), phone: '', email: '', address: '', emergencyContact: '', emergencyPhone: '', skillIds: const [], role: UserRole.member, gender: Gender.female),
    Member(id: 'm331', memberNo: 'RC-331', nameEn: '', nameMm: '', rank: MemberRank.private, unitType: UnitType.section, companyNo: 3, platoonNo: 2, sectionNo: 2, status: MemberStatus.active, bloodType: BloodType.OP, joinDate: DateTime(2020,1,1), dateOfBirth: DateTime(1990,1,1), phone: '', email: '', address: '', emergencyContact: '', emergencyPhone: '', skillIds: const [], role: UserRole.member, gender: Gender.female),

    // ─────────────────────────────────────────────────────────
    // COMPANY 4 — Intentionally empty for now.
    // No mock data entries. Structure, permissions, and rank/unit
    // logic (UnitType.company/platoon, companyNo: 4, the Company 4
    // filter option, permission scope rules, etc.) all remain fully
    // intact elsewhere in the app — only the placeholder data here
    // was removed. To re-add Company 4 later, copy the Company 1 or
    // Company 3 block's structure (Commander → Deputy → Sgt Major →
    // Platoons → Sections → Privates) with companyNo: 4.
    // ─────────────────────────────────────────────────────────
  ];
}

// ═══════════════════════════════════════════════════════════════
// MOCK SKILLS
// ═══════════════════════════════════════════════════════════════
class MockSkills {
  static const List<Skill> all = [
    Skill(id: 'sk1', nameEn: 'First Aid Level 1', nameMm: 'အသက်ဆယ်ယူ အဆင့် ၁', category: 'Medical', expiryMonths: 24),
    Skill(id: 'sk2', nameEn: 'First Aid Level 2', nameMm: 'အသက်ဆယ်ယူ အဆင့် ၂', category: 'Medical', expiryMonths: 24),
    Skill(id: 'sk3', nameEn: 'CPR Certified', nameMm: 'CPR လက်မှတ်', category: 'Medical', expiryMonths: 12),
    Skill(id: 'sk4', nameEn: 'Disaster Management', nameMm: 'ဘေးအန္တရာယ် စီမံခန့်ခွဲမှု', category: 'Disaster'),
    Skill(id: 'sk5', nameEn: 'Leadership', nameMm: 'ခေါင်းဆောင်မှု', category: 'Administrative'),
  ];

  static Skill? findById(String id) {
    try { return all.firstWhere((s) => s.id == id); }
    catch (_) { return null; }
  }
}

// ═══════════════════════════════════════════════════════════════
// MOCK DUTIES — empty until real data entered via the app
// (Matches Module 3 placeholder convention)
// ═══════════════════════════════════════════════════════════════
class MockDuties {
  // In-memory store — resets on app restart, replaced by Supabase in
  // Module 16. Seeded with a mix of upcoming, ongoing, and completed
  // duties using real Company 1/3 members so the Duties module has
  // something meaningful to display and test against.
  static final List<Duty> all = _seedDuties();

  static List<Duty> _seedDuties() {
    final now = DateTime.now();
    DateTime d(int dayOffset) =>
        DateTime(now.year, now.month, now.day + dayOffset);

    DutyMember accepted(String memberId, DutyRoleInDuty role) => DutyMember(
          memberId: memberId,
          roleInDuty: role,
          status: DutyAssignmentStatus.accepted,
          assignedAt: d(-3),
          respondedAt: d(-2),
        );

    DutyMember pending(String memberId, DutyRoleInDuty role) => DutyMember(
          memberId: memberId,
          roleInDuty: role,
          status: DutyAssignmentStatus.pending,
          assignedAt: d(-1),
        );

    DutyMember completedAssignment(String memberId, DutyRoleInDuty role) =>
        DutyMember(
          memberId: memberId,
          roleInDuty: role,
          status: DutyAssignmentStatus.completed,
          assignedAt: d(-10),
          respondedAt: d(-9),
        );

    return [
      // Upcoming regular duty — Company 1, Platoon 1
      Duty(
        id: 'duty1',
        title: 'Township Health Fair — First Aid Support',
        titleMm: 'မြို့နယ်ကျန်းမာရေးပွဲ — ရှေးဦးပြုစုထောက်ပံ့မှု',
        type: DutyType.firstAid,
        scale: DutyScale.regular,
        date: d(3),
        startHour: 8, startMinute: 0,
        endHour: 16, endMinute: 0,
        location: 'Botahtaung Township Hall',
        members: [
          accepted('m103', DutyRoleInDuty.officer),
          accepted('m107', DutyRoleInDuty.member),
          pending('m105', DutyRoleInDuty.member),
        ],
        status: DutyStatus.upcoming,
        description: 'Standard first aid coverage for the township health fair.',
      ),

      // Upcoming emergency duty — Company 3
      Duty(
        id: 'duty2',
        title: 'Flood Response Standby',
        titleMm: 'ရေကြီးရေလျှံ အရေးပေါ်အသင့်ရှိမှု',
        type: DutyType.disaster,
        scale: DutyScale.regular,
        date: d(1),
        startHour: 6, startMinute: 0,
        endHour: 18, endMinute: 0,
        location: 'Pazundaung Creek Area',
        members: [
          accepted('m304', DutyRoleInDuty.officer),
          accepted('m306', DutyRoleInDuty.member),
          accepted('m308', DutyRoleInDuty.member),
        ],
        status: DutyStatus.upcoming,
        description: 'Monitoring water levels, on standby for evacuation support.',
      ),

      // Ongoing duty — today
      Duty(
        id: 'duty3',
        title: 'Blood Donation Drive',
        titleMm: 'သွေးလှူဒါန်းမှုအခမ်းအနား',
        type: DutyType.bloodDonation,
        scale: DutyScale.regular,
        date: d(0),
        startHour: 9, startMinute: 0,
        endHour: 15, endMinute: 0,
        location: 'Brigade Office Compound',
        members: [
          accepted('m101', DutyRoleInDuty.commander),
          accepted('m102', DutyRoleInDuty.officer),
          accepted('m106', DutyRoleInDuty.member),
          accepted('m118', DutyRoleInDuty.member),
        ],
        status: DutyStatus.ongoing,
        description: 'Quarterly blood donation drive in partnership with the regional blood bank.',
      ),

      // Completed duty — last week
      Duty(
        id: 'duty4',
        title: 'School Safety Patrol',
        titleMm: 'ကျောင်းဘေးကင်းရေးကင်းလှည့်ခြင်း',
        type: DutyType.patrol,
        scale: DutyScale.regular,
        date: d(-7),
        startHour: 7, startMinute: 0,
        endHour: 9, endMinute: 0,
        location: 'No. 1 Basic Education School',
        members: [
          completedAssignment('m120', DutyRoleInDuty.officer),
          completedAssignment('m113', DutyRoleInDuty.member),
        ],
        status: DutyStatus.completed,
        description: 'Morning school crossing patrol — completed without incident.',
      ),

      // Completed emergency duty — large scale, last month
      Duty(
        id: 'duty5',
        title: 'New Year Festival Crowd Safety',
        titleMm: 'နှစ်ဆက်ပွဲတော် လူစုလူပေါင်းဘေးကင်းရေး',
        type: DutyType.eventMedical,
        scale: DutyScale.largeScale,
        date: d(-30),
        startHour: 18, startMinute: 0,
        endHour: 23, endMinute: 30,
        location: 'Botahtaung Pagoda Festival Grounds',
        members: [
          completedAssignment('m1', DutyRoleInDuty.commander),
          completedAssignment('m101', DutyRoleInDuty.officer),
          completedAssignment('m302', DutyRoleInDuty.officer),
          completedAssignment('m109', DutyRoleInDuty.member),
          completedAssignment('m312', DutyRoleInDuty.member),
        ],
        status: DutyStatus.completed,
        description: 'Large-scale festival medical and crowd safety coverage.',
        isEvent: true,
      ),

      // Upcoming large-scale event — Charity Marathon (links to an
      // Event with positions — see MockEvents below)
      Duty(
        id: 'duty7',
        title: 'Botahtaung Charity Marathon — Medical Coverage',
        titleMm: 'ဗိုလ်တထောင် မဟာမိတ် မာရသွန် — ကျန်းမာရေးထောက်ပံ့မှု',
        type: DutyType.eventMedical,
        scale: DutyScale.largeScale,
        date: d(14),
        startHour: 5, startMinute: 0,
        endHour: 11, endMinute: 0,
        location: 'Botahtaung Township — Strand Road Route',
        members: [
          accepted('m1', DutyRoleInDuty.commander),
          accepted('m101', DutyRoleInDuty.officer),
          accepted('m302', DutyRoleInDuty.officer),
          pending('m109', DutyRoleInDuty.member),
          accepted('m120', DutyRoleInDuty.member),
          pending('m306', DutyRoleInDuty.member),
        ],
        status: DutyStatus.upcoming,
        description: 'Medical and safety coverage along the marathon route, with aid stations and a command post.',
        isEvent: true,
        eventId: 'event1',
      ),

      // Cancelled duty — example
      Duty(
        id: 'duty6',
        title: 'Joint Training Exercise',
        titleMm: 'ပူးတွဲလေ့ကျင့်ခန်း',
        type: DutyType.training,
        scale: DutyScale.regular,
        date: d(-2),
        startHour: 13, startMinute: 0,
        endHour: 16, endMinute: 0,
        location: 'Brigade Training Hall',
        members: [
          DutyMember(
            memberId: 'm118',
            roleInDuty: DutyRoleInDuty.officer,
            status: DutyAssignmentStatus.rejected,
            assignedAt: d(-5),
            respondedAt: d(-4),
            rejectionReason: 'Venue unavailable — rescheduling needed.',
          ),
        ],
        status: DutyStatus.cancelled,
        description: 'Cancelled due to venue conflict.',
      ),
    ];
  }

  static Duty? findById(String id) {
    try {
      return all.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Adds a newly created duty to the in-memory list, so it actually
  /// shows up in the Duties screen this session. Replaced by a real
  /// Supabase insert in Module 16.
  static void add(Duty duty) {
    all.add(duty);
  }

  /// All DutyMember assignment records for `memberId`, paired with
  /// the Duty they belong to (most recent first).
  static List<({Duty duty, DutyMember assignment})> getMemberDuties(String memberId) {
    final results = <({Duty duty, DutyMember assignment})>[];
    for (final duty in all) {
      final assignment =
          duty.members.where((dm) => dm.memberId == memberId).firstOrNull;
      if (assignment != null) {
        results.add((duty: duty, assignment: assignment));
      }
    }
    results.sort((a, b) => b.duty.date.compareTo(a.duty.date));
    return results;
  }

  /// Duties visible to `member` based on unit scope — reuses the same
  /// company-scoping convention as other Module 4/5 screens. Brigade
  /// Office sees everything; everyone else sees duties where at least
  /// one assigned member shares their company (a reasonable proxy
  /// for "duties relevant to my unit" until a dedicated unit field
  /// is added to Duty in a later module).
  static List<Duty> visibleTo(Member viewer) {
    if (viewer.unitType == UnitType.brigadeOffice) return all;
    if (PermissionService.hasAdminOrMasterAccess(viewer)) return all;

    return all.where((duty) {
      return duty.members.any((dm) {
        final m = MockMembers.findById(dm.memberId);
        return m != null && m.companyNo == viewer.companyNo;
      });
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════
// MOCK MEETINGS — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockMeetings {
  static final List<Meeting> all = [];

  static Meeting? findById(String id) => null;

  static List<Meeting> visibleTo(Member member) => [];
}

// ═══════════════════════════════════════════════════════════════
// MOCK INVESTIGATIONS — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockInvestigations {
  static final List<Investigation> all = [];

  static Investigation? findById(String id) => null;
}

// ═══════════════════════════════════════════════════════════════
// MOCK PUNISHMENTS — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockPunishments {
  static final List<Punishment> all = [];

  static List<Punishment> forMember(String memberId) => [];
}

// ═══════════════════════════════════════════════════════════════
// MOCK BLOOD DONORS — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockBloodDonors {
  static final List<BloodDonor> all = [];

  static BloodDonor? findById(String id) => null;

  static List<BloodDonor> eligibleByBloodType(BloodType type) => [];
}

// ═══════════════════════════════════════════════════════════════
// MOCK NOTIFICATIONS — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockNotifications {
  // In-memory store — resets on app restart, replaced by Supabase in
  // Module 16.
  static final List<AppNotification> all = [];

  static List<AppNotification> forMember(String memberId) {
    return all.where((n) => n.recipientId == memberId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static int unreadCount(String memberId) {
    return all.where((n) => n.recipientId == memberId && !n.isRead).length;
  }

  static void add(AppNotification notification) {
    all.add(notification);
  }

  /// Sends an availability-change notification up the FULL chain of
  /// command from `member` to Brigade Office — not just the immediate
  /// higher rank. Used when a member changes their own short-term
  /// Available/Not Available status, which applies immediately with
  /// no approval needed; this is purely an FYI to leadership.
  ///
  /// Chain walked: member's direct higher rank → their higher rank →
  /// ... → Brigade Office. Determined structurally from unit
  /// assignment (section → platoon → company → brigade), not by
  /// walking actual person-to-person rank order, since multiple
  /// people can hold the same supervisory tier.
  static void notifyChainOfCommandOfAvailabilityChange({
    required Member member,
    required bool isNowAvailable,
  }) {
    final recipients = _chainOfCommandFor(member);
    final statusText = isNowAvailable ? 'Available' : 'Not Available';

    for (final recipient in recipients) {
      add(AppNotification(
        id: 'notif_${DateTime.now().microsecondsSinceEpoch}_${recipient.id}',
        recipientId: recipient.id,
        title: 'Availability Update',
        body: '${member.nameEn} (${member.rankNameEn}) marked themselves $statusText.',
        type: NotificationType.availability,
        priority: NotificationPriority.normal,
        isRead: false,
        createdAt: DateTime.now(),
        routeTo: 'members/${member.id}',
      ));
    }
  }

  /// Walks up the chain of command for `member`: direct higher-rank
  /// supervisors at section → platoon → company level, plus all of
  /// Brigade Office at the top, regardless of how many tiers exist
  /// in between. Skips levels that don't apply (e.g. a member with no
  /// platoon assignment skips straight to company/brigade).
  static List<Member> _chainOfCommandFor(Member member) {
    final all = MockMembers.all.where((m) => m.nameEn.isNotEmpty);
    final chain = <Member>[];

    void addIfNotSelf(Iterable<Member> candidates) {
      for (final c in candidates) {
        if (c.id != member.id && !chain.any((existing) => existing.id == c.id)) {
          chain.add(c);
        }
      }
    }

    // Section level (Deputy Section Leader -> Section Leader)
    if (member.sectionNo != null) {
      addIfNotSelf(all.where((m) =>
          m.companyNo == member.companyNo &&
          m.platoonNo == member.platoonNo &&
          m.sectionNo == member.sectionNo &&
          m.rank == MemberRank.sectionLeader));
    }

    // Platoon level (Platoon Sergeant, Platoon Leader)
    if (member.platoonNo != null) {
      addIfNotSelf(all.where((m) =>
          m.companyNo == member.companyNo &&
          m.platoonNo == member.platoonNo &&
          (m.rank == MemberRank.platoonSergeant ||
              m.rank == MemberRank.platoonLeader)));
    }

    // Company level (Company Sergeant Major, Deputy/Company Commander)
    if (member.companyNo != null) {
      addIfNotSelf(all.where((m) =>
          m.companyNo == member.companyNo &&
          (m.rank == MemberRank.companySergeantMajor ||
              m.rank == MemberRank.deputyCompanyCommander ||
              m.rank == MemberRank.companyCommander)));
    }

    // Brigade Office — always included at the top of the chain
    addIfNotSelf(all.where((m) => m.unitType == UnitType.brigadeOffice));

    return chain;
  }
}

// ═══════════════════════════════════════════════════════════════
// MOCK AVAILABILITY — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockAvailability {
  // In-memory store — resets on app restart, replaced by Supabase in
  // Module 16. Seeded with a few sample entries so the calendar UI has
  // something to render during development.
  static final List<AvailabilityEntry> _entries = _seedEntries();

  static List<AvailabilityEntry> _seedEntries() {
    final now = DateTime.now();
    DateTime d(int dayOffset) =>
        DateTime(now.year, now.month, now.day + dayOffset);

    // Real (non-vacant) members across Company 1 and Company 3 —
    // used to seed a deterministic but varied pattern so the unit
    // summary breakdown (by company/platoon/section) and the day
    // trend chart (today/week/month) have meaningful data to show.
    const company1MemberIds = [
      'm101', 'm102', 'm103', 'm105', 'm106', 'm107', 'm108', 'm109',
      'm110', 'm111', 'm112', 'm113', 'm114', 'm115', 'm116', 'm117',
      'm118', 'm119', 'm120', 'm121', 'm122', 'm124', 'm125', 'm126',
      'm127',
    ];
    const company3MemberIds = [
      'm302', 'm303', 'm304', 'm305', 'm306', 'm307', 'm308', 'm309',
      'm310', 'm311', 'm312', 'm313', 'm314', 'm315', 'm318', 'm319',
      'm320', 'm321', 'm322', 'm323', 'm324', 'm326', 'm327',
    ];
    final allIds = [...company1MemberIds, ...company3MemberIds];

    final entries = <AvailabilityEntry>[];
    var counter = 0;

    // Deterministic pattern across a -10..+20 day window (covers last
    // week, this week, and this month comfortably either side of
    // today): each member has a short "not available" block on a
    // day offset derived from their position in the list, so the
    // pattern is spread out rather than everyone clustering on the
    // same days. Roughly 1 in 4 members get a block in any given week.
    for (var i = 0; i < allIds.length; i++) {
      final memberId = allIds[i];

      // Stagger start day using member index so blocks spread across
      // the whole window instead of bunching up.
      final startOffset = -10 + ((i * 3) % 28);
      final blockLength = 1 + (i % 3); // 1, 2, or 3 day blocks
      final groupId = 'rg_seed_$i';

      for (var dayInBlock = 0; dayInBlock < blockLength; dayInBlock++) {
        counter++;
        entries.add(AvailabilityEntry(
          id: 'ae_seed_$counter',
          memberId: memberId,
          date: d(startOffset + dayInBlock),
          status: DayAvailabilityStatus.notAvailable,
          rangeGroupId: blockLength > 1 ? groupId : null,
        ));
      }
    }

    return entries;
  }

  static List<AvailabilityEntry> forMember(String memberId) {
    return _entries.where((e) => e.memberId == memberId).toList();
  }

  static List<AvailabilityEntry> forMemberInMonth(
    String memberId,
    int year,
    int month,
  ) {
    return _entries
        .where((e) =>
            e.memberId == memberId &&
            e.date.year == year &&
            e.date.month == month)
        .toList();
  }

  static List<AvailabilityEntry> forMembersOnDate(
    List<String> memberIds,
    DateTime date,
  ) {
    return _entries
        .where((e) => memberIds.contains(e.memberId) && e.isOnDate(date))
        .toList();
  }

  /// Set a single day's status directly (Master Access/Admin path, or
  /// applying an already-approved request). Replaces any existing
  /// entry for that member+date.
  static void setDay({
    required String memberId,
    required DateTime date,
    required DayAvailabilityStatus status,
    String? reason,
    String? rangeGroupId,
  }) {
    _entries.removeWhere((e) => e.memberId == memberId && e.isOnDate(date));
    _entries.add(AvailabilityEntry(
      id: 'ae_${DateTime.now().microsecondsSinceEpoch}',
      memberId: memberId,
      date: DateTime(date.year, date.month, date.day),
      status: status,
      rangeGroupId: rangeGroupId,
      reason: reason,
    ));
  }

  /// Set a date range (inclusive) all at once, sharing one rangeGroupId
  /// so they collapse into a single visual block.
  static void setRange({
    required String memberId,
    required DateTime startDate,
    required DateTime endDate,
    required DayAvailabilityStatus status,
    String? reason,
  }) {
    final groupId = 'rg_${DateTime.now().microsecondsSinceEpoch}';
    var current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    while (!current.isAfter(end)) {
      setDay(
        memberId: memberId,
        date: current,
        status: status,
        reason: reason,
        rangeGroupId: groupId,
      );
      current = current.add(const Duration(days: 1));
    }
  }

  /// Clear a single day back to default (no entry = implicitly
  /// available, per the existing isAvailable/status fields).
  static void clearDay({required String memberId, required DateTime date}) {
    _entries.removeWhere((e) => e.memberId == memberId && e.isOnDate(date));
  }
}

// ═══════════════════════════════════════════════════════════════
// MOCK CERTIFICATES — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockCertificates {
  static final List<Certificate> all = [];

  static List<Certificate> forMember(String memberId) => [];
}

// ═══════════════════════════════════════════════════════════════
// MOCK TRANSFER HISTORY — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockTransferHistory {
  static final List<TransferHistory> all = [];

  static List<TransferHistory> forMember(String memberId) => [];
}

// ═══════════════════════════════════════════════════════════════
// MOCK EQUIPMENT — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockEquipment {
  static final List<Equipment> all = [
    Equipment(id: 'eq1', name: 'First Aid Kit (Standard)', nameMm: 'အသက်ဆယ်ယူပစ္စည်းအိတ် (သာမန်)', category: 'Medical', totalQuantity: 20, availableQuantity: 14, condition: 'Good', storageLocation: 'Brigade Office Store Room A'),
    Equipment(id: 'eq2', name: 'Stretcher', nameMm: 'လေငွေ့ထမ်းစင်', category: 'Medical', totalQuantity: 6, availableQuantity: 5, condition: 'Good', storageLocation: 'Brigade Office Store Room A'),
    Equipment(id: 'eq3', name: 'Megaphone', nameMm: 'အသံချဲ့စက်', category: 'Communication', totalQuantity: 8, availableQuantity: 6, condition: 'Good', storageLocation: 'Brigade Office Store Room B'),
    Equipment(id: 'eq4', name: 'Walkie-Talkie Set', nameMm: 'ဝေါ်ကီတေါ်ကီ', category: 'Communication', totalQuantity: 12, availableQuantity: 9, condition: 'Fair', storageLocation: 'Brigade Office Store Room B'),
    Equipment(id: 'eq5', name: 'Barricade Tape Roll', nameMm: 'အတားအဆီးကြိုးလိပ်', category: 'Safety', totalQuantity: 30, availableQuantity: 22, condition: 'Good', storageLocation: 'Brigade Office Store Room C'),
    Equipment(id: 'eq6', name: 'Reflective Vest', nameMm: 'အလင်းပြန်အင်္ကျီ', category: 'Safety', totalQuantity: 40, availableQuantity: 35, condition: 'Good', storageLocation: 'Brigade Office Store Room C'),
  ];
}

// ═══════════════════════════════════════════════════════════════
// MODULE 7 ADDITIONS — MockEvents
//
// Seeded with one realistic large-scale event (charity marathon
// along Strand Road, Botahtaung) linked to duty7 above. Positions
// use real-world coordinates around the Botahtaung/Strand Road area
// of Yangon so the map renders a believable route layout.
// ═══════════════════════════════════════════════════════════════
class MockEvents {
  static final List<Event> all = _seedEvents();

  static List<Event> _seedEvents() {
    final now = DateTime.now();
    DateTime d(int dayOffset) =>
        DateTime(now.year, now.month, now.day + dayOffset);

    return [
      Event(
        id: 'event1',
        dutyId: 'duty7',
        title: 'Botahtaung Charity Marathon — Medical Coverage',
        titleMm: 'ဗိုလ်တထောင် မဟာမိတ် မာရသွန် — ကျန်းမာရေးထောက်ပံ့မှု',
        date: d(14),
        startHour: 5, startMinute: 0,
        endHour: 11, endMinute: 0,
        location: 'Botahtaung Township — Strand Road Route',
        latitude: 16.7733, longitude: 96.1689, // Botahtaung jetty area
        description: 'Medical and safety coverage along the marathon route, with aid stations and a command post.',
        status: EventStatus.planning,
        positions: [
          EventPosition(
            id: 'pos1',
            eventId: 'event1',
            nameEn: 'Command Post — Botahtaung Jetty',
            type: EventPositionType.command,
            locationDescription: 'Start/finish line, Botahtaung Jetty',
            latitude: 16.7733, longitude: 96.1689,
            requiredMembers: 2,
            assignedMemberIds: const ['m1'],
            requiredSkillIds: const ['sk5'], // Leadership
            equipmentIds: const ['eq3', 'eq4'], // Megaphone, Walkie-talkie
          ),
          EventPosition(
            id: 'pos2',
            eventId: 'event1',
            nameEn: 'Aid Station 1 — Strand Road Junction',
            type: EventPositionType.point,
            locationDescription: 'Strand Road & Lower Pazundaung Street junction',
            latitude: 16.7708, longitude: 96.1652,
            requiredMembers: 3,
            assignedMemberIds: const ['m101'],
            requiredSkillIds: const ['sk1'], // First Aid Level 1
            equipmentIds: const ['eq1', 'eq2'], // First aid kit, Stretcher
          ),
          EventPosition(
            id: 'pos3',
            eventId: 'event1',
            nameEn: 'Aid Station 2 — Pansodan Junction',
            type: EventPositionType.point,
            locationDescription: 'Strand Road & Pansodan Street junction',
            latitude: 16.7726, longitude: 96.1583,
            requiredMembers: 3,
            assignedMemberIds: const [],
            requiredSkillIds: const ['sk1'],
            equipmentIds: const ['eq1', 'eq2'],
          ),
          EventPosition(
            id: 'pos4',
            eventId: 'event1',
            nameEn: 'Mobile Patrol — Route Midpoint',
            type: EventPositionType.patrol,
            locationDescription: 'Patrolling Strand Road between aid stations',
            latitude: 16.7717, longitude: 96.1618,
            requiredMembers: 2,
            assignedMemberIds: const ['m120'],
            requiredSkillIds: const ['sk1'],
            equipmentIds: const ['eq4', 'eq6'], // Walkie-talkie, Vest
            // Patrols only this stretch — Aid Station 1 to the
            // midpoint — NOT the full marathon route, demonstrating
            // that a patrol's path doesn't have to cover everything.
            patrolPath: const [
              RouteWaypoint(latitude: 16.7708, longitude: 96.1652, label: 'Aid Station 1'),
              RouteWaypoint(latitude: 16.7717, longitude: 96.1618, label: 'Midpoint'),
            ],
          ),
          EventPosition(
            id: 'pos5',
            eventId: 'event1',
            nameEn: 'Standby — Reserve Team',
            type: EventPositionType.standby,
            locationDescription: 'Brigade Office, on call for overflow',
            latitude: 16.7745, longitude: 96.1701,
            requiredMembers: 2,
            assignedMemberIds: const [],
            requiredSkillIds: const [],
            equipmentIds: const ['eq1'],
          ),
        ],
        routes: [
          EventRoute(
            id: 'route1',
            eventId: 'event1',
            name: 'Main Route — Strand Road Out-and-Back',
            colorHex: '#1D9E75', // teal
            waypoints: const [
              RouteWaypoint(latitude: 16.7733, longitude: 96.1689, label: 'Start — Botahtaung Jetty'),
              RouteWaypoint(latitude: 16.7720, longitude: 96.1665),
              RouteWaypoint(latitude: 16.7708, longitude: 96.1652, label: 'Aid Station 1 — Strand Rd Junction'),
              RouteWaypoint(latitude: 16.7717, longitude: 96.1618, label: 'Midpoint — Patrol Zone'),
              RouteWaypoint(latitude: 16.7726, longitude: 96.1583, label: 'Aid Station 2 — Pansodan Junction'),
              RouteWaypoint(latitude: 16.7717, longitude: 96.1618),
              RouteWaypoint(latitude: 16.7708, longitude: 96.1652),
              RouteWaypoint(latitude: 16.7720, longitude: 96.1665),
              RouteWaypoint(latitude: 16.7733, longitude: 96.1689, label: 'Finish — Botahtaung Jetty'),
            ],
          ),
        ],
      ),
    ];
  }

  static Event? findById(String id) {
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Adds a newly created event to the in-memory list. Replaced by a
  /// real Supabase insert in Module 16.
  static void add(Event event) {
    all.add(event);
  }

  /// Replaces an existing event by id (e.g. after setting the venue
  /// location, or adding/editing positions and routes).
  static void update(Event updated) {
    final index = all.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      all[index] = updated;
    } else {
      all.add(updated);
    }
  }

  static Event? findByDutyId(String dutyId) {
    try {
      return all.firstWhere((e) => e.dutyId == dutyId);
    } catch (_) {
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// MOCK FUND ENTRIES — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockFundEntries {
  static final List<FundEntry> all = [];

  static double get balance =>
      all.fold(0.0, (sum, e) => e.type == 'income' ? sum + e.amount : sum - e.amount);
}

// ═══════════════════════════════════════════════════════════════
// MOCK LIBRARY DOCUMENTS — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockLibrary {
  static final List<LibraryDocument> all = [];
}