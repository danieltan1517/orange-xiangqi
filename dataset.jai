// 
// create an evaluation dataset.
// a buggy implementation with infinite loop problems
// every once in a while, but usable...
// 
#run load_model("orange10_18_23.nnue");

DEPTH :: 4;
MOVETIME :: 3_600_000;
MAX_COMPUTATIONS :: 35_000_000;

main :: () {
  init_xiangqi_tables();
  init_tt(size_in_bytes = 16_000_000);
  random_seed(0xcafe_babe_10_31_1517);
  FILE_NAME :: "xiangqi_games.txt";
  text, success := read_entire_file(FILE_NAME);
  if !success {
    print("Error. % cannot be opened.", FILE_NAME);
    return;
  }

  table: Table(u32, void);
  init(*table, 16_000_000);

  xiangqi: Xiangqi;
  xiangqi_startpos(*xiangqi);

  print("eval,positions\n");
  for i: 0..1_000_000 {
    reset_temporary_storage();
    clear_tt();
    found, line, rest := split_from_left(text, #char "\n");
    if found == false {
      break;
    }
    defer {
      text = rest;
    }
    replace_chars(line, "',", #char " ");
    xiangqi_startpos(*xiangqi);

    time_calendar := calendar_to_string(to_calendar(current_time_consensus()));
    print("----Game %. Time: [%]. Positions in Hash Table: %. Positions Evaluated: %\n", i, time_calendar, table.count, positions_computed, to_standard_error=true);

    // the starting position has 32 pieces total
    count := compute_phase(*xiangqi);
    while true {
      fen := to_fenstring(*xiangqi);
      rollout(fen, *table);

      reset_temporary_storage();
      if positions_computed >= MAX_COMPUTATIONS then {
        break i;
      }

      line = eat_spaces(line);
      token, found := parse_token(*line);
      if found == false {
        break;
      }
      
      move := to_move32(*xiangqi, token);

      make_move(*xiangqi, move);
      if is_capture(move) {
        reset_hashes(*xiangqi);
        count -= phase_incr(move);
      }

      if count < 3 then {
        break;
      }
    }
  }

}

add_evaluation :: (xiangqi: *Xiangqi, evaluation: int) {
  fen := to_fenstring(xiangqi);
  print("%,%\n", evaluation, fen);
  positions_computed += 1;
}

positions_computed := 0;

position_outbounds :: inline (evaluation: int) -> bool {
  evaluation = abs(evaluation);
  return evaluation == 300 || evaluation > MAX_SCORE;
}

MAX_SCORE :: 1000;

Status :: enum {
  QuietPosition;
  CriticalPosition;
  TacticalPosition;
}

rollout :: (fen: string, table: *Table(u32, void)) {
  xiangqi: Xiangqi;
  xiangqi_fen(*xiangqi, fen);
  moves: Moves;

  for 0..5 {

    mov_make: Move32 = NULL_MOVE;

    reset(*moves);
    legal_moves(*xiangqi, *moves);
    for mov : moves {
      make_move(*xiangqi, mov);
      defer {
        unmake_move(*xiangqi, mov);
      }
 
      if table_contains(table, xiangqi.hash) then {
        continue;
      }
 
      att := attackers(*xiangqi);
      if incheck(*xiangqi, att) then {
        continue;
      }
 
      evaluation, status := search_evaluation(*xiangqi, DEPTH, MOVETIME);
      if position_outbounds(evaluation) then {
        continue;
      }
 
      if status == .QuietPosition then {
        none: void;
        table_add(table, xiangqi.hash, none);
        add_evaluation(*xiangqi, evaluation);

        if (is_capture(mov) || (mov.piece >> 2) == 0) && is_null(mov_make) then {
          mov_make = mov;
        }
      } 

      if status == .CriticalPosition then {
        mov_make = mov;
      }
    }

    if is_null(mov_make) then {
      break;
    }

    make_move(*xiangqi, mov_make);
  }
}


// according to evaluation paper,
// 0 = even
// 30-70 = slightly better, one pawn lost
// 70-170 = better, one guard or one elephant lost.
// 170-310 = much better = one horse or cannon lost.
// 310+ = one rook or more lost

// main search evaluation function.
search_evaluation :: (xiangqi: *Xiangqi, search_depth: int, searchtime_ms: int) -> int, Status #must {
  time_stop_ms = searchtime_ms;
  search_should_stop = false;
  nodes = 0;
  best_move := NULL_MOVE;
  history: History;
  alpha := -MATE;
  beta  :=  MATE;
  delta :=  100;

  // aspiration window with iterative deepening.
  searchstarttime = current_time_monotonic();
  ticks = 300_000_000;
  history.accum[0] = evaluate_absolute(xiangqi);
  history.phase_value = compute_phase(xiangqi);
  nnue_incremental_init(xiangqi, *history);

  // do not compute positions which are not 'quiet'. 'quiet' positions are such
  // that a depth of 1 does not change the position much. exchanges will not 
  // change the evaluation much in quiet positions.
  // this is similar to the 'quiet' position definition found in fairy stockfish

  evaluation_score := evaluate(xiangqi);
  quiescene_score  := quiescene(xiangqi, *history, alpha, beta);

  if abs(evaluation_score - quiescene_score) > 50 then {
    return quiescene_score, Status.TacticalPosition;
  }
  
  pv: PV;
  depth := 1;
  score: int = 0;
  while depth <= search_depth {
    score = negamax_root(xiangqi, *history, *pv, depth, alpha, beta);
    best_move = pv.moves[0];
    alpha = max(score - delta, -MATE);
    beta  = min(score + delta,  MATE);
    depth += 1;
  }

  best_move = pv.moves[0];
  status: Status;
  if abs(evaluation_score - score) > 70 {
    status = Status.CriticalPosition;
  } else {
    status = Status.QuietPosition;
  }

  return score, status;
}

#import "Basic";
#import "File";
#import "String";
#import "Random";
#import "Hash_Table";
