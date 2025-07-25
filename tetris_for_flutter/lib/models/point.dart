/// 盤面上のセルの位置を表す不変（immutable）な座標クラス。
/// テトリスでは、各ブロックの構成マスの位置を表現するのに使用される。
class Point {
  /// セルの行インデックス（上から何行目か）
  final int row;

  /// セルの列インデックス（左から何列目か）
  final int col;

  /// [row], [col] を指定して位置を初期化する。
  const Point(this.row, this.col);
}
