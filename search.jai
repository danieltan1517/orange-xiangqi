main :: () {
  xiangqi: Xiangqi;
  xiangqi_startpos(*xiangqi);

  count := perft(*xiangqi, 1);
  print("perft for startpos: %\n", count);
}

perft :: (xiangqi: *Xiangqi, depth: int) -> int {
  if depth == 0 then
    return 1;

  moves: Moves;
  generate_moves(xiangqi, *moves);
  
  count := 0;
  for mov: moves {
    if !is_legal(xiangqi, mov) then
      continue;

    make_move(xiangqi, mov);
    count += perft(xiangqi, depth-1);
    unmake_move(xiangqi, mov);
  }

  print("%\n", count);
  return count;
}

#load "movegen.jai";
