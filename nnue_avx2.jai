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
  #asm AVX, AVX2 {
    movdqa.y ymm0:  vec, [biases + 0x00];
    movdqa.y ymm1:  vec, [biases + 0x20];
    movdqa.y ymm2:  vec, [biases + 0x40];
    movdqa.y ymm3:  vec, [biases + 0x60];
    movdqa.y ymm4:  vec, [biases + 0x80];
    movdqa.y ymm5:  vec, [biases + 0xa0];
    movdqa.y ymm6:  vec, [biases + 0xc0];
    movdqa.y ymm7:  vec, [biases + 0xe0];
  }

  for feature : subtracted_features {
    #asm AVX, AVX2 {
      psubw.y ymm0, ymm0, [feature + 0x00];
      psubw.y ymm1, ymm1, [feature + 0x20];
      psubw.y ymm2, ymm2, [feature + 0x40];
      psubw.y ymm3, ymm3, [feature + 0x60];
      psubw.y ymm4, ymm4, [feature + 0x80];
      psubw.y ymm5, ymm5, [feature + 0xa0];
      psubw.y ymm6, ymm6, [feature + 0xc0];
      psubw.y ymm7, ymm7, [feature + 0xe0];
    }
  }

  // add the values up.
  for feature : added_features {
    #asm AVX, AVX2 {
      paddw.y ymm0, ymm0, [feature + 0x00];
      paddw.y ymm1, ymm1, [feature + 0x20];
      paddw.y ymm2, ymm2, [feature + 0x40];
      paddw.y ymm3, ymm3, [feature + 0x60];
      paddw.y ymm4, ymm4, [feature + 0x80];
      paddw.y ymm5, ymm5, [feature + 0xa0];
      paddw.y ymm6, ymm6, [feature + 0xc0];
      paddw.y ymm7, ymm7, [feature + 0xe0];
    }
  }

  // store back the values in the accumulator.
  #asm AVX, AVX2 {
    movdqa.y [accum + 0x00], ymm0;
    movdqa.y [accum + 0x20], ymm1;
    movdqa.y [accum + 0x40], ymm2;
    movdqa.y [accum + 0x60], ymm3;
    movdqa.y [accum + 0x80], ymm4;
    movdqa.y [accum + 0xa0], ymm5;
    movdqa.y [accum + 0xc0], ymm6;
    movdqa.y [accum + 0xe0], ymm7;
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
    movdqa.x sum:, zeroes;
    movd     ones_xmm: vec, eax;
    pshufd   ones_xmm, ones_xmm, 0x0;
  }

  for 0..7 {
    #asm SSE {
      movdqa.x     xmm0:, [acc0];
      movdqa.x     xmm1:, [acc1];
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
  feature_weights: [2][9][90][HIDDEN] s16;
  feature_biases:  [HIDDEN] s16;
  output_weights:  [2][HIDDEN] s8;
  output_bias:     s32;
}

#no_reset nnue: NNUE #align 64;

load_model :: (filename: string) {
  print("loading file %\n", filename);
  memcpy(_nnuename.data, filename.data, size_of(u8) * filename.count);
  filename_count = cast(s8) filename.count;
  weights, success := read_entire_file(filename);
  assert(success, "File % not found.", filename);
  assert(weights.count == size_of(NNUE), "Size of file does not match struct size. Expect % Got %", size_of(NNUE), weights.count);
  memcpy(*nnue, *weights[0], size_of(NNUE));
  free(weights);
}

get_nnuename :: () -> string {
  return to_string(_nnuename.data, filename_count);
}

#no_reset _nnuename: [32] u8 #align 16;
#no_reset filename_count: s8 = 0;

KSQ_INDEX :: s8.[
  -1, -1, -1,  1,  0,  1, -1, -1, -1,
  -1, -1, -1,  1,  1,  1, -1, -1, -1,
  -1, -1, -1,  1,  1,  1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1, -1, -1, -1, -1, -1, -1,
  -1, -1, -1,  1,  1,  1, -1, -1, -1,
  -1, -1, -1,  1,  1,  1, -1, -1, -1,
  -1, -1, -1,  1,  0,  1, -1, -1, -1,
];

#import "Basic";
#import "File";
