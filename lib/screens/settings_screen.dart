
import 'package:banglascan_pro/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the settings provider professionally
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeTile(context, settings),
          const Divider(indent: 20, endIndent: 20),
          _buildSectionHeader(context, 'Voice & Reading'),
          _buildSpeechRateSlider(context, settings),
          const Divider(indent: 20, endIndent: 20),
          _buildSectionHeader(context, 'Support & Info'),
          _buildInfoTile(context, Icons.info_outline_rounded, 'Version', '1.0.0 Stable'),
          _buildInfoTile(context, Icons.code_rounded, 'Engine', 'Google ML Kit'),
          _buildInfoTile(context, Icons.favorite_border_rounded, 'Made for', 'Bangladesh 🇧🇩'),
          const SizedBox(height: 40),
          Center(
            child: Text(
              '© 2024 BanglaScan Pro',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, SettingsProvider settings) {
    String currentMode = 'System';
    if (settings.themeMode == ThemeMode.light) currentMode = 'Light';
    if (settings.themeMode == ThemeMode.dark) currentMode = 'Dark';

    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('Current: $currentMode'),
      trailing: DropdownButton<String>(
        value: currentMode,
        underline: Container(),
        onChanged: (String? newValue) {
          if (newValue != null) settings.setThemeMode(newValue);
        },
        items: ['Light', 'Dark', 'System'].map((String mode) {
          return DropdownMenuItem<String>(
            value: mode,
            child: Text(mode),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpeechRateSlider(BuildContext context, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Speech Rate', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('${settings.speechRate.toStringAsFixed(1)}x', 
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: settings.speechRate,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (double value) => settings.setSpeechRate(value),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(value, style: const TextStyle(color: Colors.grey)),
    );
  }
}
