main :: () {
  xiangqi: Xiangqi;
  xiangqi_startpos(*xiangqi);

  time := get_time();
  score := negamax(*xiangqi, 5, -MATE, MATE);
  time = get_time() - time;
  time_ms: int = xx (time*1000.0);
  nps: int = xx (cast(float)nodes / time);
  bmove := best_moves[0];
  print("cp % nodes % time % nps %\n", score, nodes, time_ms, nps);
  from := bmove.from;
  to := bmove.to;
  row1, col1 := row_col_of(from);
  row2, col2 := row_col_of(to);
  print("bestmove (%,%) => (%,%)\n", row1, col1, row2, col2);

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

perft_divide :: (xiangqi: *Xiangqi, depth: int) -> int {
  moves: Moves;
  generate_moves(xiangqi, *moves);

  time := get_time();
  count := 0;
  for mov: moves {
    if !is_legal(xiangqi, mov) then
      continue;
    make_move(xiangqi, mov);
    num_moves := perft(xiangqi, depth-1);
    from := mov.from;
    to := mov.to;
    row1, col1 := row_col_of(from);
    row2, col2 := row_col_of(to);
    print("move (%,%) => (%,%): %\n", row1, col1, row2, col2, num_moves);
    count += num_moves;
    unmake_move(xiangqi, mov);
  }
  time = get_time() - time;

  print("Total Moves: %, Time Taken: %\n", count, time);
  return count;
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

negamax :: (xiangqi: *Xiangqi, depth: int, alpha: int, beta: int) -> eval: int {
  if depth <= 0 then {
    return evaluate(xiangqi);
  }

  moves: Moves;
  generate_moves(xiangqi, *moves);

  for mov: moves {
    if !is_legal(xiangqi, mov) then
      continue;
    make_move(xiangqi, mov);
    ply += 1;
    nodes += 1;

    score := -negamax(xiangqi, depth-1, -beta, -alpha);
    unmake_move(xiangqi, mov);
    ply -= 1;

    // alpha beta pruning.
    if score >= beta then {
      return score;
    }
    
    if score > alpha then {
      best_moves[ply] = mov;
      alpha = score;
    }
  }

  return alpha;
}

MATE :: 20_000;

nodes := 0;
ply := 0;

best_moves: [5] Move32;

#load "movegen.jai";
#load "eval.jai";
