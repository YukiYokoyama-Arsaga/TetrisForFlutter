// lib/widgets/tetris_board.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/block.dart';
import '../utils/block_factory.dart';

class TetrisBoard extends StatefulWidget {
  const TetrisBoard({super.key});

  @override
  State<TetrisBoard> createState() => _TetrisBoardState();
}

class _TetrisBoardState extends State<TetrisBoard> {
  static const int rowCount = 20;
  static const int colCount = 10;

  Timer? _timer;
  late DateTime _startTime;
  Duration _elapsed = Duration.zero;

  late Block currentBlock;
  Block? holdBlock;
  bool hasHeld = false;
  Block? nextBlock;
  List<List<bool>> fixedBlocks = List.generate(
    rowCount,
    (_) => List.filled(colCount, false),
  );
  int _score = 0;

  final List<int> _scoreHistory = [];

  int get _level => (_score ~/ 1000).clamp(0, 10);
  int get _nextLevelThreshold => (_level + 1) * 1000 - _score;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    currentBlock = createRandomBlock();
    nextBlock = createRandomBlock();
    _score = 0;
    _elapsed = Duration.zero;
    _startTime = DateTime.now();
    _startFalling();
  }

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

          if (isGameOver(currentBlock)) {
            _scoreHistory.add(_score);
            _timer?.cancel();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                title: const Text("Game Over"),
                content: Text(
                  "スコア: $_score\nレベル: $_level\n時間: ${_elapsed.inMinutes}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}\n\nスコア履歴: ${_scoreHistory.join(", ")}",
                ),
                actions: [
                  TextButton(
                    child: const Text("Retry"),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        fixedBlocks = List.generate(
                          rowCount,
                          (_) => List.filled(colCount, false),
                        );
                        _startGame();
                      });
                    },
                  ),
                ],
              ),
            );
          }
        }
      });
    });
  }

  Duration _currentSpeed() {
    return Duration(milliseconds: 500 - _level * 40);
  }

  void fixCurrentBlock() {
    for (final point in currentBlock.occupiedCells) {
      if (point.row < rowCount && point.col >= 0 && point.col < colCount) {
        fixedBlocks[point.row][point.col] = true;
      }
    }
  }

  bool _canMoveDown() {
    for (final point in currentBlock.occupiedCells) {
      final belowRow = point.row + 1;
      if (belowRow >= rowCount || fixedBlocks[belowRow][point.col]) {
        return false;
      }
    }
    return true;
  }

  bool isGameOver(Block block) {
    for (final point in block.occupiedCells) {
      if (point.row >= rowCount || fixedBlocks[point.row][point.col]) {
        return true;
      }
    }
    return false;
  }

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

  void _resetTimerWithSpeed() {
    _timer?.cancel();
    _startFalling();
  }

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

  bool isCurrentBlockCell(int row, int col) {
    return currentBlock.occupiedCells.any(
      (point) => point.row == row && point.col == col,
    );
  }

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

  bool isGhostBlockCell(int row, int col) {
    final ghost = getGhostBlock();
    return ghost.occupiedCells.any(
      (point) => point.row == row && point.col == col,
    );
  }

  void hardDrop() {
    while (_canMoveDown()) {
      currentBlock.row++;
      _score += 2;
    }
  }

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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
