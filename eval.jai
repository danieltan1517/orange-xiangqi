
// this evaluation function was inspired by: https://github.com/markdirish/xiangqi
// as well as: https://github.com/maksimKorzh/wukong-xiangqi/blob/main/src/engine/wukong.js

evaluate :: (xiangqi: *Xiangqi) -> int {
  red := *xiangqi.red;
  black := *xiangqi.black;

  // calculate materials
  mat_sol  := cast(int)(red.soldiers.count - black.soldiers.count) * soldier_mat;
  mat_adv  := cast(int)(red.advisors.count - black.advisors.count) * advisor_mat;
  mat_ele  := cast(int)(red.elephants.count - black.elephants.count) * elephant_mat;
  mat_kni  := cast(int)(red.knights.count - black.knights.count) * knight_mat;
  mat_can  := cast(int)(red.cannons.count - black.cannons.count) * cannon_mat;
  mat_rook := cast(int)(red.rooks.count - black.rooks.count) * rook_mat;
  score := mat_sol + mat_adv + mat_ele + mat_kni + mat_can + mat_rook;

  // calculate PST.
  red_score := calculate_pst(red, false);
  black_score := calculate_pst(black, true);

  score += red_score;
  score -= black_score;
  if xiangqi.turn == 0 then {
    return score;
  } else {
    return -score;
  }

  // calculate the piece square attack tables.
  calculate_pst :: (pieces: *Pieces, $flip: bool) -> int {
    score := 0;
    for sol: pieces.soldiers {
      row, col := row_col_of(sol);
      index := index_eval(row, col, flip);
      score += soldier_table[index];
    }

    for knight: pieces.knights {
      row, col := row_col_of(knight);
      index := index_eval(row, col, flip);
      score += horse_table[index];
    }

    for rook: pieces.rooks {
      row, col := row_col_of(rook);
      index := index_eval(row, col, flip);
      score += rook_table[index];
    }

    for cannon: pieces.cannons {
      row, col := row_col_of(cannon);
      index := index_eval(row, col, flip);
      score += cannon_table[index];
    }

    return score;
  }

  index_eval :: (row: u8, col: u8, flip: bool) -> u8 #expand {
    #if flip == false {
      return row * 10 + col;
    } else {
      return (8-row) * 10 + col;
    }
  }


}



#scope_file
// piece square attack tables.
soldier_table :: s16.[
   0,  0,  0,  0,   0,  0,  0,  0,  0,
   0,  0,  0,  0,   0,  0,  0,  0,  0,
   0,  0,  0,  0,   0,  0,  0,  0,  0,
   0,  0, -2,  0,   4,  0, -2,  0,  0,
   2,  0,  8,  0,   8,  0,  8,  0,  2,
   6, 12, 18, 18,  20, 18, 18, 12,  6,
  10, 20, 30, 34,  40, 34, 30, 20, 10,
  14, 26, 42, 60,  80, 60, 42, 26, 14,
  18, 36, 56, 80, 120, 80, 56, 36, 18,
   0,  3,  6,  9,  12,  9,  6,  3,  0
];

horse_table :: s16.[
   0, -4,  0,  0,  0,  0,  0, -4,  0,
   0,  2,  4,  4, -2,  4,  4,  2,  0,
   4,  2,  8,  8,  4,  8,  8,  2,  4,
   2,  6,  8,  6, 10,  6,  8,  6,  2,
   4, 12, 16, 14, 12, 14, 16, 12,  4,
   6, 16, 14, 18, 16, 18, 14, 16,  6,
   8, 24, 18, 24, 20, 24, 18, 24,  8,
  12, 14, 16, 20, 18, 20, 16, 14, 12,
   4, 10, 28, 16,  8, 16, 28, 10,  4,
   4,  8, 16, 12,  4, 12, 16,  8,  4
];

rook_table :: s16.[
  -2, 10,  6, 14, 12, 14,  6, 10, -2,
   8,  4,  8, 16,  8, 16,  8,  4,  8,
   4,  8,  6, 14, 12, 14,  6,  8,  4,
   6, 10,  8, 14, 14, 14,  8, 10,  6,
  12, 16, 14, 20, 20, 20, 14, 16, 12,
  12, 14, 12, 18, 18, 18, 12, 14, 12,
  12, 18, 16, 22, 22, 22, 16, 18, 12,
  12, 12, 12, 18, 18, 18, 12, 12, 12,
  16, 20, 18, 24, 26, 24, 18, 20, 16,
  14, 14, 12, 18, 16, 18, 12, 14, 14
];

cannon_table :: s16.[
   0, 0,  2,   6,   6,   6,  2, 0,  0,
   0, 2,  4,   6,   6,   6,  4, 2,  0,
   4, 0,  8,   6,  10,   6,  8, 0,  4,
   0, 0,  0,   2,   4,   2,  0, 0,  0,
  -2, 0,  4,   2,   6,   2,  4, 0, -2,
   0, 0,  0,   2,   8,   2,  0, 0,  0,
   0, 0, -2,   4,  10,   4, -2, 0,  0,
   2, 2,  0, -10,  -8, -10,  0, 2,  2,
   2, 2,  0,  -4, -14,  -4,  0, 2,  2,
   6, 4,  0, -10, -12, -10,  0, 4,  6
];

soldier_mat  ::  30;
advisor_mat  :: 120;
elephant_mat :: 120;
knight_mat   :: 270;
cannon_mat   :: 285;
rook_mat     :: 600;





