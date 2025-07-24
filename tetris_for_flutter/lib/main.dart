import 'package:flutter/material.dart';

import 'screens/title_screen.dart';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TitleScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
