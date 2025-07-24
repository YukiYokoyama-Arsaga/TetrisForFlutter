import 'package:flutter/material.dart';

import 'point.dart';

class Block {
  List<List<int>> shape;
  int row;
  int col;
  final Color color;

  Block({
    required this.shape,
    required this.row,
    required this.col,
    required this.color,
  });

  int get height => shape.length;
  int get width => shape[0].length;

  Iterable<Point> get occupiedCells sync* {
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (shape[i][j] == 1) {
          yield Point(row + i, col + j);
        }
      }
    }
  }

  void rotateClockwise() {
    final newShape = List.generate(
      width,
      (i) => List.generate(height, (j) => shape[height - j - 1][i]),
    );
    shape = newShape;
  }

  void rotateCounterClockwise() {
    final newShape = List.generate(
      width,
      (i) => List.generate(height, (j) => shape[j][width - i - 1]),
    );
    shape = newShape;
  }

  Block clone() {
    return Block(
      shape: shape.map((row) => List<int>.from(row)).toList(),
      row: row,
      col: col,
      color: color,
    );
  }
}
