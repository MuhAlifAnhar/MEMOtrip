import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/admin_sidebar.dart';
import 'overview_page.dart';
import 'devices_page.dart';
import 'destinations_page.dart';
import 'moderation_page.dart';
import 'analytics_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  late final AnimationController _transitionCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  final List<Widget> _pages = const [
    OverviewPage(),
    DevicesPage(),
    DestinationsPage(),
    ModerationPage(),
    AnalyticsPage(),
  ];

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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradientDeep),
        child: Row(children: [
        AdminSidebar(
          selectedIndex: _selectedIndex,
          onTap: _onPageSelected,
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
                  return FadeTransition(opacity: animation, child: child);
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
  }
}
