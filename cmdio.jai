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
    }

  case "go";
    str = eat_spaces(str);
    token = parse_token(*str);
    if token == {
    case "perft";
      depth, TF := parse_int(*str);
      if TF == false then {
        println("info string invalid perft");
        return false;
      }

      perft_divide(xiangqi, depth);

    case "depth";
      depth, TF := parse_int(*str);
      if TF == false then {
        println("info string invalid depth number");
        return false;
      }

      move := search(xiangqi, depth);
      builder: String_Builder;
      builder.allocator = temp;
      append(*builder, "bestmove ");
      append(*builder, move);
      println(builder_to_string(*builder));
    }
  }
  return false;
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
