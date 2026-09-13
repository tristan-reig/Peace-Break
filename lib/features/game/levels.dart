const int kGridColumns = 8;

class LevelDef {
  const LevelDef({required this.rows, required this.seconds});

  final List<String> rows;
  final int seconds;
}

const List<LevelDef> kLevels = [
  LevelDef(rows: ['11111111', '11111111', '11111111'], seconds: 120),
  LevelDef(rows: ['.111111.', '.122221.', '.111111.'], seconds: 130),
  LevelDef(
    rows: ['...11...', '..1221..', '.122221.', '12222221'],
    seconds: 150,
  ),
  LevelDef(
    rows: ['22222222', '1.1.1.1.', '.2.2.2.2', '11111111'],
    seconds: 165,
  ),
  LevelDef(rows: ['33333333', '.222222.', '..1111..'], seconds: 180),
  LevelDef(
    rows: ['1.2.2.1.', '.2.3.3.2', '2.3.3.2.', '.1.2.2.1', '11111111'],
    seconds: 195,
  ),
  LevelDef(
    rows: ['33.22.33', '3.2112.3', '.211112.', '3.2112.3', '33.22.33'],
    seconds: 210,
  ),
  LevelDef(
    rows: ['22222222', '23333332', '23111132', '23333332', '22222222'],
    seconds: 225,
  ),
  LevelDef(
    rows: ['3.3.3.3.', '.3.3.3.3', '22222222', '.3.3.3.3', '3.3.3.3.'],
    seconds: 240,
  ),
  LevelDef(
    rows: [
      '33333333',
      '33333333',
      '32222223',
      '32111123',
      '32222223',
      '33333333',
    ],
    seconds: 270,
  ),
];

LevelDef level(int stage) => kLevels[(stage - 1).clamp(0, kLevels.length - 1)];
