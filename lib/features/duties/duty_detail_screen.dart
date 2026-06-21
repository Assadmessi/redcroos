import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';
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
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(accept ? 'Assignment accepted' : 'Assignment declined')),
    );
  }

  void _markComplete() {
    setState(() {
      _duty = _copyWithStatus(_duty, DutyStatus.completed);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duty marked as completed')),
    );
  }

  void _cancelDuty() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Duty'),
        content: const Text('Are you sure you want to cancel this duty? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _duty = _copyWithStatus(_duty, DutyStatus.cancelled);
              });
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
      builder: (_) => AlertDialog(
        title: const Text('Delete Duty'),
        content: const Text(
          'Are you sure you want to permanently delete this duty? '
          'Unlike cancelling, this removes the record entirely and cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // return to duties list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Duty deleted')),
              );
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
        DutyType.other => 'Other',
      };

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigned Members (${_duty.members.length})', style: AppTextStyles.headingSmall),
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