import 'package:flutter/material.dart';
import '../../../core/constants/brand_colors.dart';
import '../../../core/constants/theme.dart';
import 'pages/dashboard_page.dart';
import 'pages/review_page.dart';
import 'pages/progress_page.dart';
import 'pages/learning_path_page.dart';
import 'pages/profile_page.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentPageIndex = 0;

  BoxDecoration _appBackgroundDecoration(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return const BoxDecoration(gradient: ThingualColors.deepInkGradient);
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          ThingualColors.cloud,
          ThingualColors.cyanShade500.withValues(alpha: 0.30),
          Colors.white,
        ],
      ),
    );
  }

  final List<_NavigationItem> _navigationItems = const [
    _NavigationItem(
      label: 'Dashboard',
      icon: Icons.home,
      page: DashboardPage(),
    ),
    _NavigationItem(
      label: 'Learning Path',
      icon: Icons.school,
      page: LearningPathPage(),
    ),
    _NavigationItem(
      label: 'Progress',
      icon: Icons.trending_up,
      page: ProgressPage(),
    ),
    _NavigationItem(label: 'Review', icon: Icons.refresh, page: ReviewPage()),
    _NavigationItem(label: 'Profile', icon: Icons.person, page: ProfilePage()),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isMobile) {
      return Scaffold(
        body: DecoratedBox(
          decoration: _appBackgroundDecoration(context),
          child: _navigationItems[_currentPageIndex].page,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPageIndex,
          onTap: (index) {
            setState(() => _currentPageIndex = index);
          },
          items: [
            for (final item in _navigationItems)
              BottomNavigationBarItem(icon: Icon(item.icon), label: item.label),
          ],
          type: BottomNavigationBarType.fixed,
          selectedItemColor: ThingualColors.deepIndigo,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: isDark ? ThingualColors.darkSurface : Colors.white,
          selectedLabelStyle: Theme.of(context).textTheme.labelSmall,
          unselectedLabelStyle: Theme.of(context).textTheme.labelSmall,
        ),
      );
    } else {
      // Desktop/Tablet layout with sidebar
      return Scaffold(
        body: DecoratedBox(
          decoration: _appBackgroundDecoration(context),
          child: Row(
            children: [
              // Sidebar
              NavigationRail(
                selectedIndex: _currentPageIndex,
                onDestinationSelected: (index) {
                  setState(() => _currentPageIndex = index);
                },
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final item in _navigationItems)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                ],
                leading: Padding(
                  padding: const EdgeInsets.all(ThingualSpacing.lg),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: ThingualColors.primaryGradient,
                      borderRadius: BorderRadius.circular(ThingualRadius.md),
                    ),
                    child: const Center(
                      child: Text(
                        'T',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Outfit',
                          package: 'google_fonts',
                        ),
                      ),
                    ),
                  ),
                ),
                backgroundColor: isDark
                    ? ThingualColors.darkSurface
                    : Colors.white,
                selectedIconTheme: const IconThemeData(
                  color: ThingualColors.deepIndigo,
                ),
                unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
                selectedLabelTextStyle: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(
                      color: ThingualColors.deepIndigo,
                      fontWeight: FontWeight.w700,
                    ),
                unselectedLabelTextStyle: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
              ),
              // Content
              Expanded(child: _navigationItems[_currentPageIndex].page),
            ],
          ),
        ),
      );
    }
  }
}

class _NavigationItem {
  final String label;
  final IconData icon;
  final Widget page;

  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.page,
  });
}
