import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';

/// Lets a Company Commander/Deputy submit a list of members
/// nominated to attend a future class, linked to the Meeting +
/// AgendaItem/Decision that authorized it. Master Access sets the
/// submission deadline. If submitted on time, the nominated members
/// auto-enroll the moment a class is created with a matching title.
class NominationListFormScreen extends StatefulWidget {
  const NominationListFormScreen({super.key});

  @override
  State<NominationListFormScreen> createState() => _NominationListFormScreenState();
}

class _NominationListFormScreenState extends State<NominationListFormScreen> {
  late final _classTitleCtrl = TextEditingController();
  String? _selectedMeetingId;
  String? _selectedAgendaItemId;
  final Set<String> _nominatedMemberIds = {};
  DateTime? _deadline;

  @override
  void dispose() {
    _classTitleCtrl.dispose();
    super.dispose();
  }

  Meeting? get _selectedMeeting =>
      _selectedMeetingId != null ? MockMeetings.findById(_selectedMeetingId!) : null;

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Submission deadline',
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _openMemberPicker(int companyNo) async {
    final candidates = MockMembers.all
        .where((m) => m.nameEn.isNotEmpty && m.companyNo == companyNo)
        .toList()
      ..sort((a, b) => a.nameEn.compareTo(b.nameEn));

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final tempSelected = Set<String>.from(_nominatedMemberIds);
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
                          Expanded(child: Text('Nominate Members', style: AppTextStyles.headingSmall)),
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
                            subtitle: Text(m.rankNameEn),
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
        _nominatedMemberIds.clear();
        _nominatedMemberIds.addAll(result);
      });
    }
  }

  void _submit(AuthProvider auth) {
    final me = auth.currentMember;
    if (me == null) return;

    if (_selectedMeetingId == null || _selectedAgendaItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please link the meeting and decision that authorized this')),
      );
      return;
    }
    if (_classTitleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the exact planned class title')),
      );
      return;
    }
    if (_nominatedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please nominate at least one member')),
      );
      return;
    }
    if (me.companyNo == null || !auth.canSubmitNominationList(me.companyNo!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to submit a nomination list')),
      );
      return;
    }

    MockNominationLists.add(ClassNominationList(
      id: 'nom_${DateTime.now().microsecondsSinceEpoch}',
      linkedMeetingId: _selectedMeetingId!,
      linkedAgendaItemId: _selectedAgendaItemId!,
      plannedClassTitle: _classTitleCtrl.text.trim(),
      companyNo: me.companyNo!,
      nominatedMemberIds: _nominatedMemberIds.toList(),
      submittedByMemberId: me.id,
      submittedAt: DateTime.now(),
      submissionDeadline: _deadline,
      status: NominationListStatus.pending,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nomination list submitted')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canSetDeadline = auth.canSetNominationDeadline;
    final meetingsWithDecisions = MockMeetings.all
        .where((m) => m.agendaItems.any((a) => a.hasDecision))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Nomination List'),
        actions: [
          TextButton(
            onPressed: () => _submit(auth),
            child: const Text('SUBMIT', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Link the meeting decision that authorized this, name the exact planned class, '
            'and nominate eligible members from your company.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedMeetingId,
            decoration: const InputDecoration(labelText: 'Meeting', border: OutlineInputBorder()),
            items: meetingsWithDecisions
                .map((m) => DropdownMenuItem(
                      value: m.id,
                      child: Text('${m.title}${m.meetingNumberDisplay != null ? ' (No. ${m.meetingNumberDisplay})' : ''}'),
                    ))
                .toList(),
            onChanged: (v) => setState(() {
              _selectedMeetingId = v;
              _selectedAgendaItemId = null;
            }),
          ),
          const SizedBox(height: 12),

          if (_selectedMeeting != null)
            DropdownButtonFormField<String>(
              initialValue: _selectedAgendaItemId,
              decoration: const InputDecoration(labelText: 'Decision', border: OutlineInputBorder()),
              items: _selectedMeeting!.agendaItems
                  .where((a) => a.hasDecision)
                  .map((a) => DropdownMenuItem(value: a.id, child: Text(a.topic, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedAgendaItemId = v),
            ),
          const SizedBox(height: 12),

          TextField(
            controller: _classTitleCtrl,
            decoration: const InputDecoration(
              labelText: 'Planned Class Title (must match exactly when created)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: auth.currentMember?.companyNo == null
                      ? null
                      : () => _openMemberPicker(auth.currentMember!.companyNo!),
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: Text('Nominate Members (${_nominatedMemberIds.length})'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey50.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.event_busy_outlined, color: AppColors.grey700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _deadline == null
                        ? 'No deadline set yet — only Master Access can set this'
                        : 'Deadline: ${AppFormatters.date(_deadline!)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                if (canSetDeadline)
                  TextButton(onPressed: _pickDeadline, child: const Text('Set')),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => _submit(auth),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Submit Nomination List'),
          ),
        ],
      ),
    );
  }
}
