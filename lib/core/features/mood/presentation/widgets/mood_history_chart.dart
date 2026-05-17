import 'package:flutter/material.dart';
import '../../../../../models/mood.dart';
import '../../../../theme/app_theme.dart';

class MoodHistoryChart extends StatelessWidget {
  final List<MoodResult> history;

  const MoodHistoryChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final counts = {for (final mood in MoodType.values) mood: 0};
    for (final result in history) {
      counts[result.mood] = (counts[result.mood] ?? 0) + 1;
    }

    final maxCount = counts.values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood history',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'A simple visualization of your recent detections.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'No mood history yet',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: MoodType.values.map((mood) {
                  final count = counts[mood] ?? 0;
                  final barHeight = maxCount == 0
                      ? 0.0
                      : (count / maxCount) * 120.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: barHeight < 8 && count > 0 ? 8 : barHeight,
                            decoration: BoxDecoration(
                              color: mood.color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mood.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
