import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../data/mock/mock_data.dart';
import '../auth/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../members/members_screen.dart';
import '../duties/duties_screen.dart';
import '../meetings/meetings_screen.dart';
import '../classes/classes_screen.dart';
import '../access/access_requests_overview_screen.dart';
import '../availability/my_availability_screen.dart';
import '../availability/unit_availability_screen.dart';

// ─────────────────────────────────────────────
// NAV ITEM MODEL
// ─────────────────────────────────────────────
class _NavItem {
  final String id;
  final String labelEn;
  final String labelMm;
  final IconData icon;
  final IconData iconFilled;
  final bool requiresPermission;

  const _NavItem({
    required this.id,
    required this.labelEn,
    required this.labelMm,
    required this.icon,
    required this.iconFilled,
    this.requiresPermission = false,
  });
}

const _navItems = [
  _NavItem(id: 'dashboard', labelEn: 'Dashboard', labelMm: 'ဒက်ရှ်ဘုတ်', icon: Icons.dashboard_outlined, iconFilled: Icons.dashboard_rounded),
  _NavItem(id: 'members', labelEn: 'Members', labelMm: 'အဖွဲ့ဝင်များ', icon: Icons.group_outlined, iconFilled: Icons.group_rounded),
  _NavItem(id: 'my_availability', labelEn: 'My Availability', labelMm: 'ကိုယ်ပိုင်အားလပ်ချိန်', icon: Icons.event_available_outlined, iconFilled: Icons.event_available_rounded),
  _NavItem(id: 'unit_availability', labelEn: 'Unit Availability', labelMm: 'တပ်ဖွဲ့ အားလပ်ချိန်', icon: Icons.event_note_outlined, iconFilled: Icons.event_note_rounded, requiresPermission: true),
  _NavItem(id: 'duties', labelEn: 'Duties', labelMm: 'တာဝန်များ', icon: Icons.calendar_today_outlined, iconFilled: Icons.calendar_today_rounded),
  _NavItem(id: 'meetings', labelEn: 'Meetings', labelMm: 'အစည်းအဝေး', icon: Icons.groups_outlined, iconFilled: Icons.groups_rounded),
  _NavItem(id: 'classes', labelEn: 'Classes', labelMm: 'သင်တန်းများ', icon: Icons.school_outlined, iconFilled: Icons.school_rounded),
  _NavItem(id: 'blood', labelEn: 'Blood', labelMm: 'သွေးလှူ', icon: Icons.bloodtype_outlined, iconFilled: Icons.bloodtype_rounded),
  _NavItem(id: 'reports', labelEn: 'Reports', labelMm: 'အစီရင်ခံ', icon: Icons.bar_chart_outlined, iconFilled: Icons.bar_chart_rounded),
  _NavItem(id: 'investigation', labelEn: 'Investigations', labelMm: 'စုံစမ်းစစ်', icon: Icons.search_outlined, iconFilled: Icons.search_rounded, requiresPermission: true),
  _NavItem(id: 'youth', labelEn: 'Youth Wing', labelMm: 'လူငယ်အဖွဲ့', icon: Icons.star_outline_rounded, iconFilled: Icons.star_rounded),
  _NavItem(id: 'library', labelEn: 'Library', labelMm: 'စာကြည့်တိုက်', icon: Icons.menu_book_outlined, iconFilled: Icons.menu_book_rounded),
  _NavItem(id: 'certificates', labelEn: 'Certificates', labelMm: 'လက်မှတ်', icon: Icons.workspace_premium_outlined, iconFilled: Icons.workspace_premium_rounded),
  _NavItem(id: 'equipment', labelEn: 'Equipment', labelMm: 'ပစ္စည်းများ', icon: Icons.inventory_2_outlined, iconFilled: Icons.inventory_2_rounded),
  _NavItem(id: 'fund', labelEn: 'Fund', labelMm: 'ရန်ပုံငွေ', icon: Icons.account_balance_outlined, iconFilled: Icons.account_balance_rounded, requiresPermission: true),
  _NavItem(id: 'archive', labelEn: 'Archive', labelMm: 'မှတ်တမ်း', icon: Icons.archive_outlined, iconFilled: Icons.archive_rounded),
  _NavItem(id: 'settings', labelEn: 'Settings', labelMm: 'ဆက်တင်', icon: Icons.settings_outlined, iconFilled: Icons.settings_rounded),
  _NavItem(id: 'access_requests', labelEn: 'Access Requests', labelMm: 'အသုံးပြုခွင့် တောင်းခံမှုများ', icon: Icons.lock_open_outlined, iconFilled: Icons.lock_open_rounded),
];

const _bottomNavIds = ['dashboard', 'duties', 'meetings', 'blood', 'settings'];

// ─────────────────────────────────────────────
// APP SHELL
// ─────────────────────────────────────────────
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _currentPage = 'dashboard';
  bool _sidebarCollapsed = false;

  void _navigate(String page) {
    setState(() => _currentPage = page);
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppResponsive.isDesktop(context);
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Sidebar(
                currentPage: _currentPage,
                collapsed: _sidebarCollapsed,
                onNavigate: _navigate,
                onToggleCollapse: () =>
                    setState(() => _sidebarCollapsed = !_sidebarCollapsed),
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopBar(currentPage: _currentPage),
                      Expanded(
                        child: _PageContent(currentPage: _currentPage),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    final auth = context.watch<AuthProvider>();
    final isEN = auth.language == AppLanguage.english;
    final bottomItems = _navItems.where((i) => _bottomNavIds.contains(i.id)).toList();
    final currentBottomIndex = bottomItems.indexWhere((i) => i.id == _currentPage);

    return Scaffold(
      appBar: _MobileAppBar(
        currentPage: _currentPage,
        onOpenDrawer: () => _openMobileDrawer(),
      ),
      drawer: _MobileDrawer(
        currentPage: _currentPage,
        onNavigate: _navigate,
      ),
      body: _PageContent(currentPage: _currentPage),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentBottomIndex < 0 ? 0 : currentBottomIndex,
        onDestinationSelected: (i) => _navigate(bottomItems[i].id),
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primaryLight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: bottomItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon, color: AppColors.grey500),
            selectedIcon: Icon(item.iconFilled, color: AppColors.primary),
            label: isEN ? item.labelEn : item.labelMm,
          );
        }).toList(),
      ),
    );
  }

  void _openMobileDrawer() {
    Scaffold.of(context).openDrawer();
  }
}

// ─────────────────────────────────────────────
// SIDEBAR
// ─────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final String currentPage;
  final bool collapsed;
  final void Function(String) onNavigate;
  final VoidCallback onToggleCollapse;

  const _Sidebar({
    required this.currentPage,
    required this.collapsed,
    required this.onNavigate,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final member = auth.currentMember;
    final isEN = auth.language == AppLanguage.english;
    final w = collapsed
        ? AppDimensions.sidebarCollapsedWidth
        : AppDimensions.sidebarWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: w,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          _SidebarHeader(
            collapsed: collapsed,
            isEN: isEN,
            onToggle: onToggleCollapse,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _navItems.map((item) {
                if (item.requiresPermission) {
                  if (item.id == 'investigation' && !auth.isBrigadeWide) {
                    return const SizedBox.shrink();
                  }
                  if (item.id == 'fund' && !auth.canViewFund) {
                    return const SizedBox.shrink();
                  }
                  if (item.id == 'unit_availability' && !auth.canAssignDuty) {
                    return const SizedBox.shrink();
                  }
                }
                return _SidebarItem(
                  item: item,
                  isSelected: currentPage == item.id,
                  collapsed: collapsed,
                  isEN: isEN,
                  onTap: () => onNavigate(item.id),
                );
              }).toList(),
            ),
          ),
          _SidebarUserTile(
            member: member,
            collapsed: collapsed,
            isEN: isEN,
            onLogout: () => auth.logout(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIDEBAR HEADER
// ─────────────────────────────────────────────
class _SidebarHeader extends StatelessWidget {
  final bool collapsed;
  final bool isEN;
  final VoidCallback onToggle;

  const _SidebarHeader({
    required this.collapsed,
    required this.isEN,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.sidebarDivider)),
      ),
      child: Row(
        mainAxisAlignment: collapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          if (!collapsed) ...[
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('✚',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      isEN ? 'Red Cross' : 'ကြက်ခြေနီ',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('✚',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          ],
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              collapsed ? Icons.chevron_right : Icons.chevron_left,
              color: AppColors.sidebarSubtext,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIDEBAR ITEM
// ─────────────────────────────────────────────
class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final bool collapsed;
  final bool isEN;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.collapsed,
    required this.isEN,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collapsed ? (isEN ? item.labelEn : item.labelMm) : '',
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: isSelected
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                isSelected ? item.iconFilled : item.icon,
                size: AppDimensions.iconMd,
                color: isSelected ? AppColors.primary : AppColors.sidebarText,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEN ? item.labelEn : item.labelMm,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.sidebarText,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIDEBAR USER TILE
// ─────────────────────────────────────────────
class _SidebarUserTile extends StatelessWidget {
  final dynamic member;
  final bool collapsed;
  final bool isEN;
  final VoidCallback onLogout;

  const _SidebarUserTile({
    required this.member,
    required this.collapsed,
    required this.isEN,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.sidebarDivider)),
      ),
      child: collapsed
          ? IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded,
                  color: AppColors.sidebarSubtext, size: 20),
              tooltip: 'Sign Out',
            )
          : Row(
              children: [
                _Avatar(
                  initials: member?.initials ?? '??',
                  memberId: member?.id ?? '',
                  size: 36,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEN
                            ? (member?.nameEn ?? 'Unknown')
                            : (member?.nameMm ?? member?.nameEn ?? 'Unknown'),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        member?.rankNameEn ?? '',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.sidebarSubtext,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.sidebarSubtext, size: 18),
                  tooltip: 'Sign Out',
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String currentPage;
  const _TopBar({required this.currentPage});

  String _getTitle(String page, bool isEN) {
    final item = _navItems.firstWhere((i) => i.id == page,
        orElse: () => _navItems.first);
    return isEN ? item.labelEn : item.labelMm;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isEN = auth.language == AppLanguage.english;
    final unread = MockNotifications.unreadCount(auth.currentMember?.id ?? '');

    return Container(
      height: AppDimensions.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          Text(_getTitle(currentPage, isEN), style: AppTextStyles.headingMedium),
          const Spacer(),
          TextButton.icon(
            onPressed: auth.toggleLanguage,
            icon: const Text('🌐', style: TextStyle(fontSize: 14)),
            label: Text(
              isEN ? 'MM' : 'EN',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.grey600),
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: AppColors.grey600),
              ),
              if (unread > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(unread.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MOBILE APP BAR
// ─────────────────────────────────────────────
class _MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentPage;
  final VoidCallback onOpenDrawer;

  const _MobileAppBar({
    required this.currentPage,
    required this.onOpenDrawer,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isEN = auth.language == AppLanguage.english;
    final item = _navItems.firstWhere((i) => i.id == currentPage,
        orElse: () => _navItems.first);
    final unread = MockNotifications.unreadCount(auth.currentMember?.id ?? '');

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: Builder(
        builder: (ctx) => IconButton(
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          icon: const Icon(Icons.menu_rounded, color: AppColors.grey700),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text('✚',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: 8),
          Text(isEN ? item.labelEn : item.labelMm,
              style: AppTextStyles.headingSmall),
        ],
      ),
      actions: [
        IconButton(
          onPressed: auth.toggleLanguage,
          icon: Text(
            isEN ? 'MM' : 'EN',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.grey600),
            ),
            if (unread > 0)
              Positioned(
                right: 6, top: 6,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(unread.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// MOBILE DRAWER
// ─────────────────────────────────────────────
class _MobileDrawer extends StatelessWidget {
  final String currentPage;
  final void Function(String) onNavigate;

  const _MobileDrawer({
    required this.currentPage,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final member = auth.currentMember;
    final isEN = auth.language == AppLanguage.english;

    return Drawer(
      backgroundColor: AppColors.sidebarBg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _Avatar(
                    initials: member?.initials ?? '??',
                    memberId: member?.id ?? '',
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEN
                              ? (member?.nameEn ?? '')
                              : (member?.nameMm ?? member?.nameEn ?? ''),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${member?.memberNo ?? ''} · ${member?.rankNameEn ?? ''}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.sidebarSubtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.sidebarDivider, height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _navItems.map((item) {
                  if (item.requiresPermission) {
                    if (item.id == 'investigation' && !auth.isBrigadeWide) {
                      return const SizedBox.shrink();
                    }
                    if (item.id == 'fund' && !auth.canViewFund) {
                      return const SizedBox.shrink();
                    }
                    if (item.id == 'unit_availability' && !auth.canAssignDuty) {
                      return const SizedBox.shrink();
                    }
                  }
                  final isSelected = currentPage == item.id;
                  return ListTile(
                    onTap: () => onNavigate(item.id),
                    leading: Icon(
                      isSelected ? item.iconFilled : item.icon,
                      color: isSelected ? AppColors.primary : AppColors.sidebarText,
                      size: 22,
                    ),
                    title: Text(
                      isEN ? item.labelEn : item.labelMm,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.sidebarText,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    tileColor: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(color: AppColors.sidebarDivider, height: 1),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                auth.logout();
              },
              leading: const Icon(Icons.logout_rounded, color: AppColors.sidebarSubtext),
              title: Text(
                isEN ? 'Sign Out' : 'ထွက်ရန်',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.sidebarSubtext,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PAGE CONTENT ROUTER
// ─────────────────────────────────────────────
class _PageContent extends StatelessWidget {
  final String currentPage;
  const _PageContent({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey(currentPage),
          child: _buildPage(context),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    switch (currentPage) {
      case 'dashboard':
        return const DashboardScreen();
      case 'members':
        return const MembersScreen();
      case 'duties':
        return const DutiesScreen();
      case 'meetings':
        return const MeetingsScreen();
      case 'classes':
        return const ClassesScreen();
      case 'access_requests':
        return const AccessRequestsOverviewScreen();
      case 'my_availability':
        return const MyAvailabilityScreen();
      case 'unit_availability':
        return const UnitAvailabilityScreen();
      default:
        return _ComingSoonPage(pageId: currentPage);
    }
  }
}

// ─────────────────────────────────────────────
// COMING SOON PLACEHOLDER
// ─────────────────────────────────────────────
class _ComingSoonPage extends StatelessWidget {
  final String pageId;
  const _ComingSoonPage({required this.pageId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isEN = auth.language == AppLanguage.english;
    final item = _navItems.firstWhere((i) => i.id == pageId,
        orElse: () => _navItems.first);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(item.icon, size: 32, color: AppColors.grey400),
          ),
          const SizedBox(height: 20),
          Text(isEN ? item.labelEn : item.labelMm,
              style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          Text(
            isEN
                ? 'This module is coming in a future update'
                : 'ဤ module ကို နောက်မှ ထည့်သွင်းမည်',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Module ${_getModuleNumber(pageId)}',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  String _getModuleNumber(String pageId) {
    const map = {
      'members': '3', 'duties': '4', 'meetings': '5',
      'classes': '6', 'blood': '7', 'reports': '8',
      'investigation': '9', 'youth': '10', 'library': '11',
      'certificates': '11', 'equipment': '12', 'fund': '12',
      'archive': '13', 'settings': '14',
    };
    return map[pageId] ?? '?';
  }
}

// ─────────────────────────────────────────────
// AVATAR WIDGET
// ─────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String initials;
  final String memberId;
  final double size;

  const _Avatar({
    required this.initials,
    required this.memberId,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final color = AvatarColorGen.fromString(memberId);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class AppAvatar extends StatelessWidget {
  final String initials;
  final String memberId;
  final double size;

  const AppAvatar({
    super.key,
    required this.initials,
    required this.memberId,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return _Avatar(initials: initials, memberId: memberId, size: size);
  }
}
