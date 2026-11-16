import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../products/providers/product_provider.dart';
import '../../products/screens/product_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

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
              const PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    Icon(Icons.light_mode_rounded),
                    SizedBox(width: 12),
                    Text('Light Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_rounded),
                    SizedBox(width: 12),
                    Text('Dark Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    Icon(Icons.brightness_auto_rounded),
                    SizedBox(width: 12),
                    Text('System Default'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              ref.invalidate(productsProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Products',
          ),
        ],
      ),
      body: const ProductListScreen(),
    );
  }
}
