// this evaluation function was inspired by: https://github.com/markdirish/xiangqi
// as well as: https://github.com/maksimKorzh/wukong-xiangqi/blob/main/src/engine/wukong.js

// calculate relative to position.
evaluate :: (xiangqi: *Xiangqi) -> int {
  // calculate PST.
  phase := compute_phase(xiangqi);
  score := evaluation_phase_scale(evaluate_absolute(xiangqi), phase);
  if abs(score) < 630 && phase > 3 {
    return nnue_evaluate(xiangqi);
  }
  if xiangqi.turn == 0 {
    return score;
  } else {
    return -score;
  }
}

evaluate_absolute :: (xiangqi: *Xiangqi) -> Score {
  // calculate PST.
  score: Score;
  score += calculate_pst(xiangqi.pieces[0], sqs[0]);
  score -= calculate_pst(xiangqi.pieces[1], sqs[1]);
  return score;
}

evaluate_handcrafted_evaluation :: (xiangqi: *Xiangqi) -> int {
  phase := compute_phase(xiangqi);
  score := evaluation_phase_scale(evaluate_absolute(xiangqi), phase);
  if xiangqi.turn == 0 {
    return score;
  } else {
    return -score;
  }
}

evaluate :: (xiangqi: *Xiangqi, history: *History) -> int {
  ply := history.ply;
  evaluation := evaluation_phase_scale(history.accum[ply], history.phase_value);
  if abs(evaluation) < 630 && history.phase_value > 3 {
    return nnue_evaluate_incr(xiangqi, history);
  }
  if xiangqi.turn == 0 {
    return evaluation;
  } else {
    return -evaluation;
  }
}

incr_evaluation :: (turn: int, accumulator: [] Score, ply: int, move: Move32) {
  eval  := accumulator[ply];
  score := Score.{0,0}; 
  piece := move.piece >> 2;
  from  := sqs[turn][move.from];
  to    := sqs[turn][move.to];
  score -= PIECE_SQ[piece][from];
  score += PIECE_SQ[piece][to];

  if move.capture != 0 then {
    to       = sqs[1][to];
    capture := move.capture >> 2;
    score   += PIECE_SQ[capture][to];
  }

  if turn == 0 {
    eval += score;
  } else {
    eval -= score;
  }
  accumulator[ply + 1] = eval;
}

// null move.
incr_null_evaluation :: inline (accumulator: [] Score, ply: int) {
  accumulator[ply + 1] = accumulator[ply];
}

// calculate the piece square attack tables.
calculate_pst :: (pieces: Pieces, SQUARES: [90] s8) -> Score {
  score: Score;
  for piece_type, p: pieces.piece {
    for sq: piece_type {
      index := SQUARES[sq];
      score += PIECE_SQ[p][index];
    }
  }

  return score;
}

sqs : [2][90] s8 : .[
  s8.[
     0,  1,  2,  3,  4,  5,  6,  7,  8,  
     9, 10, 11, 12, 13, 14, 15, 16, 17,  
    18, 19, 20, 21, 22, 23, 24, 25, 26,  
    27, 28, 29, 30, 31, 32, 33, 34, 35, 
    36, 37, 38, 39, 40, 41, 42, 43, 44,
    45, 46, 47, 48, 49, 50, 51, 52, 53,
    54, 55, 56, 57, 58, 59, 60, 61, 62,
    63, 64, 65, 66, 67, 68, 69, 70, 71,
    72, 73, 74, 75, 76, 77, 78, 79, 80,
    81, 82, 83, 84, 85, 86, 87, 88, 89,
  ],

  s8.[
    81, 82, 83, 84, 85, 86, 87, 88, 89,
    72, 73, 74, 75, 76, 77, 78, 79, 80,
    63, 64, 65, 66, 67, 68, 69, 70, 71,
    54, 55, 56, 57, 58, 59, 60, 61, 62,
    45, 46, 47, 48, 49, 50, 51, 52, 53,
    36, 37, 38, 39, 40, 41, 42, 43, 44,
    27, 28, 29, 30, 31, 32, 33, 34, 35, 
    18, 19, 20, 21, 22, 23, 24, 25, 26,  
     9, 10, 11, 12, 13, 14, 15, 16, 17,  
     0,  1,  2,  3,  4,  5,  6,  7,  8,  
  ]
];

Score :: struct {
  midgame: s16;
  endgame: s16;
}

compute_phase :: (x: *Xiangqi) -> int {
  count := 0;
  count += (x.pieces[0].kni.count + x.pieces[1].kni.count);
  count += (x.pieces[0].cannon.count + x.pieces[1].cannon.count);
  count += (x.pieces[0].rook.count + x.pieces[1].rook.count) * 2;
  return count;
}

phase_incr :: (move: Move32) -> int {
  capture: int = move.capture >> 2;
  PHASE_BONUS :: int.[0, 0, 0, 1, 2, 1, 0];
  return PHASE_BONUS[capture];
}

operator + :: inline (a: Score, b: Score) -> Score {
  c: Score = Score.{0,0};
  c.midgame = a.midgame + b.midgame;
  c.endgame = a.endgame + b.endgame;
  return c;
}

operator - :: inline (a: Score, b: Score) -> Score {
  c: Score = Score.{0,0};
  c.midgame = a.midgame - b.midgame;
  c.endgame = a.endgame - b.endgame;
  return c;
}

operator += :: inline (a: *Score, b: Score) {
  a.midgame += b.midgame;
  a.endgame += b.endgame;
}

operator -= :: inline (a: *Score, b: Score) {
  a.midgame -= b.midgame;
  a.endgame -= b.endgame;
}

evaluation_phase_scale :: (score: Score, phase: int) -> int {
  midgame: int = cast(int)(score.midgame) * phase;
  endgame: int = cast(int)(score.endgame) * (16 - phase);
  return (midgame + endgame) / 16;
}

PIECE_SQ : [7][90] Score : [90] Score.[

Score.[
  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{-5, -1},  Score.{0, 0},  Score.{-5, -1},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},
  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{-7, -1},  Score.{-5, -1},  Score.{-7, -1},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},
  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{-7, -1},  Score.{-7, -1},  Score.{-7, -1},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},
  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},
  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},
  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},
  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},
  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},
  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},
  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},  Score.{0, 0},
],

Score.[
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{115, 135},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{105, 125},  Score.{110, 130},  Score.{105, 125},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
],

Score.[
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{102, 122},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{118, 138},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{102, 122},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{114, 134},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{114, 134},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},  Score.{110, 130},
],

Score.[
  Score.{270, 300},  Score.{266, 296},  Score.{270, 300},  Score.{270, 300},  Score.{270, 300},  Score.{270, 300},  Score.{270, 300},  Score.{266, 296},  Score.{270, 300},
  Score.{270, 300},  Score.{272, 302},  Score.{274, 304},  Score.{274, 304},  Score.{268, 298},  Score.{274, 304},  Score.{274, 304},  Score.{272, 302},  Score.{270, 300},
  Score.{274, 304},  Score.{272, 302},  Score.{278, 308},  Score.{278, 308},  Score.{274, 304},  Score.{278, 308},  Score.{278, 308},  Score.{272, 302},  Score.{274, 304},
  Score.{272, 302},  Score.{276, 306},  Score.{278, 308},  Score.{276, 306},  Score.{280, 310},  Score.{276, 306},  Score.{278, 308},  Score.{276, 306},  Score.{272, 302},
  Score.{274, 304},  Score.{282, 312},  Score.{286, 316},  Score.{284, 314},  Score.{282, 312},  Score.{284, 314},  Score.{286, 316},  Score.{282, 312},  Score.{274, 304},
  Score.{276, 306},  Score.{286, 316},  Score.{284, 314},  Score.{288, 318},  Score.{286, 316},  Score.{288, 318},  Score.{284, 314},  Score.{286, 316},  Score.{276, 306},
  Score.{274, 304},  Score.{278, 308},  Score.{286, 316},  Score.{282, 312},  Score.{274, 304},  Score.{282, 312},  Score.{286, 316},  Score.{278, 308},  Score.{274, 304},
  Score.{274, 304},  Score.{280, 310},  Score.{298, 328},  Score.{286, 316},  Score.{278, 308},  Score.{286, 316},  Score.{298, 328},  Score.{280, 310},  Score.{274, 304},
  Score.{282, 312},  Score.{284, 314},  Score.{286, 316},  Score.{290, 320},  Score.{288, 318},  Score.{290, 320},  Score.{286, 316},  Score.{284, 314},  Score.{282, 312},
  Score.{278, 308},  Score.{294, 324},  Score.{288, 318},  Score.{294, 324},  Score.{290, 320},  Score.{294, 324},  Score.{288, 318},  Score.{294, 324},  Score.{278, 308},
],

Score.[
  Score.{598, 608},  Score.{610, 620},  Score.{606, 616},  Score.{614, 624},  Score.{612, 622},  Score.{614, 624},  Score.{606, 616},  Score.{610, 620},  Score.{598, 608},
  Score.{608, 618},  Score.{604, 614},  Score.{608, 618},  Score.{616, 626},  Score.{608, 618},  Score.{616, 626},  Score.{608, 618},  Score.{604, 614},  Score.{608, 618},
  Score.{604, 614},  Score.{608, 618},  Score.{606, 616},  Score.{614, 624},  Score.{612, 622},  Score.{614, 624},  Score.{606, 616},  Score.{608, 618},  Score.{604, 614},
  Score.{606, 616},  Score.{610, 620},  Score.{608, 618},  Score.{614, 624},  Score.{614, 624},  Score.{614, 624},  Score.{608, 618},  Score.{610, 620},  Score.{606, 616},
  Score.{612, 622},  Score.{616, 626},  Score.{614, 624},  Score.{620, 630},  Score.{620, 630},  Score.{620, 630},  Score.{614, 624},  Score.{616, 626},  Score.{612, 622},
  Score.{612, 622},  Score.{614, 624},  Score.{612, 622},  Score.{618, 628},  Score.{618, 628},  Score.{618, 628},  Score.{612, 622},  Score.{614, 624},  Score.{612, 622},
  Score.{612, 622},  Score.{618, 628},  Score.{616, 626},  Score.{622, 632},  Score.{622, 632},  Score.{622, 632},  Score.{616, 626},  Score.{618, 628},  Score.{612, 622},
  Score.{612, 622},  Score.{612, 622},  Score.{612, 622},  Score.{618, 628},  Score.{618, 628},  Score.{618, 628},  Score.{612, 622},  Score.{612, 622},  Score.{612, 622},
  Score.{616, 626},  Score.{620, 630},  Score.{618, 628},  Score.{624, 634},  Score.{626, 636},  Score.{624, 634},  Score.{618, 628},  Score.{620, 630},  Score.{616, 626},
  Score.{614, 624},  Score.{614, 624},  Score.{612, 622},  Score.{618, 628},  Score.{616, 626},  Score.{618, 628},  Score.{612, 622},  Score.{614, 624},  Score.{614, 624},
],

Score.[
  Score.{300, 270},  Score.{300, 270},  Score.{302, 272},  Score.{306, 276},  Score.{306, 276},  Score.{306, 276},  Score.{302, 272},  Score.{300, 270},  Score.{300, 270},
  Score.{300, 270},  Score.{302, 272},  Score.{304, 274},  Score.{306, 276},  Score.{306, 276},  Score.{306, 276},  Score.{304, 274},  Score.{302, 272},  Score.{300, 270},
  Score.{304, 274},  Score.{300, 270},  Score.{308, 278},  Score.{306, 276},  Score.{310, 280},  Score.{306, 276},  Score.{308, 278},  Score.{300, 270},  Score.{304, 274},
  Score.{300, 270},  Score.{300, 270},  Score.{300, 270},  Score.{302, 272},  Score.{304, 274},  Score.{302, 272},  Score.{300, 270},  Score.{300, 270},  Score.{300, 270},
  Score.{298, 268},  Score.{300, 270},  Score.{304, 274},  Score.{302, 272},  Score.{306, 276},  Score.{302, 272},  Score.{304, 274},  Score.{300, 270},  Score.{298, 268},
  Score.{300, 270},  Score.{300, 270},  Score.{300, 270},  Score.{302, 272},  Score.{308, 278},  Score.{302, 272},  Score.{300, 270},  Score.{300, 270},  Score.{300, 270},
  Score.{300, 270},  Score.{300, 270},  Score.{298, 268},  Score.{304, 274},  Score.{310, 280},  Score.{304, 274},  Score.{298, 268},  Score.{300, 270},  Score.{300, 270},
  Score.{302, 272},  Score.{302, 272},  Score.{300, 270},  Score.{290, 260},  Score.{292, 262},  Score.{290, 260},  Score.{300, 270},  Score.{302, 272},  Score.{302, 272},
  Score.{302, 272},  Score.{302, 272},  Score.{300, 270},  Score.{296, 266},  Score.{286, 256},  Score.{296, 266},  Score.{300, 270},  Score.{302, 272},  Score.{302, 272},
  Score.{306, 276},  Score.{304, 274},  Score.{300, 270},  Score.{290, 260},  Score.{288, 258},  Score.{290, 260},  Score.{300, 270},  Score.{304, 274},  Score.{306, 276},
],

Score.[
  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},
  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},
  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},  Score.{10, 50},
  Score.{10, 50},  Score.{10, 50},  Score.{8, 48},  Score.{10, 50},  Score.{14, 54},  Score.{10, 50},  Score.{8, 48},  Score.{10, 50},  Score.{10, 50},
  Score.{12, 52},  Score.{10, 50},  Score.{18, 58},  Score.{10, 50},  Score.{18, 58},  Score.{10, 50},  Score.{18, 58},  Score.{10, 50},  Score.{12, 52},
  Score.{16, 56},  Score.{22, 62},  Score.{28, 68},  Score.{28, 68},  Score.{30, 70},  Score.{28, 68},  Score.{28, 68},  Score.{22, 62},  Score.{16, 56},
  Score.{20, 60},  Score.{30, 70},  Score.{40, 80},  Score.{44, 84},  Score.{50, 90},  Score.{44, 84},  Score.{40, 80},  Score.{30, 70},  Score.{20, 60},
  Score.{24, 64},  Score.{36, 76},  Score.{52, 92},  Score.{70, 110},  Score.{90, 130},  Score.{70, 110},  Score.{52, 92},  Score.{36, 76},  Score.{24, 64},
  Score.{28, 68},  Score.{46, 86},  Score.{66, 106},  Score.{90, 130},  Score.{130, 170},  Score.{90, 130},  Score.{66, 106},  Score.{46, 86},  Score.{28, 68},
  Score.{10, 50},  Score.{13, 53},  Score.{16, 56},  Score.{19, 59},  Score.{22, 62},  Score.{19, 59},  Score.{16, 56},  Score.{13, 53},  Score.{10, 50},
],

];



