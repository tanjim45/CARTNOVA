import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

      home: const CartNovaHome(),
    );
  }
}


class CartNovaHome extends ConsumerWidget {
  const CartNovaHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CartNova',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<ThemeMode>(
            tooltip: 'Change Theme',
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : themeMode == ThemeMode.light
                      ? Icons.light_mode_rounded
                      : Icons.brightness_auto_rounded,
            ),
            onSelected: (mode) {
              ref.read(themeProvider.notifier).changeTheme(mode);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ThemeMode.light,
                child: const Row(
                  children: [
                    Icon(Icons.light_mode_rounded),
                    SizedBox(width: 12),
                    Text('Light Mode'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: const Row(
                  children: [
                    Icon(Icons.dark_mode_rounded),
                    SizedBox(width: 12),
                    Text('Dark Mode'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.system,
                child: const Row(
                  children: [
                    Icon(Icons.brightness_auto_rounded),
                    SizedBox(width: 12),
                    Text('System Default'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to CartNova',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Your style, your shopping experience.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Shopping experience coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Explore Shopping'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
