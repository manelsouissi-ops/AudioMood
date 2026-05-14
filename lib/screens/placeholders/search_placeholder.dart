import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_scaffold.dart';

class SearchPlaceholder extends StatelessWidget {
  const SearchPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      currentIndex: 1,
      body: _ComingSoon(label: 'Search', phase: 'Phase 7'),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String label;
  final String phase;
  const _ComingSoon({required this.label, required this.phase});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 80, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Coming in $phase',
              style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
