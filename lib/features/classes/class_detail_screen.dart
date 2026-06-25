import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';
import 'class_form_screen.dart';
import 'class_feedback_screen.dart';
import 'class_closure_report_screen.dart';

class ClassDetailScreen extends StatefulWidget {
  final String classId;
  const ClassDetailScreen({super.key, required this.classId});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  late TrainingClass _trainingClass;

  @override
  void initState() {
    super.initState();
    _trainingClass = MockClasses.findById(widget.classId)!;
  }

  void _refresh() {
    setState(() {
      _trainingClass = MockClasses.findById(widget.classId)!;
    });
  }

  void _requestEnrollment(AuthProvider auth) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request to Join'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Reason (optional)', border: OutlineInputBorder()),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              MockEnrollmentRequests.add(EnrollmentRequest(
                id: 'enroll_${DateTime.now().microsecondsSinceEpoch}',
                classId: _trainingClass.id,
                memberId: auth.currentMember!.id,
                reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim(),
                status: EnrollmentRequestStatus.pending,
                requestedAt: DateTime.now(),
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request sent to the instructor/committee')),
              );
              setState(() {});
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _openAttendanceSheet(ClassSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Attendance — ${session.topic.isEmpty ? "Session ${session.sessionNumber}" : session.topic}',
                              style: AppTextStyles.headingSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              setState(() {}); // refresh attendance-dependent UI
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _trainingClass.enrolledMemberIds.length,
                        itemBuilder: (context, index) {
                          final memberId = _trainingClass.enrolledMemberIds[index];
                          final m = MockMembers.findById(memberId);
                          final present = MockSessionAttendance.attendanceFor(session.id, memberId);
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: m != null ? AvatarColorGen.fromString(m.id) : AppColors.grey500,
                              child: Text(m?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                            title: Text(m?.nameEn ?? memberId),
                            subtitle: Text(m?.rankNameEn ?? ''),
                            trailing: SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(value: true, label: Text('Present')),
                                ButtonSegment(value: false, label: Text('Absent')),
                              ],
                              selected: present == null ? {} : {present},
                              emptySelectionAllowed: true,
                              onSelectionChanged: (selection) {
                                if (selection.isNotEmpty) {
                                  MockSessionAttendance.setAttendance(session.id, memberId, selection.first);
                                  setSheetState(() {});
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _openAddMemberSheet(AuthProvider auth) async {
    final candidates = MockMembers.all.where((m) => m.nameEn.isNotEmpty).toList()
      ..sort((a, b) => a.nameEn.compareTo(b.nameEn));
    final currentlyEnrolled = Set<String>.from(_trainingClass.enrolledMemberIds);

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final tempSelected = Set<String>.from(currentlyEnrolled);
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: Text('Manage Enrollment', style: AppTextStyles.headingSmall)),
                          TextButton(
                            onPressed: () => Navigator.pop(sheetContext, tempSelected),
                            child: Text('Done (${tempSelected.length})'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: candidates.length,
                        itemBuilder: (context, index) {
                          final m = candidates[index];
                          final isSelected = tempSelected.contains(m.id);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (v) => setSheetState(() {
                              if (v == true) {
                                tempSelected.add(m.id);
                              } else {
                                tempSelected.remove(m.id);
                              }
                            }),
                            secondary: CircleAvatar(
                              radius: 16,
                              backgroundColor: AvatarColorGen.fromString(m.id),
                              child: Text(m.initials, style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                            title: Text(m.nameEn),
                            subtitle: MockCertificates.hasCertificateMatching(m.id, _trainingClass.title)
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(child: Text(m.rankNameEn)),
                                      Tooltip(
                                        message: 'Already holds this certificate',
                                        child: Icon(Icons.workspace_premium, size: 16, color: Colors.amber.shade700),
                                      ),
                                    ],
                                  )
                                : Text(m.rankNameEn),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (result != null) {
      _updateClass(enrolledMemberIds: result.toList());
    }
  }

  void _updateClass({List<String>? enrolledMemberIds, ClassStatus? status}) {
    final updated = TrainingClass(
      id: _trainingClass.id, title: _trainingClass.title, titleMm: _trainingClass.titleMm,
      type: _trainingClass.type, category: _trainingClass.category, description: _trainingClass.description,
      instructorId: _trainingClass.instructorId, instructorName: _trainingClass.instructorName,
      isExternalInstructor: _trainingClass.isExternalInstructor,
      startDate: _trainingClass.startDate, endDate: _trainingClass.endDate,
      location: _trainingClass.location, maxParticipants: _trainingClass.maxParticipants,
      enrolledMemberIds: enrolledMemberIds ?? _trainingClass.enrolledMemberIds,
      status: status ?? _trainingClass.status,
      requiredSkillIds: _trainingClass.requiredSkillIds, awardedSkillIds: _trainingClass.awardedSkillIds,
      issuesCertificate: _trainingClass.issuesCertificate, certificateTemplateId: _trainingClass.certificateTemplateId,
      hasCommittee: _trainingClass.hasCommittee, committee: _trainingClass.committee,
      budget: _trainingClass.budget, timetable: _trainingClass.timetable,
      minRankRequired: _trainingClass.minRankRequired, videoUrl: _trainingClass.videoUrl,
    );
    MockClasses.update(updated);
    setState(() => _trainingClass = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enrollment updated')),
    );
  }

  int? get _classCompanyNo {
    final instructor = MockMembers.findById(_trainingClass.instructorId);
    return instructor?.companyNo;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.currentMember;
    final canManage = auth.canManageClass(_classCompanyNo, _trainingClass.status);
    final canPrepareClosureReport = auth.canPrepareClosureReport(_classCompanyNo);
    final isEnrolled = me != null && _trainingClass.enrolledMemberIds.contains(me.id);
    final hasPendingRequest = me != null &&
        MockEnrollmentRequests.submittedBy(me.id)
            .any((r) => r.classId == _trainingClass.id && r.status == EnrollmentRequestStatus.pending);
    final alreadyHasCertificate = me != null &&
        MockCertificates.hasCertificateMatching(me.id, _trainingClass.title);
    final canRequestEnroll = me != null &&
        !isEnrolled &&
        !hasPendingRequest &&
        !alreadyHasCertificate &&
        !_trainingClass.isFull &&
        (_trainingClass.status == ClassStatus.open || _trainingClass.status == ClassStatus.draft);
    final isCompleted = _trainingClass.status == ClassStatus.completed ||
        _trainingClass.status == ClassStatus.archived;

    return Scaffold(
      appBar: AppBar(
        title: Text(_trainingClass.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (canManage)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ClassFormScreen(trainingClass: _trainingClass)),
              ).then((_) => _refresh()),
            ),
          if (canPrepareClosureReport && isCompleted)
            IconButton(
              icon: const Icon(Icons.summarize_outlined),
              tooltip: 'Closure Report',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ClassClosureReportScreen(classId: _trainingClass.id)),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          if (_trainingClass.videoUrl != null) _buildVideoCard(),
          if (_trainingClass.videoUrl != null) const SizedBox(height: 16),
          if (canRequestEnroll || hasPendingRequest || isEnrolled || alreadyHasCertificate)
            _buildEnrollmentStatusCard(auth, isEnrolled, hasPendingRequest, canRequestEnroll, alreadyHasCertificate),
          if (canRequestEnroll || hasPendingRequest || isEnrolled || alreadyHasCertificate) const SizedBox(height: 16),
          if (canManage) _buildManageEnrollmentCard(auth),
          if (canManage) const SizedBox(height: 16),
          if (isEnrolled && isCompleted) _buildFeedbackCard(),
          if (isEnrolled && isCompleted) const SizedBox(height: 16),
          _buildTimetableCard(auth),
          const SizedBox(height: 16),
          if (_trainingClass.hasCommittee) _buildCommitteeCard(),
          if (_trainingClass.hasCommittee) const SizedBox(height: 16),
          if (_trainingClass.budget != null && canManage) _buildBudgetCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(_trainingClass.title, style: AppTextStyles.headingMedium)),
                _statusChip(),
              ],
            ),
            if (_trainingClass.titleMm.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(_trainingClass.titleMm, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700)),
            ],
            const Divider(height: 24),
            Text(_trainingClass.description, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            _infoRow(Icons.category_outlined, 'Category', _trainingClass.category),
            _infoRow(Icons.person_outline, 'Instructor',
                '${_trainingClass.instructorName}${_trainingClass.isExternalInstructor ? ' (External)' : ''}'),
            _infoRow(Icons.calendar_today_outlined, 'Dates',
                '${AppFormatters.date(_trainingClass.startDate)} – ${AppFormatters.date(_trainingClass.endDate)}'),
            _infoRow(Icons.location_on_outlined, 'Location', _trainingClass.location),
            _infoRow(Icons.people_outline, 'Enrollment',
                '${_trainingClass.enrolledCount}/${_trainingClass.maxParticipants}'),
            if (_trainingClass.requiredSkillIds.isNotEmpty)
              _infoRow(Icons.lock_outline, 'Requires',
                  _trainingClass.requiredSkillIds.map((id) => MockSkills.findById(id)?.nameEn ?? id).join(', ')),
            if (_trainingClass.awardedSkillIds.isNotEmpty)
              _infoRow(Icons.workspace_premium_outlined, 'Awards',
                  _trainingClass.awardedSkillIds.map((id) => MockSkills.findById(id)?.nameEn ?? id).join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.grey500),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _statusChip() {
    final color = switch (_trainingClass.status) {
      ClassStatus.draft => Colors.grey,
      ClassStatus.open => Colors.blue,
      ClassStatus.full => Colors.orange,
      ClassStatus.ongoing => Colors.green,
      ClassStatus.completed => Colors.purple,
      ClassStatus.archived => Colors.grey,
    };
    return Chip(
      label: Text(_trainingClass.status.name.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildVideoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_display_outlined, color: Colors.red),
                const SizedBox(width: 8),
                Text('Video Lesson', style: AppTextStyles.headingSmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This class has an online video lesson (YouTube Private — link access only).',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                // Opening an external URL requires url_launcher, which
                // isn't wired up yet — showing the link for now so it's
                // at least copyable/visible. Module 16/19 can add real
                // external-link handling.
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Video Link'),
                    content: SelectableText(_trainingClass.videoUrl!),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('View Video Link'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentStatusCard(AuthProvider auth, bool isEnrolled, bool hasPendingRequest, bool canRequestEnroll, bool alreadyHasCertificate) {
    if (isEnrolled) {
      return Card(
        color: Colors.green.withValues(alpha: 0.06),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('You are enrolled in this class.'),
            ],
          ),
        ),
      );
    }
    if (alreadyHasCertificate) {
      return Card(
        color: AppColors.grey50.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.workspace_premium_outlined, color: AppColors.grey700),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You already hold the certificate this class awards.',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (hasPendingRequest) {
      return Card(
        color: Colors.orange.withValues(alpha: 0.06),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.hourglass_empty, color: Colors.orange),
              SizedBox(width: 10),
              Text('Your request to join is pending approval.'),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Text('Interested in this class?', style: AppTextStyles.bodyMedium)),
            ElevatedButton(
              onPressed: () => _requestEnrollment(auth),
              child: const Text('Request to Join'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageEnrollmentCard(AuthProvider auth) {
    final pendingRequests = MockEnrollmentRequests.pendingForClass(_trainingClass.id);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Enrolled Members', style: AppTextStyles.headingSmall)),
                TextButton.icon(
                  onPressed: () => _openAddMemberSheet(auth),
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: const Text('Manage'),
                ),
              ],
            ),
            ..._trainingClass.enrolledMemberIds.map((id) {
              final m = MockMembers.findById(id);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: m != null ? AvatarColorGen.fromString(m.id) : AppColors.grey500,
                  child: Text(m?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
                title: Text(m?.nameEn ?? id, style: AppTextStyles.bodySmall),
              );
            }),
            if (pendingRequests.isNotEmpty) ...[
              const Divider(height: 20),
              Text('Pending Join Requests (${pendingRequests.length})',
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.orange)),
              ...pendingRequests.map((r) => _pendingRequestRow(r)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pendingRequestRow(EnrollmentRequest request) {
    final m = MockMembers.findById(request.memberId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(m?.nameEn ?? request.memberId, style: AppTextStyles.bodySmall),
          ),
          TextButton(
            onPressed: () {
              MockEnrollmentRequests.update(EnrollmentRequest(
                id: request.id, classId: request.classId, memberId: request.memberId,
                reason: request.reason, status: EnrollmentRequestStatus.denied,
                requestedAt: request.requestedAt, decidedAt: DateTime.now(),
              ));
              setState(() {});
            },
            child: const Text('Deny'),
          ),
          ElevatedButton(
            onPressed: () {
              MockEnrollmentRequests.update(EnrollmentRequest(
                id: request.id, classId: request.classId, memberId: request.memberId,
                reason: request.reason, status: EnrollmentRequestStatus.approved,
                requestedAt: request.requestedAt, decidedAt: DateTime.now(),
              ));
              _updateClass(enrolledMemberIds: [..._trainingClass.enrolledMemberIds, request.memberId]);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
    final me = context.read<AuthProvider>().currentMember;
    final alreadySubmitted = me != null && MockClassFeedback.hasSubmitted(_trainingClass.id, me.id);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                alreadySubmitted ? 'Thanks for your feedback!' : 'How was this class?',
                style: AppTextStyles.bodyMedium,
              ),
            ),
            if (!alreadySubmitted)
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ClassFeedbackScreen(classId: _trainingClass.id)),
                ).then((_) => _refresh()),
                child: const Text('Give Feedback'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableCard(AuthProvider auth) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timetable', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            ..._trainingClass.timetable.map((session) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary,
                        child: Text('${session.sessionNumber}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(session.topic, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                            Text(
                              '${AppFormatters.date(session.date)} · ${session.startHour.toString().padLeft(2, '0')}:${session.startMinute.toString().padLeft(2, '0')}–${session.endHour.toString().padLeft(2, '0')}:${session.endMinute.toString().padLeft(2, '0')} · ${session.location}',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                            ),
                          ],
                        ),
                      ),
                      if (auth.canManageClass(_classCompanyNo, _trainingClass.status))
                        TextButton(
                          onPressed: () => _openAttendanceSheet(session),
                          child: const Text('Attendance'),
                        ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitteeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Committee', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            ..._trainingClass.committee.map((cm) {
              final m = MockMembers.findById(cm.memberId);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: m != null ? AvatarColorGen.fromString(m.id) : AppColors.grey500,
                  child: Text(m?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
                title: Text(m?.nameEn ?? cm.memberId, style: AppTextStyles.bodySmall),
                trailing: Text(cm.role, style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard() {
    final budget = _trainingClass.budget!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budget', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            _infoRow(Icons.attach_money, 'Total', 'BHD ${budget.totalAmount.toStringAsFixed(0)}'),
            _infoRow(Icons.money_off, 'Spent', 'BHD ${budget.totalSpent.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            ...budget.categoryAllocations.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key, style: AppTextStyles.bodySmall)),
                      Text('BHD ${e.value.toStringAsFixed(0)}', style: AppTextStyles.bodySmall),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}