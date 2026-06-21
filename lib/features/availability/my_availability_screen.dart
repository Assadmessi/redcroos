import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';

class MyAvailabilityScreen extends StatefulWidget {
  final String? memberId; // null = current user's own calendar
  const MyAvailabilityScreen({super.key, this.memberId});

  @override
  State<MyAvailabilityScreen> createState() => _MyAvailabilityScreenState();
}

/// Wraps [MyAvailabilityScreen] in its own Scaffold + back-button AppBar,
/// for use when pushed as a standalone route (e.g. from
/// UnitAvailabilityScreen tapping a member). The bare [MyAvailabilityScreen]
/// itself is body-only, since it's also used directly as a shell page
/// (the "My Availability" nav item), which already provides its own
/// top bar — see app_shell.dart's _buildPage().
class MyAvailabilityPage extends StatelessWidget {
  final String? memberId;
  const MyAvailabilityPage({super.key, this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      body: MyAvailabilityScreen(memberId: memberId),
    );
  }
}

class _MyAvailabilityScreenState extends State<MyAvailabilityScreen> {
  late DateTime _visibleMonth;
  bool _rangeMode = false;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
      _rangeStart = null;
      _rangeEnd = null;
    });
  }

  void _onDayTap(Member target, DateTime day, AuthProvider auth) {
    if (_rangeMode) {
      setState(() {
        if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
          _rangeStart = day;
          _rangeEnd = null;
        } else if (day.isBefore(_rangeStart!)) {
          _rangeEnd = _rangeStart;
          _rangeStart = day;
        } else {
          _rangeEnd = day;
        }
      });
      return;
    }
    _showStatusPicker(target, day, day, auth);
  }

  void _confirmRange(Member target, AuthProvider auth) {
    if (_rangeStart == null) return;
    final end = _rangeEnd ?? _rangeStart!;
    _showStatusPicker(target, _rangeStart!, end, auth);
  }

  /// Primary way to set a continuous range — a direct From/To date
  /// picker dialog, no calendar tapping required. The tap-to-select
  /// range mode (_rangeMode) remains available as an alternative for
  /// when picking dates visually on the calendar is easier.
  Future<void> _pickContinuousRange(Member target, AuthProvider auth) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day),
      ),
      helpText: 'Select continuous range',
      saveText: 'Next',
    );
    if (picked == null) return;
    _showStatusPicker(target, picked.start, picked.end, auth);
  }

  void _showStatusPicker(
    Member target,
    DateTime startDate,
    DateTime endDate,
    AuthProvider auth,
  ) {
    final isRange = !(startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day);
    final label = isRange
        ? '${AppFormatters.date(startDate)} – ${AppFormatters.date(endDate)}'
        : AppFormatters.date(startDate);

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(label, style: AppTextStyles.headingSmall),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: const Text('Available'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _applyOrRequest(
                    target, startDate, endDate, DayAvailabilityStatus.available, auth,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_busy, color: Colors.orange),
                title: const Text('Not Available'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _applyOrRequest(
                    target, startDate, endDate, DayAvailabilityStatus.notAvailable, auth,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear, color: Colors.grey),
                title: const Text('Clear (reset to default)'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() {
                    var d = startDate;
                    while (!d.isAfter(endDate)) {
                      MockAvailability.clearDay(memberId: target.id, date: d);
                      d = d.add(const Duration(days: 1));
                    }
                    _rangeStart = null;
                    _rangeEnd = null;
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _applyOrRequest(
    Member target,
    DateTime startDate,
    DateTime endDate,
    DayAvailabilityStatus status,
    AuthProvider auth,
  ) {
    // Available/Not Available is always a direct change now — no
    // approval step, for self or for someone else. We still notify the
    // target's full chain of command up to Brigade Office as an FYI.
    setState(() {
      MockAvailability.setRange(
        memberId: target.id,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );
      _rangeStart = null;
      _rangeEnd = null;
    });

    if (status == DayAvailabilityStatus.available ||
        status == DayAvailabilityStatus.notAvailable) {
      MockNotifications.notifyChainOfCommandOfAvailabilityChange(
        member: target,
        isNowAvailable: status == DayAvailabilityStatus.available,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_statusLabel(status)} set')),
    );
  }

  String _statusLabel(DayAvailabilityStatus status) {
    switch (status) {
      case DayAvailabilityStatus.available: return 'Available';
      case DayAvailabilityStatus.notAvailable: return 'Not Available';
      case DayAvailabilityStatus.onLeave: return 'On Leave';
    }
  }

  Color _statusColor(DayAvailabilityStatus status) {
    switch (status) {
      case DayAvailabilityStatus.available: return Colors.green;
      case DayAvailabilityStatus.notAvailable: return Colors.orange;
      case DayAvailabilityStatus.onLeave: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.currentMember;
    if (me == null) return const SizedBox.shrink();

    final target = widget.memberId == null
        ? me
        : (MockMembers.findById(widget.memberId!) ?? me);

    final entries = MockAvailability.forMemberInMonth(
      target.id, _visibleMonth.year, _visibleMonth.month,
    );
    final ranges = AvailabilityRangeHelper.collapse(entries);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  target.id == me.id
                      ? auth.tr('My Availability', 'ကိုယ်ပိုင်အားလပ်ချိန်')
                      : '${target.nameEn} — Availability',
                  style: AppTextStyles.headingMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.date_range_outlined),
                tooltip: 'Set continuous range',
                onPressed: () => _pickContinuousRange(target, auth),
              ),
              IconButton(
                icon: Icon(_rangeMode ? Icons.event_repeat : Icons.touch_app_outlined),
                tooltip: _rangeMode ? 'Range mode ON (tap days)' : 'Tap days to select a range',
                onPressed: () => setState(() {
                  _rangeMode = !_rangeMode;
                  _rangeStart = null;
                  _rangeEnd = null;
                }),
              ),
            ],
          ),
        ),
        _buildMonthHeader(),
        _buildLegend(),
        if (_rangeMode) _buildRangeBanner(target, auth),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCalendarGrid(target, entries, auth),
                if (ranges.isNotEmpty) _buildRangeSummary(ranges),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthHeader() {
    final monthName = _monthName(_visibleMonth.month);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text('$monthName ${_visibleMonth.year}', style: AppTextStyles.headingMedium),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    Widget dot(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey700)),
          ],
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 16,
        children: [
          dot(Colors.green, 'Available'),
          dot(Colors.orange, 'Not Available'),
          dot(Colors.blueGrey, 'On Leave'),
        ],
      ),
    );
  }

  Widget _buildRangeBanner(Member target, AuthProvider auth) {
    final hasSelection = _rangeStart != null;
    final label = !hasSelection
        ? 'Tap a start day, then an end day'
        : _rangeEnd == null
            ? 'Start: ${AppFormatters.date(_rangeStart!)} — now tap an end day'
            : '${AppFormatters.date(_rangeStart!)} – ${AppFormatters.date(_rangeEnd!)}';

    return Container(
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySmall)),
          if (_rangeStart != null)
            TextButton(
              onPressed: () => _confirmRange(target, auth),
              child: const Text('Set Status'),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    Member target,
    List<AvailabilityEntry> entries,
    AuthProvider auth,
  ) {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday % 7; // Sunday = 0

    final entryByDay = <int, AvailabilityEntry>{};
    for (final e in entries) {
      entryByDay[e.date.day] = e;
    }

    const weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            children: weekdayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final dayNum = index - leadingBlanks + 1;
              final day = DateTime(_visibleMonth.year, _visibleMonth.month, dayNum);
              final entry = entryByDay[dayNum];
              final isToday = _isSameDay(day, DateTime.now());
              final isInSelectedRange = _rangeStart != null &&
                  !day.isBefore(_rangeStart!) &&
                  (_rangeEnd == null ? day == _rangeStart : !day.isAfter(_rangeEnd!));

              return InkWell(
                onTap: () => _onDayTap(target, day, auth),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isInSelectedRange
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : entry != null
                            ? _statusColor(entry.status).withValues(alpha: 0.15)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '$dayNum',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (entry != null)
                        Positioned(
                          bottom: 4,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 5, height: 5,
                              decoration: BoxDecoration(
                                color: _statusColor(entry.status),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSummary(List<AvailabilityRange> ranges) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Month', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          ...ranges.map((r) => Card(
                child: ListTile(
                  dense: true,
                  leading: Container(
                    width: 10, height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(r.status), shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    r.isSingleDay
                        ? AppFormatters.date(r.startDate)
                        : '${AppFormatters.date(r.startDate)} – ${AppFormatters.date(r.endDate)}',
                  ),
                  subtitle: Text(
                    '${_statusLabel(r.status)}${r.isSingleDay ? '' : ' · ${r.dayCount} days'}',
                  ),
                ),
              )),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month - 1];
  }
}