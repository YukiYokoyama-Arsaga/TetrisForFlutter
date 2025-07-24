import 'dart:math';

import 'package:flutter/material.dart';

import '../models/block.dart';

Block createRandomBlock() {
  final blocks = <Block Function()>[
    () => Block(
      shape: [
        [1],
        [1],
        [1],
        [1],
      ],
      row: 0,
      col: 3,
      color: Colors.cyan,
    ),
    () => Block(
      shape: [
        [1, 1],
        [1, 1],
      ],
      row: 0,
      col: 4,
      color: Colors.yellow,
    ),
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
    () => Block(
      shape: [
        [0, 1, 0],
        [1, 1, 1],
      ],
      row: 0,
      col: 3,
      color: Colors.purple,
    ),
    () => Block(
      shape: [
        [0, 1, 1],
        [1, 1, 0],
      ],
      row: 0,
      col: 3,
      color: Colors.green,
    ),
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

  final rand = Random();
  return blocks[rand.nextInt(blocks.length)]();
}
