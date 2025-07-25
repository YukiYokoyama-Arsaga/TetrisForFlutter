import 'package:flutter/material.dart';

import 'screens/title_screen.dart';

/// アプリのエントリーポイント（main関数）
/// runApp に TetrisApp を渡してアプリケーションを起動
void main() {
  runApp(const TetrisApp());
}

/// アプリ全体のルートウィジェット
/// MaterialApp を使ってアプリ全体のテーマやルーティングを管理
class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // 最初に表示する画面を TitleScreen に設定
      home: TitleScreen(),

      // 右上のデバッグバナーを非表示にする
      debugShowCheckedModeBanner: false,
    );
  }
}
