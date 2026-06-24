import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/utils/permission_service.dart';
import '../auth/auth_provider.dart';

class MeetingFormScreen extends StatefulWidget {
  final Meeting? meeting; // null = create new, non-null = edit
  const MeetingFormScreen({super.key, this.meeting});

  @override
  State<MeetingFormScreen> createState() => _MeetingFormScreenState();
}

class _MeetingFormScreenState extends State<MeetingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEdit => widget.meeting != null;

  late final _titleCtrl = TextEditingController(text: widget.meeting?.title ?? '');
  late final _titleMmCtrl = TextEditingController(text: widget.meeting?.titleMm ?? '');
  late final _locationCtrl = TextEditingController(text: widget.meeting?.location ?? '');

  MeetingType _type = MeetingType.general;
  DateTime? _date;
  TimeOfDay? _time;
  MemberRank? _minimumRank;
  int? _targetCompanyNo; // null = brigade-wide

  // memberId -> manually added/removed on top of the rank-based list
  final Set<String> _manuallyAddedIds = {};
  final Set<String> _manuallyRemovedIds = {};

  final List<AgendaItem> _agendaItems = [];
  List<MeetingTask> _pulledForwardTasks = [];

  @override
  void initState() {
    super.initState();
    if (widget.meeting != null) {
      final m = widget.meeting!;
      _type = m.type;
      _date = m.date;
      _time = TimeOfDay(hour: m.timeHour, minute: m.timeMinute);
      _minimumRank = m.minimumRank;
      _manuallyAddedIds.addAll(m.invitedMemberIds);
      _agendaItems.addAll(m.agendaItems);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _titleMmCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _date = picked);
      _pullForwardPendingTasks();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  /// Auto-pulls forward pending (incomplete) tasks from the most
  /// recent meeting of the same type, so they don't get forgotten —
  /// per the locked requirement that each new meeting's agenda
  /// surfaces unfinished business from last time.
  void _pullForwardPendingTasks() {
    if (_date == null) return;
    final previous = MockMeetings.mostRecentOfType(_type, _date!);
    setState(() {
      _pulledForwardTasks = previous?.pendingTasks ?? [];
    });
  }

  /// Rank-based auto-invite list: everyone at or above `_minimumRank`
  /// within scope (brigade-wide if creator is Brigade Office /
  /// targetCompanyNo is null, otherwise that company only) — plus any
  /// manually added members, minus any manually removed ones.
  Set<String> _computeInvitedIds(AuthProvider auth) {
    final ids = <String>{};

    if (_minimumRank != null) {
      final minOrder = RankHelper.rankOrder(_minimumRank!);
      for (final m in MockMembers.all) {
        if (m.nameEn.isEmpty) continue; // vacant position
        if (RankHelper.rankOrder(m.rank) > minOrder) continue; // below minimum
        if (_targetCompanyNo != null && m.companyNo != _targetCompanyNo) continue;
        ids.add(m.id);
      }
    }

    ids.addAll(_manuallyAddedIds);
    ids.removeAll(_manuallyRemovedIds);
    return ids;
  }

  Future<void> _openManualMemberPicker(AuthProvider auth) async {
    final invited = _computeInvitedIds(auth);
    final candidates = MockMembers.all.where((m) => m.nameEn.isNotEmpty).toList()
      ..sort((a, b) => a.nameEn.compareTo(b.nameEn));

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final tempSelected = Set<String>.from(invited);
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
                          Expanded(child: Text('Invite Members', style: AppTextStyles.headingSmall)),
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
                          final isFromRank = _minimumRank != null &&
                              RankHelper.rankOrder(m.rank) <= RankHelper.rankOrder(_minimumRank!) &&
                              (_targetCompanyNo == null || m.companyNo == _targetCompanyNo);
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
                            subtitle: Text(isFromRank ? '${m.rankNameEn} · auto-invited by rank' : m.rankNameEn),
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
      setState(() {
        final rankBased = _minimumRank == null
            ? <String>{}
            : MockMembers.all
                .where((m) =>
                    m.nameEn.isNotEmpty &&
                    RankHelper.rankOrder(m.rank) <= RankHelper.rankOrder(_minimumRank!) &&
                    (_targetCompanyNo == null || m.companyNo == _targetCompanyNo))
                .map((m) => m.id)
                .toSet();
        _manuallyAddedIds
          ..clear()
          ..addAll(result.difference(rankBased));
        _manuallyRemovedIds
          ..clear()
          ..addAll(rankBased.difference(result));
      });
    }
  }

  void _addAgendaItem() {
    setState(() {
      _agendaItems.add(AgendaItem(
        id: 'agenda_${DateTime.now().microsecondsSinceEpoch}',
        meetingId: widget.meeting?.id ?? '',
        order: _agendaItems.length + 1,
        topic: '',
      ));
    });
  }

  void _removeAgendaItem(int index) {
    setState(() => _agendaItems.removeAt(index));
  }

  void _save(AuthProvider auth) {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set the date and time')),
      );
      return;
    }
    if (!auth.canCreateMeetingForUnit(_targetCompanyNo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to create a meeting for this unit')),
      );
      return;
    }

    final invitedIds = _computeInvitedIds(auth).toList();
    if (invitedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please invite at least one member (set a minimum rank or add manually)')),
      );
      return;
    }

    final meetingId = widget.meeting?.id ?? 'meeting_${DateTime.now().microsecondsSinceEpoch}';
    final meetingYear = _date!.year;
    final meetingNumber = widget.meeting?.meetingNumber ??
        MockMeetings.nextMeetingNumber(_type, meetingYear);

    // Carry forward any still-pending tasks from the previous meeting
    // of the same type into this meeting's task list.
    final tasks = [
      ..._pulledForwardTasks,
    ];

    final meeting = Meeting(
      id: meetingId,
      title: _titleCtrl.text.trim(),
      titleMm: _titleMmCtrl.text.trim(),
      type: _type,
      date: _date!,
      timeHour: _time!.hour,
      timeMinute: _time!.minute,
      location: _locationCtrl.text.trim(),
      invitedMemberIds: invitedIds,
      attendedMemberIds: widget.meeting?.attendedMemberIds ?? const [],
      excusedMemberIds: widget.meeting?.excusedMemberIds ?? const [],
      absentMemberIds: widget.meeting?.absentMemberIds ?? const [],
      minimumRank: _minimumRank,
      status: widget.meeting?.status ?? MeetingStatus.scheduled,
      tasks: tasks,
      createdAt: widget.meeting?.createdAt ?? DateTime.now(),
      meetingNumber: meetingNumber,
      meetingYear: meetingYear,
      organizerMemberId: widget.meeting?.organizerMemberId ?? auth.currentMember?.id,
      recorderMemberId: widget.meeting?.recorderMemberId,
      agendaItems: _agendaItems
          .where((a) => a.topic.trim().isNotEmpty)
          .toList(),
    );

    if (_isEdit) {
      MockMeetings.update(meeting);
    } else {
      MockMeetings.add(meeting);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Meeting updated' : 'Meeting scheduled (No. $meetingNumber/$meetingYear)')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.currentMember;
    final isBrigadeWide = me != null &&
        (me.unitType == UnitType.brigadeOffice || PermissionService.hasAdminOrMasterAccess(me));
    final invitedCount = _computeInvitedIds(auth).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Meeting' : 'Schedule Meeting'),
        actions: [
          TextButton(
            onPressed: () => _save(auth),
            child: const Text('SAVE', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard('Meeting Details', [
              _textField(_titleCtrl, 'Title (English)', required: true),
              _textField(_titleMmCtrl, 'Title (Myanmar)'),
              _typeDropdown(),
              if (isBrigadeWide) _unitScopeDropdown(),
            ]),
            _sectionCard('Schedule', [
              _dateField('Date', _date, _pickDate),
              _timeField('Time', _time, _pickTime),
              _textField(_locationCtrl, 'Location', required: true),
            ]),
            _sectionCard('Invitation', [
              _minimumRankDropdown(),
              const SizedBox(height: 8),
              Text(
                'Everyone at or above this rank in scope is auto-invited. '
                'Add or remove individuals below.',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _openManualMemberPicker(auth),
                icon: const Icon(Icons.person_add_outlined),
                label: Text('Manage Invitees ($invitedCount invited)'),
              ),
            ]),
            if (_pulledForwardTasks.isNotEmpty)
              _sectionCard('Pending Tasks (carried forward)', [
                Text(
                  'From the previous ${_typeLabel(_type)} meeting — still incomplete:',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                ),
                const SizedBox(height: 8),
                ..._pulledForwardTasks.map((t) {
                  final m = MockMembers.findById(t.assignedMemberId);
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.pending_actions, size: 18, color: Colors.orange),
                    title: Text(t.title, style: AppTextStyles.bodySmall),
                    subtitle: Text('Assigned to ${m?.nameEn ?? t.assignedMemberId}', style: AppTextStyles.labelSmall),
                  );
                }),
              ]),
            _sectionCard('Agenda', [
              ..._agendaItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: item.topic,
                          decoration: InputDecoration(
                            labelText: 'Agenda item ${index + 1}',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() {
                            _agendaItems[index] = AgendaItem(
                              id: item.id, meetingId: item.meetingId, order: item.order,
                              topic: v, presenterMemberId: item.presenterMemberId,
                              discussion: item.discussion, decision: item.decision,
                            );
                          }),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _removeAgendaItem(index),
                      ),
                    ],
                  ),
                );
              }),
              OutlinedButton.icon(
                onPressed: _addAgendaItem,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Agenda Item'),
              ),
            ]),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _save(auth),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(_isEdit ? 'Save Changes' : 'Schedule Meeting'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headingSmall),
              const SizedBox(height: 8),
              ...children.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: c,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String label, {bool required = false}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _dateField(String label, DateTime? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text(value == null ? 'Select date' : '${value.day}/${value.month}/${value.year}'),
      ),
    );
  }

  Widget _timeField(String label, TimeOfDay? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text(value == null ? 'Select time' : value.format(context)),
      ),
    );
  }

  Widget _typeDropdown() {
    return DropdownButtonFormField<MeetingType>(
      initialValue: _type,
      decoration: const InputDecoration(labelText: 'Meeting Type', border: OutlineInputBorder()),
      items: MeetingType.values
          .map((t) => DropdownMenuItem(value: t, child: Text(_typeLabel(t))))
          .toList(),
      onChanged: (v) {
        setState(() => _type = v!);
        _pullForwardPendingTasks();
      },
    );
  }

  String _typeLabel(MeetingType type) => switch (type) {
        MeetingType.general => 'General',
        MeetingType.officer => 'Officer',
        MeetingType.committee => 'Committee',
        MeetingType.investigation => 'Investigation',
        MeetingType.youthLeaders => 'Youth Leaders',
        MeetingType.youthGroup => 'Youth Group',
        MeetingType.custom => 'Custom',
      };

  Widget _unitScopeDropdown() {
    return DropdownButtonFormField<int?>(
      initialValue: _targetCompanyNo,
      decoration: const InputDecoration(labelText: 'Unit Scope', border: OutlineInputBorder()),
      items: const [
        DropdownMenuItem(value: null, child: Text('Brigade-wide')),
        DropdownMenuItem(value: 1, child: Text('Company 1')),
        DropdownMenuItem(value: 2, child: Text('Company 2')),
        DropdownMenuItem(value: 3, child: Text('Company 3')),
        DropdownMenuItem(value: 4, child: Text('Company 4')),
      ],
      onChanged: (v) => setState(() => _targetCompanyNo = v),
    );
  }

  Widget _minimumRankDropdown() {
    return DropdownButtonFormField<MemberRank?>(
      initialValue: _minimumRank,
      decoration: const InputDecoration(
        labelText: 'Minimum Rank (auto-invite)',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('None — manual selection only')),
        ...MemberRank.values.map((r) => DropdownMenuItem(value: r, child: Text(RankHelper.nameEn(r)))),
      ],
      onChanged: (v) => setState(() => _minimumRank = v),
    );
  }
}
