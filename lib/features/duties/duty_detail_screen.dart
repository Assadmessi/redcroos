import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';
import '../events/event_detail_screen.dart';
import 'duty_form_screen.dart';

class DutyDetailScreen extends StatefulWidget {
  final String dutyId;
  const DutyDetailScreen({super.key, required this.dutyId});

  @override
  State<DutyDetailScreen> createState() => _DutyDetailScreenState();
}

class _DutyDetailScreenState extends State<DutyDetailScreen> {
  late Duty _duty;

  @override
  void initState() {
    super.initState();
    _duty = MockDuties.findById(widget.dutyId)!;
  }

  void _respondToDuty(bool accept) {
    setState(() {
      _duty = Duty(
        id: _duty.id, title: _duty.title, titleMm: _duty.titleMm,
        type: _duty.type, scale: _duty.scale, date: _duty.date,
        startHour: _duty.startHour, startMinute: _duty.startMinute,
        endHour: _duty.endHour, endMinute: _duty.endMinute,
        location: _duty.location,
        members: _duty.members.map((dm) {
          if (dm.memberId != context.read<AuthProvider>().currentMember?.id) return dm;
          return DutyMember(
            memberId: dm.memberId,
            roleInDuty: dm.roleInDuty,
            positionId: dm.positionId,
            status: accept ? DutyAssignmentStatus.accepted : DutyAssignmentStatus.rejected,
            rejectionReason: accept ? null : 'Declined by member',
            checkedInAt: dm.checkedInAt,
            assignedAt: dm.assignedAt,
            respondedAt: DateTime.now(),
          );
        }).toList(),
        status: _duty.status,
        description: _duty.description,
        isEvent: _duty.isEvent,
        eventId: _duty.eventId,
        createdByMemberId: _duty.createdByMemberId,
        isDisasterLevel: _duty.isDisasterLevel,
        escalatedToDutyId: _duty.escalatedToDutyId,
        originatingEmergencyDutyId: _duty.originatingEmergencyDutyId,
        isMutualAidOutsideBotahtaung: _duty.isMutualAidOutsideBotahtaung,
        report: _duty.report,
        reportSubmittedByMemberId: _duty.reportSubmittedByMemberId,
        reportSubmittedAt: _duty.reportSubmittedAt,
        approvedByMemberId: _duty.approvedByMemberId,
        approvedAt: _duty.approvedAt,
      );
    });
    MockDuties.update(_duty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(accept ? 'Assignment accepted' : 'Assignment declined')),
    );
  }

  /// Real-time check-in — any member (whether formally assigned or
  /// not, for emergency duties) marks themselves present at the duty
  /// site with a timestamp. If they weren't already in the duty's
  /// member list (e.g. self-joining an Emergency Duty), they're
  /// added now with an auto-accepted assignment. Location
  /// verification is held for Module 16/19 — this is presence-intent
  /// only for now.
  void _checkIn() {
    final auth = context.read<AuthProvider>();
    final me = auth.currentMember;
    if (me == null) return;

    final alreadyInDuty = _duty.members.any((dm) => dm.memberId == me.id);
    final now = DateTime.now();

    setState(() {
      final updatedMembers = alreadyInDuty
          ? _duty.members.map((dm) {
              if (dm.memberId != me.id) return dm;
              return DutyMember(
                memberId: dm.memberId,
                roleInDuty: dm.roleInDuty,
                positionId: dm.positionId,
                status: dm.status,
                rejectionReason: dm.rejectionReason,
                checkedInAt: now,
                assignedAt: dm.assignedAt,
                respondedAt: dm.respondedAt,
              );
            }).toList()
          : [
              ..._duty.members,
              DutyMember(
                memberId: me.id,
                roleInDuty: DutyRoleInDuty.member,
                status: DutyAssignmentStatus.accepted,
                checkedInAt: now,
                assignedAt: now,
                respondedAt: now,
              ),
            ];

      _duty = Duty(
        id: _duty.id, title: _duty.title, titleMm: _duty.titleMm,
        type: _duty.type, scale: _duty.scale, date: _duty.date,
        startHour: _duty.startHour, startMinute: _duty.startMinute,
        endHour: _duty.endHour, endMinute: _duty.endMinute,
        location: _duty.location,
        members: updatedMembers,
        status: _duty.status,
        description: _duty.description,
        isEvent: _duty.isEvent,
        eventId: _duty.eventId,
        createdByMemberId: _duty.createdByMemberId,
        isDisasterLevel: _duty.isDisasterLevel,
        escalatedToDutyId: _duty.escalatedToDutyId,
        originatingEmergencyDutyId: _duty.originatingEmergencyDutyId,
        isMutualAidOutsideBotahtaung: _duty.isMutualAidOutsideBotahtaung,
        report: _duty.report,
        reportSubmittedByMemberId: _duty.reportSubmittedByMemberId,
        reportSubmittedAt: _duty.reportSubmittedAt,
        approvedByMemberId: _duty.approvedByMemberId,
        approvedAt: _duty.approvedAt,
      );
    });

    MockDuties.update(_duty);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checked in')),
    );
  }

  /// Self-join an upcoming duty ahead of time (non-emergency only,
  /// gated by canJoinUpcomingDuty — must be more than 1 day before
  /// the duty starts). Adds the member as accepted, but WITHOUT a
  /// check-in timestamp — check-in itself still happens separately,
  /// at/near the duty, once they're an assigned member.
  void _joinDuty() {
    final auth = context.read<AuthProvider>();
    final me = auth.currentMember;
    if (me == null) return;

    final now = DateTime.now();

    setState(() {
      _duty = Duty(
        id: _duty.id, title: _duty.title, titleMm: _duty.titleMm,
        type: _duty.type, scale: _duty.scale, date: _duty.date,
        startHour: _duty.startHour, startMinute: _duty.startMinute,
        endHour: _duty.endHour, endMinute: _duty.endMinute,
        location: _duty.location,
        members: [
          ..._duty.members,
          DutyMember(
            memberId: me.id,
            roleInDuty: DutyRoleInDuty.member,
            status: DutyAssignmentStatus.accepted,
            assignedAt: now,
            respondedAt: now,
          ),
        ],
        status: _duty.status,
        description: _duty.description,
        isEvent: _duty.isEvent,
        eventId: _duty.eventId,
        createdByMemberId: _duty.createdByMemberId,
        isDisasterLevel: _duty.isDisasterLevel,
        escalatedToDutyId: _duty.escalatedToDutyId,
        originatingEmergencyDutyId: _duty.originatingEmergencyDutyId,
        isMutualAidOutsideBotahtaung: _duty.isMutualAidOutsideBotahtaung,
        report: _duty.report,
        reportSubmittedByMemberId: _duty.reportSubmittedByMemberId,
        reportSubmittedAt: _duty.reportSubmittedAt,
        approvedByMemberId: _duty.approvedByMemberId,
        approvedAt: _duty.approvedAt,
      );
    });

    MockDuties.update(_duty);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Joined duty — you can check in once it starts')),
    );
  }

  void _rebuildDuty({
    String? report,
    String? reportSubmittedByMemberId,
    DateTime? reportSubmittedAt,
    String? approvedByMemberId,
    DateTime? approvedAt,
    String? escalatedToDutyId,
  }) {
    _duty = Duty(
      id: _duty.id, title: _duty.title, titleMm: _duty.titleMm,
      type: _duty.type, scale: _duty.scale, date: _duty.date,
      startHour: _duty.startHour, startMinute: _duty.startMinute,
      endHour: _duty.endHour, endMinute: _duty.endMinute,
      location: _duty.location, members: _duty.members,
      status: _duty.status, description: _duty.description,
      isEvent: _duty.isEvent, eventId: _duty.eventId,
      createdByMemberId: _duty.createdByMemberId,
      isDisasterLevel: _duty.isDisasterLevel,
      escalatedToDutyId: escalatedToDutyId ?? _duty.escalatedToDutyId,
      originatingEmergencyDutyId: _duty.originatingEmergencyDutyId,
      isMutualAidOutsideBotahtaung: _duty.isMutualAidOutsideBotahtaung,
      report: report ?? _duty.report,
      reportSubmittedByMemberId: reportSubmittedByMemberId ?? _duty.reportSubmittedByMemberId,
      reportSubmittedAt: reportSubmittedAt ?? _duty.reportSubmittedAt,
      approvedByMemberId: approvedByMemberId ?? _duty.approvedByMemberId,
      approvedAt: approvedAt ?? _duty.approvedAt,
    );
  }

  Future<void> _submitReport() async {
    final ctrl = TextEditingController(text: _duty.report ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Submit After-Action Report'),
        content: TextField(
          controller: ctrl,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'What happened, who responded, outcome...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;

    final me = context.read<AuthProvider>().currentMember;
    setState(() {
      _rebuildDuty(
        report: result,
        reportSubmittedByMemberId: me?.id,
        reportSubmittedAt: DateTime.now(),
      );
    });
    MockDuties.update(_duty);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted — awaiting approval')),
    );
  }

  void _approveReport() {
    final me = context.read<AuthProvider>().currentMember;
    setState(() {
      _rebuildDuty(approvedByMemberId: me?.id, approvedAt: DateTime.now());
    });
    MockDuties.update(_duty);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report approved')),
    );
  }

  void _escalateToLargeScale() {
    final now = DateTime.now();
    final newDutyId = 'duty_largescale_${now.microsecondsSinceEpoch}';

    final largeScaleDuty = Duty(
      id: newDutyId,
      title: '${_duty.title} — Large Scale Operation',
      titleMm: '',
      type: DutyType.disaster,
      scale: DutyScale.largeScale,
      date: now,
      startHour: now.hour,
      startMinute: now.minute,
      location: _duty.location,
      members: _duty.members,
      status: DutyStatus.upcoming,
      description: 'Escalated from Emergency Duty: ${_duty.title}',
      originatingEmergencyDutyId: _duty.id,
    );
    MockDuties.add(largeScaleDuty);

    setState(() {
      _rebuildDuty(escalatedToDutyId: newDutyId);
    });
    MockDuties.update(_duty);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Escalated to Large Scale operation')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DutyDetailScreen(dutyId: newDutyId)),
    );
  }

  void _markComplete() {
    setState(() {
      _duty = _copyWithStatus(_duty, DutyStatus.completed);
    });
    MockDuties.update(_duty);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duty marked as completed')),
    );
  }

  void _cancelDuty() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Duty'),
        content: const Text('Are you sure you want to cancel this duty? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _duty = _copyWithStatus(_duty, DutyStatus.cancelled);
              });
              MockDuties.update(_duty);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Duty cancelled')),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  /// Deletes the duty record entirely — distinct from cancel, which
  /// keeps a cancelled record in the list. Wiring to MockDuties /
  /// Supabase removal happens when the data layer is connected
  /// (Module 16); for now this confirms the permission gate and UI
  /// flow, then returns to the duties list.
  void _deleteDuty() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Duty'),
        content: const Text(
          'Are you sure you want to permanently delete this duty? '
          'Unlike cancelling, this removes the record entirely and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext); // close dialog only

              MockDuties.all.removeWhere((d) => d.id == _duty.id);

              // Capture the Navigator and show the snackbar BEFORE
              // popping this screen — Navigator.pop() unmounts
              // DutyDetailScreen, and using its `context` afterward
              // (for ScaffoldMessenger) throws "widget has been
              // unmounted". Grabbing NavigatorState first lets us
              // pop safely after the context-dependent work is done.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Duty deleted')),
              );
              Navigator.of(context).pop(); // return to duties list
            },
            child: const Text('Yes, Delete'),
          ),
        ],
      ),
    );
  }

  Duty _copyWithStatus(Duty duty, DutyStatus status) {
    return Duty(
      id: duty.id, title: duty.title, titleMm: duty.titleMm,
      type: duty.type, scale: duty.scale, date: duty.date,
      startHour: duty.startHour, startMinute: duty.startMinute,
      endHour: duty.endHour, endMinute: duty.endMinute,
      location: duty.location, members: duty.members,
      status: status, description: duty.description,
      isEvent: duty.isEvent, eventId: duty.eventId,
      createdByMemberId: duty.createdByMemberId,
      isDisasterLevel: duty.isDisasterLevel,
      escalatedToDutyId: duty.escalatedToDutyId,
      originatingEmergencyDutyId: duty.originatingEmergencyDutyId,
      isMutualAidOutsideBotahtaung: duty.isMutualAidOutsideBotahtaung,
      report: duty.report,
      reportSubmittedByMemberId: duty.reportSubmittedByMemberId,
      reportSubmittedAt: duty.reportSubmittedAt,
      approvedByMemberId: duty.approvedByMemberId,
      approvedAt: duty.approvedAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.currentMember;
    final canRespond = me != null && auth.canRespondToDutyAssignment(_duty);
    final canEdit = auth.canEditDuty(_duty);
    final canComplete = auth.canMarkDutyComplete(_duty) &&
        (_duty.status == DutyStatus.upcoming || _duty.status == DutyStatus.ongoing);
    final canCancel = auth.canCancelDuty(_duty) &&
        (_duty.status == DutyStatus.upcoming || _duty.status == DutyStatus.ongoing);
    final canDelete = auth.canDeleteDuty(_duty);
    final myDutyMember = me != null
        ? _duty.members.where((dm) => dm.memberId == me.id).firstOrNull
        : null;
    final alreadyCheckedIn = myDutyMember?.checkedInAt != null;
    final canCheckIn = me != null &&
        auth.canCheckIn(_duty) &&
        !alreadyCheckedIn &&
        (_duty.status == DutyStatus.upcoming || _duty.status == DutyStatus.ongoing);
    final canJoinDuty = me != null && auth.canJoinUpcomingDuty(_duty);
    final isEmergencyDuty = _duty.type == DutyType.emergency;
    final joinWindowClosed = me != null &&
        !isEmergencyDuty &&
        myDutyMember == null &&
        !canJoinDuty &&
        (_duty.status == DutyStatus.upcoming || _duty.status == DutyStatus.ongoing);
    final canSubmitReport = isEmergencyDuty &&
        me != null &&
        myDutyMember != null &&
        _duty.status == DutyStatus.completed &&
        !_duty.isReportApproved;
    final canApproveReport = isEmergencyDuty &&
        auth.canApproveEmergencyDutyReport &&
        _duty.report != null &&
        !_duty.isReportApproved;
    final canEscalate = isEmergencyDuty &&
        _duty.isEligibleForEscalation &&
        auth.canEscalateToLargeScale(_duty);

    return Scaffold(
      appBar: AppBar(
        title: Text(_duty.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DutyFormScreen(duty: _duty)),
              ),
            ),
          if (canCancel || canComplete || canDelete)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'complete') _markComplete();
                if (value == 'cancel') _cancelDuty();
                if (value == 'delete') _deleteDuty();
              },
              itemBuilder: (context) => [
                if (canComplete)
                  const PopupMenuItem(value: 'complete', child: Text('Mark Complete')),
                if (canCancel)
                  const PopupMenuItem(value: 'cancel', child: Text('Cancel Duty')),
                if (canDelete)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Duty', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          if (canJoinDuty) _buildJoinDutyCard(),
          if (canJoinDuty) const SizedBox(height: 16),
          if (joinWindowClosed) _buildJoinWindowClosedCard(),
          if (joinWindowClosed) const SizedBox(height: 16),
          if (canCheckIn || alreadyCheckedIn) _buildCheckInCard(canCheckIn, alreadyCheckedIn, myDutyMember),
          if (canCheckIn || alreadyCheckedIn) const SizedBox(height: 16),
          if (isEmergencyDuty && (canSubmitReport || _duty.report != null)) _buildEmergencyReportCard(canSubmitReport, canApproveReport),
          if (isEmergencyDuty && (canSubmitReport || _duty.report != null)) const SizedBox(height: 16),
          if (canEscalate) _buildEscalationCard(),
          if (canEscalate) const SizedBox(height: 16),
          if (canRespond) _buildResponseCard(),
          if (canRespond) const SizedBox(height: 16),
          _buildMembersCard(auth),
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
                Expanded(
                  child: Text(_duty.title, style: AppTextStyles.headingMedium),
                ),
                _statusChip(),
              ],
            ),
            if (_duty.titleMm.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(_duty.titleMm, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700)),
            ],
            const Divider(height: 24),
            _infoRow(Icons.category_outlined, 'Type', _typeLabel(_duty.type)),
            _infoRow(Icons.scale_outlined, 'Scale',
                _duty.scale == DutyScale.largeScale ? 'Large Scale' : 'Regular'),
            _infoRow(Icons.calendar_today_outlined, 'Date', AppFormatters.date(_duty.date)),
            _infoRow(
              Icons.access_time,
              'Time',
              _duty.endHour != null
                  ? '${_duty.startTimeDisplay} – ${_duty.endHour!.toString().padLeft(2, '0')}:${_duty.endMinute!.toString().padLeft(2, '0')}'
                  : _duty.startTimeDisplay,
            ),
            _infoRow(Icons.location_on_outlined, 'Location', _duty.location),
            if (_duty.description != null && _duty.description!.isNotEmpty)
              _infoRow(Icons.notes_outlined, 'Notes', _duty.description!),
            if (_duty.isEvent && _duty.eventId != null && MockEvents.findById(_duty.eventId!) != null) ...[
              const Divider(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailScreen(eventId: _duty.eventId!),
                  ),
                ),
                icon: const Icon(Icons.map_outlined),
                label: const Text('View Event Positions & Map'),
              ),
            ],
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
    final color = switch (_duty.status) {
      DutyStatus.upcoming => Colors.blue,
      DutyStatus.ongoing => Colors.green,
      DutyStatus.completed => Colors.grey,
      DutyStatus.cancelled => Colors.red,
    };
    final label = switch (_duty.status) {
      DutyStatus.upcoming => 'UPCOMING',
      DutyStatus.ongoing => 'ONGOING',
      DutyStatus.completed => 'COMPLETED',
      DutyStatus.cancelled => 'CANCELLED',
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  String _typeLabel(DutyType type) => switch (type) {
        DutyType.firstAid => 'First Aid',
        DutyType.bloodDonation => 'Blood Donation',
        DutyType.training => 'Training',
        DutyType.patrol => 'Patrol',
        DutyType.eventMedical => 'Event Medical',
        DutyType.disaster => 'Disaster Response',
        DutyType.administrative => 'Administrative',
        DutyType.emergency => 'Emergency',
        DutyType.other => 'Other',
      };

  Widget _buildEmergencyReportCard(bool canSubmitReport, bool canApproveReport) {
    final submitter = _duty.reportSubmittedByMemberId != null
        ? MockMembers.findById(_duty.reportSubmittedByMemberId!)
        : null;
    final approver = _duty.approvedByMemberId != null
        ? MockMembers.findById(_duty.approvedByMemberId!)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('After-Action Report', style: AppTextStyles.headingSmall)),
                if (_duty.isReportApproved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('APPROVED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                  )
                else if (_duty.report != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('PENDING APPROVAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ),
              ],
            ),
            if (_duty.report != null) ...[
              const SizedBox(height: 8),
              Text(_duty.report!, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 6),
              if (submitter != null)
                Text('Submitted by ${submitter.nameEn}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
              if (approver != null)
                Text('Approved by ${approver.nameEn}', style: AppTextStyles.labelSmall.copyWith(color: Colors.green)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (canSubmitReport)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitReport,
                      child: Text(_duty.report == null ? 'Submit Report' : 'Edit Report'),
                    ),
                  ),
                if (canSubmitReport && canApproveReport) const SizedBox(width: 12),
                if (canApproveReport)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _approveReport,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Approve Report'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEscalationCard() {
    return Card(
      color: Colors.red.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text('Disaster-Level Response', style: AppTextStyles.headingSmall.copyWith(color: Colors.red))),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'This emergency is flagged disaster-level and within Botahtaung. '
              'If the situation requires a coordinated multi-section response, escalate it to a Large Scale operation.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _escalateToLargeScale,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size.fromHeight(44)),
              icon: const Icon(Icons.trending_up, size: 18),
              label: const Text('Escalate to Large Scale'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinWindowClosedCard() {
    return Card(
      color: AppColors.grey50.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, size: 18, color: AppColors.grey500),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Joining has closed for this duty — it\'s within 1 day of starting. '
                'Contact your Commander/Officer if you need to be added.',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinDutyCard() {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Want to join this duty?', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    'You\'re not currently assigned. You can join up until 1 day before it starts.',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _joinDuty,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Join Duty'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInCard(bool canCheckIn, bool alreadyCheckedIn, DutyMember? myDutyMember) {
    if (alreadyCheckedIn) {
      final time = myDutyMember!.checkedInAt!;
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      return Card(
        color: Colors.green.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text('You checked in at $timeStr on ${AppFormatters.date(time)}.'),
              ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('At the duty site?', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    'Check in to confirm you\'ve arrived.',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _checkIn,
              icon: const Icon(Icons.location_on_outlined, size: 18),
              label: const Text('Check In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard() {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have been assigned to this duty', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _respondToDuty(false),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToDuty(true),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersCard(AuthProvider auth) {
    final checkedInCount = _duty.members.where((dm) => dm.checkedInAt != null).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Assigned Members (${_duty.members.length})', style: AppTextStyles.headingSmall),
                ),
                if (checkedInCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$checkedInCount checked in',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ..._duty.members.map((dm) => _memberRow(dm)),
          ],
        ),
      ),
    );
  }

  Widget _memberRow(DutyMember dm) {
    final member = MockMembers.findById(dm.memberId);
    final name = member?.nameEn ?? dm.memberId;
    final rank = member?.rankNameEn ?? '';

    final (statusColor, statusLabel) = switch (dm.status) {
      DutyAssignmentStatus.pending => (Colors.orange, 'Pending'),
      DutyAssignmentStatus.accepted => (Colors.green, 'Accepted'),
      DutyAssignmentStatus.rejected => (Colors.red, 'Declined'),
      DutyAssignmentStatus.completed => (Colors.grey, 'Completed'),
    };

    final roleLabel = switch (dm.roleInDuty) {
      DutyRoleInDuty.commander => 'Commander',
      DutyRoleInDuty.officer => 'Officer',
      DutyRoleInDuty.member => 'Member',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: member != null ? AvatarColorGen.fromString(member.id) : AppColors.grey500,
            child: Text(
              member?.initials ?? '?',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium),
                Text('$rank · $roleLabel', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
                if (dm.checkedInAt != null)
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 12, color: Colors.green),
                      const SizedBox(width: 3),
                      Text(
                        'Checked in ${dm.checkedInAt!.hour.toString().padLeft(2, '0')}:${dm.checkedInAt!.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.green),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
          ),
        ],
      ),
    );
  }
}