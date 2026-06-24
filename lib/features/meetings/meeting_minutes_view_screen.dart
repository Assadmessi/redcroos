import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class MeetingMinutesViewScreen extends StatelessWidget {
  final String meetingId;
  const MeetingMinutesViewScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    final meeting = MockMeetings.findById(meetingId);
    if (meeting == null) {
      return const Scaffold(body: Center(child: Text('Meeting not found')));
    }

    final organizer = meeting.organizerMemberId != null
        ? MockMembers.findById(meeting.organizerMemberId!)
        : null;
    final recorder = meeting.recorderMemberId != null
        ? MockMembers.findById(meeting.recorderMemberId!)
        : null;
    final approver = meeting.approvedByMemberId != null
        ? MockMembers.findById(meeting.approvedByMemberId!)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Meeting Minutes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header ──
          Center(
            child: Column(
              children: [
                Text('MYANMAR RED CROSS BRIGADE', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
                const Text('Botahtaung Township', style: TextStyle(fontSize: 11)),
                const SizedBox(height: 12),
                Text('MEETING MINUTES', style: AppTextStyles.headingMedium),
                Text(meeting.titleMm, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700)),
                if (meeting.meetingNumberDisplay != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${meeting.typeDisplay} Meeting No. ${meeting.meetingNumberDisplay}',
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 32),

          // ── Basic Info ──
          _sectionHeading('Meeting Details'),
          _kv('Title', meeting.title),
          _kv('Type', meeting.typeDisplay),
          _kv('Date', AppFormatters.date(meeting.date)),
          _kv('Time', meeting.timeDisplay),
          _kv('Location', meeting.location),
          if (organizer != null) _kv('Organized By', '${organizer.nameEn} (${organizer.rankNameEn})'),
          if (recorder != null) _kv('Minutes Recorded By', '${recorder.nameEn} (${recorder.rankNameEn})'),

          const SizedBox(height: 20),

          // ── Attendance ──
          _sectionHeading('Attendance'),
          _attendanceTable(meeting),

          const SizedBox(height: 20),

          // ── Pending tasks carried forward ──
          if (meeting.tasks.isNotEmpty) ...[
            _sectionHeading('Action Items'),
            ...meeting.tasks.map((t) {
              final assignee = MockMembers.findById(t.assignedMemberId);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      t.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 16,
                      color: t.isCompleted ? Colors.green : AppColors.grey500,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${t.title} — ${assignee?.nameEn ?? t.assignedMemberId} (due ${AppFormatters.date(t.dueDate)})',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],

          // ── Agenda / Discussion / Decisions ──
          _sectionHeading('Agenda & Decisions'),
          if (meeting.agendaItems.isEmpty)
            Text('No agenda items recorded.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500))
          else
            ...meeting.agendaItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final presenter = item.presenterMemberId != null
                  ? MockMembers.findById(item.presenterMemberId!)
                  : null;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey50.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}. ${item.topic}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    if (presenter != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('Presented by ${presenter.nameEn}',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
                      ),
                    if (item.discussion != null && item.discussion!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Discussion:', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                      Text(item.discussion!, style: AppTextStyles.bodySmall),
                    ],
                    if (item.hasDecision) ...[
                      const SizedBox(height: 6),
                      Text('Decision:', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                      Text(item.decision!, style: AppTextStyles.bodySmall),
                    ],
                  ],
                ),
              );
            }),

          if (meeting.minutes != null && meeting.minutes!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionHeading('Summary'),
            Text(meeting.minutes!, style: AppTextStyles.bodySmall),
          ],

          const SizedBox(height: 32),

          // ── Signature block ──
          _sectionHeading('Approval'),
          _signatureRow('Recorded by', recorder),
          _signatureRow('Approved by', approver),

          const SizedBox(height: 20),
          Center(
            child: Text(
              'Distribution: All invited members',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500, fontStyle: FontStyle.italic),
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

  Widget _attendanceTable(Meeting meeting) {
    final present = meeting.attendedMemberIds;
    final excused = meeting.excusedMemberIds;
    final absent = meeting.absentMemberIds;
    final notMarked = meeting.invitedMemberIds
        .where((id) => !present.contains(id) && !excused.contains(id) && !absent.contains(id))
        .toList();

    Widget group(String label, List<String> ids, Color color) {
      if (ids.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label (${ids.length})', style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold)),
            ...ids.map((id) {
              final m = MockMembers.findById(id);
              return Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Text('${m?.nameEn ?? id} — ${m?.rankNameEn ?? ''}', style: AppTextStyles.bodySmall),
              );
            }),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        group('Present', present, Colors.green),
        group('Excused', excused, Colors.orange),
        group('Absent', absent, Colors.red),
        group('Not Yet Marked', notMarked, AppColors.grey500),
      ],
    );
  }

  Widget _signatureRow(String label, Member? member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Divider(),
                Text(
                  member != null ? '(${member.nameEn})' : '(Not yet assigned)',
                  style: AppTextStyles.bodySmall,
                ),
                if (member != null)
                  Text(member.rankNameEn, style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
