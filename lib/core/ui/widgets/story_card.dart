import 'package:flutter/material.dart';
import '../zyra_theme.dart';

/// Logical size of a 9:16 story card; captured at pixelRatio 4 it is 1080x1920.
const storyCardWidth = 270.0;
const storyCardHeight = 480.0;

/// A 9:16 card for Instagram/TikTok stories: [emoji], a big [value] with a
/// [caption], and a few [lines] of detail.
class StoryCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String value;
  final String caption;
  final List<String> lines;
  final String footer;

  const StoryCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.value,
    required this.caption,
    this.lines = const [],
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: storyCardWidth,
      height: storyCardHeight,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 56),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF241C0A), Color(0xFF1E1E1E)],
        ),
      ),
      child: Column(
        children: [
          Text(
            'STUDY CAFE',
            style: TextStyle(
              color: ZyraColors.primary,
              fontSize: 14,
              letterSpacing: 4,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          Text(emoji,
              style: const TextStyle(
                  fontSize: 56, decoration: TextDecoration.none)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 2,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: ZyraColors.primary,
              fontSize: 72,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                l,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          const Spacer(),
          Text(
            footer,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
