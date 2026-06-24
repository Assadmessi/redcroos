import 'package:flutter/material.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/permission_service.dart';

// ─────────────────────────────────────────────
// MOCK CREDENTIALS
// memberNo → password, memberId
// ─────────────────────────────────────────────
const _mockCredentials = {
  // Brigade Office
  'RC-001': {'password': '1234', 'memberId': 'm1'}, // Brigade Commander
  'RC-002': {'password': '1234', 'memberId': 'm2'}, // Deputy Brigade Commander
  'RC-003': {'password': '1234', 'memberId': 'm3'}, // Brigade Office Chief (Company Commander)
  'RC-006': {'password': '1234', 'memberId': 'm6'}, // Warrant Officer (Brigade Office)
  'RC-007': {'password': '1234', 'memberId': 'm7'}, // Sergeant Clerk (Brigade Office)

  // Company 1
  'RC-101': {'password': '1234', 'memberId': 'm101'}, // Company Commander C1
  'RC-102': {'password': '1234', 'memberId': 'm102'}, // Deputy Company Commander C1
  'RC-103': {'password': '1234', 'memberId': 'm103'}, // Platoon Leader C1/P1
  'RC-104': {'password': '1234', 'memberId': 'm104'}, // Section Leader C1/P1/S1
  'RC-105': {'password': '1234', 'memberId': 'm105'}, // Private C1/P1/S1
  'RC-106': {'password': '1234', 'memberId': 'm106'}, // Company Sergeant Major C1
  'RC-107': {'password': '1234', 'memberId': 'm107'}, // Platoon Sergeant C1/P1

  // Quick logins for testing
  'admin':   {'password': 'admin123', 'memberId': 'm1'},
  'chief':   {'password': 'chief123', 'memberId': 'm3'},
  'company': {'password': '1234', 'memberId': 'm101'},
  'sgtmajor': {'password': '1234', 'memberId': 'm106'},
  'platoonsgt': {'password': '1234', 'memberId': 'm107'},
  'private': {'password': '1234', 'memberId': 'm105'},
};

class AuthProvider extends ChangeNotifier {
  Member? _currentMember;
  bool _isLoading = false;
  String? _error;
  AppLanguage _language = AppLanguage.english;

  Member? get currentMember => _currentMember;
  bool get isLoggedIn => _currentMember != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AppLanguage get language => _language;
  bool get isEnglish => _language == AppLanguage.english;

  // ─── PERMISSION SHORTCUTS ────────────────

  bool get hasMasterAccess =>
      _currentMember != null &&
      PermissionService.hasMasterAccess(_currentMember!);

  UnitScope get unitScope =>
      _currentMember != null
          ? PermissionService.getUnitScope(_currentMember!)
          : UnitScope.ownOnly;

  bool get isBrigadeWide => unitScope == UnitScope.brigadWide;

  bool get canGenerateReports =>
      _currentMember != null &&
      PermissionService.canGenerateReports(_currentMember!);

  bool get canViewFund =>
      _currentMember != null &&
      PermissionService.canViewFund(_currentMember!);

  bool get canEditFund =>
      _currentMember != null &&
      PermissionService.canEditFundDirectly(_currentMember!);

  bool get canSubmitFundForApproval =>
      _currentMember != null &&
      PermissionService.canSubmitFundForApproval(_currentMember!);

  bool get canViewSettings =>
      _currentMember != null &&
      PermissionService.canViewSettings(_currentMember!);

  bool get canAssignDuty =>
      _currentMember != null &&
      PermissionService.canAssignDuty(_currentMember!);

  // ── Module 6 additions: Duties ──
  bool get canCreateDuty =>
      _currentMember != null &&
      PermissionService.canCreateDuty(_currentMember!);

  bool canRespondToDutyAssignment(Duty duty) =>
      _currentMember != null &&
      PermissionService.canRespondToDutyAssignment(_currentMember!, duty);

  bool canMarkDutyComplete(Duty duty) =>
      _currentMember != null &&
      PermissionService.canMarkDutyComplete(_currentMember!, duty);

  bool canCancelDuty(Duty duty) =>
      _currentMember != null &&
      PermissionService.canCancelDuty(_currentMember!, duty);

  bool canDeleteDuty(Duty duty) =>
      _currentMember != null &&
      PermissionService.canDeleteDuty(_currentMember!, duty);

  // ── Module 7 additions: Events & Positional Duty ──
  bool get canManageEvent =>
      _currentMember != null &&
      PermissionService.canManageEvent(_currentMember!);

  bool canAssignToPosition(Duty hostDuty) =>
      _currentMember != null &&
      PermissionService.canAssignToPosition(_currentMember!, hostDuty);

  // ── Module 8 additions: Meetings ──
  bool get canCreateMeeting =>
      _currentMember != null &&
      PermissionService.canCreateMeeting(_currentMember!);

  bool canCreateMeetingForUnit(int? targetCompanyNo) =>
      _currentMember != null &&
      PermissionService.canCreateMeetingForUnit(_currentMember!, targetCompanyNo);

  bool canManageMeeting(Meeting meeting, int? meetingCompanyNo) =>
      _currentMember != null &&
      PermissionService.canManageMeeting(_currentMember!, meeting, meetingCompanyNo);

  bool canMarkAttendance(Meeting meeting) =>
      _currentMember != null &&
      PermissionService.canMarkAttendance(_currentMember!, meeting);

  bool canRecordDiscussion(Meeting meeting) =>
      _currentMember != null &&
      PermissionService.canRecordDiscussion(_currentMember!, meeting);

  bool get canApproveMinutes =>
      _currentMember != null &&
      PermissionService.canApproveMinutes(_currentMember!);

  // ── Access Grant System ──
  bool canRequestAccessGrant(Member target) =>
      _currentMember != null &&
      PermissionService.canRequestAccessGrant(_currentMember!, target);

  bool canApproveAccessGrant(Member target) =>
      _currentMember != null &&
      PermissionService.canApproveAccessGrant(_currentMember!, target);

  // ── Generic Feature Access Request System ──
  bool get canRequestFeatureAccess =>
      _currentMember != null &&
      PermissionService.canRequestFeatureAccess(_currentMember!);

  bool get canApproveFeatureAccess =>
      _currentMember != null &&
      PermissionService.canApproveFeatureAccess(_currentMember!);

  bool canEditDuty(Duty duty) =>
      _currentMember != null &&
      PermissionService.canEditDuty(_currentMember!, duty);

  bool get canCreateDispatch =>
      _currentMember != null &&
      PermissionService.canCreateDispatch(_currentMember!);

  bool get canConfirmDispatch =>
      _currentMember != null &&
      PermissionService.canConfirmDispatch(_currentMember!);

  bool get canTriggerEmergencySearch =>
      _currentMember != null &&
      PermissionService.canTriggerEmergencySearch(_currentMember!);

  bool get canApproveYouthReport =>
      _currentMember != null &&
      PermissionService.canApproveYouthReport(_currentMember!);

  bool get isOfficer =>
      _currentMember != null &&
      RankHelper.isOfficerRank(_currentMember!.rank);

  bool get canViewArchive =>
      _currentMember != null &&
      PermissionService.canViewArchive(_currentMember!);

  // ── Module 4 additions: Add Member permissions ──
  bool get canAddMemberDirectly =>
      _currentMember != null &&
      PermissionService.canAddMemberDirectly(_currentMember!);

  bool get canProposeNewMember =>
      _currentMember != null &&
      PermissionService.canProposeNewMember(_currentMember!);

  bool get canAddOrProposeMember =>
      _currentMember != null &&
      PermissionService.canAddOrProposeMember(_currentMember!);

  bool canApproveNewMemberProposal(Member proposer) =>
      _currentMember != null &&
      PermissionService.canApproveNewMemberProposal(_currentMember!, proposer);

  // ── Module 4 additions: Available/Not Available toggle ──
  // NOTE: previously the availability toggle UI checked hasMasterAccess
  // directly, which does NOT account for Admin role — these proper
  // shortcuts fix that gap.
  bool canToggleAvailabilityDirectly(Member target) =>
      _currentMember != null &&
      PermissionService.canToggleAvailabilityDirectly(_currentMember!, target);

  // ── Module 4 additions: Active/Inactive (long leave/overseas) ──
  // Same request/approval pattern as availability above, but for the
  // long-term Active ↔ Inactive status (going overseas, extended
  // leave) — distinct from the disciplinary suspension/dismissal path.
  bool canSetInactiveLeaveDirectly(Member target) =>
      _currentMember != null &&
      PermissionService.hasAdminOrMasterAccess(_currentMember!);

  bool canRequestInactiveLeaveToggle(Member target) =>
      _currentMember != null &&
      PermissionService.canRequestInactiveLeaveToggle(_currentMember!, target);

  // ── Module 4 additions: detail/fullscreen restriction ──
  // canViewFullDetail gates Info tab, Analytics tab, AND ID Card tab
  // visibility all from one rule — see PermissionService.canViewFullDetail.
  bool canViewFullDetail(Member target) =>
      _currentMember != null &&
      PermissionService.canViewFullDetail(_currentMember!, target);

  bool canViewIdCardFullscreen(Member target) =>
      _currentMember != null &&
      PermissionService.canViewIdCardFullscreen(_currentMember!, target);

  bool canSeeInMemberList(Member target) =>
      _currentMember != null &&
      PermissionService.canSeeInMemberList(_currentMember!, target);

  // Member-specific checks
  bool canViewMember(Member target) =>
      _currentMember != null &&
      PermissionService.canViewMember(_currentMember!, target);

  bool canManageMember(Member target) =>
      _currentMember != null &&
      PermissionService.canManageMember(_currentMember!, target);

  bool canViewInvestigation(Investigation investigation) =>
      _currentMember != null &&
      PermissionService.canViewInvestigation(_currentMember!, investigation);

  bool canManageInvestigation(Investigation investigation) =>
      _currentMember != null &&
      PermissionService.canManageInvestigation(_currentMember!, investigation);

  bool canViewSealedAttachment(Investigation investigation) =>
      _currentMember != null &&
      PermissionService.canViewSealedAttachment(_currentMember!, investigation);

  bool canViewPunishment(
    Punishment punishment,
    Member punishedMember,
    Investigation? relatedInvestigation,
  ) =>
      _currentMember != null &&
      PermissionService.canViewPunishmentWithTarget(
        _currentMember!,
        punishment,
        punishedMember,
        relatedInvestigation,
      );

  bool canViewCertificate(Member owner) =>
      _currentMember != null &&
      PermissionService.canViewCertificate(_currentMember!, owner);

  bool canViewBloodDonors() =>
      _currentMember != null &&
      PermissionService.canViewBloodDonors(_currentMember!);

  bool canEditBloodDonors() =>
      _currentMember != null &&
      PermissionService.canEditBloodDonors(_currentMember!);

  // ─── LANGUAGE ────────────────────────────
  void toggleLanguage() {
    _language = _language == AppLanguage.english
        ? AppLanguage.burmese
        : AppLanguage.english;
    notifyListeners();
  }

  String tr(String en, String mm) =>
      _language == AppLanguage.english ? en : mm;

  // ─── LOGIN ───────────────────────────────
  Future<bool> login(String memberNo, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final key = memberNo.trim().toUpperCase();
    final credentials = _mockCredentials[key] ?? _mockCredentials[memberNo.trim()];

    if (credentials == null) {
      _error = 'Member ID not found';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (credentials['password'] != password) {
      _error = 'Incorrect password';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final memberId = credentials['memberId']!;
    _currentMember = MockMembers.findById(memberId);

    if (_currentMember == null) {
      _error = 'Member record not found';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentMember = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}