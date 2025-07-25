import 'package:flutter/material.dart';

/// スコア記録を表すモデルクラス（未使用）
/// 今後、型安全な履歴管理を行う場合に利用可能
class ScoreRecord {
  final int score; // 最終スコア
  final int level; // 到達レベル
  final Duration playTime; // プレイ時間
  final DateTime playedAt; // プレイ日時

  ScoreRecord({
    required this.score,
    required this.level,
    required this.playTime,
    required this.playedAt,
  });
}

/// スコア履歴を表形式で表示するウィジェット。
/// スコア・レベル・消去行数・プレイ時間を含む。
class ScoreTable extends StatelessWidget {
  /// スコア履歴（各要素は Map<String, dynamic>）
  /// 期待されるキー: score, level, lines, time
  final List<Map<String, dynamic>> scoreHistory;

  const ScoreTable({super.key, required this.scoreHistory});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // 縦スクロール可能にする

      child: DataTable(
        columns: const [
          DataColumn(label: Text('スコア')), // 得点
          DataColumn(label: Text('レベル')), // 最終レベル
          DataColumn(label: Text('行数')), // 消した行数
          DataColumn(label: Text('時間')), // 経過時間
        ],

        // 各スコア記録を1行のDataRowとして表示
        rows: scoreHistory.map((record) {
          return DataRow(
            cells: [
              DataCell(Text(record['score'].toString())),
              DataCell(Text(record['level'].toString())),
              DataCell(Text(record['lines'].toString())),
              DataCell(Text(record['time'].toString())),
            ],
          );
        }).toList(),
      ),
    );
  }
}
