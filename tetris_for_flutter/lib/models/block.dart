import 'package:flutter/material.dart';

import 'point.dart';

/// テトリスのブロックを表すクラス。
/// 各ブロックは shape（2次元リスト）と位置(row, col)、色(color)を持つ。
class Block {
  /// ブロックの形状を示す2次元配列（1 = ブロックあり, 0 = 空白）
  /// 例: [
  ///   [0, 1, 0],
  ///   [1, 1, 1]
  /// ]
  List<List<int>> shape;

  /// ブロックの左上セルの行インデックス（ゲーム盤上の位置）
  int row;

  /// ブロックの左上セルの列インデックス（ゲーム盤上の位置）
  int col;

  /// ブロックの表示色（描画用）
  final Color color;

  /// コンストラクタ（ブロック生成時に shape, row, col, color を指定）
  Block({
    required this.shape,
    required this.row,
    required this.col,
    required this.color,
  });

  /// ブロックの高さ（行数）を返す
  int get height => shape.length;

  /// ブロックの幅（列数）を返す
  int get width => shape[0].length;

  /// ブロックが占有しているマス（PointのIterable）を返す
  /// ゲーム盤上で実際に描画・当たり判定に使う位置
  Iterable<Point> get occupiedCells sync* {
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (shape[i][j] == 1) {
          // shape内の相対位置 (i, j) を盤面上の絶対位置 (row + i, col + j) に変換
          yield Point(row + i, col + j);
        }
      }
    }
  }

  /// 時計回りに90度回転させる
  /// 新しいshapeを作って置き換える（元のshapeを変更）
  void rotateClockwise() {
    final newShape = List.generate(
      width, // 新しい行数は元の列数
      (i) => List.generate(
        height, // 新しい列数は元の行数
        (j) => shape[height - j - 1][i], // 時計回りに90度回転
      ),
    );
    shape = newShape;
  }

  /// 反時計回りに90度回転させる
  void rotateCounterClockwise() {
    final newShape = List.generate(
      width,
      (i) => List.generate(
        height,
        (j) => shape[j][width - i - 1], // 反時計回りに90度回転
      ),
    );
    shape = newShape;
  }

  /// ブロックを複製する（deep copy）
  /// shapeはList`<List<int>>`なので、各行もコピーして参照切り離し
  Block clone() {
    return Block(
      shape: shape.map((row) => List<int>.from(row)).toList(), // deep copy
      row: row,
      col: col,
      color: color,
    );
  }
}
