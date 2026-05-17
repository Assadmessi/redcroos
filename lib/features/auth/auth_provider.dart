import 'package:flutter/material.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../core/constants/app_constants.dart';

// ─────────────────────────────────────────────
// MOCK CREDENTIALS
// Replace with real Supabase auth later
// ─────────────────────────────────────────────
const _mockCredentials = {
  'RC-001': {'password': '1234', 'memberId': 'm1'}, // Senior Officer
  'RC-002': {'password': '1234', 'memberId': 'm2'}, // Officer
  'RC-003': {'password': '1234', 'memberId': 'm3'}, // Duty Officer
  'RC-004': {'password': '1234', 'memberId': 'm4'}, // Member
  'RC-005': {'password': '1234', 'memberId': 'm5'}, // Member
  'admin':  {'password': 'admin123', 'memberId': 'm1'}, // Quick admin login
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

  // Role permission helpers
  bool get isAdmin => _currentMember?.role == UserRole.admin;
  bool get isTopBrass => _currentMember?.role == UserRole.topBrass;
  bool get isSeniorOfficer => _currentMember?.role == UserRole.seniorOfficer;
  bool get isOfficer => _currentMember?.role == UserRole.officer;
  bool get isDutyOfficer => _currentMember?.role == UserRole.dutyOfficer;
  bool get isMember => _currentMember?.role == UserRole.member;

  bool get canManageMembers =>
      isAdmin || isTopBrass || isSeniorOfficer;

  bool get canAssignDuties =>
      isAdmin || isTopBrass || isSeniorOfficer || isOfficer || isDutyOfficer;

  bool get canApproveReports =>
      isAdmin || isTopBrass || isSeniorOfficer || isOfficer;

  bool get canViewInvestigations =>
      isAdmin || isTopBrass || isSeniorOfficer;

  bool get canViewPunishments =>
      isAdmin || isTopBrass || isSeniorOfficer || isOfficer;

  bool get canManageFund =>
      isAdmin || isTopBrass;

  bool get canIssueInvestigation =>
      isAdmin || isTopBrass || isSeniorOfficer;

  void toggleLanguage() {
    _language = _language == AppLanguage.english
        ? AppLanguage.burmese
        : AppLanguage.english;
    notifyListeners();
  }

  Future<bool> login(String memberNo, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final credentials = _mockCredentials[memberNo.trim().toUpperCase()] ??
        _mockCredentials[memberNo.trim()];

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
