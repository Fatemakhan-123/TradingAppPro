import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/main_shell.dart';
import 'core/app_colors/app_colors.dart';
import 'core/providers/holdings_provider.dart';
import 'core/providers/orders_provider.dart';
import 'core/providers/wallet_provider.dart';
import 'core/providers/watchlist_provider.dart';
import 'core/services/market_data_service.dart';
import 'core/services/persistence_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final persistence = PersistenceService();
  await persistence.init();

  final market = MarketDataService(ticksPerSecondPerStock: 1.5);
  market.start();

  runApp( MyApp(persistence: persistence, market: market));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.persistence, required this.market});

  final PersistenceService persistence;
  final MarketDataService market;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MarketDataService>.value(value: market),
        ChangeNotifierProvider<WatchlistProvider>(
          create: (_) => WatchlistProvider(persistence)..load(),
        ),
        ChangeNotifierProvider<WalletProvider>(
          create: (_) => WalletProvider(persistence)..load(),
        ),
        ChangeNotifierProvider<OrdersProvider>(
          create: (_) => OrdersProvider(persistence)..load(),
        ),
        ChangeNotifierProvider<HoldingsProvider>(
          create: (_) => HoldingsProvider(persistence, market)..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Trading Pro',
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            primary: AppColors.primaryColor,
            secondary: AppColors.secondaryColor,
            surface: AppColors.cardDark,
            background: AppColors.bgDark,
          ),
          scaffoldBackgroundColor: AppColors.bgDark,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.bgDark,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: const TextStyle(
              color: AppColors.textDarkPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          cardTheme: CardThemeData(
            color: AppColors.cardDark,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              color: AppColors.textDarkPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
            headlineMedium: TextStyle(
              color: AppColors.textDarkPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            titleLarge: TextStyle(
              color: AppColors.textDarkPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: TextStyle(
              color: AppColors.textDarkPrimary,
              fontSize: 16,
            ),
            bodyMedium: TextStyle(
              color: AppColors.textDarkSecondary,
              fontSize: 14,
            ),
          ),
        ),
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor,
            secondary: AppColors.secondaryColor,
            surface: AppColors.cardLight,
            background: AppColors.bgLight,
          ),
          scaffoldBackgroundColor: AppColors.bgLight,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.bgLight,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: const TextStyle(
              color: AppColors.textLightPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          cardTheme: CardThemeData(
            color: AppColors.cardLight,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        themeMode: ThemeMode.dark,
        home: const MainShell(),
      ),
    );
  }
}
