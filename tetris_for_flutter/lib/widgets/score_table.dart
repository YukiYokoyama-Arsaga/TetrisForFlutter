import 'package:flutter/material.dart';

class ScoreRecord {
  final int score;
  final int level;
  final Duration playTime;
  final DateTime playedAt;

  ScoreRecord({
    required this.score,
    required this.level,
    required this.playTime,
    required this.playedAt,
  });
}

class ScoreTable extends StatelessWidget {
  final List<Map<String, dynamic>> scoreHistory;

  const ScoreTable({super.key, required this.scoreHistory});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('スコア')),
          DataColumn(label: Text('レベル')),
          DataColumn(label: Text('行数')),
          DataColumn(label: Text('時間')),
        ],
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
