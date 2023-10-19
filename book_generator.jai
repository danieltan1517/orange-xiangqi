// generates an opening book based
// off of the google drive set of 
// grandmaster games.

main :: () {
  init_xiangqi_tables();
  random_seed(0xcafe_babe_10_31_1517);
  FILE_NAME :: "xiangqi_games.txt";
  text, success := read_entire_file(FILE_NAME);
  if !success {
    print("Error. % cannot be opened.", FILE_NAME);
    return;
  }

  table: Table(Xiangqi, string,
               (xiangqi)=>xiangqi.hash,
               (a,b) => a.hash == b.hash);

  xiangqi: Xiangqi;
  xiangqi_startpos(*xiangqi);

  for i: 0..1_000_000_000 {
    print("Game Number %\n", i);
    found, line, rest := split_from_left(text, #char "\n");
    if found == false {
      break;
    }
    defer {
      text = rest;
    }
    reset_temporary_storage();
    replace_chars(line, "',", #char " ");
    xiangqi_startpos(*xiangqi);

    mov1 := (random_get() % 30) + 5;
    mov2 := (random_get() % 30) + 5;
    mov3 := (random_get() % 30) + 5;

    for index: 0..cast(u64)1_000_000 {
      line = eat_spaces(line);
      token, found := parse_token(*line);
      if found == false {
        break;
      }
      
      move := to_move32(*xiangqi, token);
      make_move(*xiangqi, move);

      if mov1 != index && mov2 != index && mov3 != index then {
        continue;
      }

      fenstring := to_fenstring(*xiangqi);
     
      if table_find_pointer(*table, xiangqi) == null {
        table_add(*table, xiangqi, copy_string(fenstring));
      }
    }
  }

  builder: String_Builder;
  append(*builder, "xiangqi_openings :: string.[\n");
  for value, key: table {
    print_to_builder(*builder, "  \"%\",\n", value);
  }
  append(*builder, "];\n");
  data := builder_to_string(*builder);
  write_entire_file("opening_book.jai", data);
}

#import "Basic";
#import "File";
#import "String";
#import "Random";
#load "board.jai";
#import "Math";
#import "Hash_Table";
