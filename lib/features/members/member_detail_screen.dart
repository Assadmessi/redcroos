import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';
import 'widgets/member_id_card.dart';
import 'member_form_screen.dart';

class MemberDetailScreen extends StatefulWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late Member _member;

  @override
  void initState() {
    super.initState();
    _member = MockMembers.findById(widget.memberId)!;
  }

  void _toggleAvailability(AuthProvider auth) {
    // Available/Not Available is always a direct change now — no
    // approval step. We still notify the member's full chain of
    // command up to Brigade Office as an FYI.
    final newAvailability = !_member.isAvailable;
    setState(() => _member = _member.copyWith(isAvailable: newAvailability));
    MockNotifications.notifyChainOfCommandOfAvailabilityChange(
      member: _member,
      isNowAvailable: newAvailability,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(newAvailability ? 'Marked Available' : 'Marked Not Available')),
    );
  }

  /// Active/Inactive toggle for long leave/overseas (NOT disciplinary
  /// suspension/dismissal — that's a separate Master-Access-only path
  /// held for Module 16). Same request/approval pattern as
  /// _toggleAvailability: Master Access/Admin act directly; everyone
  /// else's change goes to their higher rank for approval.
  void _toggleActiveLeave(AuthProvider auth) {
    final isCurrentlyInactiveLeave =
        _member.status == MemberStatus.inactive && _member.inactiveReason != null;
    final canDirect = auth.canSetInactiveLeaveDirectly(_member);

    if (isCurrentlyInactiveLeave) {
      // Returning to active — confirm, then apply directly or request.
      if (canDirect) {
        setState(() => _member = _member.markActiveAgain());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked Active')),
        );
      } else {
        _showInactiveLeaveRequestDialog(auth, goingInactive: false);
      }
      return;
    }

    if (canDirect) {
      _showInactiveLeaveDetailForm(auth, applyDirectly: true);
    } else {
      _showInactiveLeaveRequestDialog(auth, goingInactive: true);
    }
  }

  void _showInactiveLeaveRequestDialog(AuthProvider auth, {required bool goingInactive}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(goingInactive ? 'Request Inactive (Long Leave)' : 'Request Return to Active'),
        content: Text(
          _member.id == auth.currentMember?.id
              ? 'This will send a request to your higher rank for approval.'
              : "This will send a request to your higher rank to confirm ${_member.nameEn}'s status change.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (goingInactive) {
                _showInactiveLeaveDetailForm(auth, applyDirectly: false);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request sent for approval')),
                );
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _showInactiveLeaveDetailForm(AuthProvider auth, {required bool applyDirectly}) async {
    final reasonCtrl = TextEditingController();
    DateTime? returnDate;

    await showModalBottomSheet(
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
                  Text('Mark Inactive (Long Leave)', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 4),
                  Text(
                    'For overseas travel or extended leave — member stays on the roster, marked clearly, and excluded from duty/meeting/class assignment until they return.',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      hintText: 'e.g. Overseas — work assignment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 1095)),
                      );
                      if (picked != null) setSheetState(() => returnDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Expected Return Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(returnDate == null
                          ? 'Select date'
                          : AppFormatters.date(returnDate!)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: reasonCtrl.text.trim().isEmpty || returnDate == null
                              ? null
                              : () {
                                  final reason = reasonCtrl.text.trim();
                                  final date = returnDate!;
                                  Navigator.pop(sheetContext);
                                  if (applyDirectly) {
                                    setState(() {
                                      _member = _member.markInactiveForLeave(
                                        reason: reason,
                                        returnDate: date,
                                      );
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Marked Inactive (Long Leave)')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Request sent for approval')),
                                    );
                                  }
                                },
                          child: Text(applyDirectly ? 'Mark Inactive' : 'Submit Request'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canEdit = auth.canManageMember(_member);
    final isVacant = _member.nameEn.isEmpty;
    final canViewDetail = auth.canViewFullDetail(_member);
    final canFullscreenCard = auth.canViewIdCardFullscreen(_member);

    // Info tab always exists (full detail or contact-info-only fallback).
    // ID Card and Analytics tabs only exist at all when canViewDetail is
    // true — per the rule that a higher rank's card/analytics should be
    // hidden entirely, not shown as a locked placeholder.
    final tabCount = canViewDetail ? 3 : 1;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isVacant ? '(Vacant Position)' : _member.nameEn),
          actions: [
            if (canEdit && !isVacant)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MemberFormScreen(member: _member)),
                ),
              ),
          ],
          bottom: canViewDetail
              ? const TabBar(
                  tabs: [
                    Tab(text: 'Info'),
                    Tab(text: 'ID Card'),
                    Tab(text: 'Analytics'),
                  ],
                )
              : null,
        ),
        body: isVacant
            ? const Center(child: Text('This position is currently vacant.'))
            : (canViewDetail
                ? TabBarView(
                    children: [
                      _InfoTab(
                        member: _member,
                        onToggleAvailability: () => _toggleAvailability(auth),
                        onToggleActiveLeave: () => _toggleActiveLeave(auth),
                      ),
                      _IdCardTab(
                        member: _member,
                        canFullscreen: canFullscreenCard,
                        canShowDetail: true,
                        canEditCard: canEdit,
                      ),
                      _AnalyticsTab(member: _member),
                    ],
                  )
                : _RestrictedTab(member: _member)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// RESTRICTED PLACEHOLDER — shown instead of Info/Analytics when
// viewing a higher-ranking member without Master Access/Admin
// ─────────────────────────────────────────────────────────────────
class _RestrictedTab extends StatefulWidget {
  final Member member;
  const _RestrictedTab({required this.member});

  @override
  State<_RestrictedTab> createState() => _RestrictedTabState();
}

class _RestrictedTabState extends State<_RestrictedTab> {
  final Set<ProfileSection> _selectedSections = {};
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _submitRequest(AuthProvider auth) {
    if (_selectedSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one section to request')),
      );
      return;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for this request')),
      );
      return;
    }

    final requester = auth.currentMember!;
    MockAccessGrants.add(AccessGrantRequest(
      id: 'grant_${DateTime.now().microsecondsSinceEpoch}',
      requesterId: requester.id,
      targetMemberId: widget.member.id,
      requestedSections: _selectedSections.toList(),
      reason: _reasonCtrl.text.trim(),
      status: AccessGrantStatus.pending,
      requestedAt: DateTime.now(),
    ));

    setState(() {
      _selectedSections.clear();
      _reasonCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request sent to Company Commander/Deputy for approval')),
    );
  }

  void _openRequestSheet(AuthProvider auth) {
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
                  Text('Request Access', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Select which sections of ${widget.member.nameEn}\'s profile you need, '
                    'and why. This goes to your Company Commander/Deputy for approval.',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 16),
                  ...ProfileSection.values.map((section) {
                    final isSelected = _selectedSections.contains(section);
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: isSelected,
                      onChanged: (v) => setSheetState(() {
                        if (v == true) {
                          _selectedSections.add(section);
                        } else {
                          _selectedSections.remove(section);
                        }
                      }),
                      title: Text(section.label, style: AppTextStyles.bodyMedium),
                    );
                  }),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reasonCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _submitRequest(auth);
                          },
                          child: const Text('Submit Request'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.currentMember;
    final canRequest = me != null && auth.canRequestAccessGrant(widget.member);
    final activeGrants = me != null
        ? MockAccessGrants.activeFor(me.id, widget.member.id)
        : <AccessGrantRequest>[];
    final grantedSections = activeGrants.expand((g) => g.requestedSections).toSet();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_outline, size: 18, color: AppColors.grey500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Full profile is restricted — contact info only',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _row('Name', widget.member.nameEn),
                _row('Rank', widget.member.rankNameEn),
                _row('Phone', widget.member.phone.isEmpty ? '—' : widget.member.phone),
                _row('Email', widget.member.email.isEmpty ? '—' : widget.member.email),
                _row('Unit / Company', widget.member.unitDisplay),
                if (grantedSections.isNotEmpty) ...[
                  const Divider(height: 20),
                  Text('Granted Access', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: grantedSections
                        .map((s) => Chip(
                              label: Text(s.label, style: const TextStyle(fontSize: 11)),
                              backgroundColor: Colors.green.withValues(alpha: 0.1),
                              avatar: const Icon(Icons.check_circle, size: 14, color: Colors.green),
                            ))
                        .toList(),
                  ),
                ],
                if (canRequest) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _openRequestSheet(auth),
                    icon: const Icon(Icons.lock_open_outlined, size: 18),
                    label: const Text('Request Access'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TAB 1 — INFO
// ─────────────────────────────────────────────────────────────────
class _InfoTab extends StatelessWidget {
  final Member member;
  final VoidCallback onToggleAvailability;
  final VoidCallback onToggleActiveLeave;
  const _InfoTab({
    required this.member,
    required this.onToggleAvailability,
    required this.onToggleActiveLeave,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _headerCard(),
        const SizedBox(height: 16),
        _section('Personal Details', [
          _row('Date of Birth', AppFormatters.date(member.dateOfBirth)),
          _row('Age', '${member.age} years'),
          _row('Gender', member.gender == Gender.male ? 'Male' : 'Female'),
          _row('NRC', member.nrc ?? '—'),
          _row('Blood Type', member.bloodTypeDisplay),
          if (member.ethnicity != null) _row('Ethnicity', member.ethnicity!),
          if (member.religion != null) _row('Religion', member.religion!),
          if (member.education != null) _row('Education', member.education!),
          if (member.height != null) _row('Height', member.height!),
          if (member.eyeColor != null) _row('Eye Color', member.eyeColor!),
          if (member.hairColor != null) _row('Hair Color', member.hairColor!),
          if (member.distinguishingMarks != null)
            _row('Distinguishing Marks', member.distinguishingMarks!),
        ]),
        _section('Parents', [
          if (member.fatherName != null) _row("Father's Name", member.fatherName!),
          if (member.fatherOccupation != null)
            _row("Father's Occupation", member.fatherOccupation!),
          if (member.motherName != null) _row("Mother's Name", member.motherName!),
          if (member.motherOccupation != null)
            _row("Mother's Occupation", member.motherOccupation!),
        ]),
        _section('Contact', [
          _row('Phone', member.phone.isEmpty ? '—' : member.phone),
          _row('Email', member.email.isEmpty ? '—' : member.email),
          _row('Address', member.address.isEmpty ? '—' : member.address),
          _row('Emergency Contact', member.emergencyContact.isEmpty ? '—' : member.emergencyContact),
          _row('Emergency Phone', member.emergencyPhone.isEmpty ? '—' : member.emergencyPhone),
        ]),
        _section('Membership', [
          _row('Join Date', AppFormatters.date(member.joinDate)),
          _row('Years of Service', '${member.yearsOfService} years'),
          if (member.currentRankDate != null) ...[
            _row('Current Rank Since', AppFormatters.date(member.currentRankDate!)),
            _row('Years in Rank', '${member.yearsInCurrentRank} years'),
          ],
          _row('Membership Type', member.membershipType.nameEn),
          if (member.membershipNo != null) _row('Membership No.', member.membershipNo!),
          if (member.ygnId != null) _row('YGN ID', member.ygnId!),
          if (member.lifetimeMemberNo != null)
            _row('Lifetime Member No.', member.lifetimeMemberNo!),
          if (member.serviceBookNo != null) _row('Service Book No.', member.serviceBookNo!),
        ]),
        if (member.completedTrainings.isNotEmpty)
          _section('Completed Trainings', [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: member.completedTrainings
                  .map((t) => Chip(label: Text(t, style: AppTextStyles.labelSmall)))
                  .toList(),
            ),
          ], isWrapContent: true),
        if (member.honorsAwards != null && member.honorsAwards!.isNotEmpty)
          _section('Honors & Awards', [Text(member.honorsAwards!)], isWrapContent: true),
      ],
    );
  }

  Widget _headerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.rankNameEn, style: AppTextStyles.headingMedium),
                      Text(member.rankNameMm,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700)),
                      const SizedBox(height: 4),
                      Text('${member.memberNo} · ${member.unitDisplay}',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
                    ],
                  ),
                ),
                _statusChip(),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    member.isAvailable ? '🟢 Available' : '🟠 Not Available',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                OutlinedButton(
                  onPressed: onToggleAvailability,
                  child: Text(member.isAvailable ? 'Mark Not Available' : 'Mark Available'),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    member.status == MemberStatus.inactive && member.inactiveReason != null
                        ? '✈️ Inactive — Long Leave'
                        : '✅ Active',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                OutlinedButton(
                  onPressed: onToggleActiveLeave,
                  child: Text(
                    member.status == MemberStatus.inactive && member.inactiveReason != null
                        ? 'Mark Active'
                        : 'Mark Inactive',
                  ),
                ),
              ],
            ),
            if (member.status == MemberStatus.inactive && member.inactiveReason != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reason: ${member.inactiveReason}',
                        style: AppTextStyles.bodySmall),
                    if (member.inactiveReturnDate != null)
                      Text(
                        'Expected return: ${AppFormatters.date(member.inactiveReturnDate!)}',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey700),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip() {
    final color = switch (member.status) {
      MemberStatus.active => Colors.green,
      MemberStatus.inactive => Colors.grey,
      MemberStatus.suspended => Colors.orange,
      MemberStatus.dismissed => Colors.red,
    };
    return Chip(
      label: Text(member.status.name.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  Widget _section(String title, List<Widget> children, {bool isWrapContent = false}) {
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
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TAB 2 — ID CARD
// ─────────────────────────────────────────────────────────────────
class _IdCardTab extends StatefulWidget {
  final Member member;
  final bool canFullscreen;
  final bool canShowDetail;
  final bool canEditCard;
  const _IdCardTab({
    required this.member,
    required this.canFullscreen,
    required this.canShowDetail,
    required this.canEditCard,
  });

  @override
  State<_IdCardTab> createState() => _IdCardTabState();
}

class _IdCardTabState extends State<_IdCardTab> {
  // ── Card-only fields ──
  // These are NOT part of the CV/Info profile and can't be reliably
  // auto-filled, so they're editable here on the ID Card tab directly:
  //   - issuerNameEn: who signs as issuing officer (defaults to current
  //     Brigade Commander, but may need overriding e.g. during a vacancy
  //     or if Deputy signs instead)
  //   - issuedDate: when this specific card was printed/issued
  //   - expiryOverride: normally issuedDate + 1 year, but can be manually
  //     extended/shortened (e.g. re-issued card, lost card replacement)
  late String _issuerNameEn;
  late DateTime _issuedDate;
  DateTime? _expiryOverride;

  @override
  void initState() {
    super.initState();
    final commander = MockMembers.all.firstWhere(
      (m) => m.rank.name == 'brigadeCommander',
      orElse: () => widget.member,
    );
    _issuerNameEn = commander.nameEn;
    _issuedDate = DateTime.now();
  }

  DateTime get _effectiveExpiry =>
      _expiryOverride ?? DateTime(_issuedDate.year + 1, _issuedDate.month, _issuedDate.day);

  Future<void> _openEditSheet() async {
    final issuerCtrl = TextEditingController(text: _issuerNameEn);
    DateTime issuedDate = _issuedDate;
    DateTime? expiryOverride = _expiryOverride;

    await showModalBottomSheet(
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
                  Text('Edit Card Details', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 4),
                  Text(
                    'These fields are specific to this physical card and are not part of the member profile.',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: issuerCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Issuing Officer Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: issuedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (picked != null) setSheetState(() => issuedDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Issued Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(AppFormatters.date(issuedDate)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: expiryOverride ??
                            DateTime(issuedDate.year + 1, issuedDate.month, issuedDate.day),
                        firstDate: issuedDate,
                        lastDate: DateTime(issuedDate.year + 5),
                      );
                      if (picked != null) setSheetState(() => expiryOverride = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Expiry Date (override)',
                        border: const OutlineInputBorder(),
                        suffixIcon: expiryOverride != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setSheetState(() => expiryOverride = null),
                              )
                            : null,
                      ),
                      child: Text(
                        expiryOverride != null
                            ? AppFormatters.date(expiryOverride!)
                            : 'Default: ${AppFormatters.date(DateTime(issuedDate.year + 1, issuedDate.month, issuedDate.day))}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _issuerNameEn = issuerCtrl.text.trim().isEmpty
                                  ? _issuerNameEn
                                  : issuerCtrl.text.trim();
                              _issuedDate = issuedDate;
                              _expiryOverride = expiryOverride;
                            });
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                MemberIdCard(
                  member: widget.member,
                  issuerNameEn: _issuerNameEn,
                  issuedDate: _issuedDate,
                  expiryDateOverride: _expiryOverride,
                  canFullscreen: widget.canFullscreen,
                  canShowDetail: widget.canShowDetail,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Download PDF'),
                ),
              ],
            ),
          ),
        ),
        if (widget.canEditCard)
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: _openEditSheet,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit card details',
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TAB 3 — ANALYTICS
// ─────────────────────────────────────────────────────────────────
enum _AnalyticsPeriod { month, threeMonth, sixMonth, year, allTime }

class _AnalyticsTab extends StatefulWidget {
  final Member member;
  const _AnalyticsTab({required this.member});

  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab> {
  _AnalyticsPeriod _period = _AnalyticsPeriod.month;

  String _periodLabel(_AnalyticsPeriod p) => switch (p) {
        _AnalyticsPeriod.month => 'This Month',
        _AnalyticsPeriod.threeMonth => 'Last 3 Months',
        _AnalyticsPeriod.sixMonth => 'Last 6 Months',
        _AnalyticsPeriod.year => 'This Year',
        _AnalyticsPeriod.allTime => 'All Time',
      };

  @override
  Widget build(BuildContext context) {
    // Mock stats — replaced with real aggregation in Reports module (Module 13)
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: PopupMenuButton<_AnalyticsPeriod>(
            onSelected: (p) => setState(() => _period = p),
            itemBuilder: (context) => _AnalyticsPeriod.values
                .map((p) => PopupMenuItem(value: p, child: Text(_periodLabel(p))))
                .toList(),
            child: Chip(
              label: Text(_periodLabel(_period)),
              avatar: const Icon(Icons.arrow_drop_down, size: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _statGrid(),
        const SizedBox(height: 16),
        _dutyBreakdownCard(),
        const SizedBox(height: 16),
        _attendanceRateCard(),
      ],
    );
  }

  Widget _statGrid() {
    final stats = [
      ('Duties', '24', Icons.shield_outlined),
      ('Classes', '5', Icons.school_outlined),
      ('Meetings', '12', Icons.groups_outlined),
      ('Donations', '3', Icons.bloodtype_outlined),
      ('Awards', '2', Icons.military_tech_outlined),
      ('Service', '${widget.member.yearsOfService} yrs', Icons.calendar_today_outlined),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.1,
      children: stats
          .map((s) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(s.$3, color: AppColors.primary, size: 20),
                      const SizedBox(height: 4),
                      Text(s.$2, style: AppTextStyles.headingMedium),
                      Text(s.$1, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _dutyBreakdownCard() {
    final rows = [
      ('Regular', 12),
      ('Emergency', 5),
      ('Blood Service', 4),
      ('Large Scale', 3),
      ('Missed', 2),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duty Breakdown', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            ...rows.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.$1, style: AppTextStyles.bodyMedium),
                      Text('${r.$2}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _attendanceRateCard() {
    final rows = [
      ('Meetings', '85%'),
      ('Duties', '92%'),
      ('Classes', '100%'),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance Rate', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            ...rows.map((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.$1, style: AppTextStyles.bodyMedium),
                      Text(r.$2, style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
