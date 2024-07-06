#run load_model("orange4_27_24.nnue");

main :: () {
  print("info string NNUE Model: %\n", get_nnuename(), to_standard_error=true);
  init_xiangqi_tables();
  init_tt(size_in_bytes = 128_000_000);
  random_seed(0xcafe_babe_10_31_1517);
  set_threads(4);
  init(*table, 16_000_000);
  defer {
    free_threads();
  }
 
  print("eval,positions\n");
  load_grandmaster_games("xiangqi_games.txt");
  load_synthetic_games("game.pgn");
  load_synthetic_games("game2.pgn");
  load_synthetic_games("game3.pgn");
  load_synthetic_games("game4.pgn");
  load_synthetic_games("game5.pgn");
  load_synthetic_games("game6.pgn");
  load_synthetic_games("game7.pgn");
  load_synthetic_games("game8.pgn");
  load_synthetic_games("game11.pgn");
}

thread_group: Thread_Group;
table: Table(u32, void);
num_threads: int = 0;

set_threads :: (num: int) {
  num -= 1;
  if num_threads == num then
    return;
  free_threads();

  num_threads = num;
  init(*thread_group, cast(s32)num_threads, search_thread, true);
  thread_group.logging = false;
}

free_threads :: () {
  if num_threads > 0 then {
    shutdown(*thread_group);
  }
}

search_thread :: (group: *Thread_Group, thread: *Thread, work_pointer: *void) -> Thread_Continue_Status {
  work := cast(*Xiangqi_Work) work_pointer;
  xiangqi := xiangqi_work[work.identifier];
  _, score, status := search_score(*xiangqi, SEARCH_DEPTH, 3_000);
  work.score = score;
  work.status= status;
  return .CONTINUE;
}

load_grandmaster_games :: (filename: string) {
  text, success := read_entire_file(filename);
  assert(success, "Error. % file cannot be opened.", filename);

  i := 0;
  while true {
    found, line, text= := split_from_left(text, #char "\n");
    if found == false {
      break;
    }
    replace_chars(line, "',", #char " ");
    compute_game(line);
    time_calendar := calendar_to_string(to_calendar(current_time_consensus()));
    print("Game %. Games Positions Computed: %. %\n", i, table.count, time_calendar, to_standard_error=true);
    i += 1;
  }
}

load_synthetic_games :: (filename: string) {

  text, success := read_entire_file(filename);
  assert(success, "Error. % file cannot be opened.", filename);

  i := 0;

  fen: string;
  while true {
    found, line, text= := split_from_left(text, #char "\n");
    if found == false {
      break;
    }

    if starts_with(line, "\n") {
      continue;
    } else if starts_with(line, "[Fen \"") {
      advance(*line, 6);
      fen = line;
      replace_chars(fen, "\"", #char " ");
      replace_chars(fen, "]", #char " ");
    } else if starts_with(line, "[") {
      continue;
    } else {
      compute_game(line, fen);
      time_calendar := calendar_to_string(to_calendar(current_time_consensus()));
      print("Game %. Games Positions Computed: %. %\n", i, table.count, time_calendar, to_standard_error=true);
      i += 1;
      
    }
  }

}

compute_game :: (game_line: string, fen := "") {
  xiangqi: Xiangqi;
  if fen {
    xiangqi_fen(*xiangqi, fen);
  } else {
    xiangqi_startpos(*xiangqi);
  }

  line := game_line;
  phase_count := compute_phase(*xiangqi);
  while true {
    line = eat_spaces(line);
    token, found := parse_token(*line);
    if found == false {
      break;
    }
    compute_position(*xiangqi);
    move := to_move32(*xiangqi, token);
    make_move(*xiangqi, move);
    if is_capture(move) {
      phase_count -= phase_incr(move);
    }
    if phase_count < 3 then {
      break;
    }
  }
}

xiangqi_work: [40] Xiangqi;

compute_position :: (xiangqi: *Xiangqi) {

  add_work_to_queue :: (i: int, work: *Xiangqi_Work) {
    work.identifier = i;
    add_work(*thread_group, work);
  }

  work: [40] Xiangqi_Work;
  moves_pv := search_best_pv(xiangqi, 4, 6, 3_000);
  work_started := 0;
  for mov : moves_pv {
    make_move(xiangqi, mov);
    if incheck(xiangqi) {
      unmake_move(xiangqi, mov);
      continue;
    }
    if table_contains(*table, xiangqi.hash) then {
      unmake_move(xiangqi, mov);
      continue;
    }

    i := work_started;
    copy_board(*xiangqi_work[i], xiangqi);
    add_work_to_queue(i, *work[i]);
    work_started += 1;
    unmake_move(xiangqi, mov);
    if work_started >= work.count then {
      break;
    }
  }

  wait_for_threads_finish(work_started);
}

wait_for_threads_finish :: (work_remaining: int) {
  start(*thread_group);
  reset_temporary_storage();
  while work_remaining > 0 {
    results := get_completed_work(*thread_group);
    for r : results {
      assert(r != null, "Error. r is null");
      work := cast(*Xiangqi_Work) r;
      id       := work.identifier;
      score    := work.score;
      status   := work.status;
      if status == .Normal && (score >= -500 && score <= 500) {
        print("%,%\n", score, to_fenstring(*xiangqi_work[id]));
        VOID: void;
        table_add(*table, xiangqi_work[id].hash, VOID);
      }
    }
    work_remaining -= results.count;
    sleep_milliseconds(1);
  }
}

Xiangqi_Work :: struct {
  identifier: int;
  score: int;
  status: SearchStatus;
}

SEARCH_DEPTH :: 7;

// main search evaluation function.
search_best_pv :: (xiangqi: *Xiangqi, search_depth: int, multipv_number: int, searchtime_ms: int) -> Moves {

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

  root_moves: Moves;

  // aspiration window with iterative deepening.
  searchstarttime = current_time_monotonic();
  ticks = 300_000_000;
  depth := 1;
  pv: PV;
  history.phase_value = compute_phase(xiangqi);
  nnue_incremental_init(xiangqi, history);
  best_score := -MATE;

  while depth <= search_depth {
    best_score = -MATE;
    pv_index := 1;
    end_multipv := false; 
    clear_moves(*root_moves);
    while pv_index <= multipv_number {
      score := negamax_root(xiangqi, history, *pv, depth, alpha, beta, *root_moves, *end_multipv);
      if end_multipv == true {
        break;
      }

      time_taken := current_time_monotonic() - searchstarttime;
      if score <= alpha then {
        alpha = max(score-delta, -MATE);
        delta += delta + delta / 5;
        continue;
      }
 
      if score >= beta then {
        beta = min(score+delta, MATE);
        delta += delta + delta / 5;
        continue;
      }
 
      ticks = 8192;
      alpha = max(score - delta, -MATE);
      beta  = min(score + delta,  MATE);
      if score > best_score {
        best_score = score;
        best_move = pv.moves[0];
      }

      append_move(*root_moves, pv.moves[0]);
      time_ms := max(1, to_milliseconds(time_taken)); // convert secs to ms, minimum is 1 to avoid division by zero.
      seldepth := history.seldepth;
      nps  := nodes * 1000 / time_ms; // max to avoid a divide by zero bug.
      pv_index += 1;
    }
    depth += 1;
  }

  is_defensive_move :: inline (move: Move32) -> bool {
    piece := move.piece >> 2;
    return piece <= 2;
  }


  all_legal_moves: Moves;
  legal_moves(xiangqi, *all_legal_moves);
  for < i : all_legal_moves.count-1..2 {
    r := cast(s64)(random_get() % cast(u64)i);
    all_legal_moves.array[i], all_legal_moves.array[r] = all_legal_moves.array[r], all_legal_moves.array[i];
  }

  num_random_moves := 0;
  for mov : all_legal_moves {
    if contains_move(*root_moves, mov) then {
      continue;
    }

    if is_defensive_move(mov) {
      append_move(*root_moves, mov);
    } else if num_random_moves < 5 {
      append_move(*root_moves, mov);
      num_random_moves += 1;
    }
  }

  return root_moves;
}


SearchStatus :: enum {
  Normal;
  Quiescene;
}

// main search evaluation function.
search_score :: (xiangqi: *Xiangqi, search_depth: int, searchtime_ms: int) -> bestmove: Move32, score: int #must, SearchStatus {

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

  root_moves: Moves;

  // aspiration window with iterative deepening.
  searchstarttime = current_time_monotonic();
  ticks = 300_000_000;
  depth := 1;
  pv: PV;
  history.phase_value = compute_phase(xiangqi);
  nnue_incremental_init(xiangqi, history);
  score := -MATE;


  evaluation_score := evaluate(xiangqi);
  quiescene_score  := quiescene(xiangqi, history, alpha, beta);
  if abs(evaluation_score - quiescene_score) > 60 then {
    return best_move, quiescene_score, SearchStatus.Quiescene;
  }

  while depth <= search_depth {
    end_multipv := false; 
    score = negamax_root(xiangqi, history, *pv, depth, alpha, beta, *root_moves, *end_multipv);
    if end_multipv == true {
      break;
    }

    if score <= alpha then {
      alpha = max(score-delta, -MATE);
      delta += delta + delta / 5;
      continue;
    }
 
    if score >= beta then {
      beta = min(score+delta, MATE);
      delta += delta + delta / 5;
      continue;
    }
 
    ticks = 8192;
    alpha = max(score - delta, -MATE);
    beta  = min(score + delta,  MATE);
    best_move = pv.moves[0];
    depth += 1;
  }

  if abs(evaluation_score - score) > 80 then {
    return best_move, evaluation_score, SearchStatus.Quiescene;
  }
  return best_move, score, SearchStatus.Normal;
}

#import "Basic";
#import "File";
#import "String";
#import "Random";
#import "Hash_Table";
#import "Thread";
