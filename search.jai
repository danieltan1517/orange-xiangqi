main :: () {
  perft_test_suite();

}

perft_test_suite :: () {
  xiangqi: Xiangqi;
  xiangqi_startpos(*xiangqi);
  test(*xiangqi, "startpos", 1, 44);
  test(*xiangqi, "startpos", 2, 1_920);
  test(*xiangqi, "startpos", 3, 79_666);
  test(*xiangqi, "startpos", 4, 3_290_240);
  test(*xiangqi, "startpos", 5, 133_312_995);
  
  test :: (xiangqi: *Xiangqi, title: string, depth: int, expected: int) {
    time := get_time();
    count := perft(xiangqi, depth);
    time = get_time() - time;
 
    if count == expected then {
      print("success for [%] perft % in % seconds: %\n", title, depth, time, count);
    } else {
      print("failed  for [%] perft % in % seconds. got %, expected %.\n", title, depth, time, count, expected);
    }
  }

}


perft :: (xiangqi: *Xiangqi, depth: int) -> int {
  if depth == 0 then
    return 1;

  moves: Moves;
  generate_moves(xiangqi, *moves);

  count := 0;
  if depth == 1 then {
    // bulk counting.
    for mov: moves {
      if !is_legal(xiangqi, mov) then
        continue;
      make_move(xiangqi, mov);
      count += 1;
      unmake_move(xiangqi, mov);
    }
  } else {
    for mov: moves {
      if !is_legal(xiangqi, mov) then
        continue;
      make_move(xiangqi, mov);
      count += perft(xiangqi, depth-1);
      unmake_move(xiangqi, mov);
    }
  }

  return count;
}

#load "movegen.jai";
