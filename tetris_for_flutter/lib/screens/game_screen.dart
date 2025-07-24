import 'package:flutter/material.dart';

import '../widgets/tetris_board.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Score and Level will appear here',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const Expanded(child: Center(child: TetrisBoard())),
          ],
        ),
      ),
    );
  }
}
