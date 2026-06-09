import '../models/models.dart';
import '../../core/constants/app_constants.dart';

// ─────────────────────────────────────────────
// MOCK MEMBERS — Real brigade structure
// Based on actual org chart
// ─────────────────────────────────────────────
class MockMembers {
  static final List<Member> all = [

    // ══════════════════════════════════════
    // BRIGADE OFFICE (ရုံးအဖွဲ့)
    // ══════════════════════════════════════

    Member(
      id: 'm1', memberNo: 'RC-001',
      nameEn: 'U Maung Maung Than', nameMm: 'ဦးမောင်မောင်သန်း',
      rank: MemberRank.brigadeCommander,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.AP,
      joinDate: DateTime(2010, 1, 1),
      phone: '09 508 5068',
      email: 'commander@redcross.mm',
      address: 'No.23, 5th Floor, 45th Street, Ward 9, Botahtaung',
      dateOfBirth: DateTime(1962, 10, 18),
      emergencyContact: 'Daw Khin', emergencyPhone: '09 111 222 333',
      skillIds: ['sk1', 'sk2', 'sk5'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.admin,
    ),

    Member(
      id: 'm2', memberNo: 'RC-002',
      nameEn: 'Daw Khin Than Soe', nameMm: 'ဒေါ်ခင်သန်းစိုး',
      rank: MemberRank.deputyBrigadeCommander,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2012, 1, 1),
      phone: '09 442 527 816',
      email: 'deputy@redcross.mm',
      address: 'No.162, 46th Street, Ward 10, Botahtaung',
      dateOfBirth: DateTime(1968, 7, 12),
      emergencyContact: 'U Mya Than', emergencyPhone: '09 333 444 555',
      skillIds: ['sk1', 'sk2', 'sk5'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.admin,
    ),

    Member(
      id: 'm3', memberNo: 'RC-003',
      nameEn: 'U Yan Paing', nameMm: 'ဦးရန်ပိုင်',
      rank: MemberRank.companyCommander,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2015, 3, 1),
      phone: '09 968 817 848',
      email: 'yanpaing@redcross.mm',
      address: 'No.B-5, Kra Phyu St, Ward 1, Botahtaung',
      dateOfBirth: DateTime(1982, 9, 8),
      emergencyContact: 'Ma Su Su', emergencyPhone: '09 444 555 666',
      skillIds: ['sk1', 'sk2', 'sk5'],
      isBrigadeOfficeChief: true,    // Chief of Brigade Office
      hasBrigadeOfficeAuthority: false,
      role: UserRole.seniorOfficer,
    ),

    Member(
      id: 'm4', memberNo: 'RC-004',
      nameEn: 'U Aye Htet Hein', nameMm: 'ဦးအေးထက်ဟိန်း',
      rank: MemberRank.deputyCompanyCommander,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.ABP,
      joinDate: DateTime(2018, 1, 1),
      phone: '09 263 137 792',
      email: 'ayehtet@redcross.mm',
      address: 'No.18/20, 49th Street, Ward 5, Botahtaung',
      dateOfBirth: DateTime(1999, 1, 22),
      emergencyContact: 'U Khin Maung Lwin', emergencyPhone: '09 222 333 444',
      skillIds: ['sk1', 'sk4'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.officer,
    ),

    Member(
      id: 'm6', memberNo: 'RC-006',
      nameEn: 'Ma Wut Yee Zin', nameMm: 'မဝတ်ရည်ဇင်',
      rank: MemberRank.warrantOfficer,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2019, 1, 1),
      phone: '09 295 369 134',
      email: 'wutyeezin@redcross.mm',
      address: 'No.434, Merchant Rd, Ward 8, Botahtaung',
      dateOfBirth: DateTime(1993, 9, 1),
      emergencyContact: 'U Khin Maung Lwin', emergencyPhone: '09 555 666 777',
      skillIds: ['sk1', 'sk3'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.dutyOfficer,
    ),

    Member(
      id: 'm7', memberNo: 'RC-007',
      nameEn: 'Ko San Thu Aung', nameMm: 'ကိုစည်သူအောင်',
      rank: MemberRank.sergeantClerk,
      unitType: UnitType.brigadeOffice,
      status: MemberStatus.active,
      bloodType: BloodType.ABP,
      joinDate: DateTime(2020, 1, 1),
      phone: '09 795 369 134',
      email: 'santhauung@redcross.mm',
      address: 'Room 35, 48 Block Line, Police Quarters, Botahtaung',
      dateOfBirth: DateTime(2000, 9, 26),
      emergencyContact: 'U Thint Sann', emergencyPhone: '09 666 777 888',
      skillIds: ['sk1'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.dutyOfficer,
    ),

    // ══════════════════════════════════════
    // COMPANY 1 — တပ်ဖွဲ့ခွဲ(၁)
    // ══════════════════════════════════════

    Member(
      id: 'm101', memberNo: 'RC-101',
      nameEn: 'U Yan Paing (C1)', nameMm: 'ဦးရန်ပိုင် (တပ်ခွဲ၁)',
      rank: MemberRank.companyCommander,
      unitType: UnitType.company,
      companyNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2015, 3, 1),
      phone: '09 429 111 807',
      email: 'c1commander@redcross.mm',
      address: 'No.B-8, Kra Phyu St, Ward 1, Botahtaung',
      dateOfBirth: DateTime(1982, 9, 8),
      emergencyContact: 'Ma Su Su', emergencyPhone: '09 444 555 666',
      skillIds: ['sk1', 'sk2', 'sk5'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.seniorOfficer,
    ),

    Member(
      id: 'm102', memberNo: 'RC-102',
      nameEn: 'U Aung Way Htun', nameMm: 'ဦးအောင်ဝေထွန်း',
      rank: MemberRank.deputyCompanyCommander,
      unitType: UnitType.company,
      companyNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2016, 6, 1),
      phone: '09 510 1069',
      email: 'c1deputy@redcross.mm',
      address: 'No.463, Merchant St, Apt 12, Ward 7, Botahtaung',
      dateOfBirth: DateTime(1982, 6, 1),
      emergencyContact: 'Daw Nwe', emergencyPhone: '09 555 666 777',
      skillIds: ['sk1', 'sk2'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.officer,
    ),

    Member(
      id: 'm103', memberNo: 'RC-103',
      nameEn: 'U Kaung Htet Nyi Nyi', nameMm: 'ဦးကောင်းထွဋ်ညီညီ',
      rank: MemberRank.platoonLeader,
      unitType: UnitType.company,
      companyNo: 1,
      platoonNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2018, 12, 6),
      phone: '09 783 777 613',
      email: 'c1p1leader@redcross.mm',
      address: 'No.50, 43rd Street, Ward 6, Botahtaung',
      dateOfBirth: DateTime(1999, 12, 6),
      emergencyContact: 'U Nay Lin Aung', emergencyPhone: '09 777 888 999',
      skillIds: ['sk1', 'sk3'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.officer,
    ),

    Member(
      id: 'm104', memberNo: 'RC-104',
      nameEn: 'Ma July', nameMm: 'မဂျူးလီ',
      rank: MemberRank.sectionLeader,
      unitType: UnitType.company,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2019, 8, 18),
      phone: '09 420 600 837',
      email: 'july@redcross.mm',
      address: 'No.B-8, Kra Phyu St, Ward 1, Botahtaung',
      dateOfBirth: DateTime(1981, 8, 18),
      emergencyContact: 'U Apprazoo', emergencyPhone: '09 333 444 555',
      skillIds: ['sk1'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.member,
    ),

    Member(
      id: 'm105', memberNo: 'RC-105',
      nameEn: 'Ma Han Thet Su', nameMm: 'မဟန်သက်စု',
      rank: MemberRank.private,
      unitType: UnitType.company,
      companyNo: 1,
      platoonNo: 1,
      sectionNo: 1,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2022, 11, 24),
      phone: '09 450 997 058',
      email: 'hanthetsu@redcross.mm',
      address: 'No.38, Zeya Thiri St, New Ward, Dagon',
      dateOfBirth: DateTime(2000, 11, 24),
      emergencyContact: 'U Khin Zaw', emergencyPhone: '09 111 222 333',
      skillIds: [],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.member,
    ),

    // ══════════════════════════════════════
    // COMPANY 2 — တပ်ဖွဲ့ခွဲ(၂)
    // ══════════════════════════════════════

    Member(
      id: 'm201', memberNo: 'RC-201',
      nameEn: 'U San Hnunt', nameMm: 'ဦးဆန်းညွှန့်',
      rank: MemberRank.companyCommander,
      unitType: UnitType.company,
      companyNo: 2,
      status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2016, 4, 26),
      phone: '09 695 880 340',
      email: 'c2commander@redcross.mm',
      address: 'No.47, Yan Pye (6) St, Ward 3, Thaketa',
      dateOfBirth: DateTime(1983, 4, 26),
      emergencyContact: 'Daw Tin Maung', emergencyPhone: '09 222 333 444',
      skillIds: ['sk1', 'sk2', 'sk5'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.seniorOfficer,
    ),

    // ══════════════════════════════════════
    // COMPANY 3 — တပ်ဖွဲ့ခွဲ(၃)
    // ══════════════════════════════════════

    Member(
      id: 'm301', memberNo: 'RC-301',
      nameEn: 'Daw Than Myint', nameMm: 'ဒေါ်သန်းမြင့်',
      rank: MemberRank.companyCommander,
      unitType: UnitType.company,
      companyNo: 3,
      status: MemberStatus.active,
      bloodType: BloodType.AP,
      joinDate: DateTime(2014, 1, 25),
      phone: '09 401 939 544',
      email: 'c3commander@redcross.mm',
      address: 'No.34/5, 54th St (Lower), Ward 4, Botahtaung',
      dateOfBirth: DateTime(1962, 1, 25),
      emergencyContact: 'U Jamal Ahmad', emergencyPhone: '09 333 444 555',
      skillIds: ['sk1', 'sk2', 'sk5'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.seniorOfficer,
    ),

    // ══════════════════════════════════════
    // COMPANY 4 — တပ်ဖွဲ့ခွဲ(၄)
    // ══════════════════════════════════════

    Member(
      id: 'm401', memberNo: 'RC-401',
      nameEn: 'U Win Htay', nameMm: 'ဦးဝင်းဌေး',
      rank: MemberRank.companyCommander,
      unitType: UnitType.company,
      companyNo: 4,
      status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2013, 7, 31),
      phone: '09 550 1383',
      email: 'c4commander@redcross.mm',
      address: '48 Block, No.62, Police Quarters, Botahtaung',
      dateOfBirth: DateTime(1963, 7, 31),
      emergencyContact: 'Daw Aye', emergencyPhone: '09 444 555 666',
      skillIds: ['sk1', 'sk2', 'sk5'],
      isBrigadeOfficeChief: false,
      hasBrigadeOfficeAuthority: false,
      role: UserRole.seniorOfficer,
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
          m.companyNo == companyNo && m.platoonNo == platoonNo).toList();

  static List<Member> bySection(int companyNo, int platoonNo, int sectionNo) =>
      all.where((m) =>
          m.companyNo == companyNo &&
          m.platoonNo == platoonNo &&
          m.sectionNo == sectionNo).toList();

  /// Filter members visible to a viewer based on unit scope
  static List<Member> visibleTo(Member viewer) {
    return all.where((m) {
      // Import permission service
      return _canViewMemberSimple(viewer, m);
    }).toList();
  }

  static bool _canViewMemberSimple(Member viewer, Member target) {
    if (viewer.id == target.id) return true;
    // Brigade office or master access
    if (viewer.isBrigadeOfficeChief ||
        viewer.rank == MemberRank.brigadeCommander ||
        viewer.rank == MemberRank.deputyBrigadeCommander ||
        viewer.isChairperson ||
        viewer.hasBrigadeOfficeAuthority ||
        viewer.unitType == UnitType.brigadeOffice) return true;
    // Company scope
    if (viewer.rank == MemberRank.companyCommander ||
        viewer.rank == MemberRank.deputyCompanyCommander) {
      return target.companyNo == viewer.companyNo;
    }
    // Platoon scope
    if (viewer.rank == MemberRank.platoonLeader ||
        viewer.rank == MemberRank.companySergeantMajor ||
        viewer.rank == MemberRank.platoonSergeant) {
      return target.companyNo == viewer.companyNo &&
          target.platoonNo == viewer.platoonNo;
    }
    // Section scope
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
// MOCK SKILLS
// ─────────────────────────────────────────────
class MockSkills {
  static const List<Skill> all = [
    Skill(id: 'sk1', nameEn: 'First Aid Level 1', nameMm: 'အသက်ဆယ်ကယ် အဆင့် ၁', category: 'Medical', expiryMonths: 24),
    Skill(id: 'sk2', nameEn: 'First Aid Level 2', nameMm: 'အသက်ဆယ်ကယ် အဆင့် ၂', category: 'Medical', expiryMonths: 24),
    Skill(id: 'sk3', nameEn: 'CPR Certified', nameMm: 'CPR လက်မှတ်', category: 'Medical', expiryMonths: 12),
    Skill(id: 'sk4', nameEn: 'Disaster Management', nameMm: 'ဘေးအန္တရာယ် စီမံခန့်ခွဲမှု', category: 'Disaster'),
    Skill(id: 'sk5', nameEn: 'Leadership', nameMm: 'ခေါင်းဆောင်မှု', category: 'Administrative'),
    Skill(id: 'sk6', nameEn: 'Water Safety', nameMm: 'ရေဘေးလုံခြုံရေး', category: 'Safety', expiryMonths: 36),
    Skill(id: 'sk7', nameEn: 'Search & Rescue', nameMm: 'ရှာဖွေကယ်ဆယ်ရေး', category: 'Disaster'),
    Skill(id: 'sk8', nameEn: 'Community Health', nameMm: 'ရပ်ရွာကျန်းမာရေး', category: 'Medical'),
  ];
}

// ─────────────────────────────────────────────
// MOCK DUTIES
// ─────────────────────────────────────────────
class MockDuties {
  static final List<Duty> all = [
    Duty(
      id: 'd1',
      title: 'Community First Aid Event',
      titleMm: 'ရပ်ရွာ အသက်ဆယ်ကယ် အစီအစဉ်',
      type: DutyType.firstAid,
      scale: DutyScale.regular,
      date: DateTime.now().add(const Duration(days: 5)),
      startHour: 8, startMinute: 0,
      endHour: 16, endMinute: 0,
      location: 'Central Park, Yangon',
      members: [
        DutyMember(memberId: 'm3', roleInDuty: DutyRoleInDuty.officer, status: DutyAssignmentStatus.accepted, assignedAt: DateTime.now().subtract(const Duration(days: 1))),
        DutyMember(memberId: 'm101', roleInDuty: DutyRoleInDuty.member, status: DutyAssignmentStatus.pending, assignedAt: DateTime.now().subtract(const Duration(hours: 2))),
        DutyMember(memberId: 'm104', roleInDuty: DutyRoleInDuty.member, status: DutyAssignmentStatus.accepted, assignedAt: DateTime.now().subtract(const Duration(days: 1))),
      ],
      status: DutyStatus.upcoming,
      description: 'Community first aid awareness event.',
    ),
    Duty(
      id: 'd2',
      title: 'Thingyan Festival Medical Coverage',
      titleMm: 'သင်္ကြန် ဆေးဘက်ဆိုင်ရာ ကာမိန်',
      type: DutyType.eventMedical,
      scale: DutyScale.largeScale,
      date: DateTime.now().add(const Duration(days: 20)),
      startHour: 9, startMinute: 0,
      endHour: 21, endMinute: 0,
      location: 'Bogyoke Road, Yangon',
      members: [
        DutyMember(memberId: 'm1', roleInDuty: DutyRoleInDuty.commander, status: DutyAssignmentStatus.accepted, assignedAt: DateTime.now().subtract(const Duration(days: 3))),
        DutyMember(memberId: 'm3', roleInDuty: DutyRoleInDuty.officer, status: DutyAssignmentStatus.accepted, assignedAt: DateTime.now().subtract(const Duration(days: 3))),
        DutyMember(memberId: 'm101', roleInDuty: DutyRoleInDuty.member, status: DutyAssignmentStatus.pending, assignedAt: DateTime.now().subtract(const Duration(hours: 5))),
        DutyMember(memberId: 'm103', roleInDuty: DutyRoleInDuty.member, status: DutyAssignmentStatus.accepted, assignedAt: DateTime.now().subtract(const Duration(days: 2))),
        DutyMember(memberId: 'm104', roleInDuty: DutyRoleInDuty.member, status: DutyAssignmentStatus.pending, assignedAt: DateTime.now().subtract(const Duration(hours: 3))),
        DutyMember(memberId: 'm105', roleInDuty: DutyRoleInDuty.member, status: DutyAssignmentStatus.accepted, assignedAt: DateTime.now().subtract(const Duration(days: 2))),
      ],
      status: DutyStatus.upcoming,
      isEvent: true, eventId: 'ev1',
    ),
    Duty(
      id: 'd3',
      title: 'Disaster Drill Training',
      titleMm: 'ဘေးအန္တရာယ် လေ့ကျင့်ရေး',
      type: DutyType.training,
      scale: DutyScale.regular,
      date: DateTime.now().subtract(const Duration(days: 5)),
      startHour: 7, startMinute: 0,
      endHour: 12, endMinute: 0,
      location: 'HQ Training Ground',
      members: [
        DutyMember(memberId: 'm3', roleInDuty: DutyRoleInDuty.officer, status: DutyAssignmentStatus.completed, assignedAt: DateTime.now().subtract(const Duration(days: 10))),
        DutyMember(memberId: 'm101', roleInDuty: DutyRoleInDuty.member, status: DutyAssignmentStatus.completed, assignedAt: DateTime.now().subtract(const Duration(days: 10))),
        DutyMember(memberId: 'm103', roleInDuty: DutyRoleInDuty.member, status: DutyAssignmentStatus.completed, assignedAt: DateTime.now().subtract(const Duration(days: 10))),
      ],
      status: DutyStatus.completed,
    ),
  ];

  static Duty? findById(String id) {
    try { return all.firstWhere((d) => d.id == id); }
    catch (_) { return null; }
  }

  static List<DutyMember> getMemberDuties(String memberId) {
    final result = <DutyMember>[];
    for (final duty in all) {
      for (final dm in duty.members) {
        if (dm.memberId == memberId) result.add(dm);
      }
    }
    return result;
  }
}

// ─────────────────────────────────────────────
// MOCK MEETINGS
// ─────────────────────────────────────────────
class MockMeetings {
  static final List<Meeting> all = [
    Meeting(
      id: 'mt1',
      title: 'Monthly Brigade Meeting',
      titleMm: 'လစဉ် တပ်ဖွဲ့ အစည်းအဝေး',
      type: MeetingType.general,
      date: DateTime.now().subtract(const Duration(days: 10)),
      timeHour: 10, timeMinute: 0,
      location: 'Main Branch Conference Room',
      invitedMemberIds: ['m1','m2','m3','m4','m6','m7','m101','m201','m301','m401'],
      attendedMemberIds: ['m1','m2','m3','m101','m201'],
      agenda: '1. Review March activities\n2. April duty schedule\n3. Budget review',
      minutes: 'The meeting discussed Q2 activities and budget allocation.',
      status: MeetingStatus.published,
      tasks: [
        MeetingTask(id: 'tk1', meetingId: 'mt1', title: 'Submit March duty reports by 20th', assignedMemberId: 'm3', dueDate: DateTime.now().subtract(const Duration(days: 5)), isCompleted: true, completedAt: DateTime.now().subtract(const Duration(days: 6)), isVerified: true),
        MeetingTask(id: 'tk2', meetingId: 'mt1', title: 'Prepare equipment inventory list', assignedMemberId: 'm7', dueDate: DateTime.now().add(const Duration(days: 5)), isCompleted: false, isVerified: false),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Meeting(
      id: 'mt2',
      title: 'Officer Coordination Meeting',
      titleMm: 'အရာရှိ ညှိနှိုင်းရေး အစည်းအဝေး',
      type: MeetingType.officer,
      date: DateTime.now().subtract(const Duration(days: 3)),
      timeHour: 14, timeMinute: 0,
      location: 'Officer Room, HQ',
      minimumRank: MemberRank.platoonLeader,
      invitedMemberIds: ['m1','m2','m3','m4','m101','m201','m301','m401'],
      attendedMemberIds: ['m1','m2','m3','m101'],
      minutes: 'Officers reviewed upcoming duty assignments.',
      status: MeetingStatus.published,
      tasks: [
        MeetingTask(id: 'tk3', meetingId: 'mt2', title: 'Finalize Thingyan event positions', assignedMemberId: 'm1', dueDate: DateTime.now().add(const Duration(days: 3)), isCompleted: false, isVerified: false),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static Meeting? findById(String id) {
    try { return all.firstWhere((m) => m.id == id); }
    catch (_) { return null; }
  }

  /// Filter meetings visible to a member
  static List<Meeting> visibleTo(Member member) {
    return all.where((meeting) {
      // Always visible if specifically invited
      if (meeting.invitedMemberIds.contains(member.id)) return true;
      // General meetings visible to all
      if (meeting.type == MeetingType.general) return true;
      // Officer meetings
      if (meeting.type == MeetingType.officer) {
        final minRank = meeting.minimumRank ?? MemberRank.platoonLeader;
        return RankHelper.rankOrder(member.rank) <= RankHelper.rankOrder(minRank) ||
            member.unitType == UnitType.brigadeOffice;
      }
      return false;
    }).toList();
  }
}

// ─────────────────────────────────────────────
// MOCK INVESTIGATIONS
// ─────────────────────────────────────────────
class MockInvestigations {
  static final List<Investigation> all = [
    Investigation(
      id: 'inv1', caseNumber: 'INV-2024-001',
      title: 'Conduct Violation — Duty Absence Without Notice',
      description: 'Member failed to report for assigned duty without prior notice.',
      openedDate: DateTime.now().subtract(const Duration(days: 20)),
      status: InvestigationStatus.underInvestigation,
      accusedMemberIds: ['m105'],
      witnessMemberIds: ['m103'],
      committeeMemberIds: ['m3', 'm6'],
      recusedMemberIds: [],
      appealCommitteeMemberIds: [],
      approvedSealedViewers: [],
      committeeJoinDates: {
        'm3': DateTime.now().subtract(const Duration(days: 18)),
        'm6': DateTime.now().subtract(const Duration(days: 18)),
      },
      stageLogs: [
        InvestigationStageLog(id: 'sl1', investigationId: 'inv1', stage: InvestigationStatus.opened, timestamp: DateTime.now().subtract(const Duration(days: 20)), actionedById: 'm1', notes: 'Case opened.'),
        InvestigationStageLog(id: 'sl2', investigationId: 'inv1', stage: InvestigationStatus.underInvestigation, timestamp: DateTime.now().subtract(const Duration(days: 18)), actionedById: 'm1', notes: 'Committee formed.'),
      ],
      attachments: [
        InvestigationAttachment(id: 'ia1', investigationId: 'inv1', filename: 'duty_roster.pdf', fileUrl: '', isSealed: false, uploadedById: 'm3', uploadedAt: DateTime.now().subtract(const Duration(days: 17))),
        InvestigationAttachment(id: 'ia2', investigationId: 'inv1', filename: 'witness_statement.pdf', fileUrl: '', isSealed: true, uploadedById: 'm6', uploadedAt: DateTime.now().subtract(const Duration(days: 16))),
      ],
      isSealed: false,
    ),
  ];

  static Investigation? findById(String id) {
    try { return all.firstWhere((i) => i.id == id); }
    catch (_) { return null; }
  }
}

// ─────────────────────────────────────────────
// MOCK NOTIFICATIONS
// ─────────────────────────────────────────────
class MockNotifications {
  static final List<AppNotification> all = [
    AppNotification(id: 'n1', recipientId: 'm1', title: 'New Duty Assigned', body: 'You have been assigned as Commander for Thingyan Festival Medical Coverage', type: NotificationType.duty, priority: NotificationPriority.normal, isRead: false, createdAt: DateTime.now().subtract(const Duration(hours: 2)), routeTo: '/duties/d2'),
    AppNotification(id: 'n2', recipientId: 'm1', title: 'Meeting Minutes Published', body: 'Officer Coordination Meeting minutes are now available', type: NotificationType.meeting, priority: NotificationPriority.normal, isRead: false, createdAt: DateTime.now().subtract(const Duration(hours: 5)), routeTo: '/meetings/mt2'),
    AppNotification(id: 'n3', recipientId: 'm1', title: 'Blood Donor Eligible', body: 'Ma July (O+) is now eligible to donate blood again', type: NotificationType.blood, priority: NotificationPriority.normal, isRead: true, createdAt: DateTime.now().subtract(const Duration(days: 1))),
    AppNotification(id: 'n4', recipientId: 'm1', title: 'Task Due Tomorrow', body: 'Task: "Finalize Thingyan event positions" is due tomorrow', type: NotificationType.task, priority: NotificationPriority.high, isRead: false, createdAt: DateTime.now().subtract(const Duration(days: 2)), routeTo: '/meetings/mt2'),
    AppNotification(id: 'n5', recipientId: 'm1', title: 'Fund Entry Pending Approval', body: 'Ko San Thu Aung submitted a fund entry for approval', type: NotificationType.system, priority: NotificationPriority.normal, isRead: true, createdAt: DateTime.now().subtract(const Duration(days: 3))),
  ];

  static List<AppNotification> forMember(String memberId) =>
      all.where((n) => n.recipientId == memberId).toList();

  static int unreadCount(String memberId) =>
      all.where((n) => n.recipientId == memberId && !n.isRead).length;
}

// ─────────────────────────────────────────────
// MOCK BLOOD DONORS
// ─────────────────────────────────────────────
class MockBloodDonors {
  static final List<BloodDonor> all = [
    BloodDonor(id: 'bd1', nameEn: 'U Yan Paing', nameMm: 'ဦးရန်ပိုင်', type: DonorType.internal, memberId: 'm3', bloodType: BloodType.OP, lastDonationDate: DateTime.now().subtract(const Duration(days: 130)), totalDonations: 8, phone: '09 968 817 848', isActive: true),
    BloodDonor(id: 'bd2', nameEn: 'Ma July', nameMm: 'မဂျူးလီ', type: DonorType.internal, memberId: 'm104', bloodType: BloodType.OP, lastDonationDate: DateTime.now().subtract(const Duration(days: 60)), totalDonations: 4, phone: '09 420 600 837', isActive: true),
    BloodDonor(id: 'bd3', nameEn: 'U Kyaw Htun', type: DonorType.external, bloodType: BloodType.BP, lastDonationDate: DateTime.now().subtract(const Duration(days: 125)), totalDonations: 3, phone: '09 111 222 333', isActive: true),
    BloodDonor(id: 'bd4', nameEn: 'Ma Aye Aye', type: DonorType.external, bloodType: BloodType.OM, lastDonationDate: DateTime.now().subtract(const Duration(days: 90)), totalDonations: 1, phone: '09 444 555 666', isActive: true),
    BloodDonor(id: 'bd5', nameEn: 'U Win Naing', type: DonorType.external, bloodType: BloodType.OP, lastDonationDate: DateTime.now().subtract(const Duration(days: 160)), totalDonations: 10, phone: '09 222 333 444', isActive: true),
  ];

  static List<BloodDonor> eligibleByBloodType(BloodType type) =>
      all.where((d) => d.bloodType == type && d.isEligible).toList();
}

// ─────────────────────────────────────────────
// MOCK AVAILABILITY
// ─────────────────────────────────────────────
class MockAvailability {
  static List<MemberAvailability> forMemberThisMonth(String memberId) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return List.generate(daysInMonth, (i) {
      final date = DateTime(now.year, now.month, i + 1);
      final isWeekend = date.weekday == 6 || date.weekday == 7;
      return MemberAvailability(
        id: 'av_${memberId}_${i + 1}',
        memberId: memberId,
        date: date,
        status: isWeekend ? AvailabilityStatus.busy : AvailabilityStatus.free,
        isConfirmed: true,
      );
    });
  }
}
