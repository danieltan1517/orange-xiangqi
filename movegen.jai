xiangqi_startpos :: (xiangqi: *Xiangqi) {

  memset(xiangqi, 0, size_of(Xiangqi));
  // red
  add_piece(xiangqi, G, RED, 4, 0);
  add_piece(xiangqi, A, RED, 3, 0);
  add_piece(xiangqi, A, RED, 5, 0);
  add_piece(xiangqi, E, RED, 2, 0);
  add_piece(xiangqi, E, RED, 6, 0);
  add_piece(xiangqi, H, RED, 1, 0);
  add_piece(xiangqi, H, RED, 7, 0);
  add_piece(xiangqi, R, RED, 0, 0);
  add_piece(xiangqi, R, RED, 8, 0);

  // cannon
  add_piece(xiangqi, C, RED, 1, 2);
  add_piece(xiangqi, C, RED, 7, 2);

  // pawn
  add_piece(xiangqi, S, RED, 0, 3);
  add_piece(xiangqi, S, RED, 2, 3);
  add_piece(xiangqi, S, RED, 4, 3);
  add_piece(xiangqi, S, RED, 6, 3);
  add_piece(xiangqi, S, RED, 8, 3);

  // black
  add_piece(xiangqi, G, BLACK, 4, 9);
  add_piece(xiangqi, A, BLACK, 3, 9);
  add_piece(xiangqi, A, BLACK, 5, 9);
  add_piece(xiangqi, E, BLACK, 2, 9);
  add_piece(xiangqi, E, BLACK, 6, 9);
  add_piece(xiangqi, H, BLACK, 1, 9);
  add_piece(xiangqi, H, BLACK, 7, 9);
  add_piece(xiangqi, R, BLACK, 0, 9);
  add_piece(xiangqi, R, BLACK, 8, 9);

  // cannon
  add_piece(xiangqi, C, BLACK, 1, 7);
  add_piece(xiangqi, C, BLACK, 7, 7);

  // pawn
  add_piece(xiangqi, S, BLACK, 0, 6);
  add_piece(xiangqi, S, BLACK, 2, 6);
  add_piece(xiangqi, S, BLACK, 4, 6);
  add_piece(xiangqi, S, BLACK, 6, 6);
  add_piece(xiangqi, S, BLACK, 8, 6);

}

add_piece :: (xiangqi: *Xiangqi, piece: u8, side: u8, row: u8, col: u8) {
  piece_code := encode_piece(piece, side);
  xiangqi.board_9x10[row][col] = piece_code;
  xiangqi.bit_row[col] |= cast(u16)(1 << row);
  xiangqi.bit_col[row] |= cast(u16)(1 << col);
  index := index_of(row, col);
  append(*xiangqi.pieces[side].piece[piece], index);
}

xiangqi_fen :: (xiangqi: *Xiangqi, fen: string) -> bool {
  // TODO: just get fen string working...no error checking until later...
  // https://www.wxf-xiangqi.org/images/computer-xiangqi/fen-for-xiangqi-chinese-chess.pdf
  // K = king
  // A = advisor
  // E = elephant
  // R = rook
  // C = cannon
  // H = horse
  // P = pawn
  // "w" if white to move/"red" to move
  // "b" if black to move

  memset(xiangqi, 0, size_of(Xiangqi));
  board_fen, success1 := parse_token(*fen);
  if success1 == false then
    return false;
  for token, index: split(board_fen, "/") {
    array:[] u8; 
    array.data = token.data;
    array.count = token.count;
    col := cast(u8)(9 - index);
    row: u8 = 0;
    for let: array {
      side: u8 = 0;
      piece: u8 = 0;

      if let == {
      case #char "K";
        side = RED;
        piece = G;
      case #char "A";
        side = RED;
        piece = A;
      case #char "B";
        side = RED;
        piece = E;
      case #char "E";
        side = RED;
        piece = E;
      case #char "R";
        side = RED;
        piece = R;
      case #char "C";
        side = RED;
        piece = C;
      case #char "H";
        side = RED;
        piece = H;
      case #char "N";
        side = RED;
        piece = H;
      case #char "P";
        side = RED;
        piece = S;

      case #char "k";
        side = BLACK;
        piece = G;
      case #char "a";
        side = BLACK;
        piece = A;
      case #char "b";
        side = BLACK;
        piece = E;
      case #char "e";
        side = BLACK;
        piece = E;
      case #char "r";
        side = BLACK;
        piece = R;
      case #char "c";
        side = BLACK;
        piece = C;
      case #char "h";
        side = BLACK;
        piece = H;
      case #char "n";
        side = BLACK;
        piece = H;
      case #char "p";
        side = BLACK;
        piece = S;
      case;
        if let < #char "1" || let > #char "9" then {
          print("invalid letter %\n", let);
          return false;
        }
        let -= #char "1";
        row += let;
        piece = 0xFF;
      }
      if piece != 0xFF {
        add_piece(xiangqi, piece, side, row, col);
      }
      row += 1;

    }
  }

  // get the turn.
  turn_fen, success2 := parse_token(*fen);
  if success2 == false then
    return false;
  if equal(turn_fen, "w") {
    xiangqi.turn = 0;
  } else if equal(turn_fen, "b") {
    xiangqi.turn = 1;
  } else {
    return false;
  }

  // we do not care about the rest of string, so return true.
  return true;
}

encode_piece :: (piece: u8, side: u8) -> u8 #expand {
  return (piece << 2) | (side << 1) | 1;
}

print_board :: (xiangqi: Xiangqi) {
  
  for < j: 9..0 {
    print("%  ", j);
    for i: 0..8 {
      piece := xiangqi.board_9x10[i][j];
      if (piece & 1) == 0 {
        print("- ");
        continue;
      }
      index := piece >> 2;
      if piece & 2 {
        if index == {
        case G;
          print("g ");
        case A;
          print("a ");
        case E;
          print("e ");
        case H;
          print("h ");
        case R;
          print("r ");
        case C;
          print("c ");
        case S;
          print("s ");
        }
      } else {
        if index == {
        case G;
          print("G ");
        case A;
          print("A ");
        case E;
          print("E ");
        case H;
          print("H ");
        case R;
          print("R ");
        case C;
          print("C ");
        case S;
          print("S ");
        }
      }
    }
    print("\n");
  }
  print("   a b c d e f g h i\n");
  if xiangqi.turn == 0 then {
    print("Turn: RED\n\n");
  } else {
    print("Turn: BLACK\n\n");
  }
}

Xiangqi :: struct {
  board_9x10: [9][10] u8;
  bit_row: [10] u16 #align 16;
  bit_col: [9]  u16 #align 16;

  pieces: [2] Pieces;
  #place pieces;
  red: Pieces;
  black: Pieces;
  turn: u8;
}

Move32 :: struct {
  from: u8;
  to: u8;
  capture: u8;
  piece: u8;
  #place from;
  #as move: u32;
}

is_quiet :: (mov: Move32) -> bool #expand {
  return mov.capture == 0;
}

is_capture :: (mov: Move32) -> bool #expand {
  return mov.capture != 0;
}

append :: (builder: *String_Builder, move: Move32) {
  row_from, col_from := row_col_of(move.from);
  row_to, col_to := row_col_of(move.to);
  append(builder, (row_from + #char "a"));
  append(builder, (col_from + #char "0"));
  append(builder, (row_to + #char "a"));
  append(builder, (col_to + #char "0"));
}

to_string :: (move: Move32, buf: [] u8) -> string {
  row_from, col_from := row_col_of(move.from);
  row_to, col_to := row_col_of(move.to);
  buf[0] = (row_from + #char "a");
  buf[1] = (col_from + #char "0");
  buf[2] = (row_to + #char "a");
  buf[3] = (col_to + #char "0");
  return to_string(buf.data, 4);
}

to_move32 :: (xiangqi: *Xiangqi, str: string) -> Move32 {
  row_from := str[0] - #char "a";
  col_from := str[1] - #char "0";
  row_to   := str[2] - #char "a";
  col_to   := str[3] - #char "0";
  from := index_of(row_from, col_from);
  to   := index_of(row_to, col_to);
  move: Move32;
  move.from = from;
  move.to   = to;
  move.piece = xiangqi.board_9x10[row_from][col_from];
  move.capture = xiangqi.board_9x10[row_to][col_to];
  return move;
}


Pieces :: struct {
  // padding out the arrays to the alignment.
  general:   Array(7, u8); // only be 1
  advisors:  Array(7, u8); // at most 2
  elephants: Array(7, u8); // at most 2
  knights:   Array(7, u8); // at most 2
  rooks:     Array(7, u8); // at most 2
  cannons:   Array(7, u8); // at most 2
  soldiers:  Array(7, u8); // at most 5

  #place general;
  piece: [7] Array(7, u8);
}

Moves :: #type Array(128, Move32);

operator == :: (a: Move32, b: Move32) -> bool #expand {
  return a.move == b.move;
}

operator == :: (a: Move32, b: u32) -> bool #expand {
  return a.move == b;
}

make_move :: (xiangqi: *Xiangqi, move: Move32) {
  piece := move.piece >> 2;
  from := move.from;

  // from:
  row, col := row_col_of(from);
  xiangqi.board_9x10[row][col] = NONE;
  xiangqi.bit_row[col] &= ~(cast(u16)(1 << row));
  xiangqi.bit_col[row] &= ~(cast(u16)(1 << col));

  // to:
  to := move.to;
  row, col = row_col_of(to);
  piece_code := encode_piece(piece, xiangqi.turn);
  xiangqi.board_9x10[row][col] = piece_code;
  xiangqi.bit_row[col] |= (cast(u16)(1 << row));
  xiangqi.bit_col[row] |= (cast(u16)(1 << col));

  array := *xiangqi.pieces[xiangqi.turn].piece[piece];
  update_piece_array(array, from, to);


  xiangqi.turn ^= 1;

  // we already flipped the turn.
  capture := move.capture;
  if capture != 0 then {
    capture = capture >> 2;
    array := *xiangqi.pieces[xiangqi.turn].piece[capture];
    remove_piece_from_array(array, to);
  }
}

unmake_move :: (xiangqi: *Xiangqi, move: Move32) {
  to    := move.to;
  capture := move.capture;
  // to:
  row, col := row_col_of(to);
  xiangqi.board_9x10[row][col] = capture;
  if capture != 0 then {
    cap := capture >> 2;
    array := *xiangqi.pieces[xiangqi.turn].piece[cap];
    append(array, to);
  } else {
    xiangqi.bit_row[col] &= ~(cast(u16)(1 << row));
    xiangqi.bit_col[row] &= ~(cast(u16)(1 << col));
  }

  xiangqi.turn ^= 1;
  piece := move.piece;
  from  := move.from;

  // from:
  row, col = row_col_of(from);
  xiangqi.board_9x10[row][col] = piece;
  xiangqi.bit_row[col] |= (cast(u16)(1 << row));
  xiangqi.bit_col[row] |= (cast(u16)(1 << col));

  piece >>= 2;
  array := *xiangqi.pieces[xiangqi.turn].piece[piece];
  update_piece_array(array, to, from);

}

generate_moves_for :: (turn: u8, xiangqi: *Xiangqi, moves: *Moves) {
  piece_array := *xiangqi.pieces[turn];

  // soldier/elephant related parameters.
  advance: s8 = 1;
  col_mask: u64 = 0b_01111_11000;
  horizontal_mask: u64 = 0b_11111_00000;
  ele_col_mask: s64 = 0b_00000_11111; // elephant column mask.
  if turn == 1 {
    advance = -1;
    col_mask = 0b_00011_11110;
    horizontal_mask = 0b_00000_11111;
    ele_col_mask = 0b_11111_00000;
  }

  general_moves(piece_array.general[0], xiangqi.board_9x10, moves);

  for advisor: piece_array.advisors {
    advisor_moves(advisor, xiangqi.board_9x10, moves);
  }

  for elephant: piece_array.elephants {
    elephant_moves(elephant, ele_col_mask, xiangqi.board_9x10, moves);
  }

  for knight: piece_array.knights {
    knight_moves(knight, xiangqi.board_9x10, moves);
  }

  for cannon: piece_array.cannons {
    cannon_moves(cannon, xiangqi, moves);
  }

  for rook: piece_array.rooks {
    rook_moves(rook, xiangqi, moves);
  }

  for soldier: piece_array.soldiers {
    soldier_moves(soldier, advance, col_mask, horizontal_mask, xiangqi.board_9x10, moves);
  }
}

// generate pseudo legal moves for xiangqi.
generate_moves :: (xiangqi: *Xiangqi, moves: *Moves) {
  turn := xiangqi.turn;
  generate_moves_for(turn, xiangqi, moves);
}

generate_moves_for_piece :: (xiangqi: *Xiangqi, moves: *Moves, row: u8, col: u8) {
  piece := xiangqi.board_9x10[row][col];
  turn := xiangqi.turn;

  if ((piece & 0x2) >> 1) != turn {
    return;
  }

  // no piece at the square.
  if piece == 0 then
    return;
  piece >>= 2;
  from := index_of(row, col);
  if piece == {
  case G;
    general_moves(from, xiangqi.board_9x10, moves);
  case A;
    advisor_moves(from, xiangqi.board_9x10, moves);
  case E;
    col_mask: s64 = 0b_00000_11111;
    ifx turn == 1 then col_mask = 0b_11111_00000;
    elephant_moves(from, col_mask, xiangqi.board_9x10, moves);
  case H;
    knight_moves(from, xiangqi.board_9x10, moves);
  case R;
    rook_moves(from, xiangqi, moves);
  case C;
    cannon_moves(from, xiangqi, moves);
  case S;
    advance: s8 = 1;
    col_mask: u64 = 0b_01111_11000;
    horizontal_mask: u64 = 0b_11111_00000;
    if turn == 1 {
      advance = -1;
      col_mask = 0b_00011_11110;
      horizontal_mask = 0b_00000_11111;
    }
    soldier_moves(from, advance, col_mask, horizontal_mask, xiangqi.board_9x10, moves);
  }
}

G :: 0; // general
A :: 1; // advisor
E :: 2; // elephant
H :: 3; // horse / knight
R :: 4; // rook / chariot
C :: 5; // cannon
S :: 6; // soldier

RED :: 0;   // red goes first...
BLACK :: 1; // black goes second...

NONE :: 0;
OCCUPIED :: 1;

Array :: struct(capacity: int, T: Type) {
  count: s8;
  array: [capacity] T;
}

update_piece_array :: (array: *Array($N, u8), from: u8, to: u8) {
  for item, index: array {
    if item == from {
      array.array[index] = to;
      break;
    }
  }
}

remove_piece_from_array :: (array: *Array($N, u8), value: u8) {
  for item, index: array {
    if item == value {
      end := array.count-1;
      array.array[index] = array.array[end];
      array.array[end] = 0;
      array.count -= 1; // hack
      break;
    }
  }
}

reset :: (array: *Array($N, $T)) {
  array.count = 0;
  data := array.array.data;
  memset(data, 0, size_of(T) * N);
}

append :: (a: *Array($N, $T), item: T) #expand {
  // print("% %\n", <<a, item);
  assert(a.count < a.capacity);
  a.array[a.count] = item;
  a.count += 1;
}

operator [] :: (a: Array($N, $T), index: int) -> T #expand {
  return a.array[index];
}

operator []= :: (a: *Array($N, $T), index: int, item: T) #expand {
  a.array[index] = item;
}

for_expansion :: (a: *Array($N, $T), body: Code, flags: For_Flags) #expand {
  `it_index := 0;
  count := a.count;
  while it_index < count {
    `it := a.array[it_index];
    defer it_index += 1;
    #insert body;
  }
}

is_legal :: (xiangqi: *Xiangqi, move: Move32) -> bool {
  turn := xiangqi.turn;
  opp  := turn ^ 1;
  adv := ifx turn == 0 1 else -1; 
  gen := xiangqi.pieces[turn].general[0];
  soldier_code := encode_piece(S, opp);
  if move.from == gen {
    gen = move.to;
  }

  row, col := row_col_of(gen);
 
  // soldier checks the king. 
  if xiangqi.board_9x10[row][(cast(s8)col)+adv] == soldier_code && index_of(row,cast(u8)(col+adv)) != move.to then {
    return false;
  }
  if xiangqi.board_9x10[row+1][col] == soldier_code && index_of(row+1,col) != move.to then {
    return false;
  }
  if xiangqi.board_9x10[row-1][col] == soldier_code && index_of(row-1,col) != move.to then {
    return false;
  }

  // knight checks the king...
  knights := *xiangqi.pieces[opp].knights;
  for kni: knights {
    if move.to == kni then {
      continue;
    }

    row_knight, col_knight := row_col_of(kni);
    row_diff := cast(s8)row - cast(s8)row_knight;
    col_diff := cast(s8)col - cast(s8)col_knight;
    row_diff_abs := cast(s8) abs(row_diff);
    col_diff_abs := cast(s8) abs(col_diff);
    index_diff := index_of(cast(u8)row_diff_abs, cast(u8) col_diff_abs);
    if index_diff != 0x21 && index_diff != 0x12 then {
      continue;
    }

    // make sure the knight is blocked.
    row_diff /= 2;
    col_diff /= 2;
    row_result := cast(u8)(cast(s8)row_knight + row_diff);
    col_result := cast(u8)(cast(s8)col_knight + col_diff);
    index_result := index_of(row_result, col_result);
    if index_result == move.to then {
      continue;
    }

    if index_result == move.from then {
      return false;
    }

    occ := xiangqi.board_9x10[row_result][col_result];
    if occ == 0 then {
      return false;
    }
  }

  // rooks, cannons, flying general rule...
  bit_rows := cast, no_check(u64) xiangqi.bit_row[col]; //row_bits(xiangqi.board_10x9[col]);
  if col == col_of(move.from) {
    bit_rows &= ~(cast, no_check (u16) (1 << row_of(move.from)));
  }

  if col == col_of(move.to) {
    bit_rows |= cast, no_check(u16) (1 << row_of(move.to));
  }

  gen_code := encode_piece(G, opp);
  rook_code := encode_piece(R, opp);
  cannon_code := encode_piece(C, opp);

  forward: u64 = cast(u64)0xFFFF << row;
  backward := ~forward & 0x1FF;
  forward <<= 1;
  forward &= 0x1FF;
  forward &= bit_rows;
  backward &= bit_rows;
  index1: s8 = -1;
  index2: s8 = -1;
  #asm {
    bsf index1, forward;
    bsr index2, backward;
    blsr forward, forward;
    btr backward, index2;
  }

  if index1 != -1 && move.to != index_of(cast(u8)index1,col) && xiangqi.board_9x10[index1][col] == rook_code {
    return false;
  }
  if index2 != -1 && move.to != index_of(cast(u8)index2,col) && xiangqi.board_9x10[index2][col] == rook_code {
    return false;
  }

  index1 = -1;
  index2 = -1;
  #asm {
    bsf index1, forward;
    bsr index2, backward;
    blsr forward, forward;
    btr backward, index2;
  }

  if index1 != -1 && move.to != index_of(cast(u8)index1,col) && xiangqi.board_9x10[index1][col] == cannon_code {
    return false;
  }
  if index2 != -1 && move.to != index_of(cast(u8)index2,col) && xiangqi.board_9x10[index2][col] == cannon_code {
    return false;
  }

  bit_cols := cast, no_check(u64)xiangqi.bit_col[row];
  if row == row_of(move.from) {
    bit_cols &= cast, no_check(u64) ~(1 << col_of(move.from));
  }

  if row == row_of(move.to) {
    bit_cols |= cast, no_check(u64) (1 << col_of(move.to));
  }

  forward = cast, no_check(u64)0xFFFF << col;
  backward = ~forward & 0x3FF;
  forward <<= 1;
  forward &= 0x3FF;
  forward &= bit_cols;
  backward &= bit_cols;

  index1 = -1;
  index2 = -1;
  #asm {
    bsf index1, forward;
    bsr index2, backward;
    blsr forward, forward;
    btr backward, index2;
  }

  if index1 != -1 && move.to != index_of(row,cast, no_check(u8)index1) {
    code := xiangqi.board_9x10[row][index1];
    if (code == rook_code || code == gen_code) {
      return false;
    }
  }
  if index2 != -1 && move.to != index_of(row,cast, no_check (u8)index2) {
    code := xiangqi.board_9x10[row][index2];
    if (code == rook_code || code == gen_code) {
      return false;
    }
  }

  index1 = -1;
  index2 = -1;
  #asm {
    bsf index1, forward;
    bsr index2, backward;
    blsr forward, forward;
    btr backward, index2;
  }

  if index1 != -1 && move.to != index_of(row,cast(u8)index1) && xiangqi.board_9x10[row][index1] == cannon_code {
    return false;
  }
  if index2 != -1 && move.to != index_of(row,cast(u8)index2) && xiangqi.board_9x10[row][index2] == cannon_code {
    return false;
  }

  return true;
}

filter_legal_moves :: (xiangqi: *Xiangqi, moves: *Moves) {
  i := 0;
  while i < moves.count {
    move := moves.array[i];
    if !is_legal(xiangqi, move) {
      moves.count -= 1;
      moves.array[i] = moves.array[moves.count];
      continue;
    }
    i += 1;
  }
}

general_moves :: (from: u8, board: [9][10] u8, moves: *Moves) {
  row_mask :: 0b000_111_000;
  col_mask :: 0b111_00_00_111;

  row, col := row_col_of(from);
  piece := board[row][col];

  // horizontal row movements.
  bits := 1 << row;
  bits = (bits << 1) | (bits >> 1);
  bits &= row_mask;
  while bits {
    row_to: u8;
    #asm BMI1 {
      bsf row_to, bits; 
      blsr bits, bits;
    }
    to := index_of(row_to, col);
    capture := board[row_to][col];
    if (capture & 0x3) == (piece & 0x3) then
      continue;
    move := Move32.{from, to, capture, piece};
    append(moves, move);
  } 

  // vertical row movements.
  bits = 1 << col;
  bits = (bits << 1) | (bits >> 1);
  bits &= col_mask;
  while bits {
    col_to: u8;
    #asm BMI1 {
      bsf col_to, bits; 
      blsr bits, bits;
    }
    capture := board[row][col_to];
    to := index_of(row, col_to);
    if (capture & 0x3) == (piece & 0x3) then
      continue;
    move := Move32.{from, to, capture, piece};
    append(moves, move);
  } 

}

advisor_moves :: (from: u8, board: [9][10] u8, moves: *Moves) {
  row_mask :: 0b000_111_000;
  col_mask :: 0b111_00_00_111;

  row, col := row_col_of(from);
  piece := board[row][col];

  bits1 := 1 << row;
  bits1 = (bits1 << 1) | (bits1 >> 1);
  bits1 &= row_mask;
  bits2 := 1 << col;
  bits2 = (bits2 << 1) | (bits2 >> 1);
  bits2 &= col_mask;
  while bits1 {
    row_to: s8;
    #asm BMI1 {
      bsf row_to, bits1; 
      blsr bits1, bits1;
    }
    bits_col := bits2;
    while bits_col {
      col_to: s8;
      #asm BMI1 {
        bsf col_to, bits_col; 
        blsr bits_col, bits_col;
      }
      capture := board[row_to][col_to];
      to := cast(u8) index_of(row_to, col_to);
      if (capture & 0x3) == (piece & 0x3) then
        continue;
      move := Move32.{from, to, capture, piece};
      append(moves, move);
    }
  }

}

elephant_moves :: (from: u8, col_mask: s64, board: [9][10] u8, moves: *Moves) {
  row_mask :: 0b1_1111_1111;
  // col_mask :: 0b_00000_11111;
  // col_mask :: 0b_11111_00000;

  row, col := row_col_of(from);
  piece := board[row][col];
  bit_horizontal := 1 << row;
  bit_vertical   := 1 << col;

  bit_h1 := (bit_horizontal << 1) | (bit_horizontal >> 1);
  bit_h1 &= row_mask;
  bit_h2 := (bit_horizontal << 2) | (bit_horizontal >> 2);
  bit_h2 &= row_mask;

  bit_v1 := (bit_vertical << 1) | (bit_vertical >> 1);
  bit_v1 &= col_mask;
  bit_v2 := (bit_vertical << 2) | (bit_vertical >> 2);
  bit_v2 &= col_mask;

  while bit_h1 {
    row_to1: s8;
    row_to2: s8;
    #asm BMI1 {
      bsf row_to1, bit_h1; 
      bsf row_to2, bit_h2; 
      blsr bit_h1, bit_h1;
      blsr bit_h2, bit_h2;
    }

    cols1 := bit_v1;
    cols2 := bit_v2;

    while cols1 {
      col_to1: s8;
      col_to2: s8;
      #asm BMI1 {
        bsf col_to1, cols1;
        bsf col_to2, cols2;
        blsr cols1, cols1;
        blsr cols2, cols2;
      }
      if board[row_to1][col_to1] == 0 {
        to := index_of(cast(u8)row_to2, cast(u8)col_to2);
        capture := board[row_to2][col_to2];
        if (capture & 0x3) == (piece & 0x3) then
          continue;
        move := Move32.{from, to, capture, piece};
        append(moves, move);
      }
    }
  }
}

soldier_moves :: (from: u8, advance: s8, col_mask: u64, horizontal_mask: u64, board: [9][10] u8, moves: *Moves) {
  // TODO: Make sure BSF works correctly...
  row_mask :: 0b1_1111_1111;
  
  //col_mask :: 0b_01111_11000;
  //horizontal_mask :: 0b_11111_00000;

  row, col := row_col_of(from);
  col_bit: u64 = cast(u64) (1 << col);
  piece := board[row][col];

  if col_bit & col_mask {
    from := index_of(row, col);
    col_to := cast(u8)(cast(s8)col + advance);
    to := index_of(row, col_to);
    capture := board[row][col_to];
    if (capture & 0x3) != (piece & 0x3) then {
      move := Move32.{from, to, capture, piece};
      append(moves, move);
    }
  }

  // col >= 1 && col <= 6
  if col_bit & horizontal_mask then {
    bit_horizontal := 1 << row;
    bit_h1 := (bit_horizontal << 1) | (bit_horizontal >> 1);
    bit_h1 &= row_mask;
    while bit_h1 {
      row_to: s8;
      #asm BMI1 {
        bsf row_to, bit_h1;
        blsr bit_h1, bit_h1;
      }
      to := index_of(cast(u8)row_to, col);
      capture := board[row_to][col];
      if (capture & 0x3) == (piece & 0x3) then
        continue;
      move := Move32.{from, to, capture, piece};
      append(moves, move);
    }
  }
}

knight_moves :: (from: u8, board: [9][10] u8, moves: *Moves) {
  row, col := row_col_of(from);
  piece := board[row][col];
  row_bit := 1 << row;
  col_bit := 1 << col;

  // horizontal 2, diagonal 1
  bit_horizontal_1 := ((row_bit << 1) | (row_bit >> 1)) & 0b_011_111_110;
  bit_horizontal_2 := ((row_bit << 2) | (row_bit >> 2)) & 0b_111_111_111;
  bit_vertical_1 := ((col_bit << 1) | (col_bit >> 1)) &   0b_11111_11111;
  while bit_horizontal_2 {
    h1: s8;
    h2: s8;
    #asm BMI1 {
      bsf h1, bit_horizontal_1;
      bsf h2, bit_horizontal_2;
      blsr bit_horizontal_1, bit_horizontal_1;
      blsr bit_horizontal_2, bit_horizontal_2;
    }

    // check that the path is not blocked.
    if board[h1][col] == 0 {
      bits := bit_vertical_1;
      while bits {
        vert: s8;
        #asm BMI1 {
          bsf  vert, bits;
          blsr bits, bits;
        }
        to := index_of(cast(u8)h2, cast(u8)vert);
        capture := board[h2][vert];
        if (capture & 0x3) == (piece & 0x3) then
          continue;
        move := Move32.{from, to, capture, piece};
        append(moves, move);
      }
    }
  }

  horizontal_1 := ((row_bit << 1) | (row_bit >> 1)) & 0b_111_111_111;
  vertical_1 := ((col_bit << 1) | (col_bit >> 1)) &   0b_01111_11110;
  vertical_2 := ((col_bit << 2) | (col_bit >> 2)) &   0b_11111_11111;
  while vertical_2 {
    v1: s8;
    v2: s8;
    #asm BMI1 {
      bsf v1, vertical_1;
      bsf v2, vertical_2;
      blsr vertical_1, vertical_1;
      blsr vertical_2, vertical_2;
    }

    // check that the path is not blocked.
    if board[row][v1] == 0 {
      bits := horizontal_1;
      while bits {
        horizontal: s8;
        #asm BMI1 {
          bsf horizontal, bits;
          blsr bits, bits;
        }
        to := index_of(cast(u8)horizontal, cast(u8)v2);
        capture := board[horizontal][v2];
        if (capture & 0x3) == (piece & 0x3) then
          continue;
        move := Move32.{from, to, capture, piece};
        append(moves, move);
      }
    }
  }
}

rook_moves :: (from: u8, xiangqi: *Xiangqi, moves: *Moves) {
  rook_captures(from, xiangqi, moves);
  quiet_sliding_moves(from, xiangqi, moves);
}

rook_captures :: (from: u8, xiangqi: *Xiangqi, moves: *Moves) {
  row, col := row_col_of(from);
  piece := xiangqi.board_9x10[row][col];
  forward: u64 = cast(u64)0xFFFF << row;
  backward := ~forward & 0x1FF;
  forward <<= 1;
  forward &= 0x1FF;
  bits := xiangqi.bit_row[col];
  forward &= bits;
  backward &= bits;
  row_back: s8 = -1;
  row_forward: s8 = -1;

  #asm {
    bsf row_forward, forward;
    bsr row_back, backward;
  }

  if row_back != -1 {
    to := index_of(cast(u8)row_back, col);
    capture := xiangqi.board_9x10[row_back][col];
    if (capture & 0x3) != (piece & 0x3) then {
      move := Move32.{from, to, capture, piece};
      append(moves, move);
    }
  }

  if row_forward != -1 {
    to := index_of(cast(u8)row_forward, col);
    capture := xiangqi.board_9x10[row_forward][col];
    if (capture & 0x3) != (piece & 0x3) then {
      move := Move32.{from, to, capture, piece};
      append(moves, move);
    }
  }

  forward = cast(u64)0xFFFF << col;
  backward = ~forward & 0x3FF;
  forward <<= 1;
  forward &= 0x3FF;
  bits = xiangqi.bit_col[row];
  forward &= bits;
  backward &= bits;
  col_back: s8 = -1;
  col_forward: s8 = -1;
  #asm {
    bsf col_forward, forward;
    bsr col_back, backward;
  }

  if col_back != -1 {
    to := index_of(row, cast(u8)col_back);
    capture := xiangqi.board_9x10[row][col_back];
    if (capture & 0x3) != (piece & 0x3) then {
      move := Move32.{from, to, capture, piece};
      append(moves, move);
    }
  }

  if col_forward != -1 {
    to := index_of(row, cast(u8)col_forward);
    capture := xiangqi.board_9x10[row][col_forward];
    if (capture & 0x3) != (piece & 0x3) then {
      move := Move32.{from, to, capture, piece};
      append(moves, move);
    }
  }
}

cannon_captures :: (from: u8, xiangqi: *Xiangqi, moves: *Moves) {
  row, col := row_col_of(from);
  piece := xiangqi.board_9x10[row][col];
  forward: u64 = cast(u64)0xFFFF << row;
  backward := ~forward & 0x1FF;
  forward <<= 1;
  forward &= 0x1FF;
  bits := xiangqi.bit_row[col];
  forward &= bits;
  backward &= bits;
  row_back: s8 = -1;
  row_forward: s8 = -1;

  #asm {
    blsr forward, forward;
    bsf row_forward, forward;

    bsr _:, backward;
    btr backward, _;

    bsr row_back, backward;
  }

  if row_back != -1 {
    to := index_of(cast(u8)row_back, col);
    capture := xiangqi.board_9x10[row_back][col];
    if (capture & 0x3) != (piece & 0x3) then {
      move := Move32.{from, to, capture, piece};
      append(moves, move);
    }
  }

  if row_forward != -1 {
    to := index_of(cast(u8)row_forward, col);
    capture := xiangqi.board_9x10[row_forward][col];
    if (capture & 0x3) != (piece & 0x3) then {
      move := Move32.{from, to, capture, piece};
      append(moves, move);
    }
  }

  forward = cast(u64)0xFFFF << col;
  backward = ~forward & 0x3FF;
  forward <<= 1;
  forward &= 0x3FF;
  bits = xiangqi.bit_col[row];
  forward &= bits;
  backward &= bits;
  col_back: s8 = -1;
  col_forward: s8 = -1;
  #asm {
    blsr forward, forward;
    bsf col_forward, forward;

    bsr __:, backward;
    btr backward, __;
    bsr col_back, backward;
  }

  if col_back != -1 {
    to := index_of(row, cast(u8)col_back);
    capture := xiangqi.board_9x10[row][col_back];
    if (capture & 0x3) != (piece & 0x3) then {
      move := Move32.{from, to, capture, piece};
      append(moves, move);
    }
  }

  if col_forward != -1 {
    to := index_of(row, cast(u8)col_forward);
    capture := xiangqi.board_9x10[row][col_forward];
    if (capture & 0x3) != (piece & 0x3) then {
      move := Move32.{from, to, capture, piece};
      append(moves, move);
    }
  }
}

quiet_sliding_moves :: (from: u8, xiangqi: *Xiangqi, moves: *Moves) {
  // this function is used for both rook and cannon quiet moves.
  row, col := row_col_of(from);
  piece := xiangqi.board_9x10[row][col];
  forward := 0xFFFF << row;
  backward := ~forward & 0x1FF;
  forward <<= 1;
  forward &= 0x1FF;
  while backward {
    index: u8;
    #asm {
      bsr index, backward;
    }
    backward >>= 1;
    to := index_of(index, col);
    capture := xiangqi.board_9x10[index][col];
    if capture != 0 then
      break;
    move := Move32.{from, to, capture, piece};
    append(moves, move);
  }

  while forward {
    index: u8;
    #asm {
      bsf index, forward;
      blsr forward, forward;
    }
    capture := xiangqi.board_9x10[index][col];
    to := index_of(index, col);
    if capture != 0 then
      break;
    move := Move32.{from, to, capture, piece};
    append(moves, move);
  }

  forward = 0xFFFF << col;
  backward = ~forward & 0x3FF;
  forward <<= 1;
  forward &= 0x3FF;
  while backward {
    index: u8;
    #asm {
      bsr index, backward;
    }
    backward >>= 1;
    capture := xiangqi.board_9x10[row][index];
    to := index_of(row, index);
    if capture != 0 then
      break;
    move := Move32.{from, to, capture, piece};
    append(moves, move);
  }

  while forward {
    index: u8;
    #asm {
      bsf index, forward;
      blsr forward, forward;
    }
    capture := xiangqi.board_9x10[row][index];
    to := index_of(row, index);
    if capture != 0 then
      break;
    move := Move32.{from, to, capture, piece};
    append(moves, move);
  }

}

cannon_moves :: (from: u8, xiangqi: *Xiangqi, moves: *Moves) {
  cannon_captures(from, xiangqi, moves);
  quiet_sliding_moves(from, xiangqi, moves);
}

// flip the index.
orient_index :: (index: u8) -> u8 {
  row, col := row_col_of(index);
  row = 8 - row;
  col = 9 - col;
  return index_of(row, col);
}

index_of :: (row: u8, col: u8) -> u8 #expand {
  return (row << 4) | col;
}

index_of :: (row: s8, col: s8) -> s8 #expand {
  return (row << 4) | col;
}

row_of :: (index: u8) -> u8 #expand {
  return index >> 4;
}

col_of :: (index: u8) -> u8 #expand {
  return index & 0xF;
}

row_col_of :: (index: u8) -> u8, u8 #expand {
  return row_of(index), col_of(index);
}

max :: (a: int, b: s32) -> int #expand {
  c: int;
  #asm {
    cmp a, b;
    mov c, a;
    cmovle c, b;
  }
  return c;
}

min :: (a: int, b: s32) -> int #expand {
  c: int;
  #asm {
    cmp a, b;
    mov c, a;
    cmovge c, b;
  }
  return c;
}

#import "Basic";
#import "String";
