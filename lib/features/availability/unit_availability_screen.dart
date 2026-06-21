import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';
import 'my_availability_screen.dart';

enum _ViewMode { list, grid, summary }
enum _TrendRange { today, week, month }
enum _SummaryPeriod { day, week, month, year }

class UnitAvailabilityScreen extends StatefulWidget {
  const UnitAvailabilityScreen({super.key});

  @override
  State<UnitAvailabilityScreen> createState() => _UnitAvailabilityScreenState();
}

class _UnitAvailabilityScreenState extends State<UnitAvailabilityScreen> {
  _ViewMode _viewMode = _ViewMode.list;
  _TrendRange _trendRange = _TrendRange.week;
  _SummaryPeriod _summaryPeriod = _SummaryPeriod.day;
  DateTime _summaryAnchorDate = DateTime.now(); // anchor for the selected period
  DateTime _selectedDate = DateTime.now();
  DateTime _weekStart = _startOfWeek(DateTime.now());

  static DateTime _startOfWeek(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday % 7));
  }

  List<Member> _unitMembers(AuthProvider auth) {
    final me = auth.currentMember;
    if (me == null) return [];
    final all = MockMembers.all;

    // Scope to the viewer's own unit, mirroring the existing
    // canSeeInMemberList + unit-display conventions from Module 4.
    // Officers viewing this screen should see their relevant unit:
    //   Brigade Office       -> entire brigade
    //   Company Office       -> own company
    //   Platoon Leader       -> own platoon
    //   Section Leader/Dep.  -> own section
    if (me.unitType == UnitType.brigadeOffice) {
      return all.where((m) => m.nameEn.isNotEmpty).toList();
    }
    if (me.unitType == UnitType.companyOffice ||
        me.rank == MemberRank.companyCommander ||
        me.rank == MemberRank.deputyCompanyCommander) {
      return all
          .where((m) => m.nameEn.isNotEmpty && m.companyNo == me.companyNo)
          .toList();
    }
    if (me.rank == MemberRank.platoonLeader) {
      return all
          .where((m) =>
              m.nameEn.isNotEmpty &&
              m.companyNo == me.companyNo &&
              m.platoonNo == me.platoonNo)
          .toList();
    }
    if (me.rank == MemberRank.sectionLeader ||
        me.rank == MemberRank.deputySectionLeader) {
      return all
          .where((m) =>
              m.nameEn.isNotEmpty &&
              m.companyNo == me.companyNo &&
              m.platoonNo == me.platoonNo &&
              m.sectionNo == me.sectionNo)
          .toList();
    }
    // Fallback — own company
    return all
        .where((m) => m.nameEn.isNotEmpty && m.companyNo == me.companyNo)
        .toList();
  }

  DayAvailabilityStatus _statusOn(Member m, DateTime date) {
    final entries = MockAvailability.forMembersOnDate([m.id], date);
    if (entries.isNotEmpty) return entries.first.status;
    if (m.status == MemberStatus.inactive && m.inactiveReason != null) {
      return DayAvailabilityStatus.onLeave;
    }
    return m.isAvailable
        ? DayAvailabilityStatus.available
        : DayAvailabilityStatus.notAvailable;
  }

  Color _statusColor(DayAvailabilityStatus status) {
    switch (status) {
      case DayAvailabilityStatus.available: return Colors.green;
      case DayAvailabilityStatus.notAvailable: return Colors.orange;
      case DayAvailabilityStatus.onLeave: return Colors.blueGrey;
    }
  }

  String _statusLabel(DayAvailabilityStatus status) {
    switch (status) {
      case DayAvailabilityStatus.available: return 'Available';
      case DayAvailabilityStatus.notAvailable: return 'Not Available';
      case DayAvailabilityStatus.onLeave: return 'On Leave';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final members = _unitMembers(auth);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  auth.tr('Unit Availability', 'တပ်ဖွဲ့ အားလပ်ချိန်'),
                  style: AppTextStyles.headingMedium,
                ),
              ),
              _ViewModeSwitch(viewMode: _viewMode, onChanged: (mode) {
                setState(() => _viewMode = mode);
              }),
            ],
          ),
        ),
        Expanded(
          child: members.isEmpty
              ? Center(
                  child: Text(
                    auth.tr('No members in your unit', 'သင့်တပ်ဖွဲ့တွင် အဖွဲ့ဝင်မရှိပါ'),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
                  ),
                )
              : switch (_viewMode) {
                  _ViewMode.list => _buildListView(members, auth),
                  _ViewMode.grid => _buildGridView(members, auth),
                  _ViewMode.summary => _buildSummaryView(members, auth),
                },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LIST VIEW — grouped by status, for a selected date
  // ─────────────────────────────────────────────────────────────
  Widget _buildListView(List<Member> members, AuthProvider auth) {
    final available = <Member>[];
    final notAvailable = <Member>[];
    final onLeave = <Member>[];

    for (final m in members) {
      switch (_statusOn(m, _selectedDate)) {
        case DayAvailabilityStatus.available: available.add(m);
        case DayAvailabilityStatus.notAvailable: notAvailable.add(m);
        case DayAvailabilityStatus.onLeave: onLeave.add(m);
      }
    }

    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _listSection('Available', available, Colors.green, auth),
              _listSection('Not Available', notAvailable, Colors.orange, auth),
              _listSection('On Leave', onLeave, Colors.blueGrey, auth),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(
              () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: Text(
              _isToday(_selectedDate) ? 'Today, ${AppFormatters.date(_selectedDate)}' : AppFormatters.date(_selectedDate),
              style: AppTextStyles.headingSmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(
              () => _selectedDate = _selectedDate.add(const Duration(days: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listSection(String title, List<Member> members, Color color, AuthProvider auth) {
    if (members.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('$title (${members.length})', style: AppTextStyles.headingSmall),
            ],
          ),
        ),
        ...members.map((m) => ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: AvatarColorGen.fromString(m.id),
                child: Text(m.initials,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              title: Text(m.nameEn),
              subtitle: Text(m.rankNameEn, style: AppTextStyles.labelSmall),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyAvailabilityPage(memberId: m.id),
                ),
              ),
            )),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // GRID VIEW — whole unit, one row per member, columns = days (week)
  // ─────────────────────────────────────────────────────────────
  Widget _buildGridView(List<Member> members, AuthProvider auth) {
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(
                  () => _weekStart = _weekStart.subtract(const Duration(days: 7)),
                ),
              ),
              Text(
                '${AppFormatters.date(days.first)} – ${AppFormatters.date(days.last)}',
                style: AppTextStyles.headingSmall,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(
                  () => _weekStart = _weekStart.add(const Duration(days: 7)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(48),
                columnWidths: const {0: FixedColumnWidth(140)},
                border: TableBorder.all(color: AppColors.grey50.withValues(alpha: 0.3)),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: AppColors.grey50.withValues(alpha: 0.2)),
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Member', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      for (final d in days)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Center(
                            child: Text(
                              '${_weekdayShort(d.weekday)}\n${d.day}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelSmall,
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (final m in members)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MyAvailabilityPage(memberId: m.id),
                              ),
                            ),
                            child: Text(
                              m.nameEn,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ),
                        for (final d in days)
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Center(
                              child: Container(
                                width: 14, height: 14,
                                decoration: BoxDecoration(
                                  color: _statusColor(_statusOn(m, d)),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 16,
            children: [
              _legendDot(Colors.green, 'Available'),
              _legendDot(Colors.orange, 'Not Available'),
              _legendDot(Colors.blueGrey, 'On Leave'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color c, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey700)),
        ],
      );

  String _weekdayShort(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  // ─────────────────────────────────────────────────────────────
  // SUMMARY VIEW — unit breakdown (company/platoon/section) +
  // day-by-day trend (today/week/month), all scoped the same way
  // as List/Grid (whatever _unitMembers(auth) returns for this viewer).
  // ─────────────────────────────────────────────────────────────
  Widget _buildSummaryView(List<Member> members, AuthProvider auth) {
    final range = _resolveSummaryRange();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _buildPeriodSelector(range),
        const SizedBox(height: 16),
        _buildOverallCounts(members, range),
        const SizedBox(height: 20),
        Text('By Unit', style: AppTextStyles.headingSmall),
        const SizedBox(height: 4),
        Text(
          _periodRangeLabel(range),
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
        ),
        const SizedBox(height: 8),
        ..._buildUnitBreakdown(members, range),
        const SizedBox(height: 20),
        _buildTrendHeader(),
        const SizedBox(height: 12),
        _buildTrendChart(members),
      ],
    );
  }

  // ── Period resolution ──────────────────────────────────────────

  /// Resolves the actual inclusive start/end DateTime for the
  /// currently selected _summaryPeriod, anchored at _summaryAnchorDate.
  ({DateTime start, DateTime end}) _resolveSummaryRange() {
    final a = _summaryAnchorDate;
    switch (_summaryPeriod) {
      case _SummaryPeriod.day:
        final d = DateTime(a.year, a.month, a.day);
        return (start: d, end: d);
      case _SummaryPeriod.week:
        final start = _startOfWeek(a);
        return (start: start, end: start.add(const Duration(days: 6)));
      case _SummaryPeriod.month:
        final start = DateTime(a.year, a.month, 1);
        final end = DateTime(a.year, a.month + 1, 0);
        return (start: start, end: end);
      case _SummaryPeriod.year:
        return (start: DateTime(a.year, 1, 1), end: DateTime(a.year, 12, 31));
    }
  }

  List<DateTime> _daysIn(({DateTime start, DateTime end}) range) {
    final days = <DateTime>[];
    var d = range.start;
    while (!d.isAfter(range.end)) {
      days.add(d);
      d = d.add(const Duration(days: 1));
    }
    return days;
  }

  String _periodRangeLabel(({DateTime start, DateTime end}) range) {
    if (range.start == range.end) return AppFormatters.date(range.start);
    return '${AppFormatters.date(range.start)} – ${AppFormatters.date(range.end)}';
  }

  void _shiftSummaryAnchor(int direction) {
    setState(() {
      switch (_summaryPeriod) {
        case _SummaryPeriod.day:
          _summaryAnchorDate = _summaryAnchorDate.add(Duration(days: direction));
        case _SummaryPeriod.week:
          _summaryAnchorDate = _summaryAnchorDate.add(Duration(days: 7 * direction));
        case _SummaryPeriod.month:
          _summaryAnchorDate = DateTime(
            _summaryAnchorDate.year, _summaryAnchorDate.month + direction, 1,
          );
        case _SummaryPeriod.year:
          _summaryAnchorDate = DateTime(_summaryAnchorDate.year + direction, 1, 1);
      }
    });
  }

  Widget _buildPeriodSelector(({DateTime start, DateTime end}) range) {
    Widget seg(_SummaryPeriod p, String label) {
      final isSelected = _summaryPeriod == p;
      return InkWell(
        onTap: () => setState(() => _summaryPeriod = p),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.grey700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey50.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              seg(_SummaryPeriod.day, 'Day'),
              seg(_SummaryPeriod.week, 'Week'),
              seg(_SummaryPeriod.month, 'Month'),
              seg(_SummaryPeriod.year, 'Year'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _shiftSummaryAnchor(-1),
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                _periodRangeLabel(range),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _shiftSummaryAnchor(1),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }

  // ── Period-aware counting ──────────────────────────────────────

  /// For a given member list and date range, returns per-status:
  ///   - distinct member count (headline number — how many people
  ///     were ever in that status at least once during the period)
  ///   - member-days total (secondary detail — total day-instances,
  ///     e.g. 3 members unavailable for 2 days each = 6 member-days)
  ///
  /// For a single-day period (day view), distinct count and
  /// member-days are always equal, which is expected — there's no
  /// double-counting possible across just one day.
  ({
    int availableMembers, int availableDays,
    int notAvailableMembers, int notAvailableDays,
    int onLeaveMembers, int onLeaveDays,
  }) _periodCounts(List<Member> members, ({DateTime start, DateTime end}) range) {
    final days = _daysIn(range);

    final availableMemberIds = <String>{};
    final notAvailableMemberIds = <String>{};
    final onLeaveMemberIds = <String>{};
    var availableDays = 0, notAvailableDays = 0, onLeaveDays = 0;

    for (final m in members) {
      for (final day in days) {
        switch (_statusOn(m, day)) {
          case DayAvailabilityStatus.available:
            availableMemberIds.add(m.id);
            availableDays++;
          case DayAvailabilityStatus.notAvailable:
            notAvailableMemberIds.add(m.id);
            notAvailableDays++;
          case DayAvailabilityStatus.onLeave:
            onLeaveMemberIds.add(m.id);
            onLeaveDays++;
        }
      }
    }

    return (
      availableMembers: availableMemberIds.length, availableDays: availableDays,
      notAvailableMembers: notAvailableMemberIds.length, notAvailableDays: notAvailableDays,
      onLeaveMembers: onLeaveMemberIds.length, onLeaveDays: onLeaveDays,
    );
  }

  Widget _buildOverallCounts(List<Member> members, ({DateTime start, DateTime end}) range) {
    final counts = _periodCounts(members, range);
    return Row(
      children: [
        Expanded(child: _countCard('Available', counts.availableMembers, Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _countCard('Not Available', counts.notAvailableMembers, Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _countCard('On Leave', counts.onLeaveMembers, Colors.blueGrey)),
      ],
    );
  }

  Widget _countCard(String label, int memberCount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text('$memberCount', style: AppTextStyles.headingMedium.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  /// Groups the (already scoped) member list by company → platoon →
  /// section, but only shows levels that actually have more than one
  /// distinct value in the current scope — e.g. a Platoon Leader's
  /// scope is a single platoon, so the breakdown collapses straight
  /// to sections; a Company Commander's scope shows platoons.
  /// Counts shown per row are totals over `range`, not a single day.
  List<Widget> _buildUnitBreakdown(List<Member> members, ({DateTime start, DateTime end}) range) {
    final byCompany = <int?, List<Member>>{};
    for (final m in members) {
      byCompany.putIfAbsent(m.companyNo, () => []).add(m);
    }

    final widgets = <Widget>[];
    final companyKeys = byCompany.keys.toList()..sort((a, b) => (a ?? -1).compareTo(b ?? -1));

    final showCompanyLevel = companyKeys.length > 1;

    for (final companyNo in companyKeys) {
      final companyMembers = byCompany[companyNo]!;
      if (showCompanyLevel) {
        widgets.add(_unitRow(
          label: companyNo == null ? 'Brigade Office' : 'Company $companyNo',
          members: companyMembers,
          range: range,
          isHeader: true,
        ));
      }

      final byPlatoon = <int?, List<Member>>{};
      for (final m in companyMembers) {
        byPlatoon.putIfAbsent(m.platoonNo, () => []).add(m);
      }
      final platoonKeys = byPlatoon.keys.toList()
        ..sort((a, b) => (a ?? -1).compareTo(b ?? -1));
      final showPlatoonLevel = platoonKeys.length > 1 ||
          (platoonKeys.length == 1 && platoonKeys.first != null && showCompanyLevel);

      for (final platoonNo in platoonKeys) {
        final platoonMembers = byPlatoon[platoonNo]!;
        if (platoonNo == null) {
          // Company/Brigade office-level members with no platoon —
          // shown at the company row itself, nothing more to break down.
          continue;
        }
        if (showPlatoonLevel) {
          widgets.add(_unitRow(
            label: 'Platoon $platoonNo',
            members: platoonMembers,
            range: range,
            isHeader: false,
            indent: showCompanyLevel ? 1 : 0,
          ));
        }

        final bySection = <int?, List<Member>>{};
        for (final m in platoonMembers) {
          bySection.putIfAbsent(m.sectionNo, () => []).add(m);
        }
        final sectionKeys = bySection.keys.where((k) => k != null).toList()
          ..sort((a, b) => a!.compareTo(b!));

        if (sectionKeys.length > 1) {
          for (final sectionNo in sectionKeys) {
            widgets.add(_unitRow(
              label: 'Section $sectionNo',
              members: bySection[sectionNo]!,
              range: range,
              isHeader: false,
              indent: (showCompanyLevel ? 1 : 0) + (showPlatoonLevel ? 1 : 0),
            ));
          }
        }
      }
    }

    if (widgets.isEmpty) {
      // Scope is flat (e.g. a single section) — just show the totals
      // already covered by _buildOverallCounts above.
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Your scope has no further unit breakdown to show.',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
        ),
      ));
    }

    return widgets;
  }

  Widget _unitRow({
    required String label,
    required List<Member> members,
    required ({DateTime start, DateTime end}) range,
    required bool isHeader,
    int indent = 0,
  }) {
    final counts = _periodCounts(members, range);
    final total = members.length;

    return Padding(
      padding: EdgeInsets.only(left: indent * 16.0, bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isHeader
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey50.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$label ($total)',
                style: isHeader
                    ? AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)
                    : AppTextStyles.bodySmall,
              ),
            ),
            _miniCount(counts.availableMembers, Colors.green),
            const SizedBox(width: 10),
            _miniCount(counts.notAvailableMembers, Colors.orange),
            const SizedBox(width: 10),
            _miniCount(counts.onLeaveMembers, Colors.blueGrey),
          ],
        ),
      ),
    );
  }

  Widget _miniCount(int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$count', style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTrendHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Day-by-Day Trend', style: AppTextStyles.headingSmall),
        _TrendRangeSwitch(
          range: _trendRange,
          onChanged: (r) => setState(() => _trendRange = r),
        ),
      ],
    );
  }

  /// Builds the list of days to show in the trend chart based on the
  /// selected range — today (just 1 day), this week (7 days), or this
  /// month (full calendar month).
  List<DateTime> _trendDays() {
    final now = DateTime.now();
    switch (_trendRange) {
      case _TrendRange.today:
        return [DateTime(now.year, now.month, now.day)];
      case _TrendRange.week:
        return List.generate(7, (i) => _weekStart.add(Duration(days: i)));
      case _TrendRange.month:
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        return List.generate(
          daysInMonth,
          (i) => DateTime(now.year, now.month, i + 1),
        );
    }
  }

  Widget _buildTrendChart(List<Member> members) {
    final days = _trendDays();

    // Pre-compute counts per day once, rather than re-scanning members
    // for every bar during layout.
    final counts = days.map((day) {
      int available = 0, notAvailable = 0, onLeave = 0;
      for (final m in members) {
        switch (_statusOn(m, day)) {
          case DayAvailabilityStatus.available: available++;
          case DayAvailabilityStatus.notAvailable: notAvailable++;
          case DayAvailabilityStatus.onLeave: onLeave++;
        }
      }
      return (available, notAvailable, onLeave);
    }).toList();

    final maxCount = members.length == 0 ? 1 : members.length;
    final isCompact = days.length > 10;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(days.length, (i) {
              final (available, notAvailable, onLeave) = counts[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 0.5 : 2),
                  child: Tooltip(
                    message:
                        '${AppFormatters.date(days[i])}\nAvailable: $available\nNot Available: $notAvailable\nOn Leave: $onLeave',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _trendBarSegment(onLeave, maxCount, Colors.blueGrey),
                        _trendBarSegment(notAvailable, maxCount, Colors.orange),
                        _trendBarSegment(available, maxCount, Colors.green),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(days.length, (i) {
            final day = days[i];
            final showLabel = _trendRange != _TrendRange.month || day.day % 5 == 0 || i == 0;
            return Expanded(
              child: Text(
                showLabel
                    ? (_trendRange == _TrendRange.today
                        ? 'Today'
                        : '${day.day}')
                    : '',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500, fontSize: 9),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          children: [
            _legendDot(Colors.green, 'Available'),
            _legendDot(Colors.orange, 'Not Available'),
            _legendDot(Colors.blueGrey, 'On Leave'),
          ],
        ),
      ],
    );
  }

  Widget _trendBarSegment(int count, int maxCount, Color color) {
    final heightFraction = maxCount == 0 ? 0.0 : count / maxCount;
    return Container(
      height: 150 * heightFraction,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.85)),
    );
  }
}

/// 3-way switch between List / Grid / Summary view modes.
class _ViewModeSwitch extends StatelessWidget {
  final _ViewMode viewMode;
  final ValueChanged<_ViewMode> onChanged;
  const _ViewModeSwitch({required this.viewMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget seg(_ViewMode mode, IconData icon, String tooltip) {
      final isSelected = viewMode == mode;
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => onChanged(mode),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.grey500,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        seg(_ViewMode.list, Icons.list, 'List view'),
        seg(_ViewMode.grid, Icons.calendar_view_week, 'Grid view'),
        seg(_ViewMode.summary, Icons.bar_chart, 'Summary view'),
      ],
    );
  }
}

/// Today / Week / Month toggle for the trend chart inside Summary view.
class _TrendRangeSwitch extends StatelessWidget {
  final _TrendRange range;
  final ValueChanged<_TrendRange> onChanged;
  const _TrendRangeSwitch({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget seg(_TrendRange r, String label) {
      final isSelected = range == r;
      return InkWell(
        onTap: () => onChanged(r),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.grey700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey50.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          seg(_TrendRange.today, 'Today'),
          seg(_TrendRange.week, 'Week'),
          seg(_TrendRange.month, 'Month'),
        ],
      ),
    );
  }
}