import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/admin_sidebar.dart';
import 'overview_page.dart';
import 'devices_page.dart';
import 'destinations_page.dart';
import 'moderation_page.dart';
import 'analytics_page.dart';
import 'users_management_page.dart';
import '../../../../core/providers/role_provider.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});
  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final AnimationController _transitionCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  List<Widget> get _pages {
    final isSuper = ref.watch(isSuperAdminProvider);
    return [
      const OverviewPage(),
      const DevicesPage(),
      const DestinationsPage(),
      const ModerationPage(),
      const AnalyticsPage(),
      if (isSuper) const UsersManagementPage(),
    ];
  }

  List<String> get _navLabels {
    final isSuper = ref.watch(isSuperAdminProvider);
    return [
      'Overview',
      'Perangkat IoT',
      'Destinasi',
      'Moderasi',
      'Analitik',
      if (isSuper) 'Kelola User',
    ];
  }

  List<(IconData, String)> get _navItems {
    final isSuper = ref.watch(isSuperAdminProvider);
    return [
      (Icons.dashboard_rounded, 'Ringkasan'),
      (Icons.sensors_rounded, 'Perangkat IoT'),
      (Icons.map_rounded, 'Destinasi'),
      (Icons.rate_review_rounded, 'Moderasi'),
      (Icons.analytics_rounded, 'Analitik'),
      if (isSuper) (Icons.people_rounded, 'Kelola User'),
    ];
  }

  @override
  void initState() {
    super.initState();
    _transitionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(
      parent: _transitionCtrl,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionCtrl,
      curve: Curves.easeOutCubic,
    ));
    _transitionCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _transitionCtrl.dispose();
    super.dispose();
  }

  void _onPageSelected(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _transitionCtrl.value = 0;
    _transitionCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        if (isWide) {
          // ── DESKTOP MODE: Permanent sidebar ──
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                  gradient: AppColors.backgroundGradientDeep),
              child: Row(children: [
                AdminSidebar(
                  selectedIndex: _selectedIndex,
                  onTap: _onPageSelected,
                  navItems: _navItems,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                        child: KeyedSubtree(
                          key: ValueKey(_selectedIndex),
                          child: _pages[_selectedIndex],
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          );
        } else {
          // ── MOBILE MODE: Drawer + AppBar ──
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () =>
                    _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Text(
                _navLabels[_selectedIndex],
                style: AppTypography.headlineSmall.copyWith(
                  color: Colors.white,
                ),
              ),
              centerTitle: false,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Builder(
                    builder: (context) {
                      final authAsync = ref.watch(authUserProvider);
                      final user = authAsync.valueOrNull;
                      final initial = (user?.displayName?.isNotEmpty == true)
                          ? user!.displayName!.substring(0, 1).toUpperCase()
                          : 'A';
                      return CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(initial,
                            style: AppTypography.labelSmall
                                .copyWith(color: Colors.white)),
                      );
                    },
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: AdminSidebar(
                selectedIndex: _selectedIndex,
                onTap: _onPageSelected,
                navItems: _navItems,
                isDrawerMode: true,
              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
                  gradient: AppColors.backgroundGradientDeep),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                          opacity: animation, child: child);
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: _pages[_selectedIndex],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
