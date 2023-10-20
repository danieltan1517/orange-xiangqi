// main search evaluation function.
search :: (xiangqi: *Xiangqi, search_depth: int, searchtime_ms: int) -> Move32 {

  unwrap :: (eval: int) -> int #expand {
    if search_should_stop == true {
      `return best_move;
    }
    return eval;
  }

  allocate_history :: () -> *History #expand {
    #if OS == .WINDOWS {
      h := NewArray(1, History, alignment=64);
      `defer array_free(h);
      return *h[0];
    } else #if OS == .LINUX || OS == .MACOS {
      `h: History #align 64;
      return *h;
    } else {
      #assert(false);
    }
  } 


  time_stop_ms = searchtime_ms;
  search_should_stop = false;
  nodes = 0;
  best_move := NULL_MOVE;
  history: *History = allocate_history();
  alpha := -MATE;
  beta  :=  MATE;
  delta :=  100;

  // aspiration window with iterative deepening.
  searchstarttime = current_time_monotonic();
  ticks = 300_000_000;
  depth := 1;
  pv: PV;
  history.accum[0] = evaluate_absolute(xiangqi);
  history.phase_value = compute_phase(xiangqi);
  nnue_incremental_init(xiangqi, history);

  while depth <= search_depth {
    score := unwrap(negamax_root(xiangqi, history, *pv, depth, alpha, beta));
    time_taken := current_time_monotonic() - searchstarttime;
    if score <= alpha then {
      print("info lowerbound score %\n", score);
      alpha = max(score-delta, -MATE);
      delta += delta + delta / 5;
      continue;
    }

    if score >= beta then {
      print("info upperbound score %\n", score);
      beta = min(score+delta, MATE);
      delta += delta + delta / 5;
      continue;
    }

    ticks = 8192;
    alpha = max(score - delta, -MATE);
    beta  = min(score + delta,  MATE);
    best_move = pv.moves[0];
    time_ms := max(1, to_milliseconds(time_taken)); // convert secs to ms, minimum is 1 to avoid division by zero.
    seldepth := history.seldepth;
    nps  := nodes * 1000 / time_ms; // max to avoid a divide by zero bug.
    print_info(depth, seldepth, nodes, time_ms, score, nps, pv);
    depth += 1;
  }

  return best_move;
}

searchstarttime: Apollo_Time;
time_stop_ms: int;
search_should_stop: bool = false;

print_info :: (depth: int, seldepth: int, nodes: int, time_ms: int, score: int, nps: int, pv: PV) {
  if abs(score) > 19980 {

    // translate the score into a mating score.
    if score < 0 then {
      score = -MATE - score;
    } else {
      score = MATE - score;
    }
    print("info depth % seldepth % nodes % time % score mate % nps % pv %\n", depth, seldepth, nodes, time_ms, score, nps, pv);

  } else {
    print("info depth % seldepth % nodes % time % score % nps % pv %\n", depth, seldepth, nodes, time_ms, score, nps, pv);
  }
}

ticks := 8192;
check_time :: () {
  ticks -= 1;
  if ticks <= 0 {
    ticks = 8192;
    time := current_time_monotonic();
    time -= searchstarttime;
    result := to_milliseconds(time);
    if result >= time_stop_ms {
      search_should_stop = true;
    }
  }
}

unwrap_time :: () #expand {
  check_time();
  if search_should_stop == true then {
    `return 0;
  }
}

negamax_root :: (xiangqi: *Xiangqi, history: *History, pv: *PV, depth: int, alpha: int, beta: int) -> int {
  incheck_position :: false;
  history.max_search_depth = depth;
  ttentry, tthit := tt_probe(xiangqi);
  att := attackers(xiangqi);
  child_pv: PV;
  moves: Moves;
  best_score := -MATE;
  best_move  := NULL_MOVE;
  flag       := Flag.Alpha;
  gen_moves(xiangqi, *moves);
  score: int;
  moves_made := 0;
  for mov: xiangqi {
    if !is_legal(xiangqi, att, mov) then {
      erase_move(*moves, it_index);
      continue;
    }

    make_move(xiangqi, history, mov);
    history.seldepth = max(history.ply, history.seldepth);
    if moves_made == 0 {
      score = -negamax(xiangqi, history, *child_pv, depth - 1, -beta, -alpha);
    } else {
      score = -negamax(xiangqi, history, *child_pv, depth - 1, -alpha-1, -alpha);
      if score > alpha {
        score = -negamax(xiangqi, history, *child_pv, depth - 1, -beta, -alpha);
      }
    }
    unmake_move(xiangqi, history, mov);
    moves_made += 1;
    if score > best_score {
      best_score = score;
      best_move  = mov;
      if score > alpha then {
        alpha = best_score;
        flag = Flag.Exact;
        copy_pv(pv, child_pv, best_move);
        if score >= beta then {
          update_hist(history, moves, best_move, depth, false);
          tt_write(xiangqi, best_move, best_score, depth, .Beta);
          return best_score;
        }
      }
    } 
  }

  tt_write(xiangqi, best_move, best_score, depth, flag);
  return best_score;
}

negamax :: (xiangqi: *Xiangqi, history: *History, pv: *PV, depth: int, alpha: int, beta: int) -> int {
  unwrap_time();

  // mate distance pruning.
  ply := history.ply;
  alpha = max(alpha, -MATE+ply);
  beta  = min(beta,   MATE-ply);
  if alpha >= beta then {
    return alpha;
  }

  // you know...I don't exactly know all the xiangqi repetition rules.
  // and I am not going to focus on that at the moment. so let's just make this simple
  // and return -300. This is a little trick by Dutch Programmer HGM that hits most cases
  // easily...
  if is_repeating(xiangqi) {
    return -300;
  }

  if depth <= 0 then {
    pv.count = 0;
    return quiescene(xiangqi, history, alpha, beta);
  }

  ttentry, tthit := tt_probe(xiangqi);
  tt_prune(tthit, ttentry, alpha, beta, depth, alpha+1 != beta);
  att := attackers(xiangqi);
  incheck_position := true;
  child_pv: PV;

  if !incheck(xiangqi, att) then {
    incheck_position = false;
    evaluation := ifx tthit then ttentry.score else evaluate(xiangqi, history);
    // reverse futility pruning.
    if evaluation >= beta + depth * 200 {
      return evaluation;
    }

    // null move pruning.
    if evaluation >= beta && depth > 2 {
      R := max(2, depth / 3) + 1;
      make_null_move(xiangqi, history);
      score := -negamax(xiangqi, history, *child_pv, depth - R, -beta, -beta+1);
      unmake_null_move(xiangqi, history);

      if score >= beta {
        if in_middlegame(history) then {
          return score;
        } else {
          // when zugzwang can happen, especially in endgames, use a verification search.
          score = negamax(xiangqi, history, *child_pv, depth - R, -beta, -beta+1);
          if score >= beta {
            return score;
          }
        }
      }
    }

    // razoring.
    if depth <= 5 && evaluation + (150*depth) <= alpha {
      score := quiescene(xiangqi, history, alpha, alpha+1);
      if score <= alpha then {
        return score;
      }
    }
  }

  extension := search_extensions(tthit, ttentry, incheck_position, xiangqi, history, depth, alpha, beta);
  if extension == -100 {
    return beta;
  }

  moves: Moves;
  score: int = 0;
  moves_made := 0;
  quiet_moves_made := 0;
  best_score := -MATE + ply;
  best_move  := NULL_MOVE;
  flag       := Flag.Alpha;
  gen_moves(xiangqi, *moves);
  for mov: xiangqi {
    if !is_legal(xiangqi, att, mov) then {
      erase_move(*moves, it_index);
      continue;
    }

    make_move(xiangqi, history, mov);
    history.seldepth = max(history.ply, history.seldepth);

    if moves_made == 0 {
      extend_depth := 0;
      if incheck_position then {
        extend_depth = 1;
      } else if mov == ttentry.best_move && extension != 0 {
        extend_depth = extension;
      }
      score = -negamax(xiangqi, history, *child_pv, depth + extend_depth - 1, -beta, -alpha);
    } else {
      R := 0;
      if incheck_position {
        R = 0;
      } else if is_capture(mov) {
        R = 1;
      } else {
        // Late Move Reduction. ~30 elo.
        //R = ifx quiet_moves_made < 5 then 1 else 2;
        R = 1;
      }

      score = -negamax(xiangqi, history, *child_pv, depth - R, -alpha-1, -alpha);
      if alpha+1 != beta && score > alpha {

        extend_depth := 0;
        if incheck_position then {
          extend_depth = 1;
        }

        score = -negamax(xiangqi, history, *child_pv, depth + extend_depth - 1, -beta, -alpha);
      }
    }
    unmake_move(xiangqi, history, mov);

    moves_made += 1;
    if is_quiet(mov) {
      quiet_moves_made += 1;
    }

    if score > best_score {
      best_score = score;
      best_move  = mov;
      if score > alpha then {
        alpha = best_score;
        flag = Flag.Exact;
        copy_pv(pv, child_pv, best_move);
        if score >= beta then {
          /*
          Mating Killers?
          if score >= MATE-100 then {
            print("%\n", xiangqi.*);
            print("%\n", best_move);
            print("% %\n", score, beta);
            print("quiet_moves_made % moves_made %\n", quiet_moves_made, moves_made);
          }*/
          update_hist(history, moves, best_move, depth, incheck_position);
          tt_write(xiangqi, best_move, best_score, depth, .Beta);
          return best_score;
        }
      }
    } 

  }
  tt_write(xiangqi, best_move, best_score, depth, flag);
  return best_score;
}

search_extensions :: (tthit: bool, ttentry: Entry, incheck_position: bool, xiangqi: *Xiangqi, history: *History, depth: int, alpha: int, beta: int) -> extension: int {

  // incheck extension.
  if incheck_position == true {
    return 100;
  }

  ply := history.ply;
  if ply >= history.max_search_depth then {
    return 0;
  }

  best_move := ttentry.best_move;
  if depth >= 4 && ttentry.flag == .Alpha && !is_null(best_move) && tthit && (ttentry.depth <= depth - 3) && abs(alpha) < MATE-20 {
    sse_beta := ttentry.score - depth;
    if sse_beta >= beta {
      return -100;
    }

    if ttentry.score >= beta {
      return -2;
    }

    // TODO: need to test to make sure SSE functions correctly.
    sse_search :: (xiangqi: *Xiangqi, best_move: Move32, history: *History, depth: int, alpha: int, beta: int) -> int {
      incheck_position :: false;
      ttentry: Entry;
      moves: Moves;
      best_score := alpha;
      att := attackers(xiangqi);
      gen_moves(xiangqi, *moves);
      for mov: xiangqi {
        if mov == best_move || !is_legal(xiangqi, att, mov) then {
          erase_move(*moves, it_index);
          continue;
        }
  
        make_move(xiangqi, history, mov);
        score := -negascout_sse(xiangqi, history, depth - 1, -beta, -alpha);
        unmake_move(xiangqi, history, mov);
  
        if score > best_score {
          best_score = score;
          if score >= beta then {
            return best_score;
          }
        } 
      }

      return best_score;
    }

    score := sse_search(xiangqi, best_move, history, (depth/2) - 1, sse_beta-1, sse_beta);
    if score < sse_beta then {
      return 1;
    } 

    if ttentry.score <= alpha && ttentry.score <= score {
      return -1;
    }
  } 


  return 0;
}

negascout_sse :: (xiangqi: *Xiangqi, history: *History, depth: int, alpha: int, beta: int) -> int {
  unwrap_time();

  // mate distance pruning.
  ply := history.ply;
  alpha = max(alpha, -MATE+ply);
  beta  = min(beta,   MATE-ply);
  if alpha >= beta then {
    return alpha;
  }

  // you know...I don't exactly know all the xiangqi repetition rules.
  // and I am not going to focus on that at the moment. so let's just make this simple
  // and return -300. This is a little trick by Dutch Programmer HGM that hits most cases
  // easily...
  if is_repeating(xiangqi) {
    return -300;
  }

  if depth <= 0 then {
    return quiescene(xiangqi, history, alpha, beta);
  }

  ttentry, tthit := tt_probe(xiangqi);
  tt_prune(tthit, ttentry, alpha, beta, depth, false);
  att := attackers(xiangqi);
  incheck_position := true;
  if !incheck(xiangqi, att) then {
    incheck_position = false;
    evaluation := ifx tthit then ttentry.score else evaluate(xiangqi, history);
    // reverse futility pruning.
    if evaluation >= beta + depth * 200 {
      return evaluation;
    }

    // null move pruning.
    if evaluation >= beta && depth > 2 {
      R := max(2, depth / 3) + 1;
      make_null_move(xiangqi, history);
      score := -negascout_sse(xiangqi, history, depth - R, -beta, -beta+1);
      unmake_null_move(xiangqi, history);

      if score >= beta {
        if in_middlegame(history) then {
          return score;
        } else {
          // when zugzwang can happen, especially in endgames, use a verification search.
          score = negascout_sse(xiangqi, history, depth - R, -beta, -beta+1);
          if score >= beta {
            return score;
          }
        }
      }
    }

    // razoring.
    if depth <= 5 && evaluation + (150*depth) <= alpha {
      score := quiescene(xiangqi, history, alpha, alpha+1);
      if score <= alpha then {
        return score;
      }
    }
  }

  moves: Moves;
  score: int = 0;
  best_score := -MATE + ply;
  best_move  := NULL_MOVE;
  gen_moves(xiangqi, *moves);
  moves_made := 0;
  quiet_moves_made := 0;

  for mov: xiangqi {
    if !is_legal(xiangqi, att, mov) then {
      erase_move(*moves, it_index);
      continue;
    }

    make_move(xiangqi, history, mov);

    R := 0;
    if incheck_position {
      R = 0;
    } else if moves_made == 0 || is_capture(mov) {
      R = 1;
    } else {
      // Late Move Reduction. ~30 elo.
      //R = ifx quiet_moves_made < 5 then 1 else 2;
      //R = 1;//ifx quiet_moves_made < 5 then 1 else 3;
      R = 1;
    }

    score = -negascout_sse(xiangqi, history, depth - R, -beta, -alpha);
    unmake_move(xiangqi, history, mov);

    moves_made += 1;
    if is_quiet(mov) {
      quiet_moves_made += 1;
    }

    if score > best_score {
      best_score = score;
      best_move  = mov;
      if score >= beta then {
        update_hist(history, moves, best_move, depth, incheck_position);
        return best_score;
      }
    } 

  }

  return best_score;
}

quiescene :: (xiangqi: *Xiangqi, history: *History, alpha: int, beta: int) -> eval: int {
  unwrap_time();
  ply := history.ply;
  best_score := evaluate(xiangqi, history);
  if best_score >= beta then
    return best_score;
 
  // quiescene delta pruning.
  if in_middlegame(history) && best_score + 700 <= alpha then {
    return best_score;
  }
 
  futility_base := best_score;
  alpha = max(alpha, best_score);
  moves: Moves;
  att := attackers(xiangqi);
  gen_captures(xiangqi, *moves);
  incheck_position := incheck(xiangqi, att);
 
  // quiescene piece values.
  // todo. later, if we want to change the piece values,
  // we may need to do some reevaluation.
  // these qpiece values are far above the average piece values on purpose, ensuring that the pruning 
  // does not accidentally prune much needed evaluations.
  QPIECE_VALUES :: int.[0, 440, 440, 575, 675, 575, 350];
 
  for mov: moves {
    if !is_legal(xiangqi, att, mov) then {
      continue;
    }

    // ~10 elo. 
    // quiescene delta pruning. if a capture move does nothing
    // to improve the current score, skip the capture move.
    piece_value := QPIECE_VALUES[mov.capture >> 2]; 
    if !incheck_position && (futility_base + piece_value) < alpha then {
      continue;
    }
 
    make_move(xiangqi, history, mov);
    score := -quiescene(xiangqi, history, -beta, -alpha);
    unmake_move(xiangqi, history, mov);
 
    if score > best_score then {
      best_score = score;
      if score > alpha then {
        alpha = best_score;
        if score >= beta then {
          return best_score;
        }
      }
    }
  }
  return best_score;
}

for_expansion :: (xiangqi: *Xiangqi, body: Code, f: For_Flags) #expand {
  stage: Stage = .PV;
  `it_index := 0;
  while it_index < `moves.count {
    defer {
      it_index += 1;
    }
    `it, stage= := pick_move(xiangqi, it_index, stage, *`moves, `ttentry.best_move, `history, `incheck_position);
    #insert body;
  }
}

Stage :: enum {
  PV :: 0;
  InitCaptures :: 1;
  Captures :: 2;
  InitKillers :: 3;
  Killers :: 4;
  InitQuiets :: 5;
  Quiets :: 6;
  Quit :: 7;
}

pick_move :: (xiangqi: *Xiangqi, index: int, stage: Stage, moves: *Moves, best_move: Move32, h: *History, incheck_position: bool) -> Move32, Stage {

  partial_sort :: (moves: *Moves, i: int) -> Move32 {
    greatest := 0x8000_0000_0000_0000;
    best_index := -1; 
 
    idx := i;
    while idx < moves.count {
      if moves.array[idx].score > greatest {
        greatest = moves.array[idx].score;
        best_index = idx;
      }
      idx += 1;
    }

    moves.array[i], moves.array[best_index] = moves.array[best_index], moves.array[i];
    return moves.array[i].move;
  }

  score_quiet_move :: (move: Move32, board_history: [][90] s32, counter_history: [][90] s32, follow_history: [][90] s32) -> s32 {
    piece := move.piece >> 1;
    to    := move.to;
    return (2 * board_history[piece][to] / 5) + counter_history[piece][to] + follow_history[piece][to];
  }

  score_evasion :: (move: Move32, evasion_history: [][90] s32) -> s32 {
    piece := move.piece >> 1;
    to    := move.to;
    return evasion_history[piece][to];
  }

  if stage == {

  case .PV;
    success := false;
    for move, idx : moves {
      if move == best_move {
        success = true;
        moves.array[0], moves.array[idx] = moves.array[idx], moves.array[0];
        moves.array[0].score = 0x7FFF_FFFF;
        break;
      }
    }

    stage += 1;
    if success == true {
      return best_move, stage;
    }
    #through;
  case .InitCaptures;
    i := index;
    while i < moves.count {
      move := moves.array[i].move;
      if is_capture(move) {
        moves.array[i].score = mvv_lva(move) + 0x7FF_FFFF;
      }
      i += 1;
    }
    stage += 1;
    #through; 
  case .Captures;
    move := partial_sort(moves, index);
    if !is_null(move) && is_capture(move) then {
      return move, stage;
    }
    stage += 1;
    #through; 
  case .InitKillers;
    k1, k2, ch := get_killers(h);
    for move, idx : moves {
      if move == k1 then {
        moves.array[idx].score = 0x7F_FFFF;
      } else if move == k2 then {
        moves.array[idx].score = 0x7F_FFFE;
      } else if move == ch then {
        moves.array[idx].score = 0x7F_FFFD;
      }
    }
    stage += 1;
    #through; 
  case .Killers;
    move := partial_sort(moves, index);
    if !is_null(move) && moves.array[index].score > 0x7F_FFF0 then {
      return move, stage;
    }
    stage += 1;
    #through; 
  case .InitQuiets;
    if incheck_position == true {
      evasion_history := get_evasion(h); 
      i := index;
      while i < moves.count {
        move := moves.array[i].move;
        moves.array[i].score = score_evasion(move, evasion_history);
        i += 1;
      }
    } else {
      board_history   := get_board_history(h);
      counter_history := get_history(h, 1);
      follow_history  := get_history(h, 2);
      i := index;
      while i < moves.count {
        move := moves.array[i].move;
        moves.array[i].score = score_quiet_move(move, board_history, counter_history, follow_history);
        i += 1;
      }
    }
    stage += 1;
    #through;
  case .Quiets;
    move := partial_sort(moves, index);
    if !is_null(move) then {
      return move, stage;
    }
    stage += 1;
    #through;
  case .Quit;

  }

  return NULL_MOVE, stage;
}

make_move :: (xiangqi: *Xiangqi, h: *History, move: Move32) {
  if is_capture(move) then {
    h.phase_value -= phase_incr(move);
  }
  incr_evaluation(xiangqi.turn, h.accum, h.ply, move);
  make_move(xiangqi, move);
  h.moves[h.ply] = move;
  h.ply += 1;
  // called after h.ply. cannot be called before that.
  nnue_incremental_update(xiangqi, h, move);
  nodes += 1;
}

unmake_move :: (xiangqi: *Xiangqi, history: *History, move: Move32) {
  if is_capture(move) then {
    history.phase_value += phase_incr(move);
  }
  unmake_move(xiangqi, move);
  history.ply -= 1;
}

make_null_move :: (xiangqi: *Xiangqi, hist: *History) {
  incr_null_evaluation(hist.accum, hist.ply);
  make_null_move(xiangqi);
  hist.moves[hist.ply] = NULL_MOVE;
  hist.ply += 1;
  nnue_incremental_nullmove(xiangqi, hist);
  hist.seldepth = max(hist.ply, hist.seldepth);
  nodes += 1;
}

unmake_null_move :: (xiangqi: *Xiangqi, history: *History) {
  unmake_null_move(xiangqi);
  history.ply -= 1;
}

mvv_lva :: (move: Move32) -> s32 {
  victim := move.capture >> 2;
  attack := move.piece   >> 2;
  TABLE :: s32.[1000, 120, 120, 270, 600, 285, 30];
  return TABLE[victim] - (TABLE[attack] / 10);
}

MATE :: 20_000;
nodes := 0;

update_hist :: (h: *History, moves: Moves, best_move: Move32, depth: int, incheck_position: bool) {

  if is_quiet(best_move) {
    if incheck_position == true {
      evasion_history := get_evasion(h); 
      bonus := cast(s32)min(depth*depth, 1024);
      for move : moves {
        if is_null(move) then {
          continue;
        }
     
        piece1 := move.piece >> 1;
        sq1    := move.to;
        if move == best_move {
          evasion_history[piece1][sq1] += bonus;
          break;
        } else {
          evasion_history[piece1][sq1] -= bonus;
        }
      }

    } else {
      ply := h.ply;
      killer: [] Move32 = h.killer[ply];
      if best_move != killer[0] {
        killer[1] = killer[0];
        killer[0] = best_move;
      }
      ply -= 1;
      piece: int;
      sq: int;
      if ply >= 0 {
        previous := h.moves[ply];
        piece = previous.piece >> 1;
        sq    = previous.to;
      } else {
        piece = 0;
        sq    = 0;
      }
     
      h.counter[piece][sq] = best_move;
      board_history   := get_board_history(h);
      counter_history := get_history(h, 1);
      follow_history  := get_history(h, 2);
      bonus := cast(s32)min((depth * 3) / 2, 50);
      for move : moves {
        if is_null(move) then {
          continue;
        }
      
        piece1 := move.piece >> 1;
        sq1    := move.to;
        if move == best_move {
          board_history[piece1][sq1] += bonus;
          counter_history[piece1][sq1] += bonus;
          follow_history[piece1][sq1] += bonus;
          break;
        } else {
          board_history[piece1][sq1] -= bonus;
          counter_history[piece1][sq1] -= bonus;
          follow_history[piece1][sq1] -= bonus;
        }
      }
    }
  }
}

get_killers :: (h: *History) -> k0: Move32, k1: Move32, ch: Move32 {
  get_countermove :: (h: *History) -> Move32 #expand {
    ply := h.ply - 1;
    piece: int;
    sq: int;
    if ply >= 0 {
      previous := h.moves[ply];
      piece = previous.piece >> 1;
      sq    = previous.to;
    } else {
      piece = 0;
      sq    = 0;
    }
    return h.counter[piece][sq];
  }

  k := h.killer[h.ply];
  return k[0], k[1], get_countermove(h);
}

get_board_history :: (h: *History) -> [][90] s32 {
  return h.history[0][1];
}

get_evasion :: (h: *History) -> [][90] s32 {
  return h.history[0][2];
}

get_history :: (h: *History, num: int) -> [][90] s32 {
  ply := h.ply - num;
  piece: int;
  sq: int;
  if ply >= 0 {
    previous := h.moves[ply];
    piece = previous.piece >> 1;
    sq    = previous.to;
  } else {
    piece = 0;
    sq    = 0;
  }
  return h.history[piece][sq];
}

History :: struct {
  ply: int;
  seldepth: int;
  phase_value: int;
  max_search_depth: int;
  accum:       [128] Score;
  moves:       [128] Move32;
  accumulator: [128] Accumulator #align 64; 
  killer:  [128][2] Move32;
  counter: [14][90] Move32;
  history: [14][90][14][90] s32;
}

Flag :: enum s16 {
  Alpha;
  Beta;
  Exact;
}

Entry :: struct {
  hash: u32;
  best_move: Move32;
  score: s32;
  depth: s16;
  flag := Flag.Alpha;
}

transpositions: [][4] Entry #align 64;

init_tt :: (size_in_bytes: int) {
  if transpositions.count != 0 {
    array_free(transpositions);
  }

  count := size_in_bytes / size_of([4] Entry);
  transpositions = NewArray(count, [4] Entry, alignment=64);
}

clear_tt :: () {
  memset(transpositions.data, 0, size_of([4] Entry)*transpositions.count);
}

tt_probe :: (x: *Xiangqi) -> Entry, bool {
  hash  := x.hash;
  index := hash % transpositions.count;
  prefetch(*transpositions[index]);
  for *tt_entry : transpositions[index] {
    entry: Entry;
    memcpy(*entry, tt_entry, size_of(Entry));
    if entry.hash == hash && is_pseudolegal(x, entry.best_move) then {
      return entry, true;
    }
  }
  return Entry.{}, false;
}

tt_prune :: (tthit: bool, ttentry: Entry, alpha: int, beta: int, depth: int, pv: bool) #expand {
  if !pv && tthit && ttentry.depth >= depth {
    score := ttentry.score;
    flag  := ttentry.flag;
    if flag == .Exact then {
      `return score;
    } 

    if flag == .Alpha && score <= alpha then {
      `return score;
    }

    if flag == .Beta && score >= beta then {
      `return score;
    }
  }
}

tt_write :: (x: *Xiangqi, best_move: Move32, score: int, depth: int, flag: Flag) {
  hash  := x.hash;
  index := hash % transpositions.count;
  prefetch(*transpositions[index]);
  e     := rand_u32() % 4;
  for entry : transpositions[index] {
    if depth > entry.depth then {
      e = xx it_index;
      break;
    }
  }

  transpositions[index][e] = Entry.{hash, best_move, cast(s32)score, cast(s16) depth, flag};
}

prefetch :: (pointer: *void) #expand {
  #if CPU == .X64 {
    #asm { prefetcht0  [pointer]; }
  }
}

abs :: inline (value: int) -> int {
  if value < 0 {
    return -value;
  } else {
    return value;
  }
}

in_middlegame :: inline (history: *History) -> bool {
  return history.phase_value > 4;
}



