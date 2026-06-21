import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/utils/permission_service.dart';
import '../auth/auth_provider.dart';

class DutyFormScreen extends StatefulWidget {
  final Duty? duty; // null = create new, non-null = edit
  const DutyFormScreen({super.key, this.duty});

  @override
  State<DutyFormScreen> createState() => _DutyFormScreenState();
}

class _DutyFormScreenState extends State<DutyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEdit => widget.duty != null;

  late final _titleCtrl = TextEditingController(text: widget.duty?.title ?? '');
  late final _titleMmCtrl = TextEditingController(text: widget.duty?.titleMm ?? '');
  late final _locationCtrl = TextEditingController(text: widget.duty?.location ?? '');
  late final _descriptionCtrl = TextEditingController(text: widget.duty?.description ?? '');

  DutyType _type = DutyType.firstAid;
  DutyScale _scale = DutyScale.regular;
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // memberId -> selected role for this duty
  final Map<String, DutyRoleInDuty> _selectedMembers = {};

  @override
  void initState() {
    super.initState();
    if (widget.duty != null) {
      final d = widget.duty!;
      _type = d.type;
      _scale = d.scale;
      _date = d.date;
      _startTime = TimeOfDay(hour: d.startHour, minute: d.startMinute);
      if (d.endHour != null && d.endMinute != null) {
        _endTime = TimeOfDay(hour: d.endHour!, minute: d.endMinute!);
      }
      for (final dm in d.members) {
        _selectedMembers[dm.memberId] = dm.roleInDuty;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _titleMmCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? _startTime : _endTime) ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _openMemberPicker(AuthProvider auth) async {
    final me = auth.currentMember;
    if (me == null) return;

    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set the duty date first, so we can check who is available')),
      );
      return;
    }

    final result = await showModalBottomSheet<Map<String, DutyRoleInDuty>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _MemberPickerSheet(
        dutyDate: _date!,
        initialSelection: _selectedMembers,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMembers.clear();
        _selectedMembers.addAll(result);
      });
    }
  }

  String _roleLabel(DutyRoleInDuty r) => switch (r) {
        DutyRoleInDuty.commander => 'Commander',
        DutyRoleInDuty.officer => 'Officer',
        DutyRoleInDuty.member => 'Member',
      };

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set the date and start time')),
      );
      return;
    }
    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign at least one member')),
      );
      return;
    }

    // Building the Duty object — wiring to MockDuties / Supabase
    // happens when the data layer is connected (Module 16). For now
    // this confirms the form captures every required field correctly.
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Duty updated' : 'Duty created')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Duty' : 'Create Duty'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard('Duty Details', [
              _textField(_titleCtrl, 'Title (English)', required: true),
              _textField(_titleMmCtrl, 'Title (Myanmar)'),
              _typeDropdown(),
              _scaleDropdown(),
            ]),
            _sectionCard('Schedule', [
              _dateField('Date', _date, () => _pickDate()),
              Row(
                children: [
                  Expanded(child: _timeField('Start Time', _startTime, () => _pickTime(isStart: true))),
                  const SizedBox(width: 12),
                  Expanded(child: _timeField('End Time (optional)', _endTime, () => _pickTime(isStart: false))),
                ],
              ),
            ]),
            _sectionCard('Location & Notes', [
              _textField(_locationCtrl, 'Location', required: true),
              _textField(_descriptionCtrl, 'Description / Notes', maxLines: 3),
            ]),
            _sectionCard('Assigned Members', [
              OutlinedButton.icon(
                onPressed: () => _openMemberPicker(auth),
                icon: const Icon(Icons.person_add_outlined),
                label: Text('Select Members (${_selectedMembers.length} selected)'),
              ),
              if (_selectedMembers.isNotEmpty) const SizedBox(height: 12),
              ..._selectedMembers.entries.map((entry) {
                final m = MockMembers.findById(entry.key);
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: AvatarColorGen.fromString(entry.key),
                    child: Text(m?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                  title: Text(m?.nameEn ?? entry.key, style: AppTextStyles.bodySmall),
                  trailing: Text(_roleLabel(entry.value), style: AppTextStyles.labelSmall),
                );
              }),
            ]),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(_isEdit ? 'Save Changes' : 'Create Duty'),
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

  Widget _textField(TextEditingController ctrl, String label,
      {bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
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
    return DropdownButtonFormField<DutyType>(
      initialValue: _type,
      decoration: const InputDecoration(labelText: 'Duty Type', border: OutlineInputBorder()),
      items: DutyType.values
          .map((t) => DropdownMenuItem(value: t, child: Text(_typeLabel(t))))
          .toList(),
      onChanged: (v) => setState(() => _type = v!),
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

  Widget _scaleDropdown() {
    return DropdownButtonFormField<DutyScale>(
      initialValue: _scale,
      decoration: const InputDecoration(labelText: 'Scale', border: OutlineInputBorder()),
      items: const [
        DropdownMenuItem(value: DutyScale.regular, child: Text('Regular')),
        DropdownMenuItem(value: DutyScale.largeScale, child: Text('Large Scale')),
      ],
      onChanged: (v) => setState(() => _scale = v!),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MEMBER PICKER SHEET
//
// Dedicated bottom sheet for assigning members to a duty. Features:
//   - Search by name/rank/memberNo
//   - Filter by company (unit-wise)
//   - Filter by rank (officers vs other ranks)
//   - Excludes members who are unavailable on the duty's date
//     (long-leave, day-specific "Not Available", or short-term
//     isAvailable=false) — they simply don't appear in the list,
//     so there's no risk of double-booking someone who's already
//     marked unavailable that day.
//   - Excludes vacant positions (empty nameEn) and members excluded
//     by isEligibleForAssignment (suspended/dismissed/long-leave).
// ═══════════════════════════════════════════════════════════════

enum _UnitFilter { all, brigadeOffice, c1, c2, c3, c4 }
enum _RankFilter { all, officers, otherRanks }

class _MemberPickerSheet extends StatefulWidget {
  final DateTime dutyDate;
  final Map<String, DutyRoleInDuty> initialSelection;

  const _MemberPickerSheet({
    required this.dutyDate,
    required this.initialSelection,
  });

  @override
  State<_MemberPickerSheet> createState() => _MemberPickerSheetState();
}

class _MemberPickerSheetState extends State<_MemberPickerSheet> {
  late Map<String, DutyRoleInDuty> _selected;
  final _searchController = TextEditingController();
  String _query = '';
  _UnitFilter _unitFilter = _UnitFilter.all;
  _RankFilter _rankFilter = _RankFilter.all;

  @override
  void initState() {
    super.initState();
    _selected = Map<String, DutyRoleInDuty>.from(widget.initialSelection);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Is `m` available to be assigned on widget.dutyDate? Checks, in
  /// order: day-specific calendar entry, long-leave status, then the
  /// short-term isAvailable flag — same precedence as Module 5's
  /// _statusOn helper.
  bool _isAvailableOnDutyDate(Member m) {
    final entries = MockAvailability.forMembersOnDate([m.id], widget.dutyDate);
    if (entries.isNotEmpty) {
      return entries.first.status == DayAvailabilityStatus.available;
    }
    if (m.status == MemberStatus.inactive && m.inactiveReason != null) {
      return false; // on leave
    }
    return m.isAvailable;
  }

  List<Member> _candidates() {
    var result = MockMembers.all.where((m) {
      if (m.nameEn.isEmpty) return false; // vacant position
      if (!PermissionService.isEligibleForAssignment(m)) return false;
      if (!_isAvailableOnDutyDate(m)) return false; // unavailable that day
      return true;
    }).toList();

    result = result.where((m) {
      switch (_unitFilter) {
        case _UnitFilter.all: return true;
        case _UnitFilter.brigadeOffice: return m.unitType == UnitType.brigadeOffice;
        case _UnitFilter.c1: return m.companyNo == 1;
        case _UnitFilter.c2: return m.companyNo == 2;
        case _UnitFilter.c3: return m.companyNo == 3;
        case _UnitFilter.c4: return m.companyNo == 4;
      }
    }).toList();

    result = result.where((m) {
      switch (_rankFilter) {
        case _RankFilter.all: return true;
        case _RankFilter.officers: return m.isOfficer;
        case _RankFilter.otherRanks: return !m.isOfficer;
      }
    }).toList();

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      result = result.where((m) {
        return m.nameEn.toLowerCase().contains(q) ||
            m.nameMm.contains(_query.trim()) ||
            m.memberNo.toLowerCase().contains(q) ||
            m.rankNameEn.toLowerCase().contains(q);
      }).toList();
    }

    result.sort((a, b) => RankHelper.rankOrder(a.rank).compareTo(RankHelper.rankOrder(b.rank)));
    return result;
  }

  String _roleLabel(DutyRoleInDuty r) => switch (r) {
        DutyRoleInDuty.commander => 'Commander',
        DutyRoleInDuty.officer => 'Officer',
        DutyRoleInDuty.member => 'Member',
      };

  String _unitLabel(_UnitFilter f) => switch (f) {
        _UnitFilter.all => 'All Units',
        _UnitFilter.brigadeOffice => 'Brigade Office',
        _UnitFilter.c1 => 'Company 1',
        _UnitFilter.c2 => 'Company 2',
        _UnitFilter.c3 => 'Company 3',
        _UnitFilter.c4 => 'Company 4',
      };

  String _rankLabel(_RankFilter f) => switch (f) {
        _RankFilter.all => 'All Ranks',
        _RankFilter.officers => 'Officers',
        _RankFilter.otherRanks => 'Other Ranks',
      };

  @override
  Widget build(BuildContext context) {
    final candidates = _candidates();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Assign Members', style: AppTextStyles.headingSmall),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    child: Text('Done (${_selected.length})'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  hintText: 'Search by name, rank, or member no...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.grey50.withValues(alpha: 0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filterChip(
                    label: _unitLabel(_unitFilter),
                    items: _UnitFilter.values,
                    labelBuilder: _unitLabel,
                    onSelected: (v) => setState(() => _unitFilter = v),
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    label: _rankLabel(_rankFilter),
                    items: _RankFilter.values,
                    labelBuilder: _rankLabel,
                    onSelected: (v) => setState(() => _rankFilter = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${candidates.length} available on ${AppFormatters.date(widget.dutyDate)}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                ),
              ),
            ),
            Expanded(
              child: candidates.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No available members match these filters for this date.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final m = candidates[index];
                        final isSelected = _selected.containsKey(m.id);
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AvatarColorGen.fromString(m.id),
                            child: Text(m.initials,
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                          title: Text(m.nameEn),
                          subtitle: Text('${m.rankNameEn} · ${m.unitDisplay}'),
                          trailing: isSelected
                              ? DropdownButton<DutyRoleInDuty>(
                                  value: _selected[m.id],
                                  items: DutyRoleInDuty.values
                                      .map((r) => DropdownMenuItem(
                                            value: r,
                                            child: Text(_roleLabel(r)),
                                          ))
                                      .toList(),
                                  onChanged: (r) => setState(() {
                                    if (r != null) _selected[m.id] = r;
                                  }),
                                )
                              : null,
                          onTap: () => setState(() {
                            if (isSelected) {
                              _selected.remove(m.id);
                            } else {
                              _selected[m.id] = DutyRoleInDuty.member;
                            }
                          }),
                          selected: isSelected,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterChip<T>({
    required String label,
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T) onSelected,
  }) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (context) => items
          .map((item) => PopupMenuItem<T>(value: item, child: Text(labelBuilder(item))))
          .toList(),
      child: Chip(
        label: Text(label, style: AppTextStyles.labelSmall),
        avatar: const Icon(Icons.arrow_drop_down, size: 16),
        backgroundColor: Colors.white,
        side: BorderSide(color: AppColors.grey50.withValues(alpha: 0.3)),
      ),
    );
  }
}