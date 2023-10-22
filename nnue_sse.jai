HIDDEN :: 128;

nnue_evaluate :: (xiangqi: *Xiangqi) -> int {
  accum: [2][HIDDEN] s16 #align 64;
  red_features := get_features(get_king(xiangqi,0), xiangqi.pieces[0], xiangqi.pieces[1], SQUARES[0]);
  blk_features := get_features(get_king(xiangqi,1), xiangqi.pieces[1], xiangqi.pieces[0], SQUARES[1]);
  empty_features: Features;
  biases := *nnue.feature_biases[0];
  compute_features(*accum[0][0], biases, red_features, empty_features);
  compute_features(*accum[1][0], biases, blk_features, empty_features);
  return compute_output_layer(xiangqi.turn, accum);
}

nnue_evaluate_incr :: (xiangqi: *Xiangqi, h: *History) -> int {
  ply := h.ply;
  return compute_output_layer(xiangqi.turn, h.accumulator[ply].values);
}

// called at the very beginning of search.
nnue_incremental_init :: (xiangqi: *Xiangqi, h: *History) {
  red_features := get_features(get_king(xiangqi,0), xiangqi.pieces[0], xiangqi.pieces[1], SQUARES[0]);
  blk_features := get_features(get_king(xiangqi,1), xiangqi.pieces[1], xiangqi.pieces[0], SQUARES[1]);
  empty_features: Features;
  biases := *nnue.feature_biases[0];
  ply := h.ply;
  compute_features(*h.accumulator[ply].values[0][0], biases, red_features, empty_features);
  compute_features(*h.accumulator[ply].values[1][0], biases, blk_features, empty_features);
}

// can only be called after ply += 1. cannot be called before that.
nnue_incremental_update :: (xiangqi: *Xiangqi, h: *History, move: Move32) {
  RED :: s8.[ 0, 0, 0, 0, 0, 0, 1, 5, 2, 6, 3, 7, 4, 8];
  BLK :: s8.[ 0, 0, 0, 0, 0, 0, 5, 1, 6, 2, 7, 3, 8, 4];

  red_added, red_subtracted, r_reset := incr_features(xiangqi, move, 0, RED, SQUARES[0]);
  blk_added, blk_subtracted, b_reset := incr_features(xiangqi, move, 1, BLK, SQUARES[1]);
  
  prev := h.ply - 1;
  red_biases := ifx r_reset then *nnue.feature_biases[0] else *h.accumulator[prev].values[0][0];
  blk_biases := ifx b_reset then *nnue.feature_biases[0] else *h.accumulator[prev].values[1][0];

  ply := h.ply;
  compute_features(*h.accumulator[ply].values[0][0], red_biases, red_added, red_subtracted);
  compute_features(*h.accumulator[ply].values[1][0], blk_biases, blk_added, blk_subtracted);
}

// used during null move pruning.
nnue_incremental_nullmove :: (xiangqi: *Xiangqi, h: *History) {
  empty: Features;
  prev := h.ply - 1;
  ply := h.ply;
  compute_features(*h.accumulator[ply].values[0][0], *h.accumulator[prev].values[0][0], empty, empty);
  compute_features(*h.accumulator[ply].values[1][0], *h.accumulator[prev].values[1][0], empty, empty);
}

incr_features :: (xiangqi: *Xiangqi, move: Move32, turn: int, PIECE: [] s8, SQ: [90] u8) -> added: Features, subtracted: Features, reset: bool {
  is_king_move :: inline (move: Move32) -> bool {
    piece := move.piece >> 2;
    return piece == 0;
  }

  is_turn :: inline (move: Move32, turn: int) -> bool {
    move_turn := (move.piece >> 1) & 1;
    return move_turn == turn;
  }

  bucket := KSQ_INDEX[get_king(xiangqi,turn)];
  added: Features;
  subtracted: Features;
  reset := false;
  if is_king_move(move) {
    if is_turn(move, turn) {
      // reset.
      added = get_features(get_king(xiangqi,turn), xiangqi.pieces[turn], xiangqi.pieces[turn^1], SQUARES[turn]);
      reset = true;
    } else {
      if is_capture(move) {
        type := PIECE[move.capture >> 1];
        to   := SQ[move.to];
        weight := *nnue.feature_weights[bucket][type][to][0];
        append_feature(*subtracted, weight);
      }
    }
  } else {
    from := SQ[move.from];
    to   := SQ[move.to];
    type := PIECE[move.piece >> 1];

    from_weight := *nnue.feature_weights[bucket][type][from][0];
    append_feature(*subtracted, from_weight);

    to_weight := *nnue.feature_weights[bucket][type][to][0];
    append_feature(*added, to_weight);

    if is_capture(move) {
      type := PIECE[move.capture >> 1];
      capture_weight := *nnue.feature_weights[bucket][type][to][0];
      append_feature(*subtracted, capture_weight);
    }
  }

  return added, subtracted, reset;
}

Accumulator :: struct {
  values: [2][HIDDEN] s16;
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

compute_features :: (accum: *s16, biases: *s16, added_features: Features, subtracted_features: Features) {
  // load the values.
  #asm SSE {
    movaps.x xmm0:  vec, [biases + 0x00];
    movaps.x xmm1:  vec, [biases + 0x10];
    movaps.x xmm2:  vec, [biases + 0x20];
    movaps.x xmm3:  vec, [biases + 0x30];
    movaps.x xmm4:  vec, [biases + 0x40];
    movaps.x xmm5:  vec, [biases + 0x50];
    movaps.x xmm6:  vec, [biases + 0x60];
    movaps.x xmm7:  vec, [biases + 0x70];
    movaps.x xmm8:  vec, [biases + 0x80];
    movaps.x xmm9:  vec, [biases + 0x90];
    movaps.x xmm10: vec, [biases + 0xa0];
    movaps.x xmm11: vec, [biases + 0xb0];
    movaps.x xmm12: vec, [biases + 0xc0];
    movaps.x xmm13: vec, [biases + 0xd0];
    movaps.x xmm14: vec, [biases + 0xe0];
    movaps.x xmm15: vec, [biases + 0xf0];
  }

  for feature : subtracted_features {
    #asm SSE {
      psubw.x xmm0,  [feature + 0x00];
      psubw.x xmm1,  [feature + 0x10];
      psubw.x xmm2,  [feature + 0x20];
      psubw.x xmm3,  [feature + 0x30];
      psubw.x xmm4,  [feature + 0x40];
      psubw.x xmm5,  [feature + 0x50];
      psubw.x xmm6,  [feature + 0x60];
      psubw.x xmm7,  [feature + 0x70];
      psubw.x xmm8,  [feature + 0x80];
      psubw.x xmm9,  [feature + 0x90];
      psubw.x xmm10, [feature + 0xa0];
      psubw.x xmm11, [feature + 0xb0];
      psubw.x xmm12, [feature + 0xc0];
      psubw.x xmm13, [feature + 0xd0];
      psubw.x xmm14, [feature + 0xe0];
      psubw.x xmm15, [feature + 0xf0];
    }
  }

  // add the values up.
  for feature : added_features {
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

  // store back the values in the accumulator.
  #asm SSE {
    movaps.x [accum + 0x00], xmm0;
    movaps.x [accum + 0x10], xmm1;
    movaps.x [accum + 0x20], xmm2;
    movaps.x [accum + 0x30], xmm3;
    movaps.x [accum + 0x40], xmm4;
    movaps.x [accum + 0x50], xmm5;
    movaps.x [accum + 0x60], xmm6;
    movaps.x [accum + 0x70], xmm7;
    movaps.x [accum + 0x80], xmm8;
    movaps.x [accum + 0x90], xmm9;
    movaps.x [accum + 0xa0], xmm10;
    movaps.x [accum + 0xb0], xmm11;
    movaps.x [accum + 0xc0], xmm12;
    movaps.x [accum + 0xd0], xmm13;
    movaps.x [accum + 0xe0], xmm14;
    movaps.x [accum + 0xf0], xmm15;
  }
}

get_features :: (ksq: int, ally: Pieces, opp: Pieces, SQ: [90] u8) -> Features {

  add_features :: (features: *Features, kidx: int, pieces: Pieces, SQ: [90] u8, N: int, R: int, C: int, P: int) {
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
      append_feature(features, *nnue.feature_weights[kidx][N][kni][0]);
    }
  
    for rook : pieces.rook {
      rook = SQ[rook];
      append_feature(features, *nnue.feature_weights[kidx][R][rook][0]);
    }
  
    for can : pieces.cannon {
      can = SQ[can];
      append_feature(features, *nnue.feature_weights[kidx][C][can][0]);
    }
  
    for pawn : pieces.pawn {
      pawn = SQ[pawn];
      append_feature(features, *nnue.feature_weights[kidx][P][pawn][0]);
    }
  }

  features: Features;
  bucket := KSQ_INDEX[ksq];
  add_features(*features, bucket, ally, SQ, 1, 2, 3, 4);
  add_features(*features, bucket, opp,  SQ, 5, 6, 7, 8);
  return features;
}

compute_output_layer :: (turn: int, accum: [2][HIDDEN] s16) -> int {
  biases := nnue.output_bias;
  oppo := turn ^ 1;
  acc0 := *accum[turn][0];
  acc1 := *accum[oppo][0];
  weights0 := *nnue.output_weights[0][0];
  weights1 := *nnue.output_weights[1][0];
  eax: s32 = 0x0001_0001;
  #asm SSE {
    pxor.x   zeroes:, zeroes;
    movaps.x sum:, zeroes;
    movd     ones_xmm: vec, eax;
    pshufd   ones_xmm, ones_xmm, 0x0;
  }

  for 0..7 {
    #asm SSE {
      movaps.x     xmm0:, [acc0];
      movaps.x     xmm1:, [acc1];
      packsswb.x   xmm0,  [acc0 + 0x10];
      packsswb.x   xmm1,  [acc1 + 0x10];
      pmaxsb.x     xmm0,  zeroes;
      pmaxsb.x     xmm1,  zeroes;
      pmaddubsw.x  xmm0,  [weights0];
      pmaddubsw.x  xmm1,  [weights1];
      pmaddwd.x    xmm0,  ones_xmm;
      pmaddwd.x    xmm1,  ones_xmm;
      paddd.x      sum,   xmm0;
      paddd.x      sum,   xmm1;
      add          acc0,  0x20;
      add          acc1,  0x20;
      add          weights0, 0x10;
      add          weights1, 0x10;
    }
  }

  #asm SSE {
    pshufd  xmm0:, sum, 0x1b;
    paddd.x sum, xmm0;
    movd eax, sum;
    pextrd val: gpr, sum, 1;
    add         eax, val;
    add         eax, biases;
  }

  return eax / 32;
}

NNUE :: struct {
  feature_weights: [3][9][90][HIDDEN] s16;
  feature_biases:  [HIDDEN] s16;
  output_weights:  [2][HIDDEN] s8;
  output_bias:     s32;
}

#no_reset nnue: NNUE #align 64;

load_model :: (filename: string) {
  print("loading file %\n", filename);
  weights, success := read_entire_file(filename);
  assert(success, "File % not found.", filename);
  assert(weights.count == size_of(NNUE), "Size of file does not match struct size. Expect % Got %", size_of(NNUE), weights.count);
  memcpy(*nnue, *weights[0], size_of(NNUE));
  free(weights);
}

KSQ_INDEX :: s8.[
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
