import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/mood.dart';
import '../../providers/mood_provider.dart';
import '../../providers/player_provider.dart';
import '../../services/deezer_service.dart';

class MoodResultScreen extends StatefulWidget {
  const MoodResultScreen({super.key});

  @override
  State<MoodResultScreen> createState() => _MoodResultScreenState();
}

class _MoodResultScreenState extends State<MoodResultScreen> {
  bool _loadingPlaylist = false;

  // Maps MoodType to a Deezer search query
  static String _queryForMood(MoodType mood) => switch (mood) {
        MoodType.happy => 'happy',
        MoodType.sad => 'sad songs',
        MoodType.angry => 'rock',
        MoodType.relaxed => 'relax',
        MoodType.energetic => 'workout',
        MoodType.calm => 'calm',
      };

  Future<void> _viewPlaylist(MoodType mood) async {
    setState(() => _loadingPlaylist = true);
    // Capture State.context refs before async gap
    final player = context.read<PlayerProvider>();
    try {
      final songs =
          await DeezerService().searchTracks(_queryForMood(mood));
      if (songs.isEmpty) throw Exception('No songs found for this mood');
      if (!mounted) return;
      await player.play(songs.first, queue: songs.skip(1).toList());
      if (!mounted) return;
      Navigator.pushNamed(context, '/player');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loadingPlaylist = false);
    }
  }

  void _showManualPicker() {
    // Atelier 7 pattern: context.read for one-shot method call
    final moodProvider = context.read<MoodProvider>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How are you feeling?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...MoodType.values.map((m) => ListTile(
                  leading: Text(m.emoji,
                      style: const TextStyle(fontSize: 28)),
                  title: Text(m.label,
                      style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    moodProvider.setMood(m, 1.0);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Atelier 7 pattern: context.watch rebuilds when mood changes
    final result = context.watch<MoodProvider>().current;

    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No mood detected',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (r) => false),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final mood = result.mood;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Your Mood',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Emoji badge
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: mood.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: mood.color, width: 2),
                ),
                child: Center(
                    child: Text(mood.emoji,
                        style: const TextStyle(fontSize: 64))),
              ),
              const SizedBox(height: 20),

              Text(
                mood.label,
                style: TextStyle(
                    color: mood.color,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Confidence bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Confidence',
                            style: TextStyle(color: AppColors.textMuted)),
                        Text(result.confidencePercent,
                            style: TextStyle(
                                color: mood.color,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: result.confidence,
                        backgroundColor: Colors.white12,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(mood.color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Message card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mood.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: mood.color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  "You seem ${mood.label}! Here's a playlist for you \u{1F3B5}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, height: 1.4),
                ),
              ),
              const SizedBox(height: 28),

              // View Playlist button — searches Deezer for mood-matching tracks
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _loadingPlaylist ? null : () => _viewPlaylist(mood),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loadingPlaylist
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('View My Playlist',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),

              // Re-scan button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _loadingPlaylist
                      ? null
                      : () => Navigator.pushReplacementNamed(
                          context, '/camera-scan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Re-scan',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: _loadingPlaylist ? null : _showManualPicker,
                child: const Text(
                  "Not what you feel? Choose manually",
                  style: TextStyle(
                      color: AppColors.textMuted,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
