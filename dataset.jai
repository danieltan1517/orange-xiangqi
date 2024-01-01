// 
// create an evaluation dataset.
// a buggy implementation with infinite loop problems
// every once in a while, but usable...
// 
#run load_model("orange12_9_23.nnue");

DEPTH :: 7;
MOVETIME :: 3_600_000;
MAX_COMPUTATIONS :: 50_000_000;

main :: () {
  print("info string NNUE Model: %\n", get_nnuename(), to_standard_error=true);
  init_xiangqi_tables();
  init_tt(size_in_bytes = 128_000_000);
  random_seed(0xcafe_babe_10_31_1517);
  set_threads(6);
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
  defer {
    free_threads();
  }
  print("eval,positions\n");
  for i: 0..1_000_000_000 {
    reset_temporary_storage();
    // clear_tt();
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
    print("----Game %. Time: [%]. Positions in Hash Table: %. Positions Evaluated: %. Depth %. Total %\n", i, time_calendar, table.count, positions_computed, DEPTH, MAX_COMPUTATIONS, to_standard_error=true);

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

add_evaluation :: inline (fen: string, evaluation: int) {
  print("%,%\n", evaluation, fen);
  positions_computed += 1;
}

positions_computed := 0;

position_outbounds :: inline (evaluation: int) -> bool {
  evaluation = abs(evaluation);
  return evaluation == 0 || evaluation > MAX_SCORE;
}

MAX_SCORE :: 1000;

PositionStatus :: enum {
  QuietPosition;
  CriticalPosition;
  TacticalPosition;
}

rollout :: (fen: string, table: *Table(u32, void)) {
  xiangqi: Xiangqi;
  xiangqi_fen(*xiangqi, fen);
  moves: Moves;

  work_started := 0;

  for 0..2 {
    reset(*moves);
    legal_moves(*xiangqi, *moves);

    // reset work started to zero
    work_started = 0;
    for mov : moves {
      r := random_get() % 100;
      if r < 30 then {
        continue;
      }

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

      history: History;
      alpha := -MATE;
      beta  :=  MATE;
      delta :=  100;
  
      // aspiration window with iterative deepening.
      searchstarttime = current_time_monotonic();
      ticks = 300_000_000;
      history.phase_value = compute_phase(*xiangqi);
      nnue_incremental_init(*xiangqi, *history);
  
      // do not compute positions which are not 'quiet'. 'quiet' positions are such
      // that a depth of 1 does not change the position much. exchanges will not 
      // change the evaluation much in quiet positions.
      // this is similar to the 'quiet' position definition found in fairy stockfish
      evaluation_score := evaluate(*xiangqi);
      quiescene_score  := quiescene(*xiangqi, *history, alpha, beta);
  
      if abs(evaluation_score - quiescene_score) > 40 then {
        continue;
      }

      work_started += 1;
      start_threads(*xiangqi, mov, DEPTH, MOVETIME);
    }

    mov_make := wait_for_threads_finish(table, work_started);
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
search_evaluation :: (xiangqi: *Xiangqi, search_depth: int, searchtime_ms: int) -> int, PositionStatus #must {
  time_stop_ms = searchtime_ms;
  search_should_stop = false;
  nodes = 0;
  history: History;
  alpha := -MATE;
  beta  :=  MATE;
  delta :=  100;

  // aspiration window with iterative deepening.
  searchstarttime = current_time_monotonic();
  ticks = 300_000_000;
  evaluation_score := evaluate(xiangqi);
  history.phase_value = compute_phase(xiangqi);
  nnue_incremental_init(xiangqi, *history);
  
  pv: PV;
  depth := 1;
  score: int = 0;
  while depth <= search_depth {
    score = negamax_root(xiangqi, *history, *pv, depth, alpha, beta);
    alpha = max(score - delta, -MATE);
    beta  = min(score + delta,  MATE);
    depth += 1;
  }

  status: PositionStatus;
  if abs(evaluation_score - score) > 70 {
    status = PositionStatus.CriticalPosition;
  } else {
    status = PositionStatus.QuietPosition;
  }

  return score, status;
}

start_threads :: (xiangqi: *Xiangqi, move: Move32, depth: int, movetime_ms: int) {
  if num_threads > 0 then {
    work := New(Xiangqi_Work, allocator=temp);
    work.fen = to_fenstring(xiangqi);
    work.hash = xiangqi.hash;
    work.bestmove = move;
    work.search_depth = DEPTH;
    work.searchtime_ms = MOVETIME;
    work.search_depth = depth;
    work.searchtime_ms = movetime_ms;
    add_work(*thread_group, work);
  }
}

wait_for_threads_finish :: (table: *Table(u32,void), work_remaining: int) -> bestmove: Move32 {

  is_king_move :: inline (move: Move32) -> bool {
    piece := move.piece >> 2;
    return piece == 0;
  }

  start(*thread_group);
  bestmove: Move32;
  while work_remaining > 0 {
    results := get_completed_work(*thread_group);
    for r : results {
      work := cast(*Xiangqi_Work) r;
      hash     := work.hash;
      score    := work.score;
      status   := work.status;
      fen      := work.fen;
      move     := work.bestmove;
      if position_outbounds(score) then {
        continue;
      }
      if status == .QuietPosition then {
        VOID: void;
        table_add(table, hash, VOID);
        add_evaluation(fen, score);
      }
      if status == .CriticalPosition then {
        bestmove = move;
      }
    }
    work_remaining -= results.count;
    sleep_milliseconds(1);
  }

  reset_temporary_storage();
  return bestmove;
}

set_threads :: (num: int) {
  num -= 1;
  if num_threads == num then
    return;
  free_threads();

  num_threads = num;
  init(*thread_group, cast(s32)num_threads, search_thread, true);
  thread_group.logging = false;
}

search_thread :: (group: *Thread_Group, thread: *Thread, work: *void) -> Thread_Continue_Status {
  setup_xiangqi_print();
  parameters := cast(*Xiangqi_Work) work;
  xiangqi: Xiangqi;
  xiangqi_fen(*xiangqi, parameters.fen);
  search_depth := parameters.search_depth;
  searchtime_ms := parameters.searchtime_ms;
  score, status := search_evaluation(*xiangqi, search_depth, searchtime_ms);
  parameters.score = score;
  parameters.status = status;
  return .CONTINUE;
}

free_threads :: () {
  if num_threads > 0 then {
    shutdown(*thread_group);
  }
}

thread_group: Thread_Group;
num_threads: int = 0;

Xiangqi_Work :: struct {
  fen: string;
  bestmove: Move32;
  hash: u32;
  search_depth: int = 0;
  searchtime_ms: int = 0;
  score: int = 0;
  status: PositionStatus;
}

#import "Basic";
#import "File";
#import "String";
#import "Random";
#import "Hash_Table";
#import "Thread";
