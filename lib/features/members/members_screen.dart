import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/models.dart';
import '../../data/mock/mock_data.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_provider.dart';
import 'widgets/member_card.dart';
import 'member_detail_screen.dart';
import 'member_form_screen.dart';
import 'access_grant_approval_screen.dart';

enum _CompanyFilter { all, office, c1, c2, c3, c4 }
enum _RankFilter { all, officers, otherRanks }
enum _StatusFilter { all, active, inactive, available, notAvailable }

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _CompanyFilter _companyFilter = _CompanyFilter.all;
  _RankFilter _rankFilter = _RankFilter.all;
  _StatusFilter _statusFilter = _StatusFilter.all;

  // "My Unit" quick filter — narrows the list to the viewer's own
  // platoon (Platoon Leader) or own section (Section Leader/Deputy),
  // so they don't have to scroll the whole brigade-wide list to find
  // their own people. Defaults ON for these ranks since that's almost
  // always what they want first; easy to switch off via the chip.
  bool _myUnitOnly = false;
  bool _myUnitDefaultApplied = false;

  @override
  void initState() {
    super.initState();
    // Defer to after first frame so Provider is guaranteed available
    // and we don't trigger a setState during initState itself.
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyDefaultView());
  }

  /// Default view on first load, based on the logged-in member:
  ///   - Company-assigned members (anyone with a companyNo, i.e. not
  ///     Brigade Office) default the Company filter to their OWN
  ///     company, so they land on their unit instead of the whole
  ///     brigade roster.
  ///   - Platoon Leader / Section Leader additionally default the
  ///     "My Unit" quick filter on, narrowing further to their exact
  ///     platoon/section.
  ///   - Brigade Office members have no single company, so they keep
  ///     the full "All" view, which is appropriate for their scope.
  void _applyDefaultView() {
    if (_myUnitDefaultApplied || !mounted) return;
    final auth = context.read<AuthProvider>();
    final me = auth.currentMember;
    if (me == null) return;

    _myUnitDefaultApplied = true;
    setState(() {
      if (me.companyNo != null) {
        _companyFilter = _companyFilterForNumber(me.companyNo!);
      }
      if (_hasMyUnitScope(me)) _myUnitOnly = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Does the viewer have a "my unit" scope worth offering as a quick
  /// filter? Platoon Leader → own platoon. Section Leader/Deputy
  /// Section Leader → own section.
  bool _hasMyUnitScope(Member me) {
    return me.rank == MemberRank.platoonLeader ||
        me.rank == MemberRank.sectionLeader ||
        me.rank == MemberRank.deputySectionLeader;
  }

  String _myUnitLabel(Member me) {
    if (me.rank == MemberRank.platoonLeader) {
      return 'My Platoon';
    }
    return 'My Section';
  }

  bool _isInMyUnit(Member me, Member m) {
    if (me.rank == MemberRank.platoonLeader) {
      return m.companyNo == me.companyNo && m.platoonNo == me.platoonNo;
    }
    // Section Leader / Deputy Section Leader
    return m.companyNo == me.companyNo &&
        m.platoonNo == me.platoonNo &&
        m.sectionNo == me.sectionNo;
  }

  _CompanyFilter _companyFilterForNumber(int companyNo) {
    switch (companyNo) {
      case 1: return _CompanyFilter.c1;
      case 2: return _CompanyFilter.c2;
      case 3: return _CompanyFilter.c3;
      case 4: return _CompanyFilter.c4;
      default: return _CompanyFilter.all;
    }
  }

  List<Member> _scopedMembers(AuthProvider auth) {
    final all = MockMembers.all;
    final me = auth.currentMember;
    if (me == null) return [];

    // List visibility: brigade-wide for everyone. See
    // PermissionService.canSeeInMemberList for the full rule set.
    var result = all.where((m) => auth.canSeeInMemberList(m)).toList();

    if (_myUnitOnly && _hasMyUnitScope(me)) {
      result = result.where((m) => _isInMyUnit(me, m)).toList();
    }

    return result;
  }

  List<Member> _applyFilters(List<Member> members) {
    var result = members;

    // Company filter
    result = result.where((m) {
      switch (_companyFilter) {
        case _CompanyFilter.all: return true;
        case _CompanyFilter.office: return m.unitType == UnitType.brigadeOffice;
        case _CompanyFilter.c1: return m.companyNo == 1;
        case _CompanyFilter.c2: return m.companyNo == 2;
        case _CompanyFilter.c3: return m.companyNo == 3;
        case _CompanyFilter.c4: return m.companyNo == 4;
      }
    }).toList();

    // Rank filter
    result = result.where((m) {
      switch (_rankFilter) {
        case _RankFilter.all: return true;
        case _RankFilter.officers: return m.isOfficer;
        case _RankFilter.otherRanks: return !m.isOfficer;
      }
    }).toList();

    // Status filter
    result = result.where((m) {
      switch (_statusFilter) {
        case _StatusFilter.all: return true;
        case _StatusFilter.active: return m.status == MemberStatus.active;
        case _StatusFilter.inactive: return m.status == MemberStatus.inactive;
        case _StatusFilter.available: return m.isAvailable;
        case _StatusFilter.notAvailable: return !m.isAvailable;
      }
    }).toList();

    // Search query — name EN/MM, memberNo, rank, phone, NRC
    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      result = result.where((m) {
        return m.nameEn.toLowerCase().contains(q) ||
            m.nameMm.contains(_query.trim()) ||
            m.memberNo.toLowerCase().contains(q) ||
            m.rankNameEn.toLowerCase().contains(q) ||
            m.rankNameMm.contains(_query.trim()) ||
            m.phone.replaceAll(' ', '').contains(q.replaceAll(' ', '')) ||
            (m.nrc?.contains(_query.trim()) ?? false);
      }).toList();
    }

    // Sort by rank order (default)
    result.sort((a, b) =>
        RankHelper.rankOrder(a.rank).compareTo(RankHelper.rankOrder(b.rank)));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.currentMember;
    final scoped = _scopedMembers(auth);
    // Own profile gets its own pinned entry above — exclude from the
    // regular browsable list so it's not shown twice.
    final filtered = _applyFilters(scoped)
        .where((m) => me == null || m.id != me.id)
        .toList();
    final canAddDirectly = auth.canAddMemberDirectly;
    final canPropose = auth.canProposeNewMember;
    final showAddButton = canAddDirectly || canPropose;

    return Container(
      color: AppColors.grey50.withValues(alpha: 0.05),
      child: Stack(
        children: [
          Column(
            children: [
              if (me != null) _buildMyProfileCard(context, auth, me),
              if (me != null) _buildAccessGrantBanner(context, me),
              _buildSearchBar(auth),
              _buildFilterChips(auth),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _myUnitOnly && me != null && _hasMyUnitScope(me)
                        ? auth.tr(
                            '${filtered.length} member${filtered.length == 1 ? '' : 's'} in ${_myUnitLabel(me)}',
                            '${filtered.length} ဦး — ${_myUnitLabel(me)}',
                          )
                        : auth.tr(
                            '${filtered.length} member${filtered.length == 1 ? '' : 's'} found',
                            '${filtered.length} ဦး တွေ့ရှိသည်',
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
                          final member = filtered[index];
                          return MemberCard(
                            member: member,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MemberDetailScreen(memberId: member.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (showAddButton)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemberFormScreen(isProposal: !canAddDirectly),
                  ),
                ),
                icon: Icon(canAddDirectly ? Icons.person_add : Icons.person_add_alt_outlined),
                label: Text(canAddDirectly
                    ? auth.tr('Add Member', 'အဖွဲ့ဝင်ထည့်ရန်')
                    : auth.tr('Propose Member', 'အဖွဲ့ဝင်အဆိုပြုရန်')),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMyProfileCard(BuildContext context, AuthProvider auth, Member me) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        color: AppColors.primary.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MemberDetailScreen(memberId: me.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  backgroundImage:
                      me.photoUrl != null ? NetworkImage(me.photoUrl!) : null,
                  child: me.photoUrl == null
                      ? Text(me.initials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.tr('My Profile', 'ကိုယ်ပိုင်ကိုယ်ရေးအချက်အလက်'),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(me.nameEn, style: AppTextStyles.headingMedium),
                      Text(me.rankNameEn,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessGrantBanner(BuildContext context, Member me) {
    final isCompanyLead = me.rank == MemberRank.companyCommander ||
        me.rank == MemberRank.deputyCompanyCommander;
    if (!isCompanyLead) return const SizedBox.shrink();

    final pendingCount = MockAccessGrants.pendingFor(me.companyNo).length;
    if (pendingCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
            MaterialPageRoute(builder: (_) => const AccessGrantApprovalScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.lock_open_outlined, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$pendingCount access request${pendingCount == 1 ? '' : 's'} awaiting your review',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.orange),
              ],
            ),
          ),
        ),
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
          hintText: auth.tr('Search members...', 'အဖွဲ့ဝင် ရှာဖွေရန်...'),
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
    final me = auth.currentMember;
    final showMyUnitChip = me != null && _hasMyUnitScope(me);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (showMyUnitChip) ...[
            FilterChip(
              label: Text(_myUnitLabel(me)),
              selected: _myUnitOnly,
              onSelected: (val) => setState(() => _myUnitOnly = val),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: AppTextStyles.labelSmall.copyWith(
                color: _myUnitOnly ? AppColors.primary : AppColors.grey700,
                fontWeight: _myUnitOnly ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: _myUnitOnly
                    ? AppColors.primary
                    : AppColors.grey50.withValues(alpha: 0.3),
              ),
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 8),
          ],
          _dropdownChip(
            label: _companyLabel(_companyFilter),
            onSelected: (val) => setState(() => _companyFilter = val),
            items: _CompanyFilter.values,
            labelBuilder: _companyLabel,
          ),
          const SizedBox(width: 8),
          _dropdownChip(
            label: _rankLabel(_rankFilter),
            onSelected: (val) => setState(() => _rankFilter = val),
            items: _RankFilter.values,
            labelBuilder: _rankLabel,
          ),
          const SizedBox(width: 8),
          _dropdownChip(
            label: _statusLabel(_statusFilter),
            onSelected: (val) => setState(() => _statusFilter = val),
            items: _StatusFilter.values,
            labelBuilder: _statusLabel,
          ),
        ],
      ),
    );
  }

  String _companyLabel(_CompanyFilter f) => switch (f) {
        _CompanyFilter.all => 'All Units',
        _CompanyFilter.office => 'Brigade Office',
        _CompanyFilter.c1 => 'Company 1',
        _CompanyFilter.c2 => 'Company 2',
        _CompanyFilter.c3 => 'Company 3',
        _CompanyFilter.c4 => 'Company 4',
      };

  String _rankLabel(_RankFilter f) => switch (f) {
        _RankFilter.all => 'All Ranks',
        _RankFilter.officers => 'Officers',
        _RankFilter.otherRanks => 'Other Ranks',
      };

  String _statusLabel(_StatusFilter f) => switch (f) {
        _StatusFilter.all => 'All Status',
        _StatusFilter.active => 'Active',
        _StatusFilter.inactive => 'Inactive',
        _StatusFilter.available => 'Available',
        _StatusFilter.notAvailable => 'Not Available',
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
          const Icon(Icons.person_search, size: 48, color: AppColors.grey50),
          const SizedBox(height: 12),
          Text(
            auth.tr('No members found', 'မည်သည့်အဖွဲ့ဝင်မှ တွေ့မရှိပါ'),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700),
          ),
        ],
      ),
    );
  }
}
