import '../../core/constants/app_constants.dart';

// ═══════════════════════════════════════════════════════════════
// MEMBER MODEL — Module 4 Extension
//
// Extends the Module 3 Member model with the official CV-format
// fields (28-field profile), probation/membership flow, availability
// (separate from active/inactive status), and admin role flag.
//
// All Module 3 fields are preserved exactly. Only new fields added,
// all nullable or defaulted so existing code keeps compiling.
// ═══════════════════════════════════════════════════════════════
class Member {
  // ── Module 3 fields (unchanged) ──
  final String id;
  final String memberNo;
  final String nameEn;
  final String nameMm;
  final MemberRank rank;
  final UnitType unitType;
  final int? companyNo;      // 1-4, null if Brigade Office
  final int? platoonNo;      // e.g. 1, 2 within company
  final int? sectionNo;      // e.g. 1, 2 within platoon
  final MemberStatus status;
  final BloodType bloodType;
  final DateTime joinDate;
  final String? photoUrl;
  final String phone;
  final String email;
  final String address;
  final DateTime dateOfBirth;
  final String emergencyContact;
  final String emergencyPhone;
  final List<String> skillIds;

  // Special flags
  final bool isChairperson;
  final bool isBrigadeOfficeChief;
  final bool hasBrigadeOfficeAuthority;

  // Duty assignment (can manage two platoons)
  final List<int>? assignedPlatoons;

  // Youth Wing
  final YouthGroup? youthGroup;
  final YouthGroupRole? youthGroupRole;

  // Legacy role (kept for backward compat)
  final UserRole role;

  // ── Module 4 additions: CV-format fields (28-field profile) ──
  final Gender gender;
  final String? fatherName;
  final String? fatherOccupation;
  final String? motherName;
  final String? motherOccupation;
  final String? nrc;                  // နိုင်ငံသားစိစစ်ရေးအမှတ် (or "လျှောက်ထားဆဲ")
  final String? ygnId;                // YGN ID No. e.g. 13017/00024
  final DateTime? currentRankDate;    // လက်ရှိရာထူးရရက်စွဲ
  final String? height;               // အရပ် e.g. "၅ ပေ ၅ လက်မ"
  final String? eyeColor;
  final String? hairColor;
  final String? distinguishingMarks;
  final String? ethnicity;
  final String? religion;
  final String? education;
  final String? occupation;
  final String? occupationDepartment;
  final List<String> completedTrainings;
  final String? honorsAwards;

  // ── Module 4 additions: Membership numbers ──
  final String? membershipNo;         // တဖ-ရက/ဗတထ/[No] or သမ-[No]/ဗတထ/ရက
  final String? lifetimeMemberNo;     // ရာသက်ပန်-XXXX
  final DateTime? lifetimeMemberDate;
  final String? serviceBookNo;        // သမ-XX/ဗတထ/ရက

  // ── Module 4 additions: Probation flow ──
  final MembershipType membershipType;
  final DateTime? probationStartDate;
  final List<int> annualFeesPaidYears; // years annual fee was paid (RCOM only)

  // ── Module 4 additions: Availability (separate from status) ──
  final bool isAvailable;             // scheduling flag, not membership status

  // ── Module 4 additions: Inactive (long leave/overseas) detail ──
  // Only meaningful when status == MemberStatus.inactive for this reason
  // (as opposed to suspended/dismissed, which are disciplinary and
  // handled separately). Captures why and for how long, so the brigade
  // knows when to expect the member back.
  final String? inactiveReason;       // e.g. "Overseas - work assignment"
  final DateTime? inactiveReturnDate; // expected return date

  // ── Module 4 additions: Admin role ──
  final bool isAdminRole;             // same power as Master Access for
                                       // availability/active-inactive/rank,
                                       // but needs approval to act on Deputy+ rank

  const Member({
    required this.id,
    required this.memberNo,
    required this.nameEn,
    required this.nameMm,
    required this.rank,
    required this.unitType,
    this.companyNo,
    this.platoonNo,
    this.sectionNo,
    required this.status,
    required this.bloodType,
    required this.joinDate,
    this.photoUrl,
    required this.phone,
    required this.email,
    required this.address,
    required this.dateOfBirth,
    required this.emergencyContact,
    required this.emergencyPhone,
    required this.skillIds,
    this.isChairperson = false,
    this.isBrigadeOfficeChief = false,
    this.hasBrigadeOfficeAuthority = false,
    this.assignedPlatoons,
    this.youthGroup,
    this.youthGroupRole,
    required this.role,
    // Module 4 additions — all default safely
    this.gender = Gender.male,
    this.fatherName,
    this.fatherOccupation,
    this.motherName,
    this.motherOccupation,
    this.nrc,
    this.ygnId,
    this.currentRankDate,
    this.height,
    this.eyeColor,
    this.hairColor,
    this.distinguishingMarks,
    this.ethnicity,
    this.religion,
    this.education,
    this.occupation,
    this.occupationDepartment,
    this.completedTrainings = const [],
    this.honorsAwards,
    this.membershipNo,
    this.lifetimeMemberNo,
    this.lifetimeMemberDate,
    this.serviceBookNo,
    this.membershipType = MembershipType.official,
    this.probationStartDate,
    this.annualFeesPaidYears = const [],
    this.isAvailable = true,
    this.inactiveReason,
    this.inactiveReturnDate,
    this.isAdminRole = false,
  });

  // ── Existing getters (unchanged) ──
  String get initials {
    final parts = nameEn.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    if (nameEn.length >= 2) return nameEn.substring(0, 2).toUpperCase();
    return nameEn.toUpperCase();
  }

  String get rankNameEn => RankHelper.nameEn(rank);
  String get rankNameMm => RankHelper.nameMm(rank);
  bool get isOfficer => RankHelper.isOfficerRank(rank);

  String get bloodTypeDisplay {
    switch (bloodType) {
      case BloodType.OP: return 'O+';
      case BloodType.OM: return 'O-';
      case BloodType.AP: return 'A+';
      case BloodType.AM: return 'A-';
      case BloodType.BP: return 'B+';
      case BloodType.BM: return 'B-';
      case BloodType.ABP: return 'AB+';
      case BloodType.ABM: return 'AB-';
    }
  }

  String get unitDisplay {
    if (unitType == UnitType.brigadeOffice) return 'Brigade Office';
    if (unitType == UnitType.companyOffice) return 'Company $companyNo Office';
    if (unitType == UnitType.platoonOffice) {
      return 'Company $companyNo Platoon $platoonNo Office';
    }
    if (companyNo != null && platoonNo != null && sectionNo != null) {
      return 'C$companyNo/P$platoonNo/S$sectionNo';
    }
    if (companyNo != null && platoonNo != null) {
      return 'Company $companyNo / Platoon $platoonNo';
    }
    if (companyNo != null) return 'Company $companyNo';
    return 'Unassigned';
  }

  // ── Module 4 new getters ──

  /// Years of service: today - joinDate
  int get yearsOfService {
    final now = DateTime.now();
    int years = now.year - joinDate.year;
    if (now.month < joinDate.month ||
        (now.month == joinDate.month && now.day < joinDate.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  /// Years in current rank: today - currentRankDate
  int? get yearsInCurrentRank {
    if (currentRankDate == null) return null;
    final now = DateTime.now();
    int years = now.year - currentRankDate!.year;
    if (now.month < currentRankDate!.month ||
        (now.month == currentRankDate!.month && now.day < currentRankDate!.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  /// Current age: today - dateOfBirth
  int get age {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  String get genderDisplayMm => gender == Gender.male ? 'ကျား' : 'မ';

  /// Honorific prefix based on gender, used in document generation
  String get honorificPrefixMm => gender == Gender.male ? 'ဦး' : 'ဒေါ်';

  bool get isProbationer => membershipType == MembershipType.probationer;
  bool get isOfficialMember => membershipType == MembershipType.official;
  bool get isPendingApplication => membershipType == MembershipType.pendingApplication;

  /// Annual fee expiry check (RCOM probationers only):
  /// 3 consecutive years missed → membership auto-expires
  bool get hasAnnualFeeExpiryRisk {
    if (!isProbationer) return false;
    final currentYear = DateTime.now().year;
    final last3Years = [currentYear, currentYear - 1, currentYear - 2];
    final missedCount = last3Years
        .where((y) => !annualFeesPaidYears.contains(y))
        .length;
    return missedCount >= 3;
  }

  /// Mark this member inactive for long leave/overseas, with reason and
  /// expected return date. Use this instead of copyWith for this
  /// transition since copyWith's `??` pattern can't be used to set a
  /// genuinely new value cleanly alongside status in one call.
  Member markInactiveForLeave({
    required String reason,
    required DateTime returnDate,
  }) {
    return copyWith(status: MemberStatus.inactive).copyWithInactiveDetail(
      reason: reason,
      returnDate: returnDate,
    );
  }

  /// Internal helper — sets inactiveReason/inactiveReturnDate directly
  /// (copyWith's `??` can't be used here since we need to actually set
  /// these, not skip when already null).
  Member copyWithInactiveDetail({
    required String reason,
    required DateTime returnDate,
  }) {
    return Member(
      id: id, memberNo: memberNo, nameEn: nameEn, nameMm: nameMm, rank: rank,
      unitType: unitType, companyNo: companyNo, platoonNo: platoonNo,
      sectionNo: sectionNo, status: status, bloodType: bloodType,
      joinDate: joinDate, photoUrl: photoUrl, phone: phone, email: email,
      address: address, dateOfBirth: dateOfBirth,
      emergencyContact: emergencyContact, emergencyPhone: emergencyPhone,
      skillIds: skillIds, isChairperson: isChairperson,
      isBrigadeOfficeChief: isBrigadeOfficeChief,
      hasBrigadeOfficeAuthority: hasBrigadeOfficeAuthority,
      assignedPlatoons: assignedPlatoons, youthGroup: youthGroup,
      youthGroupRole: youthGroupRole, role: role, gender: gender,
      fatherName: fatherName, fatherOccupation: fatherOccupation,
      motherName: motherName, motherOccupation: motherOccupation, nrc: nrc,
      ygnId: ygnId, currentRankDate: currentRankDate, height: height,
      eyeColor: eyeColor, hairColor: hairColor,
      distinguishingMarks: distinguishingMarks, ethnicity: ethnicity,
      religion: religion, education: education, occupation: occupation,
      occupationDepartment: occupationDepartment,
      completedTrainings: completedTrainings, honorsAwards: honorsAwards,
      membershipNo: membershipNo, lifetimeMemberNo: lifetimeMemberNo,
      lifetimeMemberDate: lifetimeMemberDate, serviceBookNo: serviceBookNo,
      membershipType: membershipType, probationStartDate: probationStartDate,
      annualFeesPaidYears: annualFeesPaidYears, isAvailable: isAvailable,
      inactiveReason: reason,
      inactiveReturnDate: returnDate,
      isAdminRole: isAdminRole,
    );
  }

  /// Returns this member to active status and clears the leave detail.
  Member markActiveAgain() {
    return Member(
      id: id, memberNo: memberNo, nameEn: nameEn, nameMm: nameMm, rank: rank,
      unitType: unitType, companyNo: companyNo, platoonNo: platoonNo,
      sectionNo: sectionNo, status: MemberStatus.active, bloodType: bloodType,
      joinDate: joinDate, photoUrl: photoUrl, phone: phone, email: email,
      address: address, dateOfBirth: dateOfBirth,
      emergencyContact: emergencyContact, emergencyPhone: emergencyPhone,
      skillIds: skillIds, isChairperson: isChairperson,
      isBrigadeOfficeChief: isBrigadeOfficeChief,
      hasBrigadeOfficeAuthority: hasBrigadeOfficeAuthority,
      assignedPlatoons: assignedPlatoons, youthGroup: youthGroup,
      youthGroupRole: youthGroupRole, role: role, gender: gender,
      fatherName: fatherName, fatherOccupation: fatherOccupation,
      motherName: motherName, motherOccupation: motherOccupation, nrc: nrc,
      ygnId: ygnId, currentRankDate: currentRankDate, height: height,
      eyeColor: eyeColor, hairColor: hairColor,
      distinguishingMarks: distinguishingMarks, ethnicity: ethnicity,
      religion: religion, education: education, occupation: occupation,
      occupationDepartment: occupationDepartment,
      completedTrainings: completedTrainings, honorsAwards: honorsAwards,
      membershipNo: membershipNo, lifetimeMemberNo: lifetimeMemberNo,
      lifetimeMemberDate: lifetimeMemberDate, serviceBookNo: serviceBookNo,
      membershipType: membershipType, probationStartDate: probationStartDate,
      annualFeesPaidYears: annualFeesPaidYears, isAvailable: isAvailable,
      inactiveReason: null,
      inactiveReturnDate: null,
      isAdminRole: isAdminRole,
    );
  }

  Member copyWith({
    bool? isBrigadeOfficeChief,
    bool? hasBrigadeOfficeAuthority,
    UnitType? unitType,
    int? companyNo,
    int? platoonNo,
    int? sectionNo,
    List<int>? assignedPlatoons,
    YouthGroup? youthGroup,
    YouthGroupRole? youthGroupRole,
    MemberStatus? status,
    // Module 4 additions
    bool? isAvailable,
    String? inactiveReason,
    DateTime? inactiveReturnDate,
    bool? isAdminRole,
    MembershipType? membershipType,
    String? membershipNo,
    MemberRank? rank,
    String? photoUrl,
  }) {
    return Member(
      id: id,
      memberNo: memberNo,
      nameEn: nameEn,
      nameMm: nameMm,
      rank: rank ?? this.rank,
      unitType: unitType ?? this.unitType,
      companyNo: companyNo ?? this.companyNo,
      platoonNo: platoonNo ?? this.platoonNo,
      sectionNo: sectionNo ?? this.sectionNo,
      status: status ?? this.status,
      bloodType: bloodType,
      joinDate: joinDate,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone,
      email: email,
      address: address,
      dateOfBirth: dateOfBirth,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
      skillIds: skillIds,
      isChairperson: isChairperson,
      isBrigadeOfficeChief: isBrigadeOfficeChief ?? this.isBrigadeOfficeChief,
      hasBrigadeOfficeAuthority:
          hasBrigadeOfficeAuthority ?? this.hasBrigadeOfficeAuthority,
      assignedPlatoons: assignedPlatoons ?? this.assignedPlatoons,
      youthGroup: youthGroup ?? this.youthGroup,
      youthGroupRole: youthGroupRole ?? this.youthGroupRole,
      role: role,
      gender: gender,
      fatherName: fatherName,
      fatherOccupation: fatherOccupation,
      motherName: motherName,
      motherOccupation: motherOccupation,
      nrc: nrc,
      ygnId: ygnId,
      currentRankDate: currentRankDate,
      height: height,
      eyeColor: eyeColor,
      hairColor: hairColor,
      distinguishingMarks: distinguishingMarks,
      ethnicity: ethnicity,
      religion: religion,
      education: education,
      occupation: occupation,
      occupationDepartment: occupationDepartment,
      completedTrainings: completedTrainings,
      honorsAwards: honorsAwards,
      membershipNo: membershipNo ?? this.membershipNo,
      lifetimeMemberNo: lifetimeMemberNo,
      lifetimeMemberDate: lifetimeMemberDate,
      serviceBookNo: serviceBookNo,
      membershipType: membershipType ?? this.membershipType,
      probationStartDate: probationStartDate,
      annualFeesPaidYears: annualFeesPaidYears,
      isAvailable: isAvailable ?? this.isAvailable,
      inactiveReason: inactiveReason ?? this.inactiveReason,
      inactiveReturnDate: inactiveReturnDate ?? this.inactiveReturnDate,
      isAdminRole: isAdminRole ?? this.isAdminRole,
    );
  }
}

// ─────────────────────────────────────────────
// DUTY MEMBER MODEL
// Tracks member's role within a specific duty
// ─────────────────────────────────────────────
class DutyMember {
  final String memberId;
  final DutyRoleInDuty roleInDuty;
  final String? positionId;       // For large scale events
  final DutyAssignmentStatus status;
  final String? rejectionReason;
  final DateTime? checkedInAt;
  final DateTime assignedAt;
  final DateTime? respondedAt;

  const DutyMember({
    required this.memberId,
    required this.roleInDuty,
    this.positionId,
    required this.status,
    this.rejectionReason,
    this.checkedInAt,
    required this.assignedAt,
    this.respondedAt,
  });

  bool get isCheckedIn => checkedInAt != null;
}

// ─────────────────────────────────────────────
// DUTY MODEL — Updated
// ─────────────────────────────────────────────
class Duty {
  final String id;
  final String title;
  final String titleMm;
  final DutyType type;
  final DutyScale scale;
  final DateTime date;
  final int startHour;
  final int startMinute;
  final int? endHour;
  final int? endMinute;
  final String location;
  final List<DutyMember> members;
  final DutyStatus status;
  final String? description;
  final bool isEvent;
  final String? eventId;

  const Duty({
    required this.id,
    required this.title,
    required this.titleMm,
    required this.type,
    required this.scale,
    required this.date,
    required this.startHour,
    required this.startMinute,
    this.endHour,
    this.endMinute,
    required this.location,
    required this.members,
    required this.status,
    this.description,
    this.isEvent = false,
    this.eventId,
  });

  String get startTimeDisplay =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  List<DutyMember> get officers =>
      members.where((m) => m.roleInDuty == DutyRoleInDuty.officer).toList();

  DutyMember? get commander => members
      .where((m) => m.roleInDuty == DutyRoleInDuty.commander)
      .firstOrNull;

  String get typeDisplay {
    switch (type) {
      case DutyType.firstAid: return 'First Aid';
      case DutyType.bloodDonation: return 'Blood Donation';
      case DutyType.training: return 'Training';
      case DutyType.patrol: return 'Patrol';
      case DutyType.eventMedical: return 'Event Medical';
      case DutyType.disaster: return 'Disaster Response';
      case DutyType.administrative: return 'Administrative';
      case DutyType.other: return 'Other';
    }
  }
}

// ─────────────────────────────────────────────
// INVESTIGATION MODEL — Updated
// ─────────────────────────────────────────────
class Investigation {
  final String id;
  final String caseNumber;
  final String title;
  final String description;
  final DateTime openedDate;
  final DateTime? concludedDate;
  final InvestigationStatus status;
  final List<String> accusedMemberIds;
  final List<String> witnessMemberIds;
  final List<String> committeeMemberIds;
  final List<String> recusedMemberIds;
  final List<String> appealCommitteeMemberIds;
  final List<String> approvedSealedViewers; // Members approved to see sealed attachments
  final Map<String, DateTime> committeeJoinDates; // memberId -> join date
  final List<InvestigationStageLog> stageLogs;
  final List<InvestigationAttachment> attachments;
  final String? outcome;
  final bool isSealed;

  const Investigation({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.description,
    required this.openedDate,
    this.concludedDate,
    required this.status,
    required this.accusedMemberIds,
    required this.witnessMemberIds,
    required this.committeeMemberIds,
    required this.recusedMemberIds,
    required this.appealCommitteeMemberIds,
    required this.approvedSealedViewers,
    required this.committeeJoinDates,
    required this.stageLogs,
    required this.attachments,
    this.outcome,
    required this.isSealed,
  });

  int get currentStageIndex {
    switch (status) {
      case InvestigationStatus.opened: return 0;
      case InvestigationStatus.underInvestigation: return 1;
      case InvestigationStatus.hearingScheduled: return 2;
      case InvestigationStatus.hearingConducted: return 3;
      case InvestigationStatus.deliberation: return 4;
      case InvestigationStatus.concluded: return 5;
      case InvestigationStatus.closed: return 6;
      case InvestigationStatus.appealed: return 7;
      case InvestigationStatus.appealReview: return 8;
      case InvestigationStatus.appealConcluded: return 9;
    }
  }
}

// ─────────────────────────────────────────────
// INVESTIGATION STAGE LOG
// ─────────────────────────────────────────────
class InvestigationStageLog {
  final String id;
  final String investigationId;
  final InvestigationStatus stage;
  final DateTime timestamp;
  final String actionedById;
  final String? notes;

  const InvestigationStageLog({
    required this.id,
    required this.investigationId,
    required this.stage,
    required this.timestamp,
    required this.actionedById,
    this.notes,
  });
}

// ─────────────────────────────────────────────
// INVESTIGATION ATTACHMENT
// ─────────────────────────────────────────────
class InvestigationAttachment {
  final String id;
  final String investigationId;
  final String filename;
  final String fileUrl;
  final bool isSealed;
  final String uploadedById;
  final DateTime uploadedAt;

  const InvestigationAttachment({
    required this.id,
    required this.investigationId,
    required this.filename,
    required this.fileUrl,
    required this.isSealed,
    required this.uploadedById,
    required this.uploadedAt,
  });
}

// ─────────────────────────────────────────────
// PUNISHMENT MODEL
// ─────────────────────────────────────────────
class Punishment {
  final String id;
  final String memberId;
  final PunishmentType type;
  final String description;
  final DateTime issuedDate;
  final DateTime? endDate;
  final String issuedById;
  final PunishmentStatus status;
  final String? investigationId;
  final bool isAppealable;
  final String? appealReason;
  final String? appealOutcome;

  const Punishment({
    required this.id,
    required this.memberId,
    required this.type,
    required this.description,
    required this.issuedDate,
    this.endDate,
    required this.issuedById,
    required this.status,
    this.investigationId,
    required this.isAppealable,
    this.appealReason,
    this.appealOutcome,
  });

  String get typeDisplay {
    switch (type) {
      case PunishmentType.verbalWarning: return 'Verbal Warning';
      case PunishmentType.writtenWarning: return 'Written Warning';
      case PunishmentType.fine: return 'Fine';
      case PunishmentType.suspension: return 'Suspension';
      case PunishmentType.demotion: return 'Demotion';
      case PunishmentType.dismissal: return 'Dismissal';
      case PunishmentType.other: return 'Other';
    }
  }
}

// ─────────────────────────────────────────────
// SKILL MODEL
// ─────────────────────────────────────────────
class Skill {
  final String id;
  final String nameEn;
  final String nameMm;
  final String category;
  final int? expiryMonths;

  const Skill({
    required this.id,
    required this.nameEn,
    required this.nameMm,
    required this.category,
    this.expiryMonths,
  });
}

// ─────────────────────────────────────────────
// MEMBER AVAILABILITY MODEL
// ─────────────────────────────────────────────
class MemberAvailability {
  final String id;
  final String memberId;
  final DateTime date;
  final AvailabilityStatus status;
  final int? freeFromHour;
  final int? freeFromMinute;
  final int? freeToHour;
  final int? freeToMinute;
  final bool isAutoCopied;
  final bool isConfirmed;

  const MemberAvailability({
    required this.id,
    required this.memberId,
    required this.date,
    required this.status,
    this.freeFromHour,
    this.freeFromMinute,
    this.freeToHour,
    this.freeToMinute,
    this.isAutoCopied = false,
    this.isConfirmed = true,
  });
}

// ─────────────────────────────────────────────
// EVENT POSITION MODEL
// ─────────────────────────────────────────────
class EventPosition {
  final String id;
  final String eventId;
  final String nameEn;
  final EventPositionType type;
  final String locationDescription;
  final double? latitude;
  final double? longitude;
  final int requiredMembers;
  final List<String> assignedMemberIds;
  final List<String> requiredSkillIds;
  final List<String> equipmentIds;

  const EventPosition({
    required this.id,
    required this.eventId,
    required this.nameEn,
    required this.type,
    required this.locationDescription,
    this.latitude,
    this.longitude,
    required this.requiredMembers,
    required this.assignedMemberIds,
    required this.requiredSkillIds,
    required this.equipmentIds,
  });

  bool get isFilled => assignedMemberIds.length >= requiredMembers;

  String get typeDisplay {
    switch (type) {
      case EventPositionType.base: return 'Base';
      case EventPositionType.point: return 'Point';
      case EventPositionType.patrol: return 'Patrol';
      case EventPositionType.standby: return 'Standby';
      case EventPositionType.command: return 'Command';
      case EventPositionType.liaison: return 'Liaison';
    }
  }
}

// ─────────────────────────────────────────────
// MEETING MODEL
// ─────────────────────────────────────────────
class Meeting {
  final String id;
  final String title;
  final String titleMm;
  final MeetingType type;
  final DateTime date;
  final int timeHour;
  final int timeMinute;
  final String location;
  final List<String> invitedMemberIds;
  final List<String> attendedMemberIds;
  final MemberRank? minimumRank;
  final String? agenda;
  final String? minutes;
  final MeetingStatus status;
  final List<MeetingTask> tasks;
  final DateTime? createdAt;

  const Meeting({
    required this.id,
    required this.title,
    required this.titleMm,
    required this.type,
    required this.date,
    required this.timeHour,
    required this.timeMinute,
    required this.location,
    required this.invitedMemberIds,
    required this.attendedMemberIds,
    this.minimumRank,
    this.agenda,
    this.minutes,
    required this.status,
    required this.tasks,
    this.createdAt,
  });

  String get timeDisplay =>
      '${timeHour.toString().padLeft(2, '0')}:${timeMinute.toString().padLeft(2, '0')}';

  String get typeDisplay {
    switch (type) {
      case MeetingType.general: return 'General';
      case MeetingType.officer: return 'Officer';
      case MeetingType.committee: return 'Committee';
      case MeetingType.investigation: return 'Investigation';
      case MeetingType.youthLeaders: return 'Youth Leaders';
      case MeetingType.youthGroup: return 'Youth Group';
      case MeetingType.custom: return 'Custom';
    }
  }
}

// ─────────────────────────────────────────────
// MEETING TASK MODEL
// ─────────────────────────────────────────────
class MeetingTask {
  final String id;
  final String meetingId;
  final String title;
  final String assignedMemberId;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isVerified;

  const MeetingTask({
    required this.id,
    required this.meetingId,
    required this.title,
    required this.assignedMemberId,
    required this.dueDate,
    required this.isCompleted,
    this.completedAt,
    required this.isVerified,
  });
}

// ─────────────────────────────────────────────
// TRAINING CLASS MODEL
// ─────────────────────────────────────────────
class TrainingClass {
  final String id;
  final String title;
  final String titleMm;
  final ClassType type;
  final String category;
  final String description;
  final String instructorId;
  final String instructorName;
  final bool isExternalInstructor;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final int maxParticipants;
  final List<String> enrolledMemberIds;
  final ClassStatus status;
  final List<String> requiredSkillIds;
  final List<String> awardedSkillIds;
  final bool issuesCertificate;
  final String? certificateTemplateId;
  final bool hasCommittee;
  final List<ClassCommitteeMember> committee;
  final ClassBudget? budget;
  final List<ClassSession> timetable;
  final String? minRankRequired;

  const TrainingClass({
    required this.id,
    required this.title,
    required this.titleMm,
    required this.type,
    required this.category,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    required this.isExternalInstructor,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.maxParticipants,
    required this.enrolledMemberIds,
    required this.status,
    required this.requiredSkillIds,
    required this.awardedSkillIds,
    required this.issuesCertificate,
    this.certificateTemplateId,
    required this.hasCommittee,
    required this.committee,
    this.budget,
    required this.timetable,
    this.minRankRequired,
  });

  int get enrolledCount => enrolledMemberIds.length;
  bool get isFull => enrolledCount >= maxParticipants;

  String? get committeeChairpersonId {
    try {
      return committee
          .firstWhere((m) => m.role == 'Committee Head')
          .memberId;
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────
// CLASS COMMITTEE MEMBER
// ─────────────────────────────────────────────
class ClassCommitteeMember {
  final String memberId;
  final String role;

  const ClassCommitteeMember({
    required this.memberId,
    required this.role,
  });
}

// ─────────────────────────────────────────────
// CLASS SESSION MODEL
// ─────────────────────────────────────────────
class ClassSession {
  final String id;
  final String classId;
  final int sessionNumber;
  final String topic;
  final DateTime date;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String location;
  final String? facilitator;
  final String status;

  const ClassSession({
    required this.id,
    required this.classId,
    required this.sessionNumber,
    required this.topic,
    required this.date,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.location,
    this.facilitator,
    required this.status,
  });

  String get startTimeDisplay =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  String get endTimeDisplay =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────
// CLASS BUDGET MODEL
// ─────────────────────────────────────────────
class ClassBudget {
  final String id;
  final String classId;
  final double totalAmount;
  final FundingSource fundingSource;
  final String? fundingSourceName;
  final Map<String, double> categoryAllocations;
  final bool memberLunchAllowed;
  final bool memberTravelAllowed;
  final String approvalStatus;
  final List<ClassExpense> expenses;

  const ClassBudget({
    required this.id,
    required this.classId,
    required this.totalAmount,
    required this.fundingSource,
    this.fundingSourceName,
    required this.categoryAllocations,
    required this.memberLunchAllowed,
    required this.memberTravelAllowed,
    required this.approvalStatus,
    required this.expenses,
  });

  double get totalSpent => expenses
      .where((e) => e.status == ExpenseStatus.approved)
      .fold(0, (s, e) => s + e.amount);
  double get remaining => totalAmount - totalSpent;
}

// ─────────────────────────────────────────────
// CLASS EXPENSE MODEL
// ─────────────────────────────────────────────
class ClassExpense {
  final String id;
  final String classId;
  final String category;
  final double amount;
  final DateTime date;
  final String paidTo;
  final String description;
  final String? proofUrl;
  final String loggedById;
  final ExpenseStatus status;
  final PaymentStatus paymentStatus;
  final ReimbursementStatus? reimbursementStatus;
  final String? reimbursementMemberId;

  const ClassExpense({
    required this.id,
    required this.classId,
    required this.category,
    required this.amount,
    required this.date,
    required this.paidTo,
    required this.description,
    this.proofUrl,
    required this.loggedById,
    required this.status,
    required this.paymentStatus,
    this.reimbursementStatus,
    this.reimbursementMemberId,
  });
}

// ─────────────────────────────────────────────
// BLOOD DONOR MODEL
// ─────────────────────────────────────────────
class BloodDonor {
  final String id;
  final String nameEn;
  final String? nameMm;
  final DonorType type;
  final String? memberId;
  final BloodType bloodType;
  final DateTime? lastDonationDate;
  final int totalDonations;
  final String phone;
  final bool isActive;

  const BloodDonor({
    required this.id,
    required this.nameEn,
    this.nameMm,
    required this.type,
    this.memberId,
    required this.bloodType,
    this.lastDonationDate,
    required this.totalDonations,
    required this.phone,
    required this.isActive,
  });

  DateTime? get nextEligibleDate {
    if (lastDonationDate == null) return null;
    return lastDonationDate!.add(const Duration(days: 120));
  }

  bool get isEligible {
    if (lastDonationDate == null) return true;
    return DateTime.now().isAfter(nextEligibleDate!);
  }

  String get bloodTypeDisplay {
    switch (bloodType) {
      case BloodType.OP: return 'O+';
      case BloodType.OM: return 'O-';
      case BloodType.AP: return 'A+';
      case BloodType.AM: return 'A-';
      case BloodType.BP: return 'B+';
      case BloodType.BM: return 'B-';
      case BloodType.ABP: return 'AB+';
      case BloodType.ABM: return 'AB-';
    }
  }
}

// ─────────────────────────────────────────────
// DONATION RECORD MODEL
// ─────────────────────────────────────────────
class DonationRecord {
  final String id;
  final String donorId;
  final DonationSource source;
  final DateTime donationDate;
  final String location;
  final String? proofUrl;
  final String loggedById;
  final bool isApproved;
  final String? approvedById;

  const DonationRecord({
    required this.id,
    required this.donorId,
    required this.source,
    required this.donationDate,
    required this.location,
    this.proofUrl,
    required this.loggedById,
    required this.isApproved,
    this.approvedById,
  });
}

// ─────────────────────────────────────────────
// TRANSFER HISTORY MODEL
// ─────────────────────────────────────────────
class TransferHistory {
  final String id;
  final String memberId;
  final TransferType type;
  final String fromRankOrUnit;
  final String toRankOrUnit;
  final DateTime date;
  final String authorizedById;
  final String? reason;
  final String? punishmentId;

  const TransferHistory({
    required this.id,
    required this.memberId,
    required this.type,
    required this.fromRankOrUnit,
    required this.toRankOrUnit,
    required this.date,
    required this.authorizedById,
    this.reason,
    this.punishmentId,
  });

  String get typeDisplay {
    switch (type) {
      case TransferType.promotion: return 'Promotion';
      case TransferType.demotion: return 'Demotion';
      case TransferType.transfer: return 'Transfer';
      case TransferType.reinstatement: return 'Reinstatement';
    }
  }
}

// ─────────────────────────────────────────────
// CERTIFICATE MODEL
// ─────────────────────────────────────────────
class Certificate {
  final String id;
  final String memberId;
  final String title;
  final String titleMm;
  final String certType;
  final DateTime issuedDate;
  final DateTime? expiryDate;
  final String issuedById;
  final String referenceNo;
  final String? classId;
  final String? fileUrl;

  const Certificate({
    required this.id,
    required this.memberId,
    required this.title,
    required this.titleMm,
    required this.certType,
    required this.issuedDate,
    this.expiryDate,
    required this.issuedById,
    required this.referenceNo,
    this.classId,
    this.fileUrl,
  });
}

// ─────────────────────────────────────────────
// NOTIFICATION MODEL
// ─────────────────────────────────────────────
class AppNotification {
  final String id;
  final String recipientId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime createdAt;
  final String? routeTo;
  final Map<String, String>? metadata;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.isRead,
    required this.createdAt,
    this.routeTo,
    this.metadata,
  });
}

// ─────────────────────────────────────────────
// EQUIPMENT MODEL
// ─────────────────────────────────────────────
class Equipment {
  final String id;
  final String name;
  final String nameMm;
  final String category;
  final int totalQuantity;
  final int availableQuantity;
  final String condition;
  final String storageLocation;

  const Equipment({
    required this.id,
    required this.name,
    required this.nameMm,
    required this.category,
    required this.totalQuantity,
    required this.availableQuantity,
    required this.condition,
    required this.storageLocation,
  });
}

// ─────────────────────────────────────────────
// FUND ENTRY MODEL
// ─────────────────────────────────────────────
class FundEntry {
  final String id;
  final String type;
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final String recordedById;
  final String? approvedById;
  final bool needsApproval;
  final String? classId;
  final String? referenceNo;

  const FundEntry({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.recordedById,
    this.approvedById,
    required this.needsApproval,
    this.classId,
    this.referenceNo,
  });
}

// ─────────────────────────────────────────────
// LIBRARY DOCUMENT MODEL
// ─────────────────────────────────────────────
class LibraryDocument {
  final String id;
  final String title;
  final String titleMm;
  final String category;
  final String fileUrl;
  final String fileType;
  final DateTime uploadedDate;
  final String uploadedById;
  final String? classId;
  final bool isPublic;

  const LibraryDocument({
    required this.id,
    required this.title,
    required this.titleMm,
    required this.category,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedDate,
    required this.uploadedById,
    this.classId,
    required this.isPublic,
  });
}

// ─────────────────────────────────────────────
// DISPATCH RECORD MODEL
// ─────────────────────────────────────────────
class DispatchRecord {
  final String id;
  final String externalClassName;
  final String organizedBy;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> dispatchedMemberIds;
  final DispatchStatus status;
  final int? quota;

  const DispatchRecord({
    required this.id,
    required this.externalClassName,
    required this.organizedBy,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.dispatchedMemberIds,
    required this.status,
    this.quota,
  });
}