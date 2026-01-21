import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: theme.isDark,
            onChanged: (v) => theme.toggleTheme(),
          ),
          const ListTile(
            title: Text('Notifications'),
            subtitle: Text('Reminders are scheduled 1 day before due time'),
          ),
        ],
      ),
    );
  }
}
