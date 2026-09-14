const double kGameWidth = 400;
const double kGameHeight = 800;

const double kPaddleWidth = 88;
const double kPaddleHeight = 16;
const double kPaddleY = kGameHeight - 70;

const double kBallRadius = 8;
const double kBallSpeed = 320;

const double kMaxBounceAngle = 1.05; // ~60°

const double kGridMargin = 12;
const double kBrickGap = 4;
const double kBrickHeight = 18;
const double kGridTop = 100;

const double kBrickWidth =
    (kGameWidth - 2 * kGridMargin - (8 - 1) * kBrickGap) / 8;

const int kPointsPerSecondLeft = 20;
const int kPointsPerLifeLeft = 500;

const double kPaddleWideWidth = 140;
const double kPaddleNarrowWidth = 56;
const double kBallFastSpeed = 470;
