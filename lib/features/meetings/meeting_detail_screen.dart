import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
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

  void _updateAgendaItem(int index, {String? discussion, String? decision}) {
    setState(() {
      final items = List<AgendaItem>.from(_meeting.agendaItems);
      final item = items[index];
      items[index] = AgendaItem(
        id: item.id, meetingId: item.meetingId, order: item.order,
        topic: item.topic, presenterMemberId: item.presenterMemberId,
        discussion: discussion ?? item.discussion,
        decision: decision ?? item.decision,
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
          _buildAttendanceCard(canMarkAttendance),
          const SizedBox(height: 16),
          _buildAgendaCard(canRecordDiscussion),
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
        if (canRecordDiscussion) {
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

    if (action == null) return const SizedBox.shrink();

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
            action,
          ],
        ),
      ),
    );
  }

  String _workflowHint() => switch (_meeting.status) {
        MeetingStatus.scheduled => 'Meeting not yet started.',
        MeetingStatus.inProgress => 'Meeting in progress — record discussion and decisions below.',
        MeetingStatus.minutesDrafted => 'Awaiting sign-off from Brigade Office.',
        MeetingStatus.signed => 'Signed — ready to publish to all invitees.',
        MeetingStatus.published => 'Published.',
      };

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
          if (canRecordDiscussion) ...[
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item.discussion,
              decoration: const InputDecoration(labelText: 'Discussion', border: OutlineInputBorder(), isDense: true),
              maxLines: 2,
              onChanged: (v) => _updateAgendaItem(index, discussion: v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item.decision,
              decoration: const InputDecoration(labelText: 'Decision', border: OutlineInputBorder(), isDense: true),
              maxLines: 2,
              onChanged: (v) => _updateAgendaItem(index, decision: v),
            ),
          ] else ...[
            if (item.discussion != null && item.discussion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Discussion: ${item.discussion}', style: AppTextStyles.bodySmall),
              ),
            if (item.hasDecision)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Decision: ${item.decision}',
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              ),
          ],
        ],
      ),
    );
  }
}
