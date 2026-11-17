import 'package:cartnova_app/core/database/hive_database.dart';
import 'package:cartnova_app/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();

  runApp(
    const ProviderScope(
      child: CartNovaApp(),
    ),
  );
}

class CartNovaApp extends ConsumerWidget {
  const CartNovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'CartNova',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          AppTheme.lightTheme.textTheme,
        ),
      ),

      darkTheme: AppTheme.darkTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          AppTheme.darkTheme.textTheme,
        ),
      ),

      themeMode: themeMode,

      home: const HomeScreen(),
    );
  }
}
