import 'package:flutter/material.dart';

/// ゲームオーバー時に表示するダイアログ。
/// スコア、レベル、プレイ時間、過去のスコア履歴を表示し、
/// 「リトライ」または「タイトルに戻る」操作が可能。
class GameOverDialog extends StatelessWidget {
  /// 最終スコア
  final int score;

  /// 到達レベル
  final int level;

  /// 経過時間
  final Duration elapsed;

  /// ゲーム内で記録されたスコア履歴（プレイ中の履歴）
  final List<int> scoreHistory;

  /// リトライ時に呼び出すコールバック（新しいゲーム開始）
  final VoidCallback onRetry;

  /// タイトル画面に戻るときのコールバック
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
      title: const Text("Game Over"), // モーダルタイトル

      content: Column(
        mainAxisSize: MainAxisSize.min, // 内容に合わせて高さを最小限に
        children: [
          /// スコアや履歴の表示テキスト
          Text(
            "スコア: $score\n"
            "レベル: $level\n"
            "時間: ${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}\n\n"
            "スコア履歴: ${scoreHistory.join(", ")}",
          ),

          const SizedBox(height: 24),

          /// 下部にリトライ／タイトル戻るボタンを左右に分けて配置
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// タイトルに戻るボタン（左端）
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ダイアログを閉じる
                  onReturnToTitle(); // タイトル画面へ戻る
                },
                child: const Text("タイトルに戻る"),
              ),

              /// リトライボタン（右端）
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ダイアログを閉じる
                  onRetry(); // 新しいゲームを開始
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
