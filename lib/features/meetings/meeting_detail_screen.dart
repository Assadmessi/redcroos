import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/utils/permission_service.dart';
import '../auth/auth_provider.dart';
import 'meeting_form_screen.dart';
import 'meeting_minutes_view_screen.dart';

class MeetingDetailScreen extends StatefulWidget {
  final String meetingId;
  const MeetingDetailScreen({super.key, required this.meetingId});

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

enum _AttendanceMark { present, excused, absent }

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  late Meeting _meeting;

  @override
  void initState() {
    super.initState();
    _meeting = MockMeetings.findById(widget.meetingId)!;
  }

  _AttendanceMark? _markFor(String memberId) {
    if (_meeting.attendedMemberIds.contains(memberId)) return _AttendanceMark.present;
    if (_meeting.excusedMemberIds.contains(memberId)) return _AttendanceMark.excused;
    if (_meeting.absentMemberIds.contains(memberId)) return _AttendanceMark.absent;
    return null;
  }

  void _setAttendance(String memberId, _AttendanceMark mark) {
    setState(() {
      final attended = List<String>.from(_meeting.attendedMemberIds)..remove(memberId);
      final excused = List<String>.from(_meeting.excusedMemberIds)..remove(memberId);
      final absent = List<String>.from(_meeting.absentMemberIds)..remove(memberId);

      switch (mark) {
        case _AttendanceMark.present: attended.add(memberId);
        case _AttendanceMark.excused: excused.add(memberId);
        case _AttendanceMark.absent: absent.add(memberId);
      }

      _meeting = _copyMeeting(
        attendedMemberIds: attended,
        excusedMemberIds: excused,
        absentMemberIds: absent,
      );
      MockMeetings.update(_meeting);
    });
  }

  void _addDiscussionEntry(int index, String speakerMemberId, String comment) {
    setState(() {
      final items = List<AgendaItem>.from(_meeting.agendaItems);
      final item = items[index];
      final entries = List<DiscussionEntry>.from(item.discussionEntries)
        ..add(DiscussionEntry(
          id: 'disc_${DateTime.now().microsecondsSinceEpoch}',
          speakerMemberId: speakerMemberId,
          comment: comment,
        ));
      items[index] = AgendaItem(
        id: item.id, meetingId: item.meetingId, order: item.order,
        topic: item.topic, presenterMemberId: item.presenterMemberId,
        discussion: item.discussion, decision: item.decision,
        discussionEntries: entries, decisions: item.decisions,
      );
      _meeting = _copyMeeting(agendaItems: items);
      MockMeetings.update(_meeting);
    });
  }

  void _removeDiscussionEntry(int itemIndex, String entryId) {
    setState(() {
      final items = List<AgendaItem>.from(_meeting.agendaItems);
      final item = items[itemIndex];
      final entries = List<DiscussionEntry>.from(item.discussionEntries)
        ..removeWhere((e) => e.id == entryId);
      items[itemIndex] = AgendaItem(
        id: item.id, meetingId: item.meetingId, order: item.order,
        topic: item.topic, presenterMemberId: item.presenterMemberId,
        discussion: item.discussion, decision: item.decision,
        discussionEntries: entries, decisions: item.decisions,
      );
      _meeting = _copyMeeting(agendaItems: items);
      MockMeetings.update(_meeting);
    });
  }

  void _addDecisionEntry(int index, String decisionText, String approvedByMemberId) {
    setState(() {
      final items = List<AgendaItem>.from(_meeting.agendaItems);
      final item = items[index];
      final decisions = List<DecisionEntry>.from(item.decisions)
        ..add(DecisionEntry(
          id: 'dec_${DateTime.now().microsecondsSinceEpoch}',
          decisionText: decisionText,
          approvedByMemberId: approvedByMemberId,
        ));
      items[index] = AgendaItem(
        id: item.id, meetingId: item.meetingId, order: item.order,
        topic: item.topic, presenterMemberId: item.presenterMemberId,
        discussion: item.discussion, decision: item.decision,
        discussionEntries: item.discussionEntries, decisions: decisions,
      );
      _meeting = _copyMeeting(agendaItems: items);
      MockMeetings.update(_meeting);
    });
  }

  void _removeDecisionEntry(int itemIndex, String decisionId) {
    setState(() {
      final items = List<AgendaItem>.from(_meeting.agendaItems);
      final item = items[itemIndex];
      final decisions = List<DecisionEntry>.from(item.decisions)
        ..removeWhere((d) => d.id == decisionId);
      items[itemIndex] = AgendaItem(
        id: item.id, meetingId: item.meetingId, order: item.order,
        topic: item.topic, presenterMemberId: item.presenterMemberId,
        discussion: item.discussion, decision: item.decision,
        discussionEntries: item.discussionEntries, decisions: decisions,
      );
      _meeting = _copyMeeting(agendaItems: items);
      MockMeetings.update(_meeting);
    });
  }

  void _startMeeting() {
    setState(() {
      _meeting = _copyMeeting(status: MeetingStatus.inProgress);
      MockMeetings.update(_meeting);
    });
  }

  void _draftMinutes() {
    setState(() {
      _meeting = _copyMeeting(status: MeetingStatus.minutesDrafted);
      MockMeetings.update(_meeting);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Minutes drafted — awaiting approval')),
    );
  }

  void _approveMinutes(AuthProvider auth) {
    setState(() {
      _meeting = _copyMeeting(
        status: MeetingStatus.signed,
        approvedByMemberId: auth.currentMember?.id,
      );
      MockMeetings.update(_meeting);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Minutes signed')),
    );
  }

  void _publishMinutes() {
    setState(() {
      _meeting = _copyMeeting(status: MeetingStatus.published);
      MockMeetings.update(_meeting);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Minutes published')),
    );
  }

  Meeting _copyMeeting({
    List<String>? attendedMemberIds,
    List<String>? excusedMemberIds,
    List<String>? absentMemberIds,
    List<AgendaItem>? agendaItems,
    MeetingStatus? status,
    String? approvedByMemberId,
  }) {
    return Meeting(
      id: _meeting.id, title: _meeting.title, titleMm: _meeting.titleMm,
      type: _meeting.type, date: _meeting.date,
      timeHour: _meeting.timeHour, timeMinute: _meeting.timeMinute,
      location: _meeting.location,
      invitedMemberIds: _meeting.invitedMemberIds,
      attendedMemberIds: attendedMemberIds ?? _meeting.attendedMemberIds,
      excusedMemberIds: excusedMemberIds ?? _meeting.excusedMemberIds,
      absentMemberIds: absentMemberIds ?? _meeting.absentMemberIds,
      minimumRank: _meeting.minimumRank,
      agenda: _meeting.agenda,
      minutes: _meeting.minutes,
      status: status ?? _meeting.status,
      tasks: _meeting.tasks,
      createdAt: _meeting.createdAt,
      meetingNumber: _meeting.meetingNumber,
      meetingYear: _meeting.meetingYear,
      agendaItems: agendaItems ?? _meeting.agendaItems,
      organizerMemberId: _meeting.organizerMemberId,
      recorderMemberId: _meeting.recorderMemberId,
      approvedByMemberId: approvedByMemberId ?? _meeting.approvedByMemberId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.currentMember;
    final meetingCompanyNo = me?.unitType == UnitType.brigadeOffice ? null : me?.companyNo;
    final canManage = auth.canManageMeeting(_meeting, meetingCompanyNo);
    final canMarkAttendance = auth.canMarkAttendance(_meeting);
    final canRecordDiscussion = auth.canRecordDiscussion(_meeting);
    final canApprove = auth.canApproveMinutes;
    final isStartedInvestigationMeeting = _meeting.type == MeetingType.investigation &&
        _meeting.status != MeetingStatus.scheduled;
    final linkedInvestigation = _meeting.linkedInvestigationId != null
        ? MockInvestigations.findById(_meeting.linkedInvestigationId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_meeting.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (canManage && _meeting.status == MeetingStatus.scheduled)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MeetingFormScreen(meeting: _meeting)),
              ).then((_) => setState(() {
                    _meeting = MockMeetings.findById(widget.meetingId)!;
                  })),
            ),
          IconButton(
            icon: const Icon(Icons.description_outlined),
            tooltip: 'View Minutes',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MeetingMinutesViewScreen(meetingId: _meeting.id)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildWorkflowCard(canRecordDiscussion, canApprove),
          const SizedBox(height: 16),
          if (isStartedInvestigationMeeting)
            _buildInvestigationStageCard(linkedInvestigation, canRecordDiscussion)
          else
            _buildAttendanceCard(canMarkAttendance),
          const SizedBox(height: 16),
          _buildAgendaCard(canRecordDiscussion),
          const SizedBox(height: 16),
          _buildDiscussionSummaryCard(),
          const SizedBox(height: 16),
          _buildDecisionsSummaryCard(),
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
                Expanded(child: Text(_meeting.title, style: AppTextStyles.headingMedium)),
                _statusChip(),
              ],
            ),
            if (_meeting.titleMm.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(_meeting.titleMm, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700)),
            ],
            if (_meeting.meetingNumberDisplay != null) ...[
              const SizedBox(height: 4),
              Text('Meeting No. ${_meeting.meetingNumberDisplay}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
            ],
            const Divider(height: 24),
            _infoRow(Icons.category_outlined, 'Type', _meeting.typeDisplay),
            _infoRow(Icons.calendar_today_outlined, 'Date', AppFormatters.date(_meeting.date)),
            _infoRow(Icons.access_time, 'Time', _meeting.timeDisplay),
            _infoRow(Icons.location_on_outlined, 'Location', _meeting.location),
            _infoRow(Icons.people_outline, 'Invited', '${_meeting.invitedMemberIds.length} members'),
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
            width: 80,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _statusChip() {
    final (color, label) = switch (_meeting.status) {
      MeetingStatus.scheduled => (Colors.blue, 'SCHEDULED'),
      MeetingStatus.inProgress => (Colors.green, 'IN PROGRESS'),
      MeetingStatus.minutesDrafted => (Colors.orange, 'MINUTES DRAFTED'),
      MeetingStatus.signed => (Colors.purple, 'SIGNED'),
      MeetingStatus.published => (Colors.grey, 'PUBLISHED'),
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildWorkflowCard(bool canRecordDiscussion, bool canApprove) {
    Widget? action;
    switch (_meeting.status) {
      case MeetingStatus.scheduled:
        if (canRecordDiscussion && _meeting.canStartNow) {
          action = ElevatedButton(onPressed: _startMeeting, child: const Text('Start Meeting'));
        }
      case MeetingStatus.inProgress:
        if (canRecordDiscussion) {
          action = ElevatedButton(onPressed: _draftMinutes, child: const Text('Draft Minutes'));
        }
      case MeetingStatus.minutesDrafted:
        if (canApprove) {
          action = ElevatedButton(
            onPressed: () => _approveMinutes(context.read<AuthProvider>()),
            child: const Text('Sign Minutes'),
          );
        }
      case MeetingStatus.signed:
        if (canApprove) {
          action = ElevatedButton(onPressed: _publishMinutes, child: const Text('Publish Minutes'));
        }
      case MeetingStatus.published:
        action = null;
    }

    final showCardAnyway = canRecordDiscussion && _meeting.status == MeetingStatus.scheduled;
    if (action == null && !showCardAnyway) return const SizedBox.shrink();

    return Card(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _workflowHint(),
                style: AppTextStyles.bodySmall,
              ),
            ),
            const SizedBox(width: 12),
            if (action != null) action,
          ],
        ),
      ),
    );
  }

  String _workflowHint() => switch (_meeting.status) {
        MeetingStatus.scheduled => _meeting.canStartNow
            ? 'Meeting not yet started.'
            : 'Starts at ${AppFormatters.date(_meeting.date)} ${_meeting.timeDisplay} — can\'t be started until then.',
        MeetingStatus.inProgress => 'Meeting in progress — record discussion and decisions below.',
        MeetingStatus.minutesDrafted => 'Awaiting sign-off from Brigade Office.',
        MeetingStatus.signed => 'Signed — ready to publish to all invitees.',
        MeetingStatus.published => 'Published.',
      };

  Widget _buildInvestigationStageCard(Investigation? investigation, bool canRecordDiscussion) {
    final auth = context.read<AuthProvider>();
    final committeeMembers = investigation != null
        ? investigation.committeeMemberIds.map((id) => MockMembers.findById(id)).whereType<Member>().toList()
        : <Member>[];
    final chairman = PermissionService.committeeChairman(committeeMembers);
    final isFinalized = _meeting.status == MeetingStatus.published;
    final canRequestInvite = !isFinalized && auth.canRequestOfficerInvite(committeeMembers);
    final canAddDirectly = !isFinalized && auth.canAddOfficerDirectly;
    final canApproveInvites = !isFinalized && auth.canApproveOfficerInvite;
    final pendingInvites = MockOfficerInviteRequests.pendingForMeeting(_meeting.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Investigation Stage', style: AppTextStyles.headingSmall),
            const SizedBox(height: 4),
            Text(
              'Committee members are assumed to always attend — showing case progress instead.',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 12),
            if (investigation == null)
              Text('No linked investigation found.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500))
            else ...[
              _kv('Case', '${investigation.caseNumber} — ${investigation.title}'),
              _kv('Current Stage', _stageLabel(investigation.status)),
              if (chairman != null) _kv('Committee Chairman', '${chairman.nameEn} (${chairman.rankNameEn})'),
              const SizedBox(height: 12),
              Text('Stage History', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...investigation.stageLogs.map((log) {
                final actor = MockMembers.findById(log.actionedById);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.fiber_manual_record, size: 10, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_stageLabel(log.stage), style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                            Text(
                              '${AppFormatters.date(log.timestamp)} · ${actor?.nameEn ?? log.actionedById}',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                            ),
                            if (log.notes != null) Text(log.notes!, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const Divider(height: 24),
            Text('Invited Officers', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ..._meeting.invitedMemberIds.map((id) {
              final m = MockMembers.findById(id);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${m?.nameEn ?? id} — ${m?.rankNameEn ?? ''}', style: AppTextStyles.bodySmall),
              );
            }),
            if (pendingInvites.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Pending Invite Requests', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.orange)),
              ...pendingInvites.map((r) => _pendingOfficerInviteRow(r, canApproveInvites)),
            ],
            if (canRequestInvite || canAddDirectly) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _openOfficerInviteSheet(canAddDirectly),
                icon: const Icon(Icons.person_add_alt_outlined, size: 18),
                label: Text(canAddDirectly ? 'Add Officer' : 'Request to Invite Officer'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _stageLabel(InvestigationStatus status) => switch (status) {
        InvestigationStatus.opened => 'Opened',
        InvestigationStatus.underInvestigation => 'Under Investigation',
        InvestigationStatus.hearingScheduled => 'Hearing Scheduled',
        InvestigationStatus.hearingConducted => 'Hearing Conducted',
        InvestigationStatus.deliberation => 'Deliberation',
        InvestigationStatus.concluded => 'Concluded',
        InvestigationStatus.closed => 'Closed',
        InvestigationStatus.appealed => 'Appealed',
        InvestigationStatus.appealReview => 'Appeal Under Review',
        InvestigationStatus.appealConcluded => 'Appeal Concluded',
      };

  Widget _pendingOfficerInviteRow(OfficerInviteRequest request, bool canApprove) {
    final officer = MockMembers.findById(request.officerMemberId);
    final requester = MockMembers.findById(request.requestedByMemberId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${officer?.nameEn ?? request.officerMemberId} — requested by ${requester?.nameEn ?? request.requestedByMemberId}',
              style: AppTextStyles.bodySmall,
            ),
          ),
          if (canApprove) ...[
            TextButton(
              onPressed: () => _decideOfficerInvite(request, false),
              child: const Text('Deny'),
            ),
            ElevatedButton(
              onPressed: () => _decideOfficerInvite(request, true),
              child: const Text('Approve'),
            ),
          ],
        ],
      ),
    );
  }

  void _decideOfficerInvite(OfficerInviteRequest request, bool approve) {
    final auth = context.read<AuthProvider>();
    MockOfficerInviteRequests.update(OfficerInviteRequest(
      id: request.id, meetingId: request.meetingId,
      requestedByMemberId: request.requestedByMemberId,
      officerMemberId: request.officerMemberId, reason: request.reason,
      status: approve ? OfficerInviteRequestStatus.approved : OfficerInviteRequestStatus.denied,
      approverId: auth.currentMember?.id,
      requestedAt: request.requestedAt, decidedAt: DateTime.now(),
    ));

    if (approve) {
      setState(() {
        _meeting = Meeting(
          id: _meeting.id, title: _meeting.title, titleMm: _meeting.titleMm,
          type: _meeting.type, date: _meeting.date,
          timeHour: _meeting.timeHour, timeMinute: _meeting.timeMinute,
          location: _meeting.location,
          invitedMemberIds: [..._meeting.invitedMemberIds, request.officerMemberId],
          attendedMemberIds: _meeting.attendedMemberIds,
          excusedMemberIds: _meeting.excusedMemberIds,
          absentMemberIds: _meeting.absentMemberIds,
          minimumRank: _meeting.minimumRank,
          agenda: _meeting.agenda, minutes: _meeting.minutes,
          status: _meeting.status, tasks: _meeting.tasks,
          createdAt: _meeting.createdAt,
          meetingNumber: _meeting.meetingNumber, meetingYear: _meeting.meetingYear,
          agendaItems: _meeting.agendaItems,
          organizerMemberId: _meeting.organizerMemberId,
          recorderMemberId: _meeting.recorderMemberId,
          approvedByMemberId: _meeting.approvedByMemberId,
          linkedInvestigationId: _meeting.linkedInvestigationId,
        );
      });
      MockMeetings.update(_meeting);
    } else {
      setState(() {});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(approve ? 'Officer invited' : 'Request denied')),
    );
  }

  Future<void> _openOfficerInviteSheet(bool canAddDirectly) async {
    final candidates = MockMembers.all
        .where((m) => m.nameEn.isNotEmpty && !_meeting.invitedMemberIds.contains(m.id))
        .toList()
      ..sort((a, b) => a.nameEn.compareTo(b.nameEn));

    String? selectedId;
    final reasonCtrl = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
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
                  Text(canAddDirectly ? 'Add Officer' : 'Request to Invite Officer', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedId,
                    decoration: const InputDecoration(labelText: 'Officer', border: OutlineInputBorder()),
                    items: candidates.map((m) => DropdownMenuItem(value: m.id, child: Text('${m.nameEn} (${m.rankNameEn})'))).toList(),
                    onChanged: (v) => setSheetState(() => selectedId = v),
                  ),
                  if (!canAddDirectly) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedId == null ? null : () => Navigator.pop(sheetContext, true),
                    child: Text(canAddDirectly ? 'Add' : 'Submit Request'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (confirmed != true || selectedId == null) return;
    final auth = context.read<AuthProvider>();

    if (canAddDirectly) {
      setState(() {
        _meeting = Meeting(
          id: _meeting.id, title: _meeting.title, titleMm: _meeting.titleMm,
          type: _meeting.type, date: _meeting.date,
          timeHour: _meeting.timeHour, timeMinute: _meeting.timeMinute,
          location: _meeting.location,
          invitedMemberIds: [..._meeting.invitedMemberIds, selectedId!],
          attendedMemberIds: _meeting.attendedMemberIds,
          excusedMemberIds: _meeting.excusedMemberIds,
          absentMemberIds: _meeting.absentMemberIds,
          minimumRank: _meeting.minimumRank,
          agenda: _meeting.agenda, minutes: _meeting.minutes,
          status: _meeting.status, tasks: _meeting.tasks,
          createdAt: _meeting.createdAt,
          meetingNumber: _meeting.meetingNumber, meetingYear: _meeting.meetingYear,
          agendaItems: _meeting.agendaItems,
          organizerMemberId: _meeting.organizerMemberId,
          recorderMemberId: _meeting.recorderMemberId,
          approvedByMemberId: _meeting.approvedByMemberId,
          linkedInvestigationId: _meeting.linkedInvestigationId,
        );
      });
      MockMeetings.update(_meeting);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Officer added')),
      );
    } else {
      MockOfficerInviteRequests.add(OfficerInviteRequest(
        id: 'invite_${DateTime.now().microsecondsSinceEpoch}',
        meetingId: _meeting.id,
        requestedByMemberId: auth.currentMember!.id,
        officerMemberId: selectedId!,
        reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim(),
        status: OfficerInviteRequestStatus.pending,
        requestedAt: DateTime.now(),
      ));
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent to Master Access for approval')),
      );
    }
  }

  Widget _buildAttendanceCard(bool canMark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance (${_meeting.invitedMemberIds.length} invited)', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            ..._meeting.invitedMemberIds.map((id) => _attendanceRow(id, canMark)),
          ],
        ),
      ),
    );
  }

  Widget _attendanceRow(String memberId, bool canMark) {
    final member = MockMembers.findById(memberId);
    final mark = _markFor(memberId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: member != null ? AvatarColorGen.fromString(member.id) : AppColors.grey500,
            child: Text(member?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(member?.nameEn ?? memberId, style: AppTextStyles.bodyMedium),
          ),
          if (canMark)
            SegmentedButton<_AttendanceMark>(
              segments: const [
                ButtonSegment(value: _AttendanceMark.present, label: Text('P')),
                ButtonSegment(value: _AttendanceMark.excused, label: Text('E')),
                ButtonSegment(value: _AttendanceMark.absent, label: Text('A')),
              ],
              selected: mark != null ? {mark} : {},
              emptySelectionAllowed: true,
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) _setAttendance(memberId, selection.first);
              },
            )
          else
            _attendanceBadge(mark),
        ],
      ),
    );
  }

  Widget _attendanceBadge(_AttendanceMark? mark) {
    final (color, label) = switch (mark) {
      _AttendanceMark.present => (Colors.green, 'Present'),
      _AttendanceMark.excused => (Colors.orange, 'Excused'),
      _AttendanceMark.absent => (Colors.red, 'Absent'),
      null => (Colors.grey, 'Pending'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildDiscussionSummaryCard() {
    final entries = _meeting.allDiscussionEntries;
    if (entries.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discussion Summary', style: AppTextStyles.headingSmall),
            const SizedBox(height: 4),
            Text(
              'All discussion across the meeting, in one place.',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 8),
            ...entries.map((pair) {
              final speaker = MockMembers.findById(pair.entry.speakerMemberId);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: speaker != null ? AvatarColorGen.fromString(speaker.id) : AppColors.grey500,
                      child: Text(speaker?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 9)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${speaker?.nameEn ?? pair.entry.speakerMemberId} — on "${pair.item.topic}"',
                            style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.grey700),
                          ),
                          Text(pair.entry.comment, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionsSummaryCard() {
    final decisions = _meeting.allDecisions;
    if (decisions.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Decisions Summary', style: AppTextStyles.headingSmall),
            const SizedBox(height: 4),
            Text(
              'All decisions reached in this meeting, with who approved each.',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 8),
            ...decisions.map((pair) {
              final approver = MockMembers.findById(pair.decision.approvedByMemberId);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pair.decision.decisionText, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          Text(
                            'On "${pair.item.topic}" — approved by ${approver?.nameEn ?? pair.decision.approvedByMemberId}',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaCard(bool canRecordDiscussion) {
    if (_meeting.agendaItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No agenda items.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500)),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agenda', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            ..._meeting.agendaItems.asMap().entries.map((entry) {
              return _agendaItemTile(entry.key, entry.value, canRecordDiscussion);
            }),
          ],
        ),
      ),
    );
  }

  Widget _agendaItemTile(int index, AgendaItem item, bool canRecordDiscussion) {
    final presenter = item.presenterMemberId != null
        ? MockMembers.findById(item.presenterMemberId!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey50.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(item.topic, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
            ],
          ),
          if (presenter != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 32),
              child: Text('Presented by ${presenter.nameEn}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
            ),
          const SizedBox(height: 8),

          // ── Discussion entries (multiple speakers) ──
          Text('Discussion', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.grey700)),
          const SizedBox(height: 4),
          if (item.discussionEntries.isEmpty && !(item.discussion?.isNotEmpty ?? false))
            Text('No discussion recorded.', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500))
          else ...[
            // Legacy single-string discussion, if present from before
            // multi-speaker support existed.
            if (item.discussion != null && item.discussion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(item.discussion!, style: AppTextStyles.bodySmall),
              ),
            ...item.discussionEntries.map((e) => _discussionRow(index, e, canRecordDiscussion)),
          ],
          if (canRecordDiscussion)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openAddDiscussionSheet(index),
                icon: const Icon(Icons.add_comment_outlined, size: 16),
                label: const Text('Add Speaker Comment'),
              ),
            ),

          const SizedBox(height: 8),

          // ── Decision entries (multiple, each attributed) ──
          Text('Decisions', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.grey700)),
          const SizedBox(height: 4),
          if (item.decisions.isEmpty && !item.hasDecision)
            Text('No decisions recorded.', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500))
          else ...[
            if (item.decision != null && item.decision!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(item.decision!, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              ),
            ...item.decisions.map((d) => _decisionRow(index, d, canRecordDiscussion)),
          ],
          if (canRecordDiscussion)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openAddDecisionSheet(index),
                icon: const Icon(Icons.gavel_outlined, size: 16),
                label: const Text('Add Decision'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _discussionRow(int itemIndex, DiscussionEntry entry, bool canRecordDiscussion) {
    final speaker = MockMembers.findById(entry.speakerMemberId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: speaker != null ? AvatarColorGen.fromString(speaker.id) : AppColors.grey500,
            child: Text(speaker?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 9)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(color: Colors.black),
                children: [
                  TextSpan(
                    text: '${speaker?.nameEn ?? entry.speakerMemberId}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: entry.comment),
                ],
              ),
            ),
          ),
          if (canRecordDiscussion)
            InkWell(
              onTap: () => _removeDiscussionEntry(itemIndex, entry.id),
              child: const Icon(Icons.close, size: 14, color: AppColors.grey500),
            ),
        ],
      ),
    );
  }

  Widget _decisionRow(int itemIndex, DecisionEntry decision, bool canRecordDiscussion) {
    final approver = MockMembers.findById(decision.approvedByMemberId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 14, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(color: Colors.black, fontWeight: FontWeight.w600),
                children: [
                  TextSpan(text: '${decision.decisionText} '),
                  TextSpan(
                    text: '— approved by ${approver?.nameEn ?? decision.approvedByMemberId}',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
          if (canRecordDiscussion)
            InkWell(
              onTap: () => _removeDecisionEntry(itemIndex, decision.id),
              child: const Icon(Icons.close, size: 14, color: AppColors.grey500),
            ),
        ],
      ),
    );
  }

  void _openAddDiscussionSheet(int itemIndex) {
    String? selectedSpeakerId;
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
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
                  Text('Add Speaker Comment', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSpeakerId,
                    decoration: const InputDecoration(labelText: 'Speaker', border: OutlineInputBorder()),
                    items: _meeting.invitedMemberIds.map((id) {
                      final m = MockMembers.findById(id);
                      return DropdownMenuItem(value: id, child: Text(m?.nameEn ?? id));
                    }).toList(),
                    onChanged: (v) => setSheetState(() => selectedSpeakerId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Comment', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedSpeakerId == null
                        ? null
                        : () {
                            if (commentCtrl.text.trim().isEmpty) return;
                            Navigator.pop(sheetContext);
                            _addDiscussionEntry(itemIndex, selectedSpeakerId!, commentCtrl.text.trim());
                          },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _openAddDecisionSheet(int itemIndex) {
    String? selectedApproverId;
    final decisionCtrl = TextEditingController();

    showModalBottomSheet(
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
                  Text('Add Decision', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  TextField(
                    controller: decisionCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Decision', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedApproverId,
                    decoration: const InputDecoration(labelText: 'Approved By', border: OutlineInputBorder()),
                    items: _meeting.invitedMemberIds.map((id) {
                      final m = MockMembers.findById(id);
                      return DropdownMenuItem(value: id, child: Text(m?.nameEn ?? id));
                    }).toList(),
                    onChanged: (v) => setSheetState(() => selectedApproverId = v),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedApproverId == null
                        ? null
                        : () {
                            if (decisionCtrl.text.trim().isEmpty) return;
                            Navigator.pop(sheetContext);
                            _addDecisionEntry(itemIndex, decisionCtrl.text.trim(), selectedApproverId!);
                          },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}