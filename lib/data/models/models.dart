import '../../core/constants/app_constants.dart';

// ─────────────────────────────────────────────
// SHARED HELPER — blood type string
// ─────────────────────────────────────────────
String _bloodTypeString(BloodType bloodType) {
  switch (bloodType) {
    case BloodType.OP:
      return 'O+';
    case BloodType.OM:
      return 'O-';
    case BloodType.AP:
      return 'A+';
    case BloodType.AM:
      return 'A-';
    case BloodType.BP:
      return 'B+';
    case BloodType.BM:
      return 'B-';
    case BloodType.ABP:
      return 'AB+';
    case BloodType.ABM:
      return 'AB-';
  }
}

// ─────────────────────────────────────────────
// MEMBER MODEL
// ─────────────────────────────────────────────
class Member {
  final String id;
  final String memberNo;
  final String nameEn;
  final String nameMm;
  final String rankId;
  final String rankNameEn;
  final String rankNameMm;
  final String unit;
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
  final String? youthGroupId;
  final UserRole role;

  const Member({
    required this.id,
    required this.memberNo,
    required this.nameEn,
    required this.nameMm,
    required this.rankId,
    required this.rankNameEn,
    required this.rankNameMm,
    required this.unit,
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
    this.youthGroupId,
    required this.role,
  });

  String get initials {
    final parts = nameEn.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    if (nameEn.length >= 2) return nameEn.substring(0, 2).toUpperCase();
    return nameEn.toUpperCase();
  }

  String get bloodTypeDisplay => _bloodTypeString(bloodType);
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
// MEMBER SKILL MODEL
// ─────────────────────────────────────────────
class MemberSkill {
  final String id;
  final String memberId;
  final String skillId;
  final String skillNameEn;
  final DateTime acquiredDate;
  final DateTime? expiryDate;
  final String acquiredVia;
  final bool isActive;

  const MemberSkill({
    required this.id,
    required this.memberId,
    required this.skillId,
    required this.skillNameEn,
    required this.acquiredDate,
    this.expiryDate,
    required this.acquiredVia,
    required this.isActive,
  });
}

// ─────────────────────────────────────────────
// DUTY MODEL
// TimeOfDay removed — stored as int hours/minutes
// to avoid Flutter dependency in pure data layer
// ─────────────────────────────────────────────
class Duty {
  final String id;
  final String title;
  final String titleMm;
  final DutyType type;
  final DateTime date;
  final int startHour;
  final int startMinute;
  final int? endHour;
  final int? endMinute;
  final String location;
  final String officerInChargeId;
  final List<String> assignedMemberIds;
  final DutyStatus status;
  final String? description;
  final bool isEvent;
  final String? eventId;

  const Duty({
    required this.id,
    required this.title,
    required this.titleMm,
    required this.type,
    required this.date,
    required this.startHour,
    required this.startMinute,
    this.endHour,
    this.endMinute,
    required this.location,
    required this.officerInChargeId,
    required this.assignedMemberIds,
    required this.status,
    this.description,
    this.isEvent = false,
    this.eventId,
  });

  String get startTimeDisplay =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get endTimeDisplay => (endHour != null && endMinute != null)
      ? '${endHour!.toString().padLeft(2, '0')}:${endMinute!.toString().padLeft(2, '0')}'
      : '';

  String get typeDisplay {
    switch (type) {
      case DutyType.firstAid:
        return 'First Aid';
      case DutyType.bloodDonation:
        return 'Blood Donation';
      case DutyType.training:
        return 'Training';
      case DutyType.patrol:
        return 'Patrol';
      case DutyType.eventMedical:
        return 'Event Medical';
      case DutyType.disaster:
        return 'Disaster Response';
      case DutyType.administrative:
        return 'Administrative';
      case DutyType.other:
        return 'Other';
    }
  }
}

// ─────────────────────────────────────────────
// DUTY ASSIGNMENT MODEL
// ─────────────────────────────────────────────
class DutyAssignment {
  final String id;
  final String dutyId;
  final String memberId;
  final DutyAssignmentStatus status;
  final String? rejectionReason;
  final DateTime assignedAt;
  final DateTime? respondedAt;

  const DutyAssignment({
    required this.id,
    required this.dutyId,
    required this.memberId,
    required this.status,
    this.rejectionReason,
    required this.assignedAt,
    this.respondedAt,
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
// EVENT MODEL (Marathon, etc.)
// ─────────────────────────────────────────────
class MedicalEvent {
  final String id;
  final String title;
  final String titleMm;
  final String eventType;
  final DateTime date;
  final String location;
  final bool hasMapPins;
  final List<EventPosition> positions;
  final DutyStatus status;
  final String createdById;

  const MedicalEvent({
    required this.id,
    required this.title,
    required this.titleMm,
    required this.eventType,
    required this.date,
    required this.location,
    required this.hasMapPins,
    required this.positions,
    required this.status,
    required this.createdById,
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
      case EventPositionType.base:
        return 'Base';
      case EventPositionType.point:
        return 'Point';
      case EventPositionType.patrol:
        return 'Patrol';
      case EventPositionType.standby:
        return 'Standby';
      case EventPositionType.command:
        return 'Command';
      case EventPositionType.liaison:
        return 'Liaison';
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
      case MeetingType.general:
        return 'General';
      case MeetingType.officer:
        return 'Officer';
      case MeetingType.committee:
        return 'Committee';
      case MeetingType.investigation:
        return 'Investigation';
      case MeetingType.youthLeaders:
        return 'Youth Leaders';
      case MeetingType.youthGroup:
        return 'Youth Group';
      case MeetingType.custom:
        return 'Custom';
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
// CLASS MODEL
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

  String get bloodTypeDisplay => _bloodTypeString(bloodType);
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
// INVESTIGATION MODEL
// ─────────────────────────────────────────────
class Investigation {
  final String id;
  final String caseNumber;
  final String title;
  final String description;
  final DateTime openedDate;
  final InvestigationStatus status;
  final List<String> accusedMemberIds;
  final List<String> witnessMemberIds;
  final List<String> committeeMemberIds;
  final List<String> recusedMemberIds;
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
    required this.status,
    required this.accusedMemberIds,
    required this.witnessMemberIds,
    required this.committeeMemberIds,
    required this.recusedMemberIds,
    required this.stageLogs,
    required this.attachments,
    this.outcome,
    required this.isSealed,
  });

  int get currentStageIndex {
    switch (status) {
      case InvestigationStatus.opened:
        return 0;
      case InvestigationStatus.underInvestigation:
        return 1;
      case InvestigationStatus.hearingScheduled:
        return 2;
      case InvestigationStatus.hearingConducted:
        return 3;
      case InvestigationStatus.deliberation:
        return 4;
      case InvestigationStatus.concluded:
        return 5;
      case InvestigationStatus.closed:
        return 6;
      case InvestigationStatus.appealed:
        return 7;
      case InvestigationStatus.appealReview:
        return 8;
      case InvestigationStatus.appealConcluded:
        return 9;
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
      case PunishmentType.verbalWarning:
        return 'Verbal Warning';
      case PunishmentType.writtenWarning:
        return 'Written Warning';
      case PunishmentType.fine:
        return 'Fine';
      case PunishmentType.suspension:
        return 'Suspension';
      case PunishmentType.demotion:
        return 'Demotion';
      case PunishmentType.dismissal:
        return 'Dismissal';
      case PunishmentType.other:
        return 'Other';
    }
  }
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
      case TransferType.promotion:
        return 'Promotion';
      case TransferType.demotion:
        return 'Demotion';
      case TransferType.transfer:
        return 'Transfer';
      case TransferType.reinstatement:
        return 'Reinstatement';
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
  final String type; // income / expenditure
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final String recordedById;
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
  final String status;
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
