import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';

/// Shows the 6-section Class Closure Report, auto-compiled from the
/// class's own data (attendance, budget, outcomes) wherever possible,
/// with two free-text sections (Issues, Recommendations) for the
/// preparer to fill in. Once saved, offers a button to additionally
/// prepare the 9-section Post-Training Report for HQ, which wraps
/// this same report and appends 3 more sections.
class ClassClosureReportScreen extends StatefulWidget {
  final String classId;
  const ClassClosureReportScreen({super.key, required this.classId});

  @override
  State<ClassClosureReportScreen> createState() => _ClassClosureReportScreenState();
}

class _ClassClosureReportScreenState extends State<ClassClosureReportScreen> {
  late TrainingClass _trainingClass;
  late final _issuesCtrl = TextEditingController();
  late final _recommendationsCtrl = TextEditingController();
  ClassClosureReport? _existingReport;
  DateTime? _submissionDeadline;

  @override
  void initState() {
    super.initState();
    _trainingClass = MockClasses.findById(widget.classId)!;
    _existingReport = MockClosureReports.forClass(_trainingClass.id);
    if (_existingReport != null) {
      _issuesCtrl.text = _existingReport!.issuesEncountered ?? '';
      _recommendationsCtrl.text = _existingReport!.recommendations ?? '';
      _submissionDeadline = _existingReport!.submissionDeadline;
    }
  }

  @override
  void dispose() {
    _issuesCtrl.dispose();
    _recommendationsCtrl.dispose();
    super.dispose();
  }

  /// Currently-granted sections from any approved post-deadline edit
  /// requests for this class's report.
  List<ClosureReportSection> get _grantedSections =>
      MockClosureReportEditRequests.grantedSectionsForClass(_trainingClass.id);

  bool get _isLocked {
    if (_submissionDeadline == null) return false;
    return DateTime.now().isAfter(_submissionDeadline!);
  }

  bool _canEditSection(AuthProvider auth, ClosureReportSection section) {
    return auth.canEditClosureReportSection(
      _trainingClass,
      section,
      reportIsLocked: _isLocked,
      grantedSections: _grantedSections,
    );
  }

  /// Auto-compiles whatever can be derived from the class's own data
  /// — attendance counts, budget figures, outcomes — leaving only
  /// the free-text Issues/Recommendations sections for manual input.
  ClassClosureReport _buildReport(AuthProvider auth) {
    final sessionIds = _trainingClass.timetable.map((s) => s.id).toList();

    // Real per-session counts, computed from actual check-in records
    // rather than approximated from total enrollment.
    final sessionAttendance = <String, int>{
      for (final s in _trainingClass.timetable)
        s.id: MockSessionAttendance.forSession(s.id).where((a) => a.present).length,
    };

    // Real per-member attendance rates across all of the class's
    // sessions — this is what actually answers "who attended, and
    // at what rate."
    final memberRates = <String, double>{
      for (final memberId in _trainingClass.enrolledMemberIds)
        memberId: MockSessionAttendance.attendanceRateFor(memberId, sessionIds),
    };

    // "Completed" now means the member attended at least one session
    // — a simple, real threshold instead of assuming everyone
    // enrolled completed the class.
    final totalCompleted = memberRates.values.where((rate) => rate > 0).length;

    return ClassClosureReport(
      id: _existingReport?.id ?? 'closure_${DateTime.now().microsecondsSinceEpoch}',
      classId: _trainingClass.id,
      preparedByMemberId: auth.currentMember!.id,
      preparedAt: DateTime.now(),
      submissionDeadline: _submissionDeadline,
      totalEnrolled: _trainingClass.enrolledCount,
      totalCompleted: totalCompleted,
      sessionAttendanceCounts: sessionAttendance,
      memberAttendanceRates: memberRates,
      totalAllocated: _trainingClass.budget?.totalAmount ?? 0,
      totalSpent: _trainingClass.budget?.totalSpent ?? 0,
      skillsAwardedSummary: _trainingClass.awardedSkillIds
          .map((id) => MockSkills.findById(id)?.nameEn ?? id)
          .toList(),
      certificatesIssuedCount: _trainingClass.issuesCertificate ? _trainingClass.enrolledCount : 0,
      issuesEncountered: _issuesCtrl.text.trim().isEmpty ? null : _issuesCtrl.text.trim(),
      recommendations: _recommendationsCtrl.text.trim().isEmpty ? null : _recommendationsCtrl.text.trim(),
    );
  }

  Future<void> _pickDeadline(AuthProvider auth) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _submissionDeadline ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Submission deadline',
    );
    if (picked == null) return;
    setState(() => _submissionDeadline = picked);
    // Persist immediately so the deadline takes effect even if the
    // preparer hasn't otherwise touched the report yet.
    if (_existingReport != null) {
      _saveReport(auth, showSnackbar: false);
    }
  }

  Future<void> _requestEditAccess(AuthProvider auth) async {
    final selectedSections = <ClosureReportSection>{};
    final reasonCtrl = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request Edit Access', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 4),
                  Text(
                    'This report is locked — the submission deadline has passed. '
                    'Select which section(s) you need to fix and explain why. '
                    'Master Access will review this request.',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 12),
                  ...ClosureReportSection.values.map((section) {
                    final isSelected = selectedSections.contains(section);
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: isSelected,
                      onChanged: (v) => setSheetState(() {
                        if (v == true) {
                          selectedSections.add(section);
                        } else {
                          selectedSections.remove(section);
                        }
                      }),
                      title: Text(section.label, style: AppTextStyles.bodyMedium),
                    );
                  }),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedSections.isEmpty
                        ? null
                        : () => Navigator.pop(sheetContext, true),
                    child: const Text('Submit Request'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result == true) {
      if (reasonCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide a reason')),
        );
        return;
      }
      MockClosureReportEditRequests.add(ClosureReportEditRequest(
        id: 'edit_req_${DateTime.now().microsecondsSinceEpoch}',
        classId: _trainingClass.id,
        closureReportId: _existingReport!.id,
        requesterId: auth.currentMember!.id,
        sectionsRequested: selectedSections.toList(),
        reason: reasonCtrl.text.trim(),
        status: ClosureReportEditRequestStatus.pending,
        requestedAt: DateTime.now(),
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edit request sent to Master Access')),
      );
      setState(() {});
    }
  }

  void _saveReport(AuthProvider auth, {bool showSnackbar = true}) {
    final report = _buildReport(auth);
    MockClosureReports.save(report);
    setState(() => _existingReport = report);
    if (showSnackbar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Closure report saved')),
      );
    }
  }

  void _openPostTrainingReport(AuthProvider auth) {
    if (_existingReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the closure report first')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostTrainingReportScreen(classId: _trainingClass.id, closureReportId: _existingReport!.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final report = _existingReport ?? _buildReport(auth);
    final instructor = MockMembers.findById(_trainingClass.instructorId);
    final canSetDeadline = auth.canSetClosureReportDeadline;
    final canIssues = _canEditSection(auth, ClosureReportSection.issuesEncountered);
    final canRecommendations = _canEditSection(auth, ClosureReportSection.recommendations);
    final canRequestEdit = auth.canRequestClosureReportEdit(_trainingClass);

    return Scaffold(
      appBar: AppBar(title: const Text('Class Closure Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDeadlineCard(canSetDeadline),
          const SizedBox(height: 16),

          _sectionHeading('1. Class Overview'),
          _kv('Title', _trainingClass.title),
          _kv('Type', _trainingClass.type.name),
          _kv('Dates', '${AppFormatters.date(_trainingClass.startDate)} – ${AppFormatters.date(_trainingClass.endDate)}'),
          _kv('Instructor', instructor?.nameEn ?? _trainingClass.instructorName),
          _kv('Location', _trainingClass.location),
          const SizedBox(height: 16),

          _sectionHeading('2. Attendance Summary'),
          _kv('Enrolled', '${report.totalEnrolled}'),
          _kv('Completed', '${report.totalCompleted}'),
          _kv('Completion Rate', '${report.completionRatePercent.toStringAsFixed(0)}%'),
          const SizedBox(height: 8),
          ..._trainingClass.enrolledMemberIds.map((memberId) => _attendanceRow(memberId, report)),
          const SizedBox(height: 16),

          _sectionHeading('3. Budget Summary'),
          _kv('Allocated', 'BHD ${report.totalAllocated.toStringAsFixed(0)}'),
          _kv('Spent', 'BHD ${report.totalSpent.toStringAsFixed(0)}'),
          _kv('Utilization', '${report.budgetUtilizationPercent.toStringAsFixed(0)}%'),
          const SizedBox(height: 16),

          _sectionHeading('4. Outcomes'),
          _kv('Skills Awarded', report.skillsAwardedSummary.isEmpty ? 'None' : report.skillsAwardedSummary.join(', ')),
          _kv('Certificates Issued', '${report.certificatesIssuedCount}'),
          const SizedBox(height: 16),

          _sectionHeading('5. Issues / Challenges'),
          if (canIssues)
            TextField(
              controller: _issuesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe any issues encountered during this class...',
                border: OutlineInputBorder(),
              ),
            )
          else
            _lockedSectionText(_issuesCtrl.text),
          const SizedBox(height: 16),

          _sectionHeading('6. Recommendations'),
          if (canRecommendations)
            TextField(
              controller: _recommendationsCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Recommendations for future classes...',
                border: OutlineInputBorder(),
              ),
            )
          else
            _lockedSectionText(_recommendationsCtrl.text),
          const SizedBox(height: 24),

          if (canIssues || canRecommendations)
            ElevatedButton(
              onPressed: () => _saveReport(auth),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(_existingReport == null ? 'Save Closure Report' : 'Update Closure Report'),
            ),
          if (_isLocked && !canIssues && !canRecommendations && canRequestEdit) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _requestEditAccess(auth),
              icon: const Icon(Icons.lock_open_outlined, size: 18),
              label: const Text('Request Edit Access'),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _openPostTrainingReport(auth),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Prepare Post-Training Report (for HQ)'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineCard(bool canSetDeadline) {
    return Card(
      color: _isLocked ? Colors.red.withValues(alpha: 0.06) : AppColors.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isLocked ? Icons.lock_outline : Icons.edit_calendar_outlined,
              color: _isLocked ? Colors.red : AppColors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _submissionDeadline == null
                        ? 'No submission deadline set'
                        : 'Submission deadline: ${AppFormatters.date(_submissionDeadline!)}',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _isLocked
                        ? 'Locked — deadline has passed. Editing requires Master Access approval.'
                        : 'Editable until the deadline.',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  ),
                ],
              ),
            ),
            if (canSetDeadline)
              TextButton(
                onPressed: () => _pickDeadline(context.read<AuthProvider>()),
                child: const Text('Set'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _lockedSectionText(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grey50.withValues(alpha: 0.3)),
      ),
      child: Text(
        value.isEmpty ? '—' : value,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700),
      ),
    );
  }

  Widget _attendanceRow(String memberId, ClassClosureReport report) {
    final m = MockMembers.findById(memberId);
    final rate = report.memberAttendanceRates[memberId] ?? 0;
    final ratePercent = (rate * 100).toStringAsFixed(0);
    final color = rate >= 0.75 ? Colors.green : (rate >= 0.5 ? Colors.orange : Colors.red);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: m != null ? AvatarColorGen.fromString(m.id) : AppColors.grey500,
            child: Text(m?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(m?.nameEn ?? memberId, style: AppTextStyles.bodySmall),
          ),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: rate,
                minHeight: 6,
                backgroundColor: AppColors.grey50.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '$ratePercent%',
              style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: AppTextStyles.headingSmall),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500))),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

/// The 9-section Post-Training Report for HQ — wraps the 6-section
/// Closure Report (shown read-only at the top) and appends the 3
/// HQ-specific sections (Impact Assessment, Skill Verification,
/// Future Planning), then routes for approval.
class PostTrainingReportScreen extends StatefulWidget {
  final String classId;
  final String closureReportId;
  const PostTrainingReportScreen({super.key, required this.classId, required this.closureReportId});

  @override
  State<PostTrainingReportScreen> createState() => _PostTrainingReportScreenState();
}

class _PostTrainingReportScreenState extends State<PostTrainingReportScreen> {
  late TrainingClass _trainingClass;
  late ClassClosureReport _closureReport;
  late final _impactCtrl = TextEditingController();
  late final _futurePlanningCtrl = TextEditingController();
  final Map<String, bool> _skillVerification = {};
  PostTrainingReport? _existingReport;

  @override
  void initState() {
    super.initState();
    _trainingClass = MockClasses.findById(widget.classId)!;
    _closureReport = MockClosureReports.forClass(widget.classId)!;
    _existingReport = MockPostTrainingReports.forClass(widget.classId);
    if (_existingReport != null) {
      _impactCtrl.text = _existingReport!.impactAssessment ?? '';
      _futurePlanningCtrl.text = _existingReport!.futurePlanning ?? '';
      _skillVerification.addAll(_existingReport!.skillVerificationByMemberId);
    } else {
      for (final id in _trainingClass.enrolledMemberIds) {
        _skillVerification[id] = false;
      }
    }
  }

  @override
  void dispose() {
    _impactCtrl.dispose();
    _futurePlanningCtrl.dispose();
    super.dispose();
  }

  void _save(AuthProvider auth) {
    final report = PostTrainingReport(
      id: _existingReport?.id ?? 'pt_${DateTime.now().microsecondsSinceEpoch}',
      classId: _trainingClass.id,
      closureReportId: widget.closureReportId,
      preparedByMemberId: auth.currentMember!.id,
      preparedAt: DateTime.now(),
      approvedByMemberId: _existingReport?.approvedByMemberId,
      impactAssessment: _impactCtrl.text.trim().isEmpty ? null : _impactCtrl.text.trim(),
      skillVerificationByMemberId: _skillVerification,
      futurePlanning: _futurePlanningCtrl.text.trim().isEmpty ? null : _futurePlanningCtrl.text.trim(),
    );
    MockPostTrainingReports.save(report);
    setState(() => _existingReport = report);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post-Training Report saved')),
    );
  }

  void _approve(AuthProvider auth) {
    if (_existingReport == null) return;
    final approved = PostTrainingReport(
      id: _existingReport!.id, classId: _existingReport!.classId,
      closureReportId: _existingReport!.closureReportId,
      preparedByMemberId: _existingReport!.preparedByMemberId,
      preparedAt: _existingReport!.preparedAt,
      approvedByMemberId: auth.currentMember!.id,
      impactAssessment: _existingReport!.impactAssessment,
      skillVerificationByMemberId: _existingReport!.skillVerificationByMemberId,
      futurePlanning: _existingReport!.futurePlanning,
    );
    MockPostTrainingReports.save(approved);
    setState(() => _existingReport = approved);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post-Training Report approved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canApprove = auth.canApprovePostTrainingReport;

    return Scaffold(
      appBar: AppBar(title: const Text('Post-Training Report (HQ)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Sections 1–6 below are carried forward from the Class Closure Report. '
              'Sections 7–9 are specific to this HQ report.',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),

          _sectionHeading('1–6. Closure Report Summary'),
          _kv('Class', _trainingClass.title),
          _kv('Enrolled / Completed', '${_closureReport.totalEnrolled} / ${_closureReport.totalCompleted}'),
          _kv('Budget Utilization', '${_closureReport.budgetUtilizationPercent.toStringAsFixed(0)}%'),
          _kv('Skills Awarded', _closureReport.skillsAwardedSummary.isEmpty ? 'None' : _closureReport.skillsAwardedSummary.join(', ')),
          const SizedBox(height: 16),

          _sectionHeading('7. Impact Assessment'),
          TextField(
            controller: _impactCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'How does this training benefit brigade readiness?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          _sectionHeading('8. Skill Verification'),
          ..._trainingClass.enrolledMemberIds.map((id) {
            final m = MockMembers.findById(id);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _skillVerification[id] ?? false,
              onChanged: (v) => setState(() => _skillVerification[id] = v ?? false),
              title: Text(m?.nameEn ?? id, style: AppTextStyles.bodySmall),
              subtitle: const Text('Competency verified'),
            );
          }),
          const SizedBox(height: 16),

          _sectionHeading('9. Future Planning'),
          TextField(
            controller: _futurePlanningCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Follow-up training needs, next steps...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => _save(auth),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text(_existingReport == null ? 'Save Report' : 'Update Report'),
          ),
          if (_existingReport != null && !_existingReport!.isApproved && canApprove) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _approve(auth),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: Colors.green),
              child: const Text('Approve Report'),
            ),
          ],
          if (_existingReport?.isApproved ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  'Approved by ${MockMembers.findById(_existingReport!.approvedByMemberId!)?.nameEn ?? _existingReport!.approvedByMemberId}',
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: AppTextStyles.headingSmall),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500))),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}