handle_command :: (input: string, xiangqi: *Xiangqi) -> bool {
  str := input;
  token := parse_token(*str);
  if token == {

  case "quit";
    return true;

  case "ucci";
    println("id name Axe (A Xiangqi Engine)");
    println("id author Daniel Tan");
    println("ucciok");

  case "isready";
    println("readyok");

  case "uccinewgame";
    xiangqi_startpos(xiangqi);

  case "perft_all";
    perft_test_suite();

  case "d";
    print_board(xiangqi);

  case "fen"; // hopefully this does not get confused with other commands...
    fenstring := to_fenstring(xiangqi);
    println("%", fenstring);

  case "eval";
    eval := evaluate(xiangqi);
    println("evaluation % cp", eval);

  case "position";
    str = eat_spaces(str);
    if begins_with(str, "fen ") {
      str = advance(str, 4);
      str = eat_spaces(str);
      index :=  find_index_from_left(str, "moves");
      fen_string := ifx index != -1 then slice(str, 0, index) else str;
      success := xiangqi_fen(xiangqi, fen_string);
      if !success then {
        println("invalid fen [%1]", fen_string);
        xiangqi_startpos(xiangqi);
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
      xiangqi_startpos(xiangqi);
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
      move32 := to_move32(xiangqi, token);
      make_move(xiangqi, move32);
      if is_capture(move32) {
        reset_hashes(xiangqi);
      }
    }

  case "go";
    go_command(str, xiangqi);
  }
  return false;
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

  depth: int = 20_000;
  movetime_ms: int = 0x7FFF_FFFF;
  time: int = -1;
  increment: int = -1;
  parse_success: bool;

  while str {
    if token == {
    case "depth";
      depth, parse_success = parse_int(*str);
      if parse_success == false {
        println("info string error unable to parse depth");
        return;
      }
    case "time";
      time, parse_success = parse_int(*str);
      if parse_success == false {
        println("info string error unable to parse time");
        return;
      }
    case "increment";
      increment, parse_success = parse_int(*str);
      if parse_success == false {
        println("info string error unable to parse increment");
        return;
      }
    case "movetime";
      movetime_ms, parse_success = parse_int(*str);
      if parse_success == false {
        println("info string error unable to parse movetime");
        return;
      }
    }

    token = parse_token(*str);
    token = eat_spaces(token);
  }

  if time > -1 then {
    movetime_ms = time_management(time, increment);
  }

  bestmove := search(xiangqi, depth, movetime_ms);
  buf: [4] u8;
  println("bestmove %", to_string(bestmove, buf));
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

  return time + incr;

}

println :: (fmt: string, args: ..Any) {
  print(fmt, ..args);
  print(NEWLINE);
}

#scope_export
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
    if str[str.count-1] == #char "\n" then
      str.count -= 1;
    if str[str.count-1] == #char "\r" then
      str.count -= 1;
    return str;
  }

}
