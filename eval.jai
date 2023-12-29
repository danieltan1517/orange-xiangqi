// this evaluation function was inspired by: https://github.com/markdirish/xiangqi
// as well as: https://github.com/maksimKorzh/wukong-xiangqi/blob/main/src/engine/wukong.js

// calculate relative to position.
evaluate :: inline (xiangqi: *Xiangqi) -> int {
  return nnue_evaluate(xiangqi);
}

evaluate :: inline (xiangqi: *Xiangqi, history: *History) -> int {
  return nnue_evaluate_incr(xiangqi, history);
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

