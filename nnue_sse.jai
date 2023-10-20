HIDDEN :: 128;

nnue_evaluate :: (xiangqi: *Xiangqi) -> int {
  accum: [2][HIDDEN] s16 #align 64;
  memcpy(*accum[0], *nnue.feature_biases[0], size_of([HIDDEN] s16));
  memcpy(*accum[1], *nnue.feature_biases[0], size_of([HIDDEN] s16));

  red_features := get_features(get_king(xiangqi,0), xiangqi.pieces[0], xiangqi.pieces[1], SQUARES[0]);
  blk_features := get_features(get_king(xiangqi,1), xiangqi.pieces[1], xiangqi.pieces[0], SQUARES[1]);

  compute_features(*accum[0][0], red_features, *nnue.feature_biases[0]);
  compute_features(*accum[1][0], blk_features, *nnue.feature_biases[0]);
  return compute_output_layer(xiangqi.turn, accum);
}

Features :: struct {
  values: [32] *s16;
  count: int;
}

append_feature :: inline (f: *Features, value: *s16) {
  f.values[f.count] = value;
  f.count += 1;
}

for_expansion :: (features: *Features, body: Code, f: For_Flags) #expand {
  `it_index := 0;
  while it_index < features.count {
    `it := features.values[it_index];
    #insert body;
    it_index += 1;
  }
}

compute_features :: (accum: *s16, features: Features, biases: *s16) {
  #asm SSE {
    movaps xmm0:  vec, [biases + 0x00];
    movaps xmm1:  vec, [biases + 0x10];
    movaps xmm2:  vec, [biases + 0x20];
    movaps xmm3:  vec, [biases + 0x30];
    movaps xmm4:  vec, [biases + 0x40];
    movaps xmm5:  vec, [biases + 0x50];
    movaps xmm6:  vec, [biases + 0x60];
    movaps xmm7:  vec, [biases + 0x70];
    movaps xmm8:  vec, [biases + 0x80];
    movaps xmm9:  vec, [biases + 0x90];
    movaps xmm10: vec, [biases + 0xa0];
    movaps xmm11: vec, [biases + 0xb0];
    movaps xmm12: vec, [biases + 0xc0];
    movaps xmm13: vec, [biases + 0xd0];
    movaps xmm14: vec, [biases + 0xe0];
    movaps xmm15: vec, [biases + 0xf0];
  }

  for feature : features {
    #asm SSE {
      paddw.x xmm0,  [feature + 0x00];
      paddw.x xmm1,  [feature + 0x10];
      paddw.x xmm2,  [feature + 0x20];
      paddw.x xmm3,  [feature + 0x30];
      paddw.x xmm4,  [feature + 0x40];
      paddw.x xmm5,  [feature + 0x50];
      paddw.x xmm6,  [feature + 0x60];
      paddw.x xmm7,  [feature + 0x70];
      paddw.x xmm8,  [feature + 0x80];
      paddw.x xmm9,  [feature + 0x90];
      paddw.x xmm10, [feature + 0xa0];
      paddw.x xmm11, [feature + 0xb0];
      paddw.x xmm12, [feature + 0xc0];
      paddw.x xmm13, [feature + 0xd0];
      paddw.x xmm14, [feature + 0xe0];
      paddw.x xmm15, [feature + 0xf0];
    }
  }

  #asm SSE {
    movaps [accum + 0x00], xmm0;
    movaps [accum + 0x10], xmm1;
    movaps [accum + 0x20], xmm2;
    movaps [accum + 0x30], xmm3;
    movaps [accum + 0x40], xmm4;
    movaps [accum + 0x50], xmm5;
    movaps [accum + 0x60], xmm6;
    movaps [accum + 0x70], xmm7;
    movaps [accum + 0x80], xmm8;
    movaps [accum + 0x90], xmm9;
    movaps [accum + 0xa0], xmm10;
    movaps [accum + 0xb0], xmm11;
    movaps [accum + 0xc0], xmm12;
    movaps [accum + 0xd0], xmm13;
    movaps [accum + 0xe0], xmm14;
    movaps [accum + 0xf0], xmm15;
  }
}

get_features :: (ksq: int, ally: Pieces, opp: Pieces, SQ: [90] u8) -> Features {

  add_features :: (features: *Features, kidx: int, pieces: Pieces, SQ: [90] u8, knight_type: int, rook_type: int, cannon_type: int, pawn_type: int) {
    for adv : pieces.adv {
      adv = SQ[adv];
      append_feature(features, *nnue.feature_weights[kidx][0][adv][0]);
    }
  
    for ele : pieces.ele {
      ele = SQ[ele];
      append_feature(features, *nnue.feature_weights[kidx][0][ele][0]);
    }
  
    for kni : pieces.kni {
      kni = SQ[kni];
      append_feature(features, *nnue.feature_weights[kidx][knight_type][kni][0]);
    }
  
    for rook : pieces.rook {
      rook = SQ[rook];
      append_feature(features, *nnue.feature_weights[kidx][rook_type][rook][0]);
    }
  
    for can : pieces.cannon {
      can = SQ[can];
      append_feature(features, *nnue.feature_weights[kidx][cannon_type][can][0]);
    }
  
    for pawn : pieces.pawn {
      pawn = SQ[pawn];
      append_feature(features, *nnue.feature_weights[kidx][pawn_type][pawn][0]);
    }
  }

  features: Features;
  bucket := KSQ_INDEX[ksq];
  add_features(*features, bucket, ally, SQ, 1, 2, 3, 4);
  add_features(*features, bucket, opp,  SQ, 5, 6, 7, 8);
  return features;
}

compute_output_layer :: (turn: int, accum: [2][HIDDEN] s16) -> int {

  relu :: (value: int) -> int {
    if value < 0 then
      return 0;
    else if value > 127 then
      return 127;
    return value;
  }

  eval: int = nnue.output_bias;
  oppo := turn ^ 1;
  for i: 0..HIDDEN-1 {
    i1: int = relu(accum[turn][i]);
    i2: int = relu(accum[oppo][i]);
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
  -1, -1, -1,  2,  2,  2, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1,  2,  2,  2, -1, -1, -1,
  -1, -1, -1,  2,  1,  2, -1, -1, -1,
  -1, -1, -1,  1,  0,  1, -1, -1, -1,
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
