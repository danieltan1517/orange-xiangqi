perft_test_suite :: () {
  xiangqi: Xiangqi;
  xiangqi_startpos(*xiangqi);
  test(*xiangqi, "startpos", 1, 44);
  test(*xiangqi, "startpos", 2, 1_920);
  test(*xiangqi, "startpos", 3, 79_666);
  test(*xiangqi, "startpos", 4, 3_290_240);
  test(*xiangqi, "startpos", 5, 133_312_995);

  fen := "r1ea1a3/4kh3/2h1e4/pHp1p1p1p/4c4/6P2/P1P2R2P/1CcC5/9/2EAKAE2 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  test(*xiangqi, fen, 1, 38);
  test(*xiangqi, fen, 2, 1_128);
  test(*xiangqi, fen, 3, 43_929);
  test(*xiangqi, fen, 4, 1_339_047);

  fen = "1ceak4/9/h2a5/2p1p3p/5cp2/2h2H3/6PCP/3AE4/2C6/3A1K1H1 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  test(*xiangqi, fen, 1, 7);
  test(*xiangqi, fen, 2, 281);
  test(*xiangqi, fen, 3, 8_620);
  test(*xiangqi, fen, 4, 326_201);
  test(*xiangqi, fen, 5, 10_369_923);
  
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

best_moves: [64] Move32;

get_move32 :: () -> Move32 {
  return best_moves[0];
}

#load "movegen.jai";
#load "eval.jai";
