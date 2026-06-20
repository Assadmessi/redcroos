import '../models/models.dart';
import '../../core/constants/app_constants.dart';

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
  static final List<Duty> all = [];

  static Duty? findById(String id) => null;

  static List<DutyMember> getMemberDuties(String memberId) => [];
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
  static final List<AppNotification> all = [];

  static List<AppNotification> forMember(String memberId) => [];

  static int unreadCount(String memberId) => 0;
}

// ═══════════════════════════════════════════════════════════════
// MOCK AVAILABILITY — empty until real data entered via the app
// ═══════════════════════════════════════════════════════════════
class MockAvailability {
  static List<MemberAvailability> forMemberThisMonth(String memberId) => [];
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
  static final List<Equipment> all = [];
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