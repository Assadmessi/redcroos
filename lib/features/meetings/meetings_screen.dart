import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';
import 'meeting_detail_screen.dart';
import 'meeting_form_screen.dart';
import '../access/request_access_link.dart';

enum _StatusFilter { all, scheduled, inProgress, minutesDrafted, signed, published }
enum _TypeFilter { all, general, officer, committee, investigation, youthLeaders, youthGroup }

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _StatusFilter _statusFilter = _StatusFilter.all;
  _TypeFilter _typeFilter = _TypeFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Meeting> _scopedMeetings(AuthProvider auth) {
    final me = auth.currentMember;
    if (me == null) return [];
    return MockMeetings.visibleTo(me);
  }

  List<Meeting> _applyFilters(List<Meeting> meetings) {
    var result = meetings;

    result = result.where((m) {
      switch (_statusFilter) {
        case _StatusFilter.all: return true;
        case _StatusFilter.scheduled: return m.status == MeetingStatus.scheduled;
        case _StatusFilter.inProgress: return m.status == MeetingStatus.inProgress;
        case _StatusFilter.minutesDrafted: return m.status == MeetingStatus.minutesDrafted;
        case _StatusFilter.signed: return m.status == MeetingStatus.signed;
        case _StatusFilter.published: return m.status == MeetingStatus.published;
      }
    }).toList();

    result = result.where((m) {
      switch (_typeFilter) {
        case _TypeFilter.all: return true;
        case _TypeFilter.general: return m.type == MeetingType.general;
        case _TypeFilter.officer: return m.type == MeetingType.officer;
        case _TypeFilter.committee: return m.type == MeetingType.committee;
        case _TypeFilter.investigation: return m.type == MeetingType.investigation;
        case _TypeFilter.youthLeaders: return m.type == MeetingType.youthLeaders;
        case _TypeFilter.youthGroup: return m.type == MeetingType.youthGroup;
      }
    }).toList();

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      result = result.where((m) {
        return m.title.toLowerCase().contains(q) ||
            m.titleMm.contains(_query.trim()) ||
            m.location.toLowerCase().contains(q);
      }).toList();
    }

    result.sort((a, b) {
      final aActive = a.status == MeetingStatus.scheduled || a.status == MeetingStatus.inProgress;
      final bActive = b.status == MeetingStatus.scheduled || b.status == MeetingStatus.inProgress;
      if (aActive != bActive) return aActive ? -1 : 1;
      return aActive ? a.date.compareTo(b.date) : b.date.compareTo(a.date);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scoped = _scopedMeetings(auth);
    final filtered = _applyFilters(scoped);
    final canCreate = auth.canCreateMeeting;

    return Container(
      color: AppColors.grey50.withValues(alpha: 0.05),
      child: Stack(
        children: [
          Column(
            children: [
              if (!canCreate)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: RequestAccessLink(featureName: 'Meetings — Create for Unit'),
                ),
              _buildSearchBar(auth),
              _buildFilterChips(auth),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    auth.tr(
                      '${filtered.length} meeting${filtered.length == 1 ? '' : 's'} found',
                      '${filtered.length} အစည်းအဝေး တွေ့ရှိသည်',
                    ),
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(auth)
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 4),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final meeting = filtered[index];
                          return _MeetingCard(
                            meeting: meeting,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MeetingDetailScreen(meetingId: meeting.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (canCreate)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MeetingFormScreen()),
                ),
                icon: const Icon(Icons.add),
                label: Text(auth.tr('Schedule Meeting', 'အစည်းအဝေးချိန်းရန်')),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          hintText: auth.tr('Search meetings...', 'အစည်းအဝေး ရှာဖွေရန်...'),
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
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() => _query = value),
      ),
    );
  }

  Widget _buildFilterChips(AuthProvider auth) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _dropdownChip(
            label: _statusLabel(_statusFilter),
            onSelected: (val) => setState(() => _statusFilter = val),
            items: _StatusFilter.values,
            labelBuilder: _statusLabel,
          ),
          const SizedBox(width: 8),
          _dropdownChip(
            label: _typeLabel(_typeFilter),
            onSelected: (val) => setState(() => _typeFilter = val),
            items: _TypeFilter.values,
            labelBuilder: _typeLabel,
          ),
        ],
      ),
    );
  }

  String _statusLabel(_StatusFilter f) => switch (f) {
        _StatusFilter.all => 'All Status',
        _StatusFilter.scheduled => 'Scheduled',
        _StatusFilter.inProgress => 'In Progress',
        _StatusFilter.minutesDrafted => 'Minutes Drafted',
        _StatusFilter.signed => 'Signed',
        _StatusFilter.published => 'Published',
      };

  String _typeLabel(_TypeFilter f) => switch (f) {
        _TypeFilter.all => 'All Types',
        _TypeFilter.general => 'General',
        _TypeFilter.officer => 'Officer',
        _TypeFilter.committee => 'Committee',
        _TypeFilter.investigation => 'Investigation',
        _TypeFilter.youthLeaders => 'Youth Leaders',
        _TypeFilter.youthGroup => 'Youth Group',
      };

  Widget _dropdownChip<T>({
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

  Widget _buildEmptyState(AuthProvider auth) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_note_outlined, size: 48, color: AppColors.grey50),
          const SizedBox(height: 12),
          Text(
            auth.tr('No meetings found', 'မည်သည့်အစည်းအဝေးမှ တွေ့မရှိပါ'),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback onTap;
  const _MeetingCard({required this.meeting, required this.onTap});

  Color get _statusColor {
    switch (meeting.status) {
      case MeetingStatus.scheduled: return Colors.blue;
      case MeetingStatus.inProgress: return Colors.green;
      case MeetingStatus.minutesDrafted: return Colors.orange;
      case MeetingStatus.signed: return Colors.purple;
      case MeetingStatus.published: return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (meeting.status) {
      case MeetingStatus.scheduled: return 'Scheduled';
      case MeetingStatus.inProgress: return 'In Progress';
      case MeetingStatus.minutesDrafted: return 'Minutes Drafted';
      case MeetingStatus.signed: return 'Signed';
      case MeetingStatus.published: return 'Published';
    }
  }

  @override
  Widget build(BuildContext context) {
    final attended = meeting.attendedMemberIds.length;
    final invited = meeting.invitedMemberIds.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.groups_outlined, color: _statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meeting.title,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (meeting.meetingNumberDisplay != null)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.grey50.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('No. ${meeting.meetingNumberDisplay}',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Text(AppFormatters.date(meeting.date), style: AppTextStyles.labelSmall),
                        const SizedBox(width: 10),
                        const Icon(Icons.access_time, size: 12, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Text(meeting.timeDisplay, style: AppTextStyles.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(meeting.location, style: AppTextStyles.labelSmall, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_statusLabel,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor)),
                        ),
                        const SizedBox(width: 8),
                        if (meeting.status != MeetingStatus.scheduled)
                          Text('$attended/$invited attended',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFB0B0B0)),
            ],
          ),
        ),
      ),
    );
  }
}
