import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';
import 'duty_detail_screen.dart';
import 'duty_form_screen.dart';
import 'emergency_duty_form_screen.dart';
import '../access/request_access_link.dart';

enum _StatusFilter { all, upcoming, ongoing, completed, cancelled }
enum _TypeFilter { all, regular, largeScale }

class DutiesScreen extends StatefulWidget {
  const DutiesScreen({super.key});

  @override
  State<DutiesScreen> createState() => _DutiesScreenState();
}

class _DutiesScreenState extends State<DutiesScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _StatusFilter _statusFilter = _StatusFilter.all;
  _TypeFilter _typeFilter = _TypeFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Duty> _scopedDuties(AuthProvider auth) {
    final me = auth.currentMember;
    if (me == null) return [];
    return MockDuties.visibleTo(me);
  }

  List<Duty> _applyFilters(List<Duty> duties) {
    var result = duties;

    result = result.where((d) {
      switch (_statusFilter) {
        case _StatusFilter.all: return true;
        case _StatusFilter.upcoming: return d.status == DutyStatus.upcoming;
        case _StatusFilter.ongoing: return d.status == DutyStatus.ongoing;
        case _StatusFilter.completed: return d.status == DutyStatus.completed;
        case _StatusFilter.cancelled: return d.status == DutyStatus.cancelled;
      }
    }).toList();

    result = result.where((d) {
      switch (_typeFilter) {
        case _TypeFilter.all: return true;
        case _TypeFilter.regular: return d.scale == DutyScale.regular;
        case _TypeFilter.largeScale: return d.scale == DutyScale.largeScale;
      }
    }).toList();

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      result = result.where((d) {
        return d.title.toLowerCase().contains(q) ||
            d.titleMm.contains(_query.trim()) ||
            d.location.toLowerCase().contains(q);
      }).toList();
    }

    // Sort: upcoming/ongoing first (soonest first), then completed/cancelled
    // (most recent first)
    result.sort((a, b) {
      final aActive = a.status == DutyStatus.upcoming || a.status == DutyStatus.ongoing;
      final bActive = b.status == DutyStatus.upcoming || b.status == DutyStatus.ongoing;
      if (aActive != bActive) return aActive ? -1 : 1;
      return aActive ? a.date.compareTo(b.date) : b.date.compareTo(a.date);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scoped = _scopedDuties(auth);
    final filtered = _applyFilters(scoped);
    final canCreate = auth.canCreateDuty;

    return Container(
      color: AppColors.grey50.withValues(alpha: 0.05),
      child: Stack(
        children: [
          Column(
            children: [
              if (!canCreate)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: RequestAccessLink(featureName: 'Duties — Create/Edit/Cancel/Delete'),
                ),
              _buildSearchBar(auth),
              _buildFilterChips(auth),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    auth.tr(
                      '${filtered.length} dut${filtered.length == 1 ? 'y' : 'ies'} found',
                      '${filtered.length} တာဝန် တွေ့ရှိသည်',
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
                          final duty = filtered[index];
                          return _DutyCard(
                            duty: duty,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DutyDetailScreen(dutyId: duty.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (auth.canCreateEmergencyDuty)
            Positioned(
              right: 16,
              bottom: canCreate ? 76 : 16,
              child: FloatingActionButton.extended(
                heroTag: 'emergency',
                backgroundColor: Colors.red,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmergencyDutyFormScreen()),
                ),
                icon: const Icon(Icons.emergency_outlined),
                label: const Text('Report Emergency'),
              ),
            ),
          if (canCreate)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                heroTag: 'create',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DutyFormScreen()),
                ),
                icon: const Icon(Icons.add),
                label: Text(auth.tr('Create Duty', 'တာဝန်သစ်ဖန်တီးရန်')),
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
          hintText: auth.tr('Search duties...', 'တာဝန် ရှာဖွေရန်...'),
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
        _StatusFilter.upcoming => 'Upcoming',
        _StatusFilter.ongoing => 'Ongoing',
        _StatusFilter.completed => 'Completed',
        _StatusFilter.cancelled => 'Cancelled',
      };

  String _typeLabel(_TypeFilter f) => switch (f) {
        _TypeFilter.all => 'All Types',
        _TypeFilter.regular => 'Regular',
        _TypeFilter.largeScale => 'Large Scale',
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
          Icon(Icons.event_busy, size: 48, color: AppColors.grey50),
          const SizedBox(height: 12),
          Text(
            auth.tr('No duties found', 'မည်သည့်တာဝန်မှ တွေ့မရှိပါ'),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}

class _DutyCard extends StatelessWidget {
  final Duty duty;
  final VoidCallback onTap;
  const _DutyCard({required this.duty, required this.onTap});

  Color get _statusColor {
    switch (duty.status) {
      case DutyStatus.upcoming: return Colors.blue;
      case DutyStatus.ongoing: return Colors.green;
      case DutyStatus.completed: return Colors.grey;
      case DutyStatus.cancelled: return Colors.red;
    }
  }

  IconData get _typeIcon {
    switch (duty.type) {
      case DutyType.firstAid: return Icons.medical_services_outlined;
      case DutyType.bloodDonation: return Icons.bloodtype_outlined;
      case DutyType.training: return Icons.school_outlined;
      case DutyType.patrol: return Icons.directions_walk_outlined;
      case DutyType.eventMedical: return Icons.local_hospital_outlined;
      case DutyType.disaster: return Icons.warning_amber_outlined;
      case DutyType.administrative: return Icons.assignment_outlined;
      case DutyType.emergency: return Icons.emergency_outlined;
      case DutyType.other: return Icons.event_note_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accepted = duty.members.where((m) => m.status == DutyAssignmentStatus.accepted).length;
    final pending = duty.members.where((m) => m.status == DutyAssignmentStatus.pending).length;

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
                child: Icon(_typeIcon, color: _statusColor, size: 22),
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
                            duty.title,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (duty.scale == DutyScale.largeScale)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('LARGE SCALE',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.purple)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Text(AppFormatters.date(duty.date), style: AppTextStyles.labelSmall),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time, size: 12, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Text(duty.startTimeDisplay, style: AppTextStyles.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(duty.location, style: AppTextStyles.labelSmall, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statusBadge(),
                        const SizedBox(width: 8),
                        if (duty.status == DutyStatus.upcoming || duty.status == DutyStatus.ongoing)
                          Text(
                            '$accepted accepted, $pending pending',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey500),
                          ),
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

  Widget _statusBadge() {
    final label = switch (duty.status) {
      DutyStatus.upcoming => 'Upcoming',
      DutyStatus.ongoing => 'Ongoing',
      DutyStatus.completed => 'Completed',
      DutyStatus.cancelled => 'Cancelled',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor)),
    );
  }
}
