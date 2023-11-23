#run load_model("orange11_6_23.nnue");

main :: () {
  init_xiangqi_tables();
  init_tt(size_in_bytes = 16_000_000);

  xiangqi: Xiangqi;
  xiangqi_startpos(*xiangqi);

  while true {
    str := getline();
    token := parse_token(*str);
    if token == {
 
    case "quit";
      print("bye\n");
      free_threads();
      break;
 
    case "ucci";
      print("id name Orange\n");
      print("id author Daniel Tan, Xiaofan Sun\n");
      print("info string NNUE %\n", get_nnuename());
      print("option Clear Hash type button\n");
      print("option Hash type spin min 1 max 2000 default 16\n");
      print("option Threads type spin min 1 max 256 default 1\n");
      print("ucciok\n");
 
    case "isready";
      print("readyok\n");
 
    case "uccinewgame";
      clear_tt();
      xiangqi_startpos(*xiangqi);
 
    case "perft_all";
      perft_test_suite();
 
    case "d";
      print("%\n", xiangqi);

    case "flip";
      if incheck(*xiangqi) {
        print("info string in check. cannot flip\n");
      } else {
        make_null_move(*xiangqi);
      }
 
    case "eval";
      eval := evaluate(*xiangqi);
      print("evaluation % cp\n", eval);
 
    case "position";
      str = eat_spaces(str);
      if begins_with(str, "fen ") {
        str = advance(str, 4);
        str = eat_spaces(str);
        index :=  find_index_from_left(str, "moves");
        fen_string := ifx index != -1 then slice(str, 0, index) else str;
        success := xiangqi_fen(*xiangqi, fen_string);
        if !success then {
          print("invalid fen [%1]\n", fen_string);
          xiangqi_startpos(*xiangqi);
        }
        if index != -1 {
          str = advance(str, index);
          str = advance(str, 5);
          str = eat_spaces(str);
        } else {
          str = advance(str, str.count);
        }
      } else if begins_with(str, "startpos") {
        str = advance(str, 8);
        str = eat_spaces(str);
        xiangqi_startpos(*xiangqi);
        index := find_index_from_left(str, "moves");
        if index != -1 {
          str = advance(str, index);
          str = advance(str, 5);
          str = eat_spaces(str);
        } else {
          str = advance(str, str.count);
        }
      }
      while str {
        token := parse_token(*str);
        move := to_move32(*xiangqi, token);
        make_move(*xiangqi, move);
        if is_capture(move) then {
          reset_hashes(*xiangqi);
        } else if incheck(*xiangqi) {
          mark_previous_move_check(*xiangqi);
        } else {
          mark_previous_move(*xiangqi, .Idle);
        }
      }

    case "setoption";
      str = eat_spaces(str);
      setoption_command(str);

    case "see";
      str = eat_spaces(str);
      token := parse_token(*str);
      move := to_move32(*xiangqi, token);
      see_score := see(*xiangqi, move);
      print("info string SEE Score %\n", see_score);

    case "go";
      go_command(str, *xiangqi);

    case;

    }
  }

}

setoption_command :: (str: string) {
  // begins_with
  if equal(str, "Clear Hash") {
    print("info string Clear Transposition Table\n");
    clear_tt();
  } else if begins_with(str, "Threads ") {
    parse_token(*str);
    value, success := parse_int(*str);
    if success == true && value >= 1 && value <= 256 {
      print("info string Threads %\n", value);
      set_threads(value);
    }
  } else if begins_with(str, "Hash ") {
    parse_token(*str);
    value, success := parse_int(*str);
    if success == true && value >= 1 && value <= 2000 {
      print("info string Hash %\n", value);
      value *= 1_000_000;
      init_tt(value);
    }
  }
}

go_command :: (command: string, xiangqi: *Xiangqi) {
  str := eat_spaces(command);
  token := parse_token(*str);
  if equal(token, "perft") {
    depth, TF := parse_int(*str);
    if !TF return;
    perft_divide(xiangqi, depth);
    return;
  }

  depth: int = 100; // won't need anything greater than depth '100'.
  movetime_ms: int = 0x7FFF_FFFF;
  time: int = -1;
  increment: int = -1;
  parse_success: bool;

  while str {
    if token == {
    case "depth";
      depth, parse_success = parse_int(*str);
      if parse_success == false {
        print("info string error unable to parse depth\n");
        return;
      }
    case "time";
      time, parse_success = parse_int(*str);
      if parse_success == false {
        print("info string error unable to parse time\n");
        return;
      }
    case "increment";
      increment, parse_success = parse_int(*str);
      if parse_success == false {
        print("info string error unable to parse increment\n");
        return;
      }
    case "movetime";
      movetime_ms, parse_success = parse_int(*str);
      if parse_success == false {
        print("info string error unable to parse movetime\n");
        return;
      }
    }

    token = parse_token(*str);
    token = eat_spaces(token);
  }

  if time > -1 then {
    movetime_ms = time_management(time, increment);
  }

  start_threads(xiangqi, depth, movetime_ms);
  xiangqi.main_thread = true;
  bestmove, score := search(xiangqi, depth, movetime_ms);
  bestmove = wait_for_threads_finish(bestmove, score, depth);
  print("bestmove %\n", bestmove);
}


// Daniel (Mar 12, 2023)
// this function handles the clock time management.
// basic algorithm to do clock time management.
// may come back to changing how this works later.
time_management :: (time: int, incr: int) -> movetime: int {

  // simplified version copied over from "Chess Engine in Jai."
  // handle edge case where increment is greater than time.
  if incr > time then
    incr = 0;

  time /= 30;
  time -= 75;

  // time up
  if time < 0 {
    time = 0;
    incr -= 75;
    if incr < 0 then {
      incr = 1;
    }
  }

  return max(time + incr, 1);

}

start_threads :: (xiangqi: *Xiangqi, depth: int, movetime_ms: int) {
  if num_threads > 0 then {
    for *work: work_array {
      copy_board(*work.xiangqi, xiangqi);
      work.search_depth = depth;
      work.searchtime_ms = movetime_ms;
      add_work(*thread_group, work);
    }
    start(*thread_group);
  }
}

wait_for_threads_finish :: (bestmove: Move32, bestscore: int, search_depth: int) -> bestmove: Move32 {
  MATE_BOUND :: MATE - 30;

  work_remaining := num_threads;
  while work_remaining > 0 {
    results := get_completed_work(*thread_group);
    for r : results {
      work := cast(*Xiangqi_Work) r;
      bestmove := work.bestmove;
      score    := work.score;
      depth    := work.search_depth;
      if score > bestscore && (depth >= search_depth || score >= MATE_BOUND) {
        bestscore = score;
        search_depth = depth;
        bestmove = work.bestmove;
      }
    }
    work_remaining -= results.count;
    reset_temporary_storage();
  }

  return bestmove;
}

set_threads :: (num: int) {
  num -= 1;
  if num_threads == num then
    return;
  free_threads();

  num_threads = num;
  init(*thread_group, cast(s32)num_threads, search_thread, false);
  thread_group.logging = false;

  // initialize the workers
  if work_array.count > 0 then {
    array_free(work_array);
  }

  work_array = NewArray(num_threads, Xiangqi_Work, alignment=64);
  for *work: work_array {
    work.main_thread = false;
  }
}

search_thread :: (group: *Thread_Group, thread: *Thread, work: *void) -> Thread_Continue_Status {
  setup_xiangqi_print();
  parameters := cast(*Xiangqi_Work) work;
  xiangqi := *parameters.xiangqi;
  search_depth := parameters.search_depth;
  searchtime_ms := parameters.searchtime_ms;
  bestmove, score := search(xiangqi, search_depth, searchtime_ms);
  parameters.bestmove = bestmove;
  parameters.score = score;
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
  using xiangqi: Xiangqi;
  search_depth: int = 0;
  searchtime_ms: int = 0;
  bestmove: Move32;
  score: int = 0;
}

work_array: [] Xiangqi_Work;

#if OS == .LINUX {
  #import "POSIX";
  buffer: [4096] u8;
  NEWLINE :: "\n";

  // TODO: This getline needs to be made MORE robust!
  getline :: () -> string {
    bytes_read := read(STDIN_FILENO, buffer.data, buffer.count);
    str := to_string(buffer.data, bytes_read);
    if str[bytes_read-1] == #char "\n" then
      str.count -= 1;
    return str;
  }
   
} 

#if OS == .WINDOWS {
  #import "Windows";
  buffer: [4096] u8;
  NEWLINE :: "\r\n";

  // TODO: This getline needs to be made MORE robust!
  getline :: () -> string {
    stdin := GetStdHandle(STD_INPUT_HANDLE);
    bytes_read: u32;
    ReadFile(stdin, buffer.data, buffer.count, *bytes_read, null);
    str := to_string(buffer.data, bytes_read);
    normalize_line_endings(*str);
    if str[str.count-1] == #char "\n" then
      str.count -= 1;
    if str[str.count-1] == #char "\r" then
      str.count -= 1;
    return str;
  }
} 

#import "Thread";
