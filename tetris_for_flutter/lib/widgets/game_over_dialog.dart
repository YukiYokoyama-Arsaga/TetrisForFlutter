import 'package:flutter/material.dart';

import 'score_table.dart';

class GameOverDialog extends StatelessWidget {
  final VoidCallback onRestart;
  final List<Map<String, dynamic>> scoreHistory;

  const GameOverDialog({
    super.key,
    required this.onRestart,
    required this.scoreHistory,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Game Over"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("ブロックが積み上がりました"),
            const SizedBox(height: 16),
            Expanded(child: ScoreTable(scoreHistory: scoreHistory)),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.pop(context);
            onRestart();
          },
        ),
      ],
    );
  }
}
