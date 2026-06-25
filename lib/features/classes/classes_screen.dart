import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../auth/auth_provider.dart';
import 'class_detail_screen.dart';
import 'class_form_screen.dart';
import 'closure_report_edit_requests_screen.dart';
import 'nomination_list_form_screen.dart';

enum _StatusFilter { all, draft, open, full, ongoing, completed, archived }
enum _TypeFilter { all, classRoom, workshop, seminar, drill, other }

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _StatusFilter _statusFilter = _StatusFilter.all;
  _TypeFilter _typeFilter = _TypeFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TrainingClass> _scopedClasses(AuthProvider auth) {
    final me = auth.currentMember;
    if (me == null) return [];
    return MockClasses.visibleTo(me);
  }

  List<TrainingClass> _applyFilters(List<TrainingClass> classes) {
    var result = classes;

    result = result.where((c) {
      switch (_statusFilter) {
        case _StatusFilter.all: return true;
        case _StatusFilter.draft: return c.status == ClassStatus.draft;
        case _StatusFilter.open: return c.status == ClassStatus.open;
        case _StatusFilter.full: return c.status == ClassStatus.full;
        case _StatusFilter.ongoing: return c.status == ClassStatus.ongoing;
        case _StatusFilter.completed: return c.status == ClassStatus.completed;
        case _StatusFilter.archived: return c.status == ClassStatus.archived;
      }
    }).toList();

    result = result.where((c) {
      switch (_typeFilter) {
        case _TypeFilter.all: return true;
        case _TypeFilter.classRoom: return c.type == ClassType.classRoom;
        case _TypeFilter.workshop: return c.type == ClassType.workshop;
        case _TypeFilter.seminar: return c.type == ClassType.seminar;
        case _TypeFilter.drill: return c.type == ClassType.drill;
        case _TypeFilter.other: return c.type == ClassType.other;
      }
    }).toList();

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      result = result.where((c) {
        return c.title.toLowerCase().contains(q) ||
            c.titleMm.contains(_query.trim()) ||
            c.category.toLowerCase().contains(q);
      }).toList();
    }

    result.sort((a, b) {
      final aActive = a.status == ClassStatus.open || a.status == ClassStatus.ongoing || a.status == ClassStatus.full;
      final bActive = b.status == ClassStatus.open || b.status == ClassStatus.ongoing || b.status == ClassStatus.full;
      if (aActive != bActive) return aActive ? -1 : 1;
      return aActive ? a.startDate.compareTo(b.startDate) : b.startDate.compareTo(a.startDate);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scoped = _scopedClasses(auth);
    final filtered = _applyFilters(scoped);
    final canCreate = auth.canCreateClass;
    final canApproveClosureEdits = auth.canApproveClosureReportEditRequest;
    final pendingClosureEdits = MockClosureReportEditRequests.pending().length;

    return Container(
      color: AppColors.grey50.withValues(alpha: 0.05),
      child: Stack(
        children: [
          Column(
            children: [
              if (canApproveClosureEdits && pendingClosureEdits > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Card(
                    color: Colors.orange.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.withValues(alpha: 0.25)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClosureReportEditRequestsScreen()),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_open_outlined, color: Colors.orange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$pendingClosureEdits closure report edit request${pendingClosureEdits == 1 ? '' : 's'} awaiting review',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.orange),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              _buildSearchBar(auth),
              _buildFilterChips(auth),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    auth.tr(
                      '${filtered.length} class${filtered.length == 1 ? '' : 'es'} found',
                      '${filtered.length} သင်တန်း တွေ့ရှိသည်',
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
                          final trainingClass = filtered[index];
                          return _ClassCard(
                            trainingClass: trainingClass,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClassDetailScreen(classId: trainingClass.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (auth.currentMember?.companyNo != null &&
              auth.canSubmitNominationList(auth.currentMember!.companyNo!))
            Positioned(
              right: 16,
              bottom: canCreate ? 76 : 16,
              child: FloatingActionButton.extended(
                heroTag: 'nominate',
                backgroundColor: AppColors.grey700,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NominationListFormScreen()),
                ),
                icon: const Icon(Icons.playlist_add_check_outlined),
                label: const Text('Nominate Members'),
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
                  MaterialPageRoute(builder: (_) => const ClassFormScreen()),
                ),
                icon: const Icon(Icons.add),
                label: Text(auth.tr('Create Class', 'သင်တန်းသစ်ဖန်တီးရန်')),
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
          hintText: auth.tr('Search classes...', 'သင်တန်း ရှာဖွေရန်...'),
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
        _StatusFilter.draft => 'Draft',
        _StatusFilter.open => 'Open',
        _StatusFilter.full => 'Full',
        _StatusFilter.ongoing => 'Ongoing',
        _StatusFilter.completed => 'Completed',
        _StatusFilter.archived => 'Archived',
      };

  String _typeLabel(_TypeFilter f) => switch (f) {
        _TypeFilter.all => 'All Types',
        _TypeFilter.classRoom => 'Classroom',
        _TypeFilter.workshop => 'Workshop',
        _TypeFilter.seminar => 'Seminar',
        _TypeFilter.drill => 'Drill',
        _TypeFilter.other => 'Other',
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
          Icon(Icons.school_outlined, size: 48, color: AppColors.grey50),
          const SizedBox(height: 12),
          Text(
            auth.tr('No classes found', 'မည်သည့်သင်တန်းမှ တွေ့မရှိပါ'),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final TrainingClass trainingClass;
  final VoidCallback onTap;
  const _ClassCard({required this.trainingClass, required this.onTap});

  Color get _statusColor {
    switch (trainingClass.status) {
      case ClassStatus.draft: return Colors.grey;
      case ClassStatus.open: return Colors.blue;
      case ClassStatus.full: return Colors.orange;
      case ClassStatus.ongoing: return Colors.green;
      case ClassStatus.completed: return Colors.purple;
      case ClassStatus.archived: return Colors.grey;
    }
  }

  IconData get _typeIcon {
    switch (trainingClass.type) {
      case ClassType.classRoom: return Icons.school_outlined;
      case ClassType.workshop: return Icons.handyman_outlined;
      case ClassType.seminar: return Icons.record_voice_over_outlined;
      case ClassType.drill: return Icons.fitness_center_outlined;
      case ClassType.other: return Icons.event_note_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      trainingClass.title,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Text(AppFormatters.date(trainingClass.startDate), style: AppTextStyles.labelSmall),
                        const SizedBox(width: 10),
                        Icon(Icons.location_on_outlined, size: 12, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(trainingClass.location, style: AppTextStyles.labelSmall, overflow: TextOverflow.ellipsis),
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
                          child: Text(
                            trainingClass.status.name.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${trainingClass.enrolledCount}/${trainingClass.maxParticipants} enrolled',
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
}
