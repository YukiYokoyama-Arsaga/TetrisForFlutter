import 'package:flutter/material.dart';

import '../widgets/tetris_board.dart';

/// テトリスのプレイ画面を構成するウィジェット。
/// スコア・レベル表示＋盤面（TetrisBoard）を含む。
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 背景色を黒に設定（ゲームっぽさ演出）
      body: SafeArea(
        child: Column(
          children: [
            /// スコアやレベルなどの情報表示欄（後で動的に表示予定）
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Score and Level will appear here',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            /// 盤面エリア。TetrisBoard（ステート管理含む）を中央に配置
            const Expanded(
              child: Center(
                child: TetrisBoard(), // 実際のゲームロジックと描画を担当
              ),
            ),
          ],
        ),
      ),
    );
  }
}
