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
  for i: 0..HIDDEN-1 {
    accum[i] = biases[i];
  }

  for feature : subtracted_features {
    for i: 0..HIDDEN-1 {
      accum[i] -= feature[i];
    }
  }

  // add the values up.
  for feature : added_features {
    for i: 0..HIDDEN-1 {
      accum[i] += feature[i];
    }
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

  relu_multiply :: inline (input: s16, weight: s16) -> int {
    value: int = ifx input > 0 then input else 0;
    value *= weight;
    return value;
  }

  biases: int = nnue.output_bias;
  oppo := turn ^ 1;
  acc0 := *accum[turn][0];
  acc1 := *accum[oppo][0];
  weights0 := *nnue.output_weights[0][0];
  weights1 := *nnue.output_weights[1][0];

  for i: 0..HIDDEN-1 {
    biases += relu_multiply(acc0[i], weights0[i]);
    biases += relu_multiply(acc1[i], weights1[i]);
  }

  return biases / 32 / 128;
}

NNUE :: struct {
  feature_weights: [2][9][90][HIDDEN] s16;
  feature_biases:  [HIDDEN] s16;
  output_weights:  [2][HIDDEN] s16;
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
  /*
  print("OUTPUTS: %\n", nnue.feature_weights);
  print("OUTPUTS: %\n", nnue.feature_biases);
  print("OUTPUTS: %\n", nnue.output_weights);
  print("OUTPUTS: %\n", nnue.output_bias);
  */
  free(weights);
}

get_nnuename :: () -> string {
  print("filename count %\n", filename_count);
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
