import 'dart:math';

import 'package:flutter/material.dart';

import '../models/block.dart';

/// ランダムなテトリスブロックを生成して返す関数。
/// 7種類の基本ブロック（I, O, L, J, T, S, Z）を定義し、その中から1つ選ばれる。
Block createRandomBlock() {
  // ブロック定義一覧（関数リストとして定義することで遅延評価を行う）
  final blocks = <Block Function()>[
    // I型ブロック（縦棒）
    () => Block(
      shape: [
        [1],
        [1],
        [1],
        [1],
      ],
      row: 0, // 盤面の一番上に出現
      col: 3, // 中央に近い位置に出現
      color: Colors.cyan,
    ),

    // O型ブロック（正方形）
    () => Block(
      shape: [
        [1, 1],
        [1, 1],
      ],
      row: 0,
      col: 4,
      color: Colors.yellow,
    ),

    // L型ブロック
    () => Block(
      shape: [
        [1, 0],
        [1, 0],
        [1, 1],
      ],
      row: 0,
      col: 3,
      color: Colors.orange,
    ),

    // J型ブロック（Lの左右反転）
    () => Block(
      shape: [
        [0, 1],
        [0, 1],
        [1, 1],
      ],
      row: 0,
      col: 3,
      color: Colors.blue,
    ),

    // T型ブロック
    () => Block(
      shape: [
        [0, 1, 0],
        [1, 1, 1],
      ],
      row: 0,
      col: 3,
      color: Colors.purple,
    ),

    // S型ブロック
    () => Block(
      shape: [
        [0, 1, 1],
        [1, 1, 0],
      ],
      row: 0,
      col: 3,
      color: Colors.green,
    ),

    // Z型ブロック（Sの左右反転）
    () => Block(
      shape: [
        [1, 1, 0],
        [0, 1, 1],
      ],
      row: 0,
      col: 3,
      color: Colors.red,
    ),
  ];

  // ランダムに1つ選んで呼び出し、Blockインスタンスを返す
  final rand = Random();
  return blocks[rand.nextInt(blocks.length)]();
}
