import '../models/models.dart';
import '../../core/constants/app_constants.dart';

// ─────────────────────────────────────────────
// MOCK SKILLS
// ─────────────────────────────────────────────
class MockSkills {
  static const List<Skill> all = [
    Skill(id: 'sk1', nameEn: 'First Aid Level 1', nameMm: 'အသက်ဆယ်ကယ် အဆင့် ၁', category: 'Medical', expiryMonths: 24),
    Skill(id: 'sk2', nameEn: 'First Aid Level 2', nameMm: 'အသက်ဆယ်ကယ် အဆင့် ၂', category: 'Medical', expiryMonths: 24),
    Skill(id: 'sk3', nameEn: 'CPR Certified', nameMm: 'CPR လက်မှတ်', category: 'Medical', expiryMonths: 12),
    Skill(id: 'sk4', nameEn: 'Disaster Management', nameMm: 'ဘေးအန္တရာယ် စီမံခန့်ခွဲမှု', category: 'Disaster', expiryMonths: null),
    Skill(id: 'sk5', nameEn: 'Leadership', nameMm: 'ခေါင်းဆောင်မှု', category: 'Administrative', expiryMonths: null),
    Skill(id: 'sk6', nameEn: 'Water Safety', nameMm: 'ရေဘေးလုံခြုံရေး', category: 'Safety', expiryMonths: 36),
    Skill(id: 'sk7', nameEn: 'Search & Rescue', nameMm: 'ရှာဖွေကယ်ဆယ်ရေး', category: 'Disaster', expiryMonths: null),
    Skill(id: 'sk8', nameEn: 'Community Health', nameMm: 'ရပ်ရွာကျန်းမာရေး', category: 'Medical', expiryMonths: null),
  ];

  static Skill? findById(String id) {
    try { return all.firstWhere((s) => s.id == id); }
    catch (_) { return null; }
  }
}

// ─────────────────────────────────────────────
// MOCK MEMBERS
// ─────────────────────────────────────────────
class MockMembers {
  static final List<Member> all = [
    Member(
      id: 'm1', memberNo: 'RC-001',
      nameEn: 'Ko Aung Kyaw', nameMm: 'ကိုအောင်ကျော်',
      rankId: 'r1', rankNameEn: 'Senior Officer', rankNameMm: 'အရာရှိကြီး',
      unit: 'Main Branch', status: MemberStatus.active,
      bloodType: BloodType.OP,
      joinDate: DateTime(2018, 3, 15),
      phone: '+95 9 123 456 789', email: 'aungkyaw@redcross.mm',
      address: 'No.12, Pazundaung Township, Yangon',
      dateOfBirth: DateTime(1985, 6, 10),
      emergencyContact: 'Ma Khin Khin', emergencyPhone: '+95 9 987 654 321',
      skillIds: ['sk1', 'sk2', 'sk3', 'sk5'],
      youthGroupId: 'yg3', role: UserRole.seniorOfficer,
    ),
    Member(
      id: 'm2', memberNo: 'RC-002',
      nameEn: 'Ma Thida Win', nameMm: 'မသိဒ္ဓာဝင်း',
      rankId: 'r2', rankNameEn: 'Officer', rankNameMm: 'အရာရှိ',
      unit: 'Main Branch', status: MemberStatus.active,
      bloodType: BloodType.AP,
      joinDate: DateTime(2019, 7, 22),
      phone: '+95 9 234 567 890', email: 'thidawin@redcross.mm',
      address: 'No.5, Sanchaung Township, Yangon',
      dateOfBirth: DateTime(1990, 2, 28),
      emergencyContact: 'U Win Myint', emergencyPhone: '+95 9 111 222 333',
      skillIds: ['sk1', 'sk3', 'sk8'],
      youthGroupId: null, role: UserRole.officer,
    ),
    Member(
      id: 'm3', memberNo: 'RC-003',
      nameEn: 'Ko Zaw Lin', nameMm: 'ကိုဇော်လင်း',
      rankId: 'r3', rankNameEn: 'Duty Officer', rankNameMm: 'တာဝန်ကျ အရာရှိ',
      unit: 'Field Unit', status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2020, 1, 10),
      phone: '+95 9 345 678 901', email: 'zawlin@redcross.mm',
      address: 'No.33, Tamwe Township, Yangon',
      dateOfBirth: DateTime(1992, 11, 5),
      emergencyContact: 'Ma Su Su', emergencyPhone: '+95 9 444 555 666',
      skillIds: ['sk4', 'sk7', 'sk1'],
      youthGroupId: 'yg2', role: UserRole.dutyOfficer,
    ),
    Member(
      id: 'm4', memberNo: 'RC-004',
      nameEn: 'Ma Su Su Myat', nameMm: 'မဆုဆုမြတ်',
      rankId: 'r4', rankNameEn: 'Member', rankNameMm: 'အဖွဲ့ဝင်',
      unit: 'Main Branch', status: MemberStatus.active,
      bloodType: BloodType.ABP,
      joinDate: DateTime(2021, 5, 18),
      phone: '+95 9 456 789 012', email: 'susu@redcross.mm',
      address: 'No.8, Thingangyun Township, Yangon',
      dateOfBirth: DateTime(1995, 8, 20),
      emergencyContact: 'Ko Kyaw Zin', emergencyPhone: '+95 9 777 888 999',
      skillIds: ['sk1', 'sk8'],
      youthGroupId: null, role: UserRole.member,
    ),
    Member(
      id: 'm5', memberNo: 'RC-005',
      nameEn: 'Ko Min Htet', nameMm: 'ကိုမင်းထက်',
      rankId: 'r4', rankNameEn: 'Member', rankNameMm: 'အဖွဲ့ဝင်',
      unit: 'Field Unit', status: MemberStatus.active,
      bloodType: BloodType.OM,
      joinDate: DateTime(2022, 3, 1),
      phone: '+95 9 567 890 123', email: 'minhtet@redcross.mm',
      address: 'No.21, Hlaing Township, Yangon',
      dateOfBirth: DateTime(1998, 4, 12),
      emergencyContact: 'Ma Aye Aye', emergencyPhone: '+95 9 000 111 222',
      skillIds: ['sk2', 'sk6'],
      youthGroupId: 'yg1', role: UserRole.member,
    ),
    Member(
      id: 'm6', memberNo: 'RC-006',
      nameEn: 'Daw Khin Moe', nameMm: 'ဒေါ်ခင်မို့',
      rankId: 'r1', rankNameEn: 'Senior Officer', rankNameMm: 'အရာရှိကြီး',
      unit: 'Main Branch', status: MemberStatus.active,
      bloodType: BloodType.AM,
      joinDate: DateTime(2015, 9, 5),
      phone: '+95 9 678 901 234', email: 'khinmoe@redcross.mm',
      address: 'No.3, Bahan Township, Yangon',
      dateOfBirth: DateTime(1978, 1, 30),
      emergencyContact: 'U Kyaw Zin', emergencyPhone: '+95 9 333 444 555',
      skillIds: ['sk1', 'sk2', 'sk5', 'sk8'],
      youthGroupId: null, role: UserRole.seniorOfficer,
    ),
    Member(
      id: 'm7', memberNo: 'RC-007',
      nameEn: 'Ko Pyae Phyo', nameMm: 'ကိုပြည့်ဖြိုး',
      rankId: 'r4', rankNameEn: 'Member', rankNameMm: 'အဖွဲ့ဝင်',
      unit: 'Field Unit', status: MemberStatus.active,
      bloodType: BloodType.BP,
      joinDate: DateTime(2023, 1, 20),
      phone: '+95 9 789 012 345', email: 'pyaephyo@redcross.mm',
      address: 'No.15, Mingalar Taung Nyunt, Yangon',
      dateOfBirth: DateTime(2000, 7, 8),
      emergencyContact: 'U Phyo Zin', emergencyPhone: '+95 9 222 333 444',
      skillIds: ['sk1'],
      youthGroupId: 'yg1', role: UserRole.member,
    ),
    Member(
      id: 'm8', memberNo: 'RC-008',
      nameEn: 'Ma Ei Phyu', nameMm: 'မဧဖြူ',
      rankId: 'r4', rankNameEn: 'Member', rankNameMm: 'အဖွဲ့ဝင်',
      unit: 'Main Branch', status: MemberStatus.active,
      bloodType: BloodType.ABM,
      joinDate: DateTime(2023, 6, 14),
      phone: '+95 9 890 123 456', email: 'eiphyu@redcross.mm',
      address: 'No.9, Kyauktada Township, Yangon',
      dateOfBirth: DateTime(2001, 3, 25),
      emergencyContact: 'U Tin Maung', emergencyPhone: '+95 9 555 666 777',
      skillIds: ['sk3'],
      youthGroupId: 'yg3', role: UserRole.member,
    ),
  ];

  static Member? findById(String id) {
    try { return all.firstWhere((m) => m.id == id); }
    catch (_) { return null; }
  }

  static List<Member> findByIds(List<String> ids) =>
      all.where((m) => ids.contains(m.id)).toList();
}

// ─────────────────────────────────────────────
// MOCK DUTIES
// ─────────────────────────────────────────────
class MockDuties {
  static final List<Duty> all = [
    Duty(
      id: 'd1', title: 'Community First Aid Event', titleMm: 'ရပ်ရွာ အသက်ဆယ်ကယ် အစီအစဉ်',
      type: DutyType.firstAid,
      date: DateTime.now().add(const Duration(days: 5)),
      startHour: 8, startMinute: 0,
      endHour: 16, endMinute: 0,
      location: 'Central Park, Yangon',
      officerInChargeId: 'm1',
      assignedMemberIds: ['m2', 'm3', 'm4'],
      status: DutyStatus.upcoming,
      description: 'Community first aid awareness event. Provide basic first aid services and education.',
    ),
    Duty(
      id: 'd2', title: 'Blood Drive Campaign', titleMm: 'သွေးလှူဒါန်း လှုပ်ရှားမှု',
      type: DutyType.bloodDonation,
      date: DateTime.now().add(const Duration(days: 8)),
      startHour: 9, startMinute: 0,
      endHour: 14, endMinute: 0,
      location: 'Yangon General Hospital',
      officerInChargeId: 'm1',
      assignedMemberIds: ['m1', 'm4', 'm5'],
      status: DutyStatus.upcoming,
      description: 'Quarterly blood drive campaign in partnership with Yangon General Hospital.',
    ),
    Duty(
      id: 'd3', title: 'Disaster Drill Training', titleMm: 'ဘေးအန္တရာယ် လေ့ကျင့်ရေး',
      type: DutyType.training,
      date: DateTime.now().subtract(const Duration(days: 5)),
      startHour: 7, startMinute: 0,
      endHour: 12, endMinute: 0,
      location: 'HQ Training Ground',
      officerInChargeId: 'm3',
      assignedMemberIds: ['m2', 'm3', 'm5', 'm7'],
      status: DutyStatus.completed,
      description: 'Annual disaster response drill. All field unit members must attend.',
    ),
    Duty(
      id: 'd4', title: 'Emergency Response Patrol', titleMm: 'အရေးပေါ် တုံ့ပြန်ရေး စောင့်ကြည့်',
      type: DutyType.patrol,
      date: DateTime.now().add(const Duration(days: 12)),
      startHour: 6, startMinute: 0,
      endHour: 18, endMinute: 0,
      location: 'River District, Yangon',
      officerInChargeId: 'm1',
      assignedMemberIds: ['m1', 'm3'],
      status: DutyStatus.upcoming,
      description: 'Routine emergency response patrol along the river district.',
    ),
    Duty(
      id: 'd5', title: 'Thingyan Medical Post', titleMm: 'သင်္ကြန် ဆေးဘက်ဆိုင်ရာ စခန်း',
      type: DutyType.eventMedical,
      date: DateTime.now().add(const Duration(days: 20)),
      startHour: 9, startMinute: 0,
      endHour: 21, endMinute: 0,
      location: 'Bogyoke Road, Yangon',
      officerInChargeId: 'm6',
      assignedMemberIds: ['m1', 'm2', 'm3', 'm4', 'm5', 'm6'],
      status: DutyStatus.upcoming,
      isEvent: true, eventId: 'ev1',
      description: 'Medical coverage for Thingyan water festival celebrations.',
    ),
  ];

  static Duty? findById(String id) {
    try { return all.firstWhere((d) => d.id == id); }
    catch (_) { return null; }
  }
}

// ─────────────────────────────────────────────
// MOCK DUTY ASSIGNMENTS
// ─────────────────────────────────────────────
class MockDutyAssignments {
  static final List<DutyAssignment> all = [
    DutyAssignment(id: 'da1', dutyId: 'd1', memberId: 'm2', status: DutyAssignmentStatus.pending, assignedAt: DateTime.now().subtract(const Duration(hours: 2))),
    DutyAssignment(id: 'da2', dutyId: 'd1', memberId: 'm3', status: DutyAssignmentStatus.accepted, assignedAt: DateTime.now().subtract(const Duration(hours: 2)), respondedAt: DateTime.now().subtract(const Duration(hours: 1))),
    DutyAssignment(id: 'da3', dutyId: 'd1', memberId: 'm4', status: DutyAssignmentStatus.rejected, rejectionReason: 'Family commitment on that day', assignedAt: DateTime.now().subtract(const Duration(hours: 2)), respondedAt: DateTime.now().subtract(const Duration(minutes: 45))),
    DutyAssignment(id: 'da4', dutyId: 'd2', memberId: 'm1', status: DutyAssignmentStatus.accepted, assignedAt: DateTime.now().subtract(const Duration(days: 1))),
    DutyAssignment(id: 'da5', dutyId: 'd2', memberId: 'm4', status: DutyAssignmentStatus.accepted, assignedAt: DateTime.now().subtract(const Duration(days: 1))),
    DutyAssignment(id: 'da6', dutyId: 'd2', memberId: 'm5', status: DutyAssignmentStatus.pending, assignedAt: DateTime.now().subtract(const Duration(hours: 5))),
    DutyAssignment(id: 'da7', dutyId: 'd3', memberId: 'm2', status: DutyAssignmentStatus.completed, assignedAt: DateTime.now().subtract(const Duration(days: 10))),
    DutyAssignment(id: 'da8', dutyId: 'd3', memberId: 'm3', status: DutyAssignmentStatus.completed, assignedAt: DateTime.now().subtract(const Duration(days: 10))),
  ];

  static List<DutyAssignment> forMember(String memberId) =>
      all.where((a) => a.memberId == memberId).toList();

  static DutyAssignment? forDutyAndMember(String dutyId, String memberId) {
    try { return all.firstWhere((a) => a.dutyId == dutyId && a.memberId == memberId); }
    catch (_) { return null; }
  }
}

// ─────────────────────────────────────────────
// MOCK MEETINGS
// ─────────────────────────────────────────────
class MockMeetings {
  static final List<Meeting> all = [
    Meeting(
      id: 'mt1', title: 'Monthly Branch Meeting', titleMm: 'လစဉ် ဌာနခွဲ အစည်းအဝေး',
      type: MeetingType.general,
      date: DateTime.now().subtract(const Duration(days: 10)),
      timeHour: 10, timeMinute: 0,
      location: 'Main Branch Conference Room',
      invitedMemberIds: ['m1','m2','m3','m4','m5','m6','m7','m8'],
      attendedMemberIds: ['m1','m2','m3','m4','m6'],
      agenda: '1. Review March activities\n2. April duty schedule\n3. Budget review\n4. AOB',
      minutes: 'The meeting discussed Q2 activities and budget allocation. Duty schedules were confirmed for April. Budget surplus from March was approved for equipment upgrade.',
      status: MeetingStatus.published,
      tasks: [
        MeetingTask(id: 'tk1', meetingId: 'mt1', title: 'Submit March duty reports by 20th', assignedMemberId: 'm2', dueDate: DateTime.now().subtract(const Duration(days: 5)), isCompleted: true, completedAt: DateTime.now().subtract(const Duration(days: 6)), isVerified: true),
        MeetingTask(id: 'tk2', meetingId: 'mt1', title: 'Prepare equipment inventory list', assignedMemberId: 'm3', dueDate: DateTime.now().add(const Duration(days: 5)), isCompleted: false, isVerified: false),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Meeting(
      id: 'mt2', title: 'Officer Coordination Meeting', titleMm: 'အရာရှိ ညှိနှိုင်းရေး အစည်းအဝေး',
      type: MeetingType.officer,
      date: DateTime.now().subtract(const Duration(days: 3)),
      timeHour: 14, timeMinute: 0,
      location: 'Officer Room, HQ',
      invitedMemberIds: ['m1','m2','m3','m6'],
      attendedMemberIds: ['m1','m2','m6'],
      agenda: '1. Review of duty assignments\n2. Upcoming events planning\n3. Staff issues',
      minutes: 'Officers reviewed upcoming duty assignments and planned coverage for Thingyan festival. Staff welfare issues were discussed and resolved.',
      status: MeetingStatus.published,
      tasks: [
        MeetingTask(id: 'tk3', meetingId: 'mt2', title: 'Finalize Thingyan event positions', assignedMemberId: 'm1', dueDate: DateTime.now().add(const Duration(days: 3)), isCompleted: false, isVerified: false),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Meeting(
      id: 'mt3', title: 'Youth Wing Leaders Meeting', titleMm: 'လူငယ်အဖွဲ့ ခေါင်းဆောင်များ အစည်းအဝေး',
      type: MeetingType.youthLeaders,
      date: DateTime.now().add(const Duration(days: 4)),
      timeHour: 11, timeMinute: 0,
      location: 'Youth Room, Branch Office',
      invitedMemberIds: ['m1','m3','m5'],
      attendedMemberIds: [],
      status: MeetingStatus.scheduled,
      tasks: [],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static Meeting? findById(String id) {
    try { return all.firstWhere((m) => m.id == id); }
    catch (_) { return null; }
  }
}

// ─────────────────────────────────────────────
// MOCK CLASSES
// ─────────────────────────────────────────────
class MockClasses {
  static final List<TrainingClass> all = [
    TrainingClass(
      id: 'cl1', title: 'Advanced First Aid', titleMm: 'အသက်ဆယ်ကယ် အဆင့်မြင့်',
      type: ClassType.classRoom, category: 'Medical',
      description: 'Advanced first aid techniques including wound care, fracture management, and emergency response protocols.',
      instructorId: 'ext1', instructorName: 'Dr. Kyaw Zin Oo', isExternalInstructor: true,
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 16)),
      location: 'Branch Training Hall',
      maxParticipants: 20,
      enrolledMemberIds: ['m2','m4','m5','m7','m8'],
      status: ClassStatus.open,
      requiredSkillIds: ['sk1'],
      awardedSkillIds: ['sk2'],
      issuesCertificate: true,
      hasCommittee: true,
      committee: [
        ClassCommitteeMember(memberId: 'm1', role: 'Committee Head'),
        ClassCommitteeMember(memberId: 'm6', role: 'Secretary'),
        ClassCommitteeMember(memberId: 'm3', role: 'Treasurer'),
      ],
      budget: ClassBudget(
        id: 'cb1', classId: 'cl1',
        totalAmount: 500000,
        fundingSource: FundingSource.organizationFund,
        categoryAllocations: {
          'Instructor Fees': 200000,
          'Instructor Lunch': 30000,
          'Instructor Travel': 20000,
          'Materials': 150000,
          'Venue': 50000,
          'Miscellaneous': 50000,
        },
        memberLunchAllowed: false,
        memberTravelAllowed: false,
        approvalStatus: 'approved',
        expenses: [
          ClassExpense(id: 'ce1', classId: 'cl1', category: 'Materials', amount: 85000, date: DateTime.now().subtract(const Duration(days: 2)), paidTo: 'Medical Supplies Co.', description: 'First aid training materials and dummies', loggedById: 'm3', status: ExpenseStatus.approved, paymentStatus: PaymentStatus.paid),
        ],
      ),
      timetable: [
        ClassSession(id: 'cs1', classId: 'cl1', sessionNumber: 1, topic: 'Introduction & Basic Review', date: DateTime.now().add(const Duration(days: 14)), startHour: 9, startMinute: 0, endHour: 12, endMinute: 0, location: 'Training Hall Room A', status: 'scheduled'),
        ClassSession(id: 'cs2', classId: 'cl1', sessionNumber: 2, topic: 'Wound Care & Fracture Management', date: DateTime.now().add(const Duration(days: 14)), startHour: 13, startMinute: 0, endHour: 17, endMinute: 0, location: 'Training Hall Room A', status: 'scheduled'),
        ClassSession(id: 'cs3', classId: 'cl1', sessionNumber: 3, topic: 'Practical Exercises Day 1', date: DateTime.now().add(const Duration(days: 15)), startHour: 9, startMinute: 0, endHour: 17, endMinute: 0, location: 'Training Ground', status: 'scheduled'),
        ClassSession(id: 'cs4', classId: 'cl1', sessionNumber: 4, topic: 'Assessment & Certification', date: DateTime.now().add(const Duration(days: 16)), startHour: 9, startMinute: 0, endHour: 13, endMinute: 0, location: 'Training Hall Room A', status: 'scheduled'),
      ],
    ),
    TrainingClass(
      id: 'cl2', title: 'Leadership Workshop', titleMm: 'ခေါင်းဆောင်မှု အလုပ်ရုံဆွေးနွေးပွဲ',
      type: ClassType.workshop, category: 'Leadership',
      description: 'Leadership skills development workshop for junior officers and senior members.',
      instructorId: 'm1', instructorName: 'Ko Aung Kyaw', isExternalInstructor: false,
      startDate: DateTime.now().add(const Duration(days: 25)),
      endDate: DateTime.now().add(const Duration(days: 25)),
      location: 'Main Conference Room',
      maxParticipants: 15,
      enrolledMemberIds: ['m3','m4','m5','m7','m8'],
      status: ClassStatus.open,
      requiredSkillIds: [],
      awardedSkillIds: ['sk5'],
      issuesCertificate: false,
      hasCommittee: false,
      committee: [],
      timetable: [
        ClassSession(id: 'cs5', classId: 'cl2', sessionNumber: 1, topic: 'Leadership Principles & Styles', date: DateTime.now().add(const Duration(days: 25)), startHour: 9, startMinute: 0, endHour: 12, endMinute: 0, location: 'Main Conference Room', status: 'scheduled'),
        ClassSession(id: 'cs6', classId: 'cl2', sessionNumber: 2, topic: 'Team Management & Communication', date: DateTime.now().add(const Duration(days: 25)), startHour: 13, startMinute: 0, endHour: 17, endMinute: 0, location: 'Main Conference Room', status: 'scheduled'),
      ],
    ),
    TrainingClass(
      id: 'cl3', title: 'Disaster Response Seminar', titleMm: 'ဘေးအန္တရာယ် တုံ့ပြန်ရေး သင်တန်း',
      type: ClassType.seminar, category: 'Disaster Management',
      description: 'Comprehensive disaster response seminar covering flood, fire, and earthquake scenarios.',
      instructorId: 'ext2', instructorName: 'MRCS Training Team', isExternalInstructor: true,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 8)),
      location: 'State Office Training Center',
      maxParticipants: 20,
      enrolledMemberIds: ['m1','m2','m3','m4','m5','m6','m7','m8'],
      status: ClassStatus.completed,
      requiredSkillIds: [],
      awardedSkillIds: ['sk4','sk7'],
      issuesCertificate: true,
      hasCommittee: true,
      committee: [
        ClassCommitteeMember(memberId: 'm6', role: 'Committee Head'),
        ClassCommitteeMember(memberId: 'm2', role: 'Secretary'),
      ],
      timetable: [],
    ),
  ];

  static TrainingClass? findById(String id) {
    try { return all.firstWhere((c) => c.id == id); }
    catch (_) { return null; }
  }
}

// ─────────────────────────────────────────────
// MOCK BLOOD DONORS
// ─────────────────────────────────────────────
class MockBloodDonors {
  static final List<BloodDonor> all = [
    BloodDonor(id: 'bd1', nameEn: 'Ko Aung Kyaw', nameMm: 'ကိုအောင်ကျော်', type: DonorType.internal, memberId: 'm1', bloodType: BloodType.OP, lastDonationDate: DateTime.now().subtract(const Duration(days: 130)), totalDonations: 8, phone: '+95 9 123 456 789', isActive: true),
    BloodDonor(id: 'bd2', nameEn: 'Ma Thida Win', nameMm: 'မသိဒ္ဓာဝင်း', type: DonorType.internal, memberId: 'm2', bloodType: BloodType.AP, lastDonationDate: DateTime.now().subtract(const Duration(days: 60)), totalDonations: 4, phone: '+95 9 234 567 890', isActive: true),
    BloodDonor(id: 'bd3', nameEn: 'Ko Min Htet', nameMm: 'ကိုမင်းထက်', type: DonorType.internal, memberId: 'm5', bloodType: BloodType.OM, lastDonationDate: DateTime.now().subtract(const Duration(days: 200)), totalDonations: 6, phone: '+95 9 567 890 123', isActive: true),
    BloodDonor(id: 'bd4', nameEn: 'U Kyaw Htun', type: DonorType.external, bloodType: BloodType.BP, lastDonationDate: DateTime.now().subtract(const Duration(days: 125)), totalDonations: 3, phone: '+95 9 111 222 333', isActive: true),
    BloodDonor(id: 'bd5', nameEn: 'Ma Aye Aye', type: DonorType.external, bloodType: BloodType.OM, lastDonationDate: DateTime.now().subtract(const Duration(days: 90)), totalDonations: 1, phone: '+95 9 444 555 666', isActive: true),
    BloodDonor(id: 'bd6', nameEn: 'Ko Thiha', type: DonorType.external, bloodType: BloodType.AP, lastDonationDate: DateTime.now().subtract(const Duration(days: 150)), totalDonations: 5, phone: '+95 9 777 888 000', isActive: true),
    BloodDonor(id: 'bd7', nameEn: 'Ma Nwe Nwe', type: DonorType.external, bloodType: BloodType.ABP, lastDonationDate: DateTime.now().subtract(const Duration(days: 45)), totalDonations: 2, phone: '+95 9 999 000 111', isActive: true),
    BloodDonor(id: 'bd8', nameEn: 'U Win Naing', type: DonorType.external, bloodType: BloodType.OP, lastDonationDate: DateTime.now().subtract(const Duration(days: 160)), totalDonations: 10, phone: '+95 9 222 333 444', isActive: true),
  ];

  static BloodDonor? findById(String id) {
    try { return all.firstWhere((d) => d.id == id); }
    catch (_) { return null; }
  }

  static List<BloodDonor> eligibleByBloodType(BloodType type) =>
      all.where((d) => d.bloodType == type && d.isEligible).toList();
}

// ─────────────────────────────────────────────
// MOCK INVESTIGATIONS
// ─────────────────────────────────────────────
class MockInvestigations {
  static final List<Investigation> all = [
    Investigation(
      id: 'inv1', caseNumber: 'INV-2024-001',
      title: 'Conduct Violation — Duty Absence Without Notice',
      description: 'Member failed to report for assigned duty without prior notice or valid reason. Duty officer was unable to find replacement in time causing operational difficulties.',
      openedDate: DateTime.now().subtract(const Duration(days: 20)),
      status: InvestigationStatus.underInvestigation,
      accusedMemberIds: ['m7'],
      witnessMemberIds: ['m3'],
      committeeMemberIds: ['m1', 'm6'],
      recusedMemberIds: [],
      stageLogs: [
        InvestigationStageLog(id: 'sl1', investigationId: 'inv1', stage: InvestigationStatus.opened, timestamp: DateTime.now().subtract(const Duration(days: 20)), actionedById: 'm1', notes: 'Case opened following duty officer report.'),
        InvestigationStageLog(id: 'sl2', investigationId: 'inv1', stage: InvestigationStatus.underInvestigation, timestamp: DateTime.now().subtract(const Duration(days: 18)), actionedById: 'm1', notes: 'Committee formed. Investigation commenced.'),
      ],
      attachments: [
        InvestigationAttachment(id: 'ia1', investigationId: 'inv1', filename: 'duty_roster_april.pdf', fileUrl: '', isSealed: false, uploadedById: 'm1', uploadedAt: DateTime.now().subtract(const Duration(days: 19))),
        InvestigationAttachment(id: 'ia2', investigationId: 'inv1', filename: 'witness_statement.pdf', fileUrl: '', isSealed: true, uploadedById: 'm6', uploadedAt: DateTime.now().subtract(const Duration(days: 17))),
      ],
      isSealed: false,
    ),
    Investigation(
      id: 'inv2', caseNumber: 'INV-2024-002',
      title: 'Equipment Misuse Report',
      description: 'Allegations of organization equipment being used for personal purposes without authorization.',
      openedDate: DateTime.now().subtract(const Duration(days: 45)),
      status: InvestigationStatus.concluded,
      accusedMemberIds: ['m4'],
      witnessMemberIds: ['m2'],
      committeeMemberIds: ['m6', 'm1'],
      recusedMemberIds: [],
      stageLogs: [
        InvestigationStageLog(id: 'sl3', investigationId: 'inv2', stage: InvestigationStatus.opened, timestamp: DateTime.now().subtract(const Duration(days: 45)), actionedById: 'm6'),
        InvestigationStageLog(id: 'sl4', investigationId: 'inv2', stage: InvestigationStatus.underInvestigation, timestamp: DateTime.now().subtract(const Duration(days: 43)), actionedById: 'm6'),
        InvestigationStageLog(id: 'sl5', investigationId: 'inv2', stage: InvestigationStatus.hearingConducted, timestamp: DateTime.now().subtract(const Duration(days: 30)), actionedById: 'm6'),
        InvestigationStageLog(id: 'sl6', investigationId: 'inv2', stage: InvestigationStatus.concluded, timestamp: DateTime.now().subtract(const Duration(days: 15)), actionedById: 'm6', notes: 'Found guilty. Written warning issued.'),
      ],
      attachments: [],
      outcome: 'Member found to have used equipment without authorization. Written warning issued. Member acknowledged and undertook not to repeat.',
      isSealed: false,
    ),
  ];

  static Investigation? findById(String id) {
    try { return all.firstWhere((i) => i.id == id); }
    catch (_) { return null; }
  }
}

// ─────────────────────────────────────────────
// MOCK PUNISHMENTS
// ─────────────────────────────────────────────
class MockPunishments {
  static final List<Punishment> all = [
    Punishment(
      id: 'pn1', memberId: 'm4',
      type: PunishmentType.writtenWarning,
      description: 'Written warning issued for unauthorized use of organization equipment. Member acknowledged and signed the warning letter.',
      issuedDate: DateTime.now().subtract(const Duration(days: 15)),
      issuedById: 'm1',
      status: PunishmentStatus.active,
      investigationId: 'inv2',
      isAppealable: true,
    ),
    Punishment(
      id: 'pn2', memberId: 'm5',
      type: PunishmentType.verbalWarning,
      description: 'Verbal warning for late arrival to duty without prior notification.',
      issuedDate: DateTime.now().subtract(const Duration(days: 60)),
      issuedById: 'm3',
      status: PunishmentStatus.completed,
      isAppealable: false,
    ),
  ];

  static List<Punishment> forMember(String memberId) =>
      all.where((p) => p.memberId == memberId).toList();
}

// ─────────────────────────────────────────────
// MOCK NOTIFICATIONS
// ─────────────────────────────────────────────
class MockNotifications {
  static final List<AppNotification> all = [
    AppNotification(id: 'n1', recipientId: 'm1', title: 'New Duty Assigned', body: 'You have been assigned to Community First Aid Event on ${DateTime.now().add(const Duration(days: 5)).day} April', type: NotificationType.duty, priority: NotificationPriority.normal, isRead: false, createdAt: DateTime.now().subtract(const Duration(hours: 2)), routeTo: '/duties/d1'),
    AppNotification(id: 'n2', recipientId: 'm1', title: 'Class Starting Soon', body: 'Advanced First Aid class starts in 14 days. You are enrolled.', type: NotificationType.classEvent, priority: NotificationPriority.normal, isRead: false, createdAt: DateTime.now().subtract(const Duration(hours: 5)), routeTo: '/classes/cl1'),
    AppNotification(id: 'n3', recipientId: 'm1', title: 'Blood Donor Eligible', body: 'Ko Aung Kyaw (O+) is now eligible to donate blood again.', type: NotificationType.blood, priority: NotificationPriority.normal, isRead: true, createdAt: DateTime.now().subtract(const Duration(days: 1)), routeTo: '/blood/bd1'),
    AppNotification(id: 'n4', recipientId: 'm1', title: 'Meeting Minutes Published', body: 'Minutes for Officer Coordination Meeting are now available.', type: NotificationType.meeting, priority: NotificationPriority.normal, isRead: true, createdAt: DateTime.now().subtract(const Duration(days: 2)), routeTo: '/meetings/mt2'),
    AppNotification(id: 'n5', recipientId: 'm1', title: 'Task Due Tomorrow', body: 'Task: "Finalize Thingyan event positions" is due tomorrow.', type: NotificationType.task, priority: NotificationPriority.high, isRead: false, createdAt: DateTime.now().subtract(const Duration(days: 2)), routeTo: '/meetings/mt2'),
    AppNotification(id: 'n6', recipientId: 'm1', title: 'Duty Rejected', body: 'Ma Su Su Myat rejected duty assignment for Community First Aid Event.', type: NotificationType.duty, priority: NotificationPriority.normal, isRead: true, createdAt: DateTime.now().subtract(const Duration(days: 3))),
  ];

  static List<AppNotification> forMember(String memberId) =>
      all.where((n) => n.recipientId == memberId).toList();

  static int unreadCount(String memberId) =>
      all.where((n) => n.recipientId == memberId && !n.isRead).length;
}

// ─────────────────────────────────────────────
// MOCK EQUIPMENT
// ─────────────────────────────────────────────
class MockEquipment {
  static final List<Equipment> all = [
    Equipment(id: 'eq1', name: 'First Aid Kit (Large)', nameMm: 'ပထမဆုံးအကူ အသေတ္တာ (ကြီး)', category: 'Medical', totalQuantity: 5, availableQuantity: 4, condition: 'Good', storageLocation: 'Store Room A'),
    Equipment(id: 'eq2', name: 'Stretcher', nameMm: 'လူနာတင်ကုတင်', category: 'Medical', totalQuantity: 3, availableQuantity: 2, condition: 'Good', storageLocation: 'Store Room A'),
    Equipment(id: 'eq3', name: 'Walkie Talkie', nameMm: 'ဝါကီတာကီ', category: 'Communication', totalQuantity: 8, availableQuantity: 6, condition: 'Good', storageLocation: 'Communication Room'),
    Equipment(id: 'eq4', name: 'Oxygen Cylinder', nameMm: 'အောက်ဆီဂျင် ဆလင်ဒါ', category: 'Medical', totalQuantity: 2, availableQuantity: 2, condition: 'Good', storageLocation: 'Store Room B'),
    Equipment(id: 'eq5', name: 'Defibrillator (AED)', nameMm: 'AED စက်', category: 'Medical', totalQuantity: 1, availableQuantity: 1, condition: 'Excellent', storageLocation: 'Store Room A'),
    Equipment(id: 'eq6', name: 'Disaster Response Tent', nameMm: 'ဘေးအန္တရာယ် တဲ', category: 'Disaster', totalQuantity: 2, availableQuantity: 1, condition: 'Fair', storageLocation: 'Warehouse'),
  ];
}

// ─────────────────────────────────────────────
// MOCK FUND ENTRIES
// ─────────────────────────────────────────────
class MockFundEntries {
  static final List<FundEntry> all = [
    FundEntry(id: 'fe1', type: 'income', description: 'Membership Fees — March 2024', amount: 240000, date: DateTime.now().subtract(const Duration(days: 30)), category: 'Membership', recordedById: 'm1', referenceNo: 'INC-2024-003'),
    FundEntry(id: 'fe2', type: 'income', description: 'Donation — Yangon Business Association', amount: 1000000, date: DateTime.now().subtract(const Duration(days: 20)), category: 'Donation', recordedById: 'm1', referenceNo: 'INC-2024-004'),
    FundEntry(id: 'fe3', type: 'expenditure', description: 'Class Budget — Advanced First Aid', amount: 500000, date: DateTime.now().subtract(const Duration(days: 5)), category: 'Training', recordedById: 'm1', classId: 'cl1', referenceNo: 'EXP-2024-007'),
    FundEntry(id: 'fe4', type: 'expenditure', description: 'Equipment Maintenance', amount: 85000, date: DateTime.now().subtract(const Duration(days: 15)), category: 'Equipment', recordedById: 'm6', referenceNo: 'EXP-2024-006'),
    FundEntry(id: 'fe5', type: 'income', description: 'Membership Fees — April 2024', amount: 240000, date: DateTime.now().subtract(const Duration(days: 2)), category: 'Membership', recordedById: 'm1', referenceNo: 'INC-2024-005'),
  ];

  double get balance => all.fold(0.0, (sum, e) => e.type == 'income' ? sum + e.amount : sum - e.amount);
}

// ─────────────────────────────────────────────
// MOCK TRANSFER HISTORY
// ─────────────────────────────────────────────
class MockTransferHistory {
  static final List<TransferHistory> all = [
    TransferHistory(id: 'tr1', memberId: 'm1', type: TransferType.promotion, fromRankOrUnit: 'Officer', toRankOrUnit: 'Senior Officer', date: DateTime(2022, 6, 1), authorizedById: 'm6', reason: 'Outstanding service and leadership performance'),
    TransferHistory(id: 'tr2', memberId: 'm3', type: TransferType.transfer, fromRankOrUnit: 'Main Branch', toRankOrUnit: 'Field Unit', date: DateTime(2022, 1, 15), authorizedById: 'm1', reason: 'Operational requirements'),
    TransferHistory(id: 'tr3', memberId: 'm4', type: TransferType.demotion, fromRankOrUnit: 'Junior Officer', toRankOrUnit: 'Member', date: DateTime.now().subtract(const Duration(days: 14)), authorizedById: 'm1', reason: 'Disciplinary action following investigation', punishmentId: 'pn1'),
  ];

  static List<TransferHistory> forMember(String memberId) =>
      all.where((t) => t.memberId == memberId).toList();
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

// ─────────────────────────────────────────────
// MOCK MEDIAL EVENTS
// ─────────────────────────────────────────────
class MockMedicalEvents {
  static final List<MedicalEvent> all = [
    MedicalEvent(
      id: 'ev1', title: 'Thingyan Festival Medical Coverage', titleMm: 'သင်္ကြန် ဆေးဘက်ဆိုင်ရာ ကာမိန်',
      eventType: 'Festival', date: DateTime.now().add(const Duration(days: 20)),
      location: 'Bogyoke Road to Sule Pagoda Road, Yangon',
      hasMapPins: true,
      positions: [
        EventPosition(id: 'ep1', eventId: 'ev1', nameEn: 'Base — Start Point', type: EventPositionType.base, locationDescription: 'Bogyoke Aung San Museum Gate', latitude: 16.7967, longitude: 96.1561, requiredMembers: 2, assignedMemberIds: ['m1', 'm2'], requiredSkillIds: ['sk2'], equipmentIds: ['eq1', 'eq4']),
        EventPosition(id: 'ep2', eventId: 'ev1', nameEn: 'Point 1 — Sule Junction', type: EventPositionType.point, locationDescription: 'Sule Pagoda Road Junction', latitude: 16.7754, longitude: 96.1536, requiredMembers: 1, assignedMemberIds: ['m3'], requiredSkillIds: ['sk1'], equipmentIds: ['eq1']),
        EventPosition(id: 'ep3', eventId: 'ev1', nameEn: 'Patrol — Bogyoke to Sule', type: EventPositionType.patrol, locationDescription: 'Patrol segment covering 2km stretch', requiredMembers: 2, assignedMemberIds: ['m4', 'm5'], requiredSkillIds: ['sk1'], equipmentIds: ['eq3']),
        EventPosition(id: 'ep4', eventId: 'ev1', nameEn: 'Standby — Mobile Unit', type: EventPositionType.standby, locationDescription: 'Stationed at Branch Office, deployable within 10 minutes', requiredMembers: 2, assignedMemberIds: ['m6'], requiredSkillIds: ['sk2'], equipmentIds: ['eq2', 'eq5']),
        EventPosition(id: 'ep5', eventId: 'ev1', nameEn: 'Command — HQ', type: EventPositionType.command, locationDescription: 'Branch Office Command Center', requiredMembers: 1, assignedMemberIds: ['m1'], requiredSkillIds: ['sk5'], equipmentIds: ['eq3']),
      ],
      status: DutyStatus.upcoming,
      createdById: 'm1',
    ),
  ];
}

// ─────────────────────────────────────────────
// MOCK LIBRARY DOCUMENTS
// ─────────────────────────────────────────────
class MockLibrary {
  static final List<LibraryDocument> all = [
    LibraryDocument(id: 'lb1', title: 'First Aid Manual 2024', titleMm: 'အသက်ဆယ်ကယ် လက်စွဲ ၂၀၂၄', category: 'Medical', fileUrl: '', fileType: 'PDF', uploadedDate: DateTime.now().subtract(const Duration(days: 30)), uploadedById: 'm1', isPublic: true),
    LibraryDocument(id: 'lb2', title: 'Disaster Response Guidelines', titleMm: 'ဘေးအန္တရာယ် တုံ့ပြန်ရေး လမ်းညွှန်', category: 'Disaster', fileUrl: '', fileType: 'PDF', uploadedDate: DateTime.now().subtract(const Duration(days: 60)), uploadedById: 'm6', isPublic: true),
    LibraryDocument(id: 'lb3', title: 'MRCS Constitution & Bylaws', titleMm: 'MRCS ဖွဲ့စည်းပုံ နှင့် စည်းမျဉ်းများ', category: 'Administrative', fileUrl: '', fileType: 'PDF', uploadedDate: DateTime.now().subtract(const Duration(days: 180)), uploadedById: 'm1', isPublic: true),
    LibraryDocument(id: 'lb4', title: 'Blood Donation Awareness Materials', titleMm: 'သွေးလှူဒါန်းရေး အသိပညာပေး', category: 'Blood Donation', fileUrl: '', fileType: 'PDF', uploadedDate: DateTime.now().subtract(const Duration(days: 15)), uploadedById: 'm1', isPublic: true),
  ];
}

// ─────────────────────────────────────────────
// MOCK CERTIFICATES
// ─────────────────────────────────────────────
class MockCertificates {
  static final List<Certificate> all = [
    Certificate(id: 'cert1', memberId: 'm1', title: 'First Aid Level 2', titleMm: 'အသက်ဆယ်ကယ် အဆင့် ၂ လက်မှတ်', certType: 'Skill Certificate', issuedDate: DateTime(2023, 3, 15), issuedById: 'm6', referenceNo: 'CERT-2023-001', classId: 'cl3'),
    Certificate(id: 'cert2', memberId: 'm2', title: 'CPR Certification', titleMm: 'CPR လက်မှတ်', certType: 'Skill Certificate', issuedDate: DateTime(2023, 8, 20), expiryDate: DateTime(2024, 8, 20), issuedById: 'm1', referenceNo: 'CERT-2023-015'),
    Certificate(id: 'cert3', memberId: 'm3', title: 'Disaster Management Certificate', titleMm: 'ဘေးအန္တရာယ် စီမံခန့်ခွဲမှု လက်မှတ်', certType: 'Participation Certificate', issuedDate: DateTime.now().subtract(const Duration(days: 8)), issuedById: 'm6', referenceNo: 'CERT-2024-003', classId: 'cl3'),
  ];

  static List<Certificate> forMember(String memberId) =>
      all.where((c) => c.memberId == memberId).toList();
}

// ─────────────────────────────────────────────
// CURRENT USER (Mock logged-in user)
// ─────────────────────────────────────────────
class MockCurrentUser {
  // Change this to test different roles:
  static final Member member = MockMembers.all[0]; // Ko Aung Kyaw — Senior Officer
  static UserRole get role => member.role;
  static String get id => member.id;

  static bool canViewInvestigations() =>
      role == UserRole.admin || role == UserRole.topBrass || role == UserRole.seniorOfficer;

  static bool canViewPunishments() =>
      role == UserRole.admin || role == UserRole.topBrass || role == UserRole.seniorOfficer || role == UserRole.officer;

  static bool canApproveReports() =>
      role == UserRole.admin || role == UserRole.topBrass || role == UserRole.seniorOfficer || role == UserRole.officer;

  static bool canAssignDuties() =>
      role != UserRole.member;

  static bool canManageMembers() =>
      role == UserRole.admin || role == UserRole.topBrass || role == UserRole.seniorOfficer;

  static bool canManageFund() =>
      role == UserRole.admin || role == UserRole.topBrass;

  static bool canIssueInvestigation() =>
      role == UserRole.admin || role == UserRole.topBrass || role == UserRole.seniorOfficer;
}
