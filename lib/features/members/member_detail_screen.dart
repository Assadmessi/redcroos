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
    final canDirect = auth.hasMasterAccess; // covers Admin via getter chain
    if (canDirect) {
      setState(() => _member = _member.copyWith(isAvailable: !_member.isAvailable));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_member.isAvailable ? 'Marked Available' : 'Marked Not Available')),
      );
      return;
    }

    // Self or higher-rank request flow
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request Availability Change'),
        content: Text(
          _member.id == auth.currentMember?.id
              ? 'This will send a request to your higher rank for approval.'
              : "This will send a request to your higher rank to confirm ${_member.nameEn}'s availability change.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request sent for approval')),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canEdit = auth.canManageMember(_member);
    final isVacant = _member.nameEn.isEmpty;

    return DefaultTabController(
      length: 3,
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Info'),
              Tab(text: 'ID Card'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: isVacant
            ? const Center(child: Text('This position is currently vacant.'))
            : TabBarView(
                children: [
                  _InfoTab(member: _member, onToggleAvailability: () => _toggleAvailability(auth)),
                  _IdCardTab(member: _member),
                  _AnalyticsTab(member: _member),
                ],
              ),
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
  const _InfoTab({required this.member, required this.onToggleAvailability});

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
class _IdCardTab extends StatelessWidget {
  final Member member;
  const _IdCardTab({required this.member});

  @override
  Widget build(BuildContext context) {
    final commander = MockMembers.all.firstWhere(
      (m) => m.rank.name == 'brigadeCommander',
      orElse: () => member,
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            MemberIdCard(
              member: member,
              issuerNameEn: commander.nameEn,
              issuedDate: DateTime.now(),
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
