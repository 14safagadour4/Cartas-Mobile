import 'dart:math';

enum BotanicalType {
  mint,     // Ne3ne3
  jasmine,  // Yasmin
  lavender, // Khouzama
  rosemary, // Iklil
  aloe,     // Sabbar
  chamomile // Babounj
}

class MatchTile {
  final int id;
  BotanicalType type;
  int row;
  int col;
  bool isMatched;
  bool isSuper; // New power-up flag

  MatchTile({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    this.isMatched = false,
    this.isSuper = false,
  });

  MatchTile copyWith({int? row, int? col, BotanicalType? type, bool? isSuper}) {
    return MatchTile(
      id: id,
      type: type ?? this.type,
      row: row ?? this.row,
      col: col ?? this.col,
      isMatched: isMatched,
      isSuper: isSuper ?? this.isSuper,
    );
  }
}

class MatchEngine {
  final int rows;
  final int cols;
  List<List<MatchTile?>> grid = [];
  int _idCounter = 0;
  final Random _random = Random();

  MatchEngine({this.rows = 8, this.cols = 7});

  void initGrid() {
    grid = List.generate(rows, (r) => List.generate(cols, (c) => null));
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        grid[r][c] = _generateValidTile(r, c);
      }
    }
  }

  MatchTile _generateValidTile(int r, int c) {
    BotanicalType type;
    do {
      type = BotanicalType.values[_random.nextInt(BotanicalType.values.length)];
    } while (_causesMatch(r, c, type));
    
    return MatchTile(id: _idCounter++, type: type, row: r, col: c);
  }

  bool _causesMatch(int r, int c, BotanicalType type) {
    // Check horizontal
    if (c >= 2 && grid[r][c - 1]?.type == type && grid[r][c - 2]?.type == type) return true;
    // Check vertical
    if (r >= 2 && grid[r - 1][c]?.type == type && grid[r - 2][c]?.type == type) return true;
    return false;
  }

  bool isAdjacent(int r1, int c1, int r2, int c2) {
    return (r1 == r2 && (c1 - c2).abs() == 1) || (c1 == c2 && (r1 - r2).abs() == 1);
  }

  bool swap(int r1, int c1, int r2, int c2) {
    if (!isAdjacent(r1, c1, r2, c2)) return false;

    final tile1 = grid[r1][c1];
    final tile2 = grid[r2][c2];

    if (tile1 == null || tile2 == null) return false;

    // Perform swap
    grid[r1][c1] = tile2.copyWith(row: r1, col: c1);
    grid[r2][c2] = tile1.copyWith(row: r2, col: c2);

    // Check if swap results in match
    if (findMatches().isEmpty) {
      // Revert swap
      grid[r1][c1] = tile1;
      grid[r2][c2] = tile2;
      return false;
    }

    return true;
  }

  List<MatchTile> findMatches() {
    List<MatchTile> matchedTiles = [];

    // Horizontal matches
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols - 2; c++) {
        final type = grid[r][c]?.type;
        if (type != null && grid[r][c + 1]?.type == type && grid[r][c + 2]?.type == type) {
          List<MatchTile> currentMatch = [grid[r][c]!, grid[r][c + 1]!, grid[r][c + 2]!];
          
          int extra = 3;
          while (c + extra < cols && grid[r][c + extra]?.type == type) {
            currentMatch.add(grid[r][c + extra]!);
            extra++;
          }

          if (currentMatch.length >= 4) {
            // Mark one tile as super (the one at the swap position or first one)
            currentMatch[0].isSuper = true;
          }
          matchedTiles.addAll(currentMatch);
        }
      }
    }

    // Vertical matches
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows - 2; r++) {
        final type = grid[r][c]?.type;
        if (type != null && grid[r + 1][c]?.type == type && grid[r + 2][c]?.type == type) {
          List<MatchTile> currentMatch = [grid[r][c]!, grid[r + 1][c]!, grid[r + 2][c]!];

          int extra = 3;
          while (r + extra < rows && grid[r + extra][c]?.type == type) {
            currentMatch.add(grid[r + extra][c]!);
            extra++;
          }

          if (currentMatch.length >= 4) {
             currentMatch[0].isSuper = true;
          }
          matchedTiles.addAll(currentMatch);
        }
      }
    }

    return matchedTiles.toSet().toList();
  }

  void removeMatches(List<MatchTile> matches) {
    for (var tile in matches) {
      grid[tile.row][tile.col] = null;
    }
  }

  List<Map<String, dynamic>> applyGravity() {
    List<Map<String, dynamic>> movements = [];

    for (int c = 0; c < cols; c++) {
      int emptySpaces = 0;
      for (int r = rows - 1; r >= 0; r--) {
        if (grid[r][c] == null) {
          emptySpaces++;
        } else if (emptySpaces > 0) {
          final tile = grid[r][c]!;
          final targetRow = r + emptySpaces;
          grid[targetRow][c] = tile.copyWith(row: targetRow);
          grid[r][c] = null;
          movements.add({'id': tile.id, 'fromRow': r, 'toRow': targetRow, 'col': c});
        }
      }
    }
    return movements;
  }

  List<MatchTile> replenish() {
    List<MatchTile> newTiles = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] == null) {
          final type = BotanicalType.values[_random.nextInt(BotanicalType.values.length)];
          final tile = MatchTile(id: _idCounter++, type: type, row: r, col: c);
          grid[r][c] = tile;
          newTiles.add(tile);
        }
      }
    }
    return newTiles;
  }
}
