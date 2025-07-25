import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris_for_flutter/widgets/game_over_dialog.dart';

import '../models/block.dart';
import '../utils/block_factory.dart';

/// テトリスのプレイエリアを構成するウィジェット
/// ブロックの移動、回転、落下、スコア・レベル管理などの処理を含む
class TetrisBoard extends StatefulWidget {
  const TetrisBoard({super.key});

  @override
  State<TetrisBoard> createState() => _TetrisBoardState();
}

class _TetrisBoardState extends State<TetrisBoard> {
  static const int rowCount = 20; // 盤面の行数
  static const int colCount = 10; // 盤面の列数

  Timer? _timer; // ブロック自動落下用タイマー
  late DateTime _startTime; // ゲーム開始時間
  Duration _elapsed = Duration.zero; // 経過時間

  late Block currentBlock; // 現在操作中のブロック
  Block? holdBlock; // ホールド中のブロック
  bool hasHeld = false; // このターンでホールド済かどうか
  Block? nextBlock; // 次に出現するブロック

  // 盤面に固定されたブロックの情報（true = ブロックあり）
  List<List<bool>> fixedBlocks = List.generate(
    rowCount,
    (_) => List.filled(colCount, false),
  );

  int _score = 0; // 現在のスコア
  final List<int> _scoreHistory = []; // スコア履歴

  // レベル計算（1000点ごとに1レベルアップ）
  int get _level => (_score ~/ 1000).clamp(0, 10);
  int get _nextLevelThreshold => (_level + 1) * 1000 - _score;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  /// ゲーム開始時の初期化処理
  void _startGame() {
    currentBlock = createRandomBlock();
    nextBlock = createRandomBlock();
    _score = 0;
    _elapsed = Duration.zero;
    _startTime = DateTime.now();
    _startFalling();
  }

  /// ブロックの自動落下処理を開始
  void _startFalling() {
    _timer?.cancel();
    _timer = Timer.periodic(_currentSpeed(), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime);

        if (_canMoveDown()) {
          currentBlock.row++;
        } else {
          fixCurrentBlock();
          checkAndClearLines();
          hasHeld = false;
          currentBlock = nextBlock!;
          nextBlock = createRandomBlock();

          // ゲームオーバー判定
          if (isGameOver(currentBlock)) {
            _scoreHistory.add(_score);
            _timer?.cancel();

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => GameOverDialog(
                score: _score,
                level: _level,
                elapsed: _elapsed,
                scoreHistory: _scoreHistory,
                onRetry: () {
                  setState(() {
                    fixedBlocks = List.generate(
                      rowCount,
                      (_) => List.filled(colCount, false),
                    );
                    _startGame();
                  });
                },
                onReturnToTitle: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
            );
          }
        }
      });
    });
  }

  /// 現在のレベルに応じたブロック落下速度を返す
  Duration _currentSpeed() {
    return Duration(milliseconds: 500 - _level * 40);
  }

  /// ブロックを盤面に固定する
  void fixCurrentBlock() {
    for (final point in currentBlock.occupiedCells) {
      if (point.row < rowCount && point.col >= 0 && point.col < colCount) {
        fixedBlocks[point.row][point.col] = true;
      }
    }
  }

  /// ブロックが1マス下に移動可能かどうかを判定
  bool _canMoveDown() {
    for (final point in currentBlock.occupiedCells) {
      final belowRow = point.row + 1;
      if (belowRow >= rowCount || fixedBlocks[belowRow][point.col]) {
        return false;
      }
    }
    return true;
  }

  /// ゲームオーバーかどうかを判定（ブロックが既に占有マスと重なる）
  bool isGameOver(Block block) {
    for (final point in block.occupiedCells) {
      if (point.row >= rowCount || fixedBlocks[point.row][point.col]) {
        return true;
      }
    }
    return false;
  }

  /// 揃った行を削除し、スコアを加算
  void checkAndClearLines() {
    int cleared = 0;
    fixedBlocks.removeWhere((row) {
      if (row.every((cell) => cell)) {
        cleared++;
        return true;
      }
      return false;
    });
    while (fixedBlocks.length < rowCount) {
      fixedBlocks.insert(0, List.filled(colCount, false));
    }
    _score += _getScoreForClearedLines(cleared);
    _resetTimerWithSpeed();
  }

  /// スコア更新後、落下速度を再設定
  void _resetTimerWithSpeed() {
    _timer?.cancel();
    _startFalling();
  }

  /// 消去行数に応じたスコアを返す
  int _getScoreForClearedLines(int lines) {
    switch (lines) {
      case 1:
        return 100;
      case 2:
        return 300;
      case 3:
        return 500;
      case 4:
        return 800;
      default:
        return 0;
    }
  }

  /// ブロックの位置が有効かどうかをチェック（範囲内かつ固定ブロックと重ならない）
  bool isValidPosition(Block block) {
    for (final point in block.occupiedCells) {
      if (point.row < 0 ||
          point.row >= rowCount ||
          point.col < 0 ||
          point.col >= colCount ||
          fixedBlocks[point.row][point.col]) {
        return false;
      }
    }
    return true;
  }

  /// 現在のブロックが指定マスにあるかを判定
  bool isCurrentBlockCell(int row, int col) {
    return currentBlock.occupiedCells.any(
      (point) => point.row == row && point.col == col,
    );
  }

  /// ゴーストブロック（落下予測位置）を取得
  Block getGhostBlock() {
    final ghost = currentBlock.clone();
    while (true) {
      ghost.row++;
      if (!isValidPosition(ghost)) {
        ghost.row--;
        break;
      }
    }
    return ghost;
  }

  /// 指定マスがゴーストブロックかどうか
  bool isGhostBlockCell(int row, int col) {
    final ghost = getGhostBlock();
    return ghost.occupiedCells.any(
      (point) => point.row == row && point.col == col,
    );
  }

  /// ハードドロップ（最下段まで即座に落とす）
  void hardDrop() {
    while (_canMoveDown()) {
      currentBlock.row++;
      _score += 2;
    }
  }

  /// ブロックのホールド処理
  void holdCurrentBlock() {
    if (hasHeld) return;
    if (holdBlock == null) {
      holdBlock = currentBlock.clone();
      currentBlock = nextBlock!;
      nextBlock = createRandomBlock();
    } else {
      final temp = holdBlock!;
      holdBlock = currentBlock.clone();
      currentBlock = temp;
    }
    currentBlock.row = 0;
    currentBlock.col = 3;
    hasHeld = true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// UIの構築（スコア表示、盤面、ホールド・ネクストブロック表示）
  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          setState(() {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              currentBlock.col--;
              if (!isValidPosition(currentBlock)) currentBlock.col++;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              currentBlock.col++;
              if (!isValidPosition(currentBlock)) currentBlock.col--;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              if (_canMoveDown()) {
                currentBlock.row++;
                _score += 1;
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              hardDrop();
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              final rotated = currentBlock.clone();
              rotated.rotateClockwise();
              if (isValidPosition(rotated)) {
                currentBlock = rotated;
              }
            } else if (event.logicalKey == LogicalKeyboardKey.keyC) {
              holdCurrentBlock();
            }
          });
        }
        return KeyEventResult.handled;
      },

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // スコア・レベルなどのステータス表示
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Score: $_score',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  'Level: $_level',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  'Next in: $_nextLevelThreshold pts',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  'Time: ${_elapsed.inMinutes}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),

          // ゲーム盤面と右側の表示（ネクスト・ホールド）
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ゲーム盤面
              Column(
                children: List.generate(rowCount, (row) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(colCount, (col) {
                      final isFixed = fixedBlocks[row][col];
                      final isCurrent = isCurrentBlockCell(row, col);
                      final isGhost = isGhostBlockCell(row, col);
                      Color color;
                      if (isCurrent) {
                        color = currentBlock.color;
                      } else if (isFixed) {
                        color = Colors.white;
                      } else if (isGhost) {
                        color = currentBlock.color.withOpacity(0.3);
                      } else {
                        color = Colors.grey[900]!;
                      }
                      return Container(
                        margin: const EdgeInsets.all(1),
                        width: 20,
                        height: 20,
                        color: color,
                      );
                    }),
                  );
                }),
              ),
              const SizedBox(width: 20),

              // ネクスト＆ホールドブロック表示
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Next:', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 5),
                  ...List.generate(4, (i) {
                    return Row(
                      children: List.generate(4, (j) {
                        bool filled = false;
                        if (nextBlock != null &&
                            i < nextBlock!.height &&
                            j < nextBlock!.width) {
                          filled = nextBlock!.shape[i][j] == 1;
                        }
                        return Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.all(1),
                          color: filled ? nextBlock!.color : Colors.grey[800],
                        );
                      }),
                    );
                  }),
                  const SizedBox(height: 20),
                  const Text('Hold:', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 5),
                  ...List.generate(4, (i) {
                    return Row(
                      children: List.generate(4, (j) {
                        bool filled = false;
                        if (holdBlock != null &&
                            i < holdBlock!.height &&
                            j < holdBlock!.width) {
                          filled = holdBlock!.shape[i][j] == 1;
                        }
                        return Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.all(1),
                          color: filled ? holdBlock!.color : Colors.grey[800],
                        );
                      }),
                    );
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
