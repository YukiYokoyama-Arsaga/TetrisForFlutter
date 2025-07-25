import 'package:flutter/material.dart';

import 'game_screen.dart';

/// アプリ起動時に最初に表示されるタイトル画面。
/// ゲーム開始ボタンを押すと GameScreen に遷移する。
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 黒背景（レトロゲーム風）
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 縦中央揃え
          children: [
            /// ゲームタイトルの表示
            const Text(
              'TETRIS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            /// ゲーム開始ボタン
            ElevatedButton(
              onPressed: () {
                // GameScreen へ画面遷移（通常の push）
                // pushReplacement にすると戻るボタンで戻れなくなる
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
