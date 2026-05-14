import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_scaffold.dart';

class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 3,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person_outline, size: 80, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text('Profile',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Coming in Phase 4 (Firebase auth)',
                style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
