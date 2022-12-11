// main search evaluation function.
search :: (xiangqi: *Xiangqi, depth: int) -> Move32 {

  nodes = 0;
  ply = 0;
  maxply = 0;
  best_move = Move32.{0,0,0,0};
  time_taken := get_time();
  score := negamax(xiangqi, depth, -MATE, MATE);
  time_taken = get_time() - time_taken;
  builder: String_Builder;
  builder.allocator = temp;

  t_ms: int = xx (time_taken*1000.0); // convert secs to ms
  nps: int = xx (cast(float)nodes / time_taken);
  println("info depth % seldepth % nodes % time % score cp % nps %", depth, maxply, nodes, t_ms, score, nps);
  return best_move;

}

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
      println("success for [%] perft % in % seconds: %", title, depth, time, count);
    } else {
      println("failed  for [%] perft % in % seconds. got %, expected %", title, depth, time, count, expected);
    }
  }

}

perft_divide :: (xiangqi: *Xiangqi, depth: int) -> int {

  moves: Moves;
  generate_moves(xiangqi, *moves);

  time := get_time();
  count := 0;
  buf:[4] u8;
  for mov: moves {
    if !is_legal(xiangqi, mov) then
      continue;
    make_move(xiangqi, mov);
    num_moves := perft(xiangqi, depth-1);
    str := to_string(mov, buf);
    println("move %: %", str, num_moves);
    count += num_moves;
    unmake_move(xiangqi, mov);
  }
  time = get_time() - time;

  println("Total Moves: %, Time Taken: %", count, time);
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
    return quiescene(xiangqi, alpha, beta);
  }

  moves: Moves;
  queue: Queue;
  generate_moves(xiangqi, *moves);

  num_moves := 0;

  for :pv mov, score: xiangqi {
    if !is_legal(xiangqi, mov) then
      continue;

    num_moves += 1;
    make_move(xiangqi, mov);
    ply += 1;
    maxply = max(ply, maxply);
    nodes += 1;

    score := -negamax(xiangqi, depth-1, -beta, -alpha);
    unmake_move(xiangqi, mov);
    ply -= 1;

    // alpha beta pruning.
    if score >= beta then {
      return score;
    }
    
    if score > alpha then {
      if ply == 0 then
        best_move = mov;
      alpha = score;
    }
  }

  if num_moves == 0 then
    return -MATE + ply;

  return alpha;

  // principle variation.
  pv :: (xiangqi: *Xiangqi, body: Code, f: For_Flags) #expand {
    stage := Move_Stage.PV;
    while outer_loop := true {
      while queue.count <= 0 {
        if stage == {
        case .PV;
          stage = .CAPTURE;
        case .CAPTURE;
          enqueue_capture_moves(*queue, moves);
          stage = .QUIET;
        case .QUIET;
          enqueue_quiet_moves(*queue, moves);
          stage = .END;
        case .END;
          break outer_loop;
        }
      }

      `it, `it_index := pop(*queue);
      #insert body;
    }
  }

}

quiescene :: (xiangqi: *Xiangqi, alpha: int, beta: int) -> eval: int {

  eval := evaluate(xiangqi);
  if eval >= beta then
    return beta;

  alpha = max(alpha, eval);

  moves: Moves;
  queue: Queue;
  generate_moves(xiangqi, *moves);

  for :pv mov, score: xiangqi {
    if !is_legal(xiangqi, mov) then
      continue;

    make_move(xiangqi, mov);
    ply += 1;
    maxply = max(ply, maxply);
    nodes += 1;

    score := -quiescene(xiangqi, -beta, -alpha);

    unmake_move(xiangqi, mov);
    ply -= 1;

    if score >= beta then
      return beta;

    if score > alpha then
      alpha = score;
  }

  return alpha;

  // principle variation.
  pv :: (xiangqi: *Xiangqi, body: Code, f: For_Flags) #expand {
    stage := Move_Stage.PV;
    while outer_loop := true {
      while queue.count <= 0 {
        if stage == {
        case .PV;
          stage = .CAPTURE;
        case .CAPTURE;
          enqueue_capture_moves(*queue, moves);
          stage = .END;
        case .END;
          break outer_loop;
        }
      }

      `it, `it_index := pop(*queue);
      #insert body;
    }
  }

}

#scope_file

Move_Stage :: enum s8 {
  PV;
  CAPTURE;
  QUIET;
  END;
}

enqueue_capture_moves :: (queue: *Queue, moves: Moves) {

  for mov: moves {
    if is_capture(mov) then {
      victim   := mov.capture >> 2;
      attacker := mov.piece   >> 2;
      priority := mvv_lva(victim, attacker);
      append(queue, priority, mov);
    }
  }

  mvv_lva :: (victim: s32, attacker: s32) -> s32 #expand {
    victim_score := PIECE_VALUE[victim];
    attacker_score := PIECE_VALUE[attacker] / 10;
    return victim_score - attacker_score; 

    // general, advisor, elephant, horse, rook, cannon, soldier
    PIECE_VALUE :: s16.[800, 120, 120, 270, 600, 285, 30]; 
  }

}

enqueue_quiet_moves :: (queue: *Queue, moves: Moves) {

  // TODO: score quiet moves.
  for mov: moves {
    if is_quiet(mov) then {
      priority: s32 = 0;
      append(queue, priority, mov);
    }
  }

}

heapify :: (queue: *Queue, index: int) {

  while true {
    largest := index;
    left := 2 * index + 1;
    right := 2 * index + 2;
 
    N := queue.count;
 
    if left < N && queue.array[left].priority > queue.array[largest].priority then
      largest = left;
 
    if right < N && queue.array[right].priority > queue.array[largest].priority then
      largest = right;

    if largest == index then
      break;
 
    temp := queue.array[index];
    queue.array[index] = queue.array[largest];
    queue.array[largest] = temp;
    index = largest;
  }

}

pop :: (queue: *Queue) -> move: Move32, priority: s32 {

  move := queue.array[0].move;
  priority := queue.array[0].priority;
  queue.count -= 1;
  queue.array[0] = queue.array[queue.count];
  heapify(queue, 0);
  return move, priority;

}

construct_heap :: (queue: *Queue) {

  count := queue.array.count/2 - 1;
  for < index: count..0 {
    heapify(queue, index);
  }

}

Queue :: struct {

  count: int;
  array: [127] Queue_Pair;

}

append :: (queue: *Queue, priority: s32, move: Move32) {

  index := queue.count;
  queue.array[index].priority = priority;
  queue.array[index].move = move;
  queue.count += 1;

}

Queue_Pair :: struct {
  priority: s32;
  move: Move32;
  #place priority;
  #as data: u64;
}

MATE :: 20_000;

nodes := 0;
ply := 0;
maxply := 0;

best_move: Move32 = Move32.{0,0,0,0};

#load "movegen.jai";
#load "eval.jai";
