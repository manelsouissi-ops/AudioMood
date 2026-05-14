import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_scaffold.dart';

class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 4,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.settings, size: 80, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text('Settings',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Coming in Phase 7',
                style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
