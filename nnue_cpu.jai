HIDDEN :: 128;

nnue_evaluate :: (xiangqi: *Xiangqi) -> int {
  accum: [2][HIDDEN] s16;
  memcpy(*accum[0], *nnue.feature_biases[0], size_of([HIDDEN] s16));
  memcpy(*accum[1], *nnue.feature_biases[0], size_of([HIDDEN] s16));

  pieces_features(accum[0], get_king(xiangqi,0), xiangqi.pieces[0], xiangqi.pieces[1], SQUARES[0]);
  pieces_features(accum[1], get_king(xiangqi,1), xiangqi.pieces[1], xiangqi.pieces[0], SQUARES[1]);
  relu(accum);
  return output_evaluation(xiangqi.turn, accum);
}

pieces_features :: (accum: [] s16, ksq: int, ally: Pieces, opp: Pieces, SQ: [90] u8) {
  piece_addition :: (accum: [] s16, ksq: int, piece: Pieces, SQ: [90] u8, knight_type: int, rook_type: int, cannon_type: int, pawn_type: int) {
    for adv : piece.adv {
      adv = SQ[adv];
      add_feature_weights(accum, ksq, 0, adv);
    }
  
    for ele : piece.ele {
      ele = SQ[ele];
      add_feature_weights(accum, ksq, 0, ele);
    }
  
    for kni : piece.kni {
      kni = SQ[kni];
      add_feature_weights(accum, ksq, knight_type, kni);
    }
  
    for rook : piece.rook {
      rook = SQ[rook];
      add_feature_weights(accum, ksq, rook_type, rook);
    }
  
    for can : piece.cannon {
      can = SQ[can];
      add_feature_weights(accum, ksq, cannon_type, can);
    }
  
    for pawn : piece.pawn {
      pawn = SQ[pawn];
      add_feature_weights(accum, ksq, pawn_type, pawn);
    }
  }

  ksq = KSQ_INDEX[SQ[ksq]];
  piece_addition(accum, ksq, ally, SQ, 1, 2, 3, 4);
  piece_addition(accum, ksq, opp,  SQ, 5, 6, 7, 8);

}

add_feature_weights :: (accum: [] s16, ksq: int, piece: int, sq: int) {
  for i : 0..HIDDEN-1 {
    accum[i] += nnue.feature_weights[ksq][piece][sq][i];
  }
}

relu :: (accum: [][HIDDEN] s16) {

  clamp :: (value: s16) -> s16 {
    if value < 0 {
      return 0;
    } else if value > 127 {
      return 127;
    } else {
      return value;
    }
  }

  for i : 0..HIDDEN-1 {
    accum[0][i] = clamp(accum[0][i]);
    accum[1][i] = clamp(accum[1][i]);
  }
}

output_evaluation :: (turn: int, accum: [2][HIDDEN] s16) -> int {
  print("%\n", accum);
  eval: int = nnue.output_bias;
  opp := turn ^ 1;
  for i: 0..HIDDEN-1 {
    i1: int = accum[turn][i];
    i2: int = accum[opp ][i];
    w1: int = nnue.output_weights[0][i];
    w2: int = nnue.output_weights[1][i];
    eval += i1 * w1;
    eval += i2 * w2;
  }

  eval /= 32;

  return eval;
}

NNUE :: struct {
  feature_weights: [3][9][90][HIDDEN] s16;
  feature_biases:  [HIDDEN] s16;
  output_weights:  [2][HIDDEN] s8;
  output_bias:     s32;
}

nnue: NNUE #align 64;

load_model :: (filename: string) {
  print("loading file %\n", filename);
  weights, success := read_entire_file(filename);
  assert(success, "File % not found.", filename);
  assert(weights.count == size_of(NNUE), "Size of file does not match struct size. Expect % Got %", size_of(NNUE), weights.count);
  memcpy(*nnue, *weights[0], size_of(NNUE));
  free(weights);
}

KSQ_INDEX :: int.[
  -1, -1, -1,  1,  0,  1, -1, -1, -1,
  -1, -1, -1,  2,  1,  2, -1, -1, -1,
  -1, -1, -1,  2,  2,  2, -1, -1, -1
];

SQUARES : [2][90] u8 : .[
  u8.[
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

  u8.[
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

#import "Basic";
#import "File";
