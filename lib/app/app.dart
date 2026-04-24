import 'package:flutter/material.dart';
import 'theme.dart';
import 'routes.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/page_transitions.dart';
import '../core/widgets/floating_navbar.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/destination/presentation/pages/discovery_page.dart';
import '../features/schedule/presentation/pages/schedule_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

/// MEMOtrip Root App Widget
class MemoTripApp extends StatelessWidget {
  const MemoTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
      // Apply custom page transitions to all named routes
      onGenerateRoute: (settings) {
        final routeBuilders = AppRoutes.routes;
        final builder = routeBuilders[settings.name];
        if (builder != null) {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, _, __) => builder(context),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: PageTransitions.defaultTransitionBuilder,
          );
        }
        return null;
      },
    );
  }
}

/// Main app shell with floating navbar and animated page transitions.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pages = const [
      DashboardPage(),
      DiscoveryPage(),
      SchedulePage(),
      ProfilePage(),
    ];

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.value = 1.0;
    _slideController.value = 1.0;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    // Animate in the new page
    _fadeController.value = 0;
    _slideController.value = 0;
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page content with animated transition
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _pages,
                  ),
                ),
              );
            },
          ),
          // Floating navbar
          FloatingNavbar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ],
      ),
    );
  }
}
