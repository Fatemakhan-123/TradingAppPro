import 'package:flutter/material.dart';

import '../core/app_colors/app_colors.dart';
import '../screens/holdings/holdings_screen.dart';
import '../screens/live_prices/live_prices_screen.dart';
import '../screens/watchlist/watchlist_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  late ValueNotifier<int> currentIndex;
  late AnimationController _animationController;

  static const _screens = [
    WatchlistListScreen(),
    LivePricesScreen(),
    HoldingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = ValueNotifier<int>(0);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    currentIndex.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: ValueListenableBuilder(
        valueListenable: currentIndex,
        builder: (context, value, child) {
          return IndexedStack(index: value, children: _screens);
        },
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: currentIndex,
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: value,
              backgroundColor: AppColors.cardDark,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              indicatorColor: AppColors.primaryColor.withOpacity(0.2),
              elevation: 0,
              onDestinationSelected: (i) {
                currentIndex.value = i;
              },
              destinations: [
                NavigationDestination(
                  icon: Tooltip(
                    message: 'Watchlist',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: value == 0
                            ? AppColors.primaryColor.withOpacity(0.2)
                            : AppColors.transparent,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        value == 0 ? Icons.star : Icons.star_border,
                        size: 22,
                        color: value == 0
                            ? AppColors.primaryColor
                            : AppColors.textDarkSecondary,
                      ),
                    ),
                  ),
                  selectedIcon: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.star,
                      size: 22,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  label: 'Watchlist',
                ),
                NavigationDestination(
                  icon: Tooltip(
                    message: 'Live Prices',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: value == 1
                            ? AppColors.primaryColor.withOpacity(0.2)
                            : AppColors.transparent,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.show_chart,
                        size: 22,
                        color: value == 1
                            ? AppColors.primaryColor
                            : AppColors.textDarkSecondary,
                      ),
                    ),
                  ),
                  selectedIcon: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.show_chart,
                      size: 22,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  label: 'Live Prices',
                ),
                NavigationDestination(
                  icon: Tooltip(
                    message: 'Holdings',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: value == 2
                            ? AppColors.primaryColor.withOpacity(0.2)
                            : AppColors.transparent,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        value == 2 ? Icons.pie_chart : Icons.pie_chart_outline,
                        size: 22,
                        color: value == 2
                            ? AppColors.primaryColor
                            : AppColors.textDarkSecondary,
                      ),
                    ),
                  ),
                  selectedIcon: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.pie_chart,
                      size: 22,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  label: 'Holdings',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
