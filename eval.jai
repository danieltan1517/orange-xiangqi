// this evaluation function was inspired by: https://github.com/markdirish/xiangqi
// as well as: https://github.com/maksimKorzh/wukong-xiangqi/blob/main/src/engine/wukong.js

// calculate relative to position.
evaluate :: inline (xiangqi: *Xiangqi) -> int {
  phase := compute_phase(xiangqi);
  return correction(xiangqi, phase, nnue_evaluate(xiangqi));
}

evaluate :: inline (xiangqi: *Xiangqi, history: *History) -> int {
  return correction(xiangqi, history.phase_value, nnue_evaluate_incr(xiangqi, history));
  //return nnue_evaluate_incr(xiangqi, history);
}

correction :: (xiangqi: *Xiangqi, phase: int, evaluation: int) -> int {

  attacker_score :: (xiangqi: *Xiangqi, turn: int, phase: int) -> int {
    score: int = 0;
    score += xiangqi.pieces[turn].kni.count * evaluation_phase_scale(270, 300, phase);
    score += xiangqi.pieces[turn].rook.count * evaluation_phase_scale(600, 610, phase);
    score += xiangqi.pieces[turn].cannon.count * evaluation_phase_scale(300, 270, phase);
    score += xiangqi.pieces[turn].pawn.count * evaluation_phase_scale(10, 50, phase);
    return score;
  }

  defender_score :: (xiangqi: *Xiangqi, turn: int, phase: int) -> int {
    score: int = 0;
    score += xiangqi.pieces[turn].adv.count * evaluation_phase_scale(110, 130, phase);
    score += xiangqi.pieces[turn].ele.count * evaluation_phase_scale(110, 130, phase);
    return score;
  }

  red_att := attacker_score(xiangqi, 0, phase);
  blk_att := attacker_score(xiangqi, 1, phase);

  red_def := defender_score(xiangqi, 0, phase); 
  blk_def := defender_score(xiangqi, 1, phase); 
  
  material_weights := red_att + red_def - blk_att - blk_def;
  correction_weights := max(red_att - blk_def, 0) - max(blk_att - red_def, 0);

  if xiangqi.turn == 1 {
    material_weights = -material_weights;
    correction_weights = -correction_weights;
  }
  difference := (material_weights - correction_weights);
  return evaluation - difference;
}

evaluation_phase_scale :: (midgame: int, endgame: int, phase: int) -> int {
  midgame = midgame * phase;
  endgame = endgame * (16 - phase);
  return (midgame + endgame) / 16;
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

