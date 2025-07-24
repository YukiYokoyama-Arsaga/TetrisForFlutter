import 'package:flutter/material.dart';
import 'package:tetris_for_flutter/screens/title_screen.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final int level;
  final Duration elapsed;
  final List<int> scoreHistory;
  final VoidCallback onRetry;
  final VoidCallback onReturnToTitle;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.level,
    required this.elapsed,
    required this.scoreHistory,
    required this.onRetry,
    required this.onReturnToTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Game Over"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "スコア: $score\n"
            "レベル: $level\n"
            "時間: ${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}\n\n"
            "スコア履歴: ${scoreHistory.join(", ")}",
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                // onPressed: () {
                //   Navigator.pop(context);
                //   onReturnToTitle();
                // },
                onPressed: () {
                  Navigator.pop(context); // ダイアログを閉じてから
                  Future.microtask(() {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const TitleScreen(),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  });
                },
                child: const Text("タイトルに戻る"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onRetry();
                },
                child: const Text("リトライ"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
