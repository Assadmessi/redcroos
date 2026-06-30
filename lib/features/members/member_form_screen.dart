import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/member_avatar.dart';

class MemberFormScreen extends StatefulWidget {
  final Member? member; // null = add new, non-null = edit
  final bool isProposal; // true = needs Company Commander approval before active
  const MemberFormScreen({super.key, this.member, this.isProposal = false});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEdit => widget.member != null;

  // ── Controllers — Section 1: Brigade Info ──
  late final _nameEnCtrl = TextEditingController(text: widget.member?.nameEn ?? '');
  late final _nameMmCtrl = TextEditingController(text: widget.member?.nameMm ?? '');
  late final _memberNoCtrl = TextEditingController(text: widget.member?.memberNo ?? '');
  MemberRank _rank = MemberRank.private;
  int? _companyNo;
  int? _platoonNo;
  int? _sectionNo;

  // ── Section 2: Personal Details ──
  DateTime? _dob;
  Gender _gender = Gender.male;
  late final _nrcCtrl = TextEditingController(text: widget.member?.nrc ?? '');
  BloodType _bloodType = BloodType.OP;
  late final _ethnicityCtrl = TextEditingController(text: widget.member?.ethnicity ?? '');
  late final _religionCtrl = TextEditingController(text: widget.member?.religion ?? '');
  late final _educationCtrl = TextEditingController(text: widget.member?.education ?? '');
  late final _heightCtrl = TextEditingController(text: widget.member?.height ?? '');
  late final _eyeColorCtrl = TextEditingController(text: widget.member?.eyeColor ?? '');
  late final _hairColorCtrl = TextEditingController(text: widget.member?.hairColor ?? '');
  late final _marksCtrl = TextEditingController(text: widget.member?.distinguishingMarks ?? '');

  // ── Section 3: Parents ──
  late final _fatherNameCtrl = TextEditingController(text: widget.member?.fatherName ?? '');
  late final _fatherOccCtrl = TextEditingController(text: widget.member?.fatherOccupation ?? '');
  late final _motherNameCtrl = TextEditingController(text: widget.member?.motherName ?? '');
  late final _motherOccCtrl = TextEditingController(text: widget.member?.motherOccupation ?? '');

  // ── Section 4: Contact ──
  late final _phoneCtrl = TextEditingController(text: widget.member?.phone ?? '');
  late final _emailCtrl = TextEditingController(text: widget.member?.email ?? '');
  late final _addressCtrl = TextEditingController(text: widget.member?.address ?? '');
  late final _emergencyContactCtrl =
      TextEditingController(text: widget.member?.emergencyContact ?? '');
  late final _emergencyPhoneCtrl =
      TextEditingController(text: widget.member?.emergencyPhone ?? '');

  // ── Section 5: Membership ──
  DateTime? _joinDate;
  DateTime? _currentRankDate;
  late final _ygnIdCtrl = TextEditingController(text: widget.member?.ygnId ?? '');
  late final _membershipNoCtrl = TextEditingController(text: widget.member?.membershipNo ?? '');
  late final _serviceBookNoCtrl =
      TextEditingController(text: widget.member?.serviceBookNo ?? '');
  MembershipType _membershipType = MembershipType.official;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _rank = widget.member!.rank;
      _companyNo = widget.member!.companyNo;
      _platoonNo = widget.member!.platoonNo;
      _sectionNo = widget.member!.sectionNo;
      _dob = widget.member!.dateOfBirth;
      _gender = widget.member!.gender;
      _bloodType = widget.member!.bloodType;
      _joinDate = widget.member!.joinDate;
      _currentRankDate = widget.member!.currentRankDate;
      _membershipType = widget.member!.membershipType;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameEnCtrl, _nameMmCtrl, _memberNoCtrl, _nrcCtrl, _ethnicityCtrl,
      _religionCtrl, _educationCtrl, _heightCtrl, _eyeColorCtrl, _hairColorCtrl,
      _marksCtrl, _fatherNameCtrl, _fatherOccCtrl, _motherNameCtrl, _motherOccCtrl,
      _phoneCtrl, _emailCtrl, _addressCtrl, _emergencyContactCtrl, _emergencyPhoneCtrl,
      _ygnIdCtrl, _membershipNoCtrl, _serviceBookNoCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(DateTime? current, void Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) onPicked(picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null || _joinDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Date of Birth and Join Date')),
      );
      return;
    }
    // Build the Member object — wiring to MockMembers / Supabase happens
    // when the data layer is connected (Module 16). For now this confirms
    // the form captures every required field correctly.
    //
    // Proposal flow: when widget.isProposal is true, the new member should
    // be created with a "pending approval" status and routed to the
    // Company Commander / Deputy Company Commander of the same company
    // for approval (see PermissionService.canApproveNewMemberProposal).
    // That approval queue UI will be built alongside the data layer.
    final message = widget.isProposal
        ? 'Member proposal submitted — pending Company Commander approval'
        : (_isEdit ? 'Member updated' : 'Member added');
    // Show the snackbar BEFORE popping — Navigator.pop() unmounts this
    // widget, and using its `context` afterward (e.g. for
    // ScaffoldMessenger) can throw "widget has been unmounted" since
    // the BuildContext no longer has a live ancestor tree.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit
        ? 'Edit Member'
        : (widget.isProposal ? 'Propose New Member' : 'Add Member');
    final saveLabel = widget.isProposal ? 'SUBMIT' : 'SAVE';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(saveLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard('Photo', [
              Center(
                child: Column(
                  children: [
                    if (widget.member != null)
                      MemberAvatar(
                        member: widget.member!,
                        width: 84,
                        height: 96,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.grey50.withValues(alpha: 0.4)),
                      )
                    else
                      Container(
                        width: 84,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.grey50.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.grey50.withValues(alpha: 0.4)),
                        ),
                        child: Icon(Icons.person, size: 50, color: AppColors.grey500),
                      ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo upload coming soon')),
                        );
                      },
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: const Text('Photo Upload Coming Soon'),
                    ),
                  ],
                ),
              ),
            ]),
            _sectionCard('Brigade Info', [
              _textField(_nameEnCtrl, 'Name (English)', required: true),
              _textField(_nameMmCtrl, 'Name (Myanmar)', required: true),
              _textField(_memberNoCtrl, 'Member No. (e.g. RC-106)', required: true),
              _rankDropdown(),
              _unitFields(),
            ]),
            _sectionCard('Personal Details', [
              _dateField('Date of Birth', _dob, (d) => setState(() => _dob = d)),
              _genderDropdown(),
              _textField(_nrcCtrl, 'NRC (or "လျှောက်ထားဆဲ" if pending)'),
              _bloodTypeDropdown(),
              _textField(_ethnicityCtrl, 'Ethnicity'),
              _textField(_religionCtrl, 'Religion'),
              _textField(_educationCtrl, 'Education'),
              _textField(_heightCtrl, 'Height (e.g. ၅ ပေ ၅ လက်မ)'),
              _textField(_eyeColorCtrl, 'Eye Color'),
              _textField(_hairColorCtrl, 'Hair Color'),
              _textField(_marksCtrl, 'Distinguishing Marks'),
            ]),
            _sectionCard('Parents', [
              _textField(_fatherNameCtrl, "Father's Name"),
              _textField(_fatherOccCtrl, "Father's Occupation"),
              _textField(_motherNameCtrl, "Mother's Name"),
              _textField(_motherOccCtrl, "Mother's Occupation"),
            ]),
            _sectionCard('Contact', [
              _textField(_phoneCtrl, 'Phone'),
              _textField(_emailCtrl, 'Email'),
              _textField(_addressCtrl, 'Address', maxLines: 2),
              _textField(_emergencyContactCtrl, 'Emergency Contact Name'),
              _textField(_emergencyPhoneCtrl, 'Emergency Contact Phone'),
            ]),
            _sectionCard('Membership', [
              _dateField('Join Date', _joinDate, (d) => setState(() => _joinDate = d)),
              _dateField('Current Rank Date', _currentRankDate,
                  (d) => setState(() => _currentRankDate = d)),
              _membershipTypeDropdown(),
              _textField(_membershipNoCtrl, 'Membership No. (e.g. တဖ-ရက/ဗတထ/106)'),
              _textField(_ygnIdCtrl, 'YGN ID (e.g. 13017/00106)'),
              _textField(_serviceBookNoCtrl, 'Service Book No. (optional)'),
            ]),
            const SizedBox(height: 24),
            if (widget.isProposal && !_isEdit) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This proposal will be sent to your Company Commander for approval before the member becomes active.',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(_isEdit
                  ? 'Save Changes'
                  : (widget.isProposal ? 'Submit Proposal' : 'Add Member')),
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
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _dateField(String label, DateTime? value, void Function(DateTime) onPicked) {
    return InkWell(
      onTap: () => _pickDate(value, onPicked),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text(value == null
            ? 'Select date'
            : '${value.day}/${value.month}/${value.year}'),
      ),
    );
  }

  Widget _rankDropdown() {
    return DropdownButtonFormField<MemberRank>(
      initialValue: _rank,
      decoration: const InputDecoration(labelText: 'Rank', border: OutlineInputBorder()),
      items: MemberRank.values
          .map((r) => DropdownMenuItem(value: r, child: Text(RankHelper.nameEn(r))))
          .toList(),
      onChanged: (v) => setState(() => _rank = v!),
    );
  }

  Widget _genderDropdown() {
    return DropdownButtonFormField<Gender>(
      initialValue: _gender,
      decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
      items: const [
        DropdownMenuItem(value: Gender.male, child: Text('Male')),
        DropdownMenuItem(value: Gender.female, child: Text('Female')),
      ],
      onChanged: (v) => setState(() => _gender = v!),
    );
  }

  Widget _bloodTypeDropdown() {
    final labels = {
      BloodType.OP: 'O+', BloodType.OM: 'O-',
      BloodType.AP: 'A+', BloodType.AM: 'A-',
      BloodType.BP: 'B+', BloodType.BM: 'B-',
      BloodType.ABP: 'AB+', BloodType.ABM: 'AB-',
    };
    return DropdownButtonFormField<BloodType>(
      initialValue: _bloodType,
      decoration: const InputDecoration(labelText: 'Blood Type', border: OutlineInputBorder()),
      items: labels.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: (v) => setState(() => _bloodType = v!),
    );
  }

  Widget _membershipTypeDropdown() {
    return DropdownButtonFormField<MembershipType>(
      initialValue: _membershipType,
      decoration:
          const InputDecoration(labelText: 'Membership Type', border: OutlineInputBorder()),
      items: MembershipType.values
          .map((t) => DropdownMenuItem(value: t, child: Text(t.nameEn)))
          .toList(),
      onChanged: (v) => setState(() => _membershipType = v!),
    );
  }

  Widget _unitFields() {
    final isOfficeRank = [
      MemberRank.brigadeCommander,
      MemberRank.deputyBrigadeCommander,
    ].contains(_rank);

    if (isOfficeRank) return const SizedBox.shrink();

    return Column(
      children: [
        DropdownButtonFormField<int?>(
          initialValue: _companyNo,
          decoration: const InputDecoration(labelText: 'Company', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: null, child: Text('Brigade Office')),
            DropdownMenuItem(value: 1, child: Text('Company 1')),
            DropdownMenuItem(value: 2, child: Text('Company 2')),
            DropdownMenuItem(value: 3, child: Text('Company 3')),
            DropdownMenuItem(value: 4, child: Text('Company 4')),
          ],
          onChanged: (v) => setState(() {
            _companyNo = v;
            _platoonNo = null;
            _sectionNo = null;
          }),
        ),
        if (_companyNo != null) const SizedBox(height: 12),
        if (_companyNo != null)
          DropdownButtonFormField<int?>(
            initialValue: _platoonNo,
            decoration: const InputDecoration(labelText: 'Platoon', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: null, child: Text('None')),
              DropdownMenuItem(value: 1, child: Text('Platoon 1')),
              DropdownMenuItem(value: 2, child: Text('Platoon 2')),
            ],
            onChanged: (v) => setState(() {
              _platoonNo = v;
              _sectionNo = null;
            }),
          ),
        if (_platoonNo != null) const SizedBox(height: 12),
        if (_platoonNo != null)
          DropdownButtonFormField<int?>(
            initialValue: _sectionNo,
            decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: null, child: Text('None')),
              DropdownMenuItem(value: 1, child: Text('Section 1')),
              DropdownMenuItem(value: 2, child: Text('Section 2')),
            ],
            onChanged: (v) => setState(() => _sectionNo = v),
          ),
      ],
    );
  }
}