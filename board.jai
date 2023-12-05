ROOK_MAGICS: [10][1024] u16;

// mix elephant and advisor squares together.
DEFENSE_SQ_TABLE : [90] u8 : u8.[
  0b0000, 0b0000, 0b1100, 0b1000, 0b0000, 0b0100, 0b1100, 0b0000, 0b0000, 
  0b0000, 0b0000, 0b0000, 0b0000, 0b1111, 0b0000, 0b0000, 0b0000, 0b0000, 
  0b1010, 0b0000, 0b0000, 0b0010, 0b1111, 0b0001, 0b0000, 0b0000, 0b0101, 
  0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 
  0b0000, 0b0000, 0b0011, 0b0000, 0b0000, 0b0000, 0b0011, 0b0000, 0b0000, 
  0b0000, 0b0000, 0b1100, 0b0000, 0b0000, 0b0000, 0b1100, 0b0000, 0b0000, 
  0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 0b0000, 
  0b1010, 0b0000, 0b0000, 0b1000, 0b1111, 0b0100, 0b0000, 0b0000, 0b0101, 
  0b0000, 0b0000, 0b0000, 0b0000, 0b1111, 0b0000, 0b0000, 0b0000, 0b0000, 
  0b0000, 0b0000, 0b0011, 0b0010, 0b0000, 0b0001, 0b0011, 0b0000, 0b0000, 
];

// king/pawn can be combined into one table
// pawn table
KP_TABLE : [2][90] u8 : [90] u8.[
  u8.[
    0b0000, 0b0000, 0b0000, 0b1100, 0b1110, 0b0110, 0b0000, 0b0000, 0b0000, 
    0b0000, 0b0000, 0b0000, 0b1101, 0b1111, 0b0111, 0b0000, 0b0000, 0b0000, 
    0b0000, 0b0000, 0b0000, 0b1001, 0b1011, 0b0011, 0b0000, 0b0000, 0b0000, 
    0b0100, 0b0000, 0b0100, 0b0000, 0b0100, 0b0000, 0b0100, 0b0000, 0b0100, 
    0b0100, 0b0000, 0b0100, 0b0000, 0b0100, 0b0000, 0b0100, 0b0000, 0b0100, 
    0b1100, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b0110, 
    0b1100, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b0110, 
    0b1100, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b0110, 
    0b1100, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b1110, 0b0110, 
    0b1000, 0b1010, 0b1010, 0b1010, 0b1010, 0b1010, 0b1010, 0b1010, 0b0010, 
  ],

  u8.[
    0b1000, 0b1010, 0b1010, 0b1010, 0b1010, 0b1010, 0b1010, 0b1010, 0b0010, 
    0b1001, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b0011, 
    0b1001, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b0011, 
    0b1001, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b0011, 
    0b1001, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b1011, 0b0011, 
    0b0001, 0b0000, 0b0001, 0b0000, 0b0001, 0b0000, 0b0001, 0b0000, 0b0001, 
    0b0001, 0b0000, 0b0001, 0b0000, 0b0001, 0b0000, 0b0001, 0b0000, 0b0001, 
    0b0000, 0b0000, 0b0000, 0b1100, 0b1110, 0b0110, 0b0000, 0b0000, 0b0000, 
    0b0000, 0b0000, 0b0000, 0b1101, 0b1111, 0b0111, 0b0000, 0b0000, 0b0000, 
    0b0000, 0b0000, 0b0000, 0b1001, 0b1011, 0b0011, 0b0000, 0b0000, 0b0000, 
  ],
];

KNIGHT_TABLE : [90] u8 : u8.[
  0b10100000, 0b11100000, 0b11110000, 0b11110000, 0b11110000, 0b11110000, 0b11110000, 0b11010000, 0b01010000, 
  0b10101000, 0b11101000, 0b11111100, 0b11111100, 0b11111100, 0b11111100, 0b11111100, 0b11010100, 0b01010100, 
  0b10101010, 0b11101011, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11010111, 0b01010101, 
  0b10101010, 0b11101011, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11010111, 0b01010101, 
  0b10101010, 0b11101011, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11010111, 0b01010101, 
                                                                                                 
  0b10101010, 0b11101011, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11010111, 0b01010101, 
  0b10101010, 0b11101011, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11010111, 0b01010101, 
  0b10101010, 0b11101011, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11010111, 0b01010101, 
  0b00101010, 0b00101011, 0b00111111, 0b00111111, 0b00111111, 0b00111111, 0b00111111, 0b00010111, 0b00010101, 
  0b00001010, 0b00001011, 0b00001111, 0b00001111, 0b00001111, 0b00001111, 0b00001111, 0b00000111, 0b00000101, 
];

SQUARES : [2][90] u8 : .[
  u8.[
     0,  1,  2,  3,  4,  5,  6,  7,  8,  
     9, 10, 11, 12, 13, 14, 15, 16, 17,  
    18, 19, 20, 21, 22, 23, 24, 25, 26,  
    27, 28, 29, 30, 31, 32, 33, 34, 35, 
    36, 37, 38, 39, 40, 41, 42, 43, 44,
    45, 46, 47, 48, 49, 50, 51, 52, 53,
    54, 55, 56, 57, 58, 59, 60, 61, 62,
    63, 64, 65, 66, 67, 68, 69, 70, 71,
    72, 73, 74, 75, 76, 77, 78, 79, 80,
    81, 82, 83, 84, 85, 86, 87, 88, 89,
  ],

  u8.[
    81, 82, 83, 84, 85, 86, 87, 88, 89,
    72, 73, 74, 75, 76, 77, 78, 79, 80,
    63, 64, 65, 66, 67, 68, 69, 70, 71,
    54, 55, 56, 57, 58, 59, 60, 61, 62,
    45, 46, 47, 48, 49, 50, 51, 52, 53,
    36, 37, 38, 39, 40, 41, 42, 43, 44,
    27, 28, 29, 30, 31, 32, 33, 34, 35, 
    18, 19, 20, 21, 22, 23, 24, 25, 26,  
     9, 10, 11, 12, 13, 14, 15, 16, 17,  
     0,  1,  2,  3,  4,  5,  6,  7,  8,  
  ]
];

KING_DIR :: int.[-9, -1, 9, 1];
ADV_DIR  :: int.[-10, -8, 8, 10];
ELE_DIR  :: int.[-20, -16, 16, 20];

KNI_DIR :: int.[-19, -17, -11, -7,  7, 11, 17, 19];
KNI_BLK :: int.[ -9,  -9,  -1,  1, -1,  1,  9,  9];

print_moves :: (from: int, moves: *Moves) {
  row := 81;
  col : u8 = #char "9";
  builder: String_Builder;
  builder.allocator = temp;
  while row >= 0 {
    append(*builder, col);
    for i: 0..8 {
      sq := row + i;
      append(*builder, "  ");
      if from == sq {
        append(*builder, #char "X");
      } else {
        TF: bool = false;
        for move : moves {
          if move.to == sq {
            append(*builder, #char "O");
            TF = true;
            break;
          }
        }

        if TF == false {
          append(*builder, #char "-");
        }
      }
    }
    append(*builder, #char "\n");
    row -= 9;
    col -= 1;
  }

  append(*builder, "   a  b  c  d  e  f  g  h  i\n");
  print("%\n", builder_to_string(*builder, allocator=temp));
}

AttFlags :: enum_flags {
  King;
  Advisor;
  Elephant;
  Knight;
  Rook;
  Cannon;
  Pawn;
  All :: King | Advisor | Elephant | Knight | Rook | Cannon | Pawn;
  KingEle :: King | Elephant;
  KingAdv :: King | Advisor;
}

SEE_Flags :: enum_flags u8 {
  King;
  Adv;
  Ele;
  Pawn;
  Knight;
  Rook;
  Cannon;
  KingEle :: King | Ele;
  KingAdv :: King | Adv;
  PawnEle :: Pawn | Ele;
  Attacking :: Knight | Rook | Cannon;
}

SEE_TABLE : [90] SEE_Flags: SEE_Flags.[
      0,      0,      .Ele,  .KingAdv,     .King,  .KingAdv,      .Ele,      0,      0,
      0,      0,         0,     .King,  .KingAdv,     .King,         0,      0,      0,
   .Ele,      0,         0,  .KingAdv,  .KingEle,  .KingAdv,         0,      0,   .Ele,
  .Pawn,      0,     .Pawn,         0,     .Pawn,         0,     .Pawn,      0,  .Pawn,
  .Pawn,      0,  .PawnEle,         0,     .Pawn,         0,  .PawnEle,      0,  .Pawn,
  .Pawn,  .Pawn,     .Pawn,     .Pawn,     .Pawn,     .Pawn,     .Pawn,  .Pawn,  .Pawn,
  .Pawn,  .Pawn,     .Pawn,     .Pawn,     .Pawn,     .Pawn,     .Pawn,  .Pawn,  .Pawn,
  .Pawn,  .Pawn,     .Pawn,     .Pawn,     .Pawn,     .Pawn,     .Pawn,  .Pawn,  .Pawn,
  .Pawn,  .Pawn,     .Pawn,     .Pawn,     .Pawn,     .Pawn,     .Pawn,  .Pawn,  .Pawn,
  .Pawn,  .Pawn,     .Pawn,     .Pawn,     .Pawn,     .Pawn,     .Pawn,  .Pawn,  .Pawn,
];                                                       

attackers :: (xiangqi: *Xiangqi) -> AttFlags #must {

  is_attacked_by_knight :: (xiangqi: *Xiangqi, diff: int) -> bool {
    diff += 19;
    return ((1 << diff) & 0b101_000001_0001_0000_0000_0000_01_0001_00000_101) != 0;
  }

  attflags: AttFlags = 0;
  turn := xiangqi.turn;
  opp := turn ^ 1;
  ksq := get_king(xiangqi, turn);
  OPP_PAWN := ((S << 2) | (opp << 1) | 1);
  for att : PAWN_ATT[turn] {
    to := att + ksq;
    if xiangqi.board[to] == OPP_PAWN {
      attflags |= .Pawn;
    }
  }

  for kni : xiangqi.pieces[opp].kni {
    abs_diff, diff := index_abs_diff(ksq, kni);
    if abs_diff > 19 then {
      continue;
    }

    if is_attacked_by_knight(xiangqi, diff) then {
      attflags |= .Knight;
    }
  }

  krow := ksq % 9;
  kcol := ksq / 9;
  occ_row: u64 = xiangqi.rows[kcol];
  occ_col: u64 = xiangqi.cols[krow];
  arr: [2] u64 = .[occ_row, occ_col];

  attacking :: (pieces: Array_u8, arr: [2] u64, ksq: int, min: int, max: int) -> bool {
    for sq : pieces {
      between, r := get_table_entry(sq, ksq);
      p := popcount(arr[r] & between);
      if p >= min && p <= max then {
        return true;
      }
    }
    return false;
  }

  if attacking(xiangqi.pieces[opp].king, arr, ksq, 3, 3) {
    attflags |= .King;
  }

  if attacking(xiangqi.pieces[opp].rook, arr, ksq, 2, 3) {
    attflags |= .Rook;
  }

  if attacking(xiangqi.pieces[opp].cannon, arr, ksq, 2, 4) {
    attflags |= .Cannon;
  }

  return attflags;
}

PAWN_ATT : [2][3] int : .[ .[-1, 1, 9], .[-9, -1, 1]];

index_abs_diff :: inline (x: int, y: int) -> abs_diff: int, diff: int {
  diff := x - y;
  if diff < 0 {
    return -diff, diff;
  } else {
    return diff, diff;
  }
}

/// is_pseudolegal() takes a random move and tests whether the move is
/// pseudo legal. It is used to validate moves from transposition table that can be corrupted
/// due to SMP concurrent access or hash position key aliasing.

is_pseudolegal :: (using xiangqi: *Xiangqi, move: Move32) -> bool {

  is_dir_pseudolegal :: (from: int, to: int, TABLE: [90] u8, DIR: [] int) -> bool {
    bits := TABLE[from];
    while bits {
      i := bit_scan_forward(bits);
      if to == from + DIR[i] then {
        return true;
      }
      bits &= bits - 1;
    }
    return false;
  }

  is_blocked_pseudolegal :: (xiangqi: *Xiangqi, from: int, to: int, TABLE: [90] u8, DIR: [] int, BLOCKS: [] int) -> bool {
    bits := TABLE[from];
    while bits {
      i := bit_scan_forward(bits);
      if to == from + DIR[i] && xiangqi.board[from + BLOCKS[i]] == 0 then {
        return true;
      }
      bits &= bits - 1;
    }
    return false;
  }

  is_rook_pseudolegal :: (xiangqi: *Xiangqi, from: int, to: int) -> bool {
    between, r := get_table_entry(from, to);
    row := from % 9;
    col := from / 9;
    occ: u64;
    if r == 0 then {
      occ = xiangqi.rows[col] & 0x1FF;
    } else {
      occ = xiangqi.cols[row];
    }
    count := popcount(occ & between);

    return count == 1 || (count == 2 && xiangqi.board[to] != 0);
  }

  is_cannon_pseudolegal :: (xiangqi: *Xiangqi, from: int, to: int) -> bool {
    between, r := get_table_entry(from, to);
    row := from % 9;
    col := from / 9;
    occ: u64;
    if r == 0 then {
      occ = xiangqi.rows[col] & 0x1FF;
    } else {
      occ = xiangqi.cols[row];
    }

    count := popcount(occ & between);
    return count == 1 || (count == 3 && xiangqi.board[to] != 0);
  }

  from:    int = move.from;
  to:      int = move.to;
  piece:   int = move.piece;
  capture: int = move.capture;

  if from == to then {
    return false;
  }

  if from < 0 || from > 89 || to < 0 || to > 89 then {
    return false;
  }

  // move piece does not match.
  if board[from] == 0 || board[from] != piece || board[to] != capture then {
    return false;
  }

  if (piece & 0x3) == (capture & 0x3) then {
    return false;
  }

  // cannot move an adversery piece on your turn.
  if ((piece >> 1) & 0x1) != turn then {
    return false;
  }

  // check if move is pseudo-legal.
  if (piece >> 2) == {

  case G;
    return is_dir_pseudolegal(from, to, KP_TABLE[turn], KING_DIR);
  case A;
    return is_dir_pseudolegal(from, to, DEFENSE_SQ_TABLE, ADV_DIR);
  case E;
    return is_blocked_pseudolegal(xiangqi, from, to, DEFENSE_SQ_TABLE, ELE_DIR, ADV_DIR);
  case H;
    return is_blocked_pseudolegal(xiangqi, from, to, KNIGHT_TABLE, KNI_DIR, KNI_BLK);
  case R;
    return is_rook_pseudolegal(xiangqi, from, to);
  case C;
    return is_cannon_pseudolegal(xiangqi, from, to);
  case S;
    return is_dir_pseudolegal(from, to, KP_TABLE[turn], KING_DIR);
  case;
    return false;

  }

  return false;
}


is_legal :: (xiangqi: *Xiangqi, attackers: AttFlags, move: Move32) -> bool {
  turn := xiangqi.turn;
  opp := turn ^ 1;
  ksq := get_king(xiangqi, turn);
  if move.from == ksq then {
    ksq = move.to;
    return is_legal_ksq(xiangqi, move, ksq, .All);
  }

  if attackers != 0 then {
    return is_legal_ksq(xiangqi, move, ksq, attackers);
  }

  return true;
}

get_modified_row_cols :: (xiangqi: *Xiangqi, ksq: int, move: Move32) -> occ_row: u64, occ_col: u64, krow: int, kcol: int {
  krow := ksq % 9;
  kcol := ksq / 9;
  occ_row: u64 = xiangqi.rows[kcol];
  if kcol == move.from / 9 {
    occ_row &= ~(cast, no_check (u16) (1 << (move.from % 9)));
  }

  if kcol == move.to / 9 {
    occ_row |= cast, no_check(u16) (1 << (move.to % 9));
  }

  occ_col: u64 = xiangqi.cols[krow];
  if krow == move.from % 9 {
    occ_col &= ~(cast, no_check (u16) (1 << (move.from / 9)));
  }

  if krow == move.to % 9 {
    occ_col |= cast, no_check(u16) (1 << (move.to / 9));
  }

  return occ_row, occ_col, krow, kcol;
}

get_table_entry :: (sq1: int, sq2: int) -> u64, u64 #expand {
  between := between_table[sq1][sq2];
  r := between & 1;
  return between >> 0x1, r;
}

popcount :: (value: u64) -> int #expand {
  result: int;
  #if CPU == .X64 {
    #asm { popcnt.q  result, value; }
  } else {
    result = 0;
    while value {
      result += 1;
      value &= value - 1;
    }
  }
  return result;
}

incheck :: inline (xiangqi: *Xiangqi) -> bool {
  att := attackers(xiangqi);
  return incheck(xiangqi, att);
}

incheck :: (xiangqi: *Xiangqi, attflags: AttFlags) -> bool {

  knight_check :: (xiangqi: *Xiangqi, kni: int, diff: int) -> bool {
    start := 0;
    end := 3;
    if diff > 0 {
      start = 4;
      end = 7;
    } 
    for i : start..end {
      if diff == KNI_DIR[i] then {
        index := kni + KNI_BLK[i];
        if xiangqi.board[index] == 0 then {
          return true;
        }
      }
    }
    return false;
  }

  legal :: (pieces: Array_u8, arr: [2] u64, ksq: int, attflags: AttFlags, type: AttFlags, number: int) -> bool {
    if attflags & type {
      for sq : pieces {
        between, r := get_table_entry(sq, ksq);
        if popcount(arr[r] & between) == number then {
          return false;
        }
      }
    }
    return true;
  }

  if attflags == 0 then {
    return false;
  }
  if attflags & .Pawn {
    return true;
  }

  turn := xiangqi.turn;
  opp := turn ^ 1;
  ksq := get_king(xiangqi, turn);

  if attflags & .Knight {
    for kni : xiangqi.pieces[opp].kni {
      abs_diff, diff := index_abs_diff(ksq, kni);
      if abs_diff > 19 then {
        continue;
      }
      if knight_check(xiangqi, kni, diff) then {
        return true;
      }
    }
  }

  // kings can never face each other. so no need to check the king.
  krow := ksq % 9;
  kcol := ksq / 9;
  occ_row: u64 = xiangqi.rows[kcol];
  occ_col: u64 = xiangqi.cols[krow];
  arr: [2] u64 = .[occ_row, occ_col];
  if !legal(xiangqi.pieces[opp].rook, arr, ksq, attflags, .Rook, 2) {
    return true;
  }

  if !legal(xiangqi.pieces[opp].cannon, arr, ksq, attflags, .Cannon, 3) {
    return true;
  }

  return false;
}

is_attacked_by_knight :: (xiangqi: *Xiangqi, kni: int, diff: int, from: int, to: int) -> bool {
  start := 0;
  end := 3;
  if diff > 0 {
    start = 4;
    end = 7;
  } 
  for i : start..end {
    if diff == KNI_DIR[i] then {
      index := kni + KNI_BLK[i];
      if to == index {
        break;
      }
      if from == index || xiangqi.board[index] == 0 then {
        return true;
      }
    }
  }
  return false;
}

is_legal_ksq :: (xiangqi: *Xiangqi, move: Move32, ksq: int, attflags: AttFlags) -> bool {

  legal :: (pieces: Array_u8, arr: [2] u64, ksq: int, to: int, attflags: AttFlags, type: AttFlags, number: int) -> bool {
    if attflags & type {
      for sq : pieces {
        if sq == to {
          continue;
        }
        between, r := get_table_entry(sq, ksq);
        if popcount(arr[r] & between) == number then {
          return false;
        }
      }
    }
    return true;
  }

  turn := xiangqi.turn;
  opp := turn ^ 1;
  OPP_PAWN := ((S << 2) | (opp << 1) | 1);

  if attflags & .Pawn {
    for att : PAWN_ATT[turn] {
      to := att + ksq;
      if to != move.to && xiangqi.board[to] == OPP_PAWN {
        return false;
      }
    }
  }

  if attflags & .Knight {
    from: int = move.from;
    to: int = move.to;
    for kni : xiangqi.pieces[opp].kni {
      if kni == move.to {
        continue;
      }
 
      abs_diff, diff := index_abs_diff(ksq, kni);
      if abs_diff > 19 then {
        continue;
      }
      if is_attacked_by_knight(xiangqi, kni, diff, from, to) then {
        return false;
      }
    }
  }

  occ_row, occ_col, krow, kcol := get_modified_row_cols(xiangqi, ksq, move);
  arr: [2] u64 = .[occ_row, occ_col];

  if !legal(xiangqi.pieces[opp].king, arr, ksq, move.to, attflags, .King, 2) {
    return false;
  }

  if !legal(xiangqi.pieces[opp].rook, arr, ksq, move.to, attflags, .Rook, 2) {
    return false;
  }

  if !legal(xiangqi.pieces[opp].cannon, arr, ksq, move.to, attflags, .Cannon, 3) {
    return false;
  }

  return true;
}

make_move :: (xiangqi: *Xiangqi, move: Move32) {
  add_hash(*xiangqi.hashes, xiangqi.hash, move);
  turn := xiangqi.turn;
  piece := move.piece >> 2;
  from: int = move.from;
  {
    r := from % 9;
    c := from / 9;
    xiangqi.board[from] = 0;
    xiangqi.rows[c] ^= (cast(u16) (1 << r));
    xiangqi.cols[r] ^= (cast(u16) (1 << c));
  }
  to: int = move.to;
  {
    r := to % 9;
    c := to / 9;
    xiangqi.board[to] = move.piece;
    xiangqi.rows[c] |= cast(u16) (1 << r);
    xiangqi.cols[r] |= cast(u16) (1 << c);
  }

  array := *xiangqi.pieces[xiangqi.turn].piece[piece];
  update_piece_array(array, move.from, move.to);
  xiangqi.hash ^= ZOBRIST[turn][piece][from];
  xiangqi.hash ^= ZOBRIST[turn][piece][to];
  xiangqi.hash ^= TURN_ZOBRIST;
  turn ^= 1;
  xiangqi.turn = turn;
  capture := move.capture;
  if capture != 0 then {
    // zobrist hash.
    capture >>= 2;
    xiangqi.hash ^= ZOBRIST[turn][capture][to];
    array := *xiangqi.pieces[turn].piece[capture];
    remove_piece_from_array(array, move.to);
  }
}

unmake_move :: (xiangqi: *Xiangqi, move: Move32) {
  xiangqi.hash = pop_hash(*xiangqi.hashes);
  to: int = move.to;
  capture := move.capture;
  // to:
  xiangqi.board[to] = capture;
  if capture != 0 then {
    cap := capture >> 2;
    array := *xiangqi.pieces[xiangqi.turn].piece[cap];
    append(array, to);
  } else {
    r := to % 9;
    c := to / 9;
    xiangqi.rows[c] ^= (cast(u16) (1 << r));
    xiangqi.cols[r] ^= (cast(u16) (1 << c));
  }

  xiangqi.turn ^= 1;
  piece := move.piece;
  from  := move.from;

  // from:
  xiangqi.board[from] = piece;
  r := from % 9;
  c := from / 9;
  xiangqi.rows[c] |= cast(u16) (1 << r);
  xiangqi.cols[r] |= cast(u16) (1 << c);

  piece >>= 2;
  array := *xiangqi.pieces[xiangqi.turn].piece[piece];
  update_piece_array(array, move.to, move.from);

}

// make/unmake for null move pruning.
make_null_move :: (xiangqi: *Xiangqi) {
  add_hash(*xiangqi.hashes, xiangqi.hash, NULL_MOVE);
  xiangqi.hash ^= TURN_ZOBRIST;
  xiangqi.turn ^= 1;
}

unmake_null_move :: (xiangqi: *Xiangqi) {
  xiangqi.hash = pop_hash(*xiangqi.hashes);
  xiangqi.turn ^= 1;
}

king_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int, color: int) #expand {
  dir_moves(xiangqi, moves, sq, KP_TABLE[color], KING_DIR);
}

king_quiet_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int, color: int) #expand {
  dir_quiet_moves(xiangqi, moves, sq, KP_TABLE[color], KING_DIR);
}

king_capture_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int, color: int) #expand {
  dir_capture_moves(xiangqi, moves, sq, KP_TABLE[color], KING_DIR);
}

advisor_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) #expand {
  dir_moves(xiangqi, moves, sq, DEFENSE_SQ_TABLE, ADV_DIR);
}

advisor_quiet_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) #expand {
  dir_quiet_moves(xiangqi, moves, sq, DEFENSE_SQ_TABLE, ADV_DIR);
}

advisor_capture_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) #expand {
  dir_capture_moves(xiangqi, moves, sq, DEFENSE_SQ_TABLE, ADV_DIR);
}

pawn_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int, color: int) #expand {
  dir_moves(xiangqi, moves, sq, KP_TABLE[color], KING_DIR);
}

pawn_quiet_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int, color: int) #expand {
  dir_quiet_moves(xiangqi, moves, sq, KP_TABLE[color], KING_DIR);
}

pawn_capture_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int, color: int) #expand {
  dir_capture_moves(xiangqi, moves, sq, KP_TABLE[color], KING_DIR);
}

ele_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) #expand {
  blocked_moves(xiangqi, moves, sq, DEFENSE_SQ_TABLE, ELE_DIR, ADV_DIR);
}

ele_quiet_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) #expand {
  blocked_quiet_moves(xiangqi, moves, sq, DEFENSE_SQ_TABLE, ELE_DIR, ADV_DIR);
}

ele_capture_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) #expand {
  blocked_capture_moves(xiangqi, moves, sq, DEFENSE_SQ_TABLE, ELE_DIR, ADV_DIR);
}

kni_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) #expand {
  blocked_moves(xiangqi, moves, sq, KNIGHT_TABLE, KNI_DIR, KNI_BLK);
}

kni_quiet_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) #expand {
  blocked_quiet_moves(xiangqi, moves, sq, KNIGHT_TABLE, KNI_DIR, KNI_BLK);
}

kni_capture_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) #expand {
  blocked_capture_moves(xiangqi, moves, sq, KNIGHT_TABLE, KNI_DIR, KNI_BLK);
}

row_col_to_index :: (row: int, col: int) -> int #expand {
  return row + col * 9;
}

is_quiet :: (mov: Move32) -> bool #expand {
  return mov.capture == 0;
}

is_capture :: (mov: Move32) -> bool #expand {
  return mov.capture != 0;
}

is_pawn_advance :: (move: Move32) -> bool {
  piece := move.piece >> 2;
  from: int = move.from;
  to:   int = move.to;
  return piece == 6 && abs(from - to) == 9;
}

add_row_moves :: (xiangqi: *Xiangqi, moves: *Moves, rows_bits: u64, move: Move32, col: int) {
  mov := move;
  while rows_bits {
    i := bit_scan_forward(rows_bits);
    rows_bits &= rows_bits - 1;
    to := row_col_to_index(i, col);
    capture := xiangqi.board[to];
    mov.to = cast(u8) to;
    mov.capture = capture;
    append_move(moves, mov);
  }
}

add_col_moves :: (xiangqi: *Xiangqi, moves: *Moves, cols_bits: u64, move: Move32, row: int) {
  mov := move;
  while cols_bits {
    i := bit_scan_forward(cols_bits);
    cols_bits &= cols_bits - 1;
    to := row_col_to_index(row, i);
    capture := xiangqi.board[to];
    mov.to = cast(u8) to;
    mov.capture = capture;
    append_move(moves, mov);
  }
}

rook_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) {
  row := sq % 9;
  col := sq / 9;
  move: Move32;
  move.from = cast(u8) sq;
  move.piece = xiangqi.board[sq];

  rows_bits: u64 = ROOK_MAGICS[row][xiangqi.rows[col]] & 0b1_1111_1111; // rows.
  cols_bits: u64 = ROOK_MAGICS[col][xiangqi.cols[row]];
  add_row_moves(xiangqi, moves, rows_bits, move, col);
  add_col_moves(xiangqi, moves, cols_bits, move, row);
}

rook_quiets :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) {
  row := sq % 9;
  col := sq / 9;
  move: Move32;
  move.from = cast(u8) sq;
  move.piece = xiangqi.board[sq];

  rows_bits: u64 = ROOK_MAGICS[row][xiangqi.rows[col]] & (~xiangqi.rows[col]) & 0b1_1111_1111;
  cols_bits: u64 = ROOK_MAGICS[col][xiangqi.cols[row]] & (~xiangqi.cols[row]);
  add_row_moves(xiangqi, moves, rows_bits, move, col);
  add_col_moves(xiangqi, moves, cols_bits, move, row);
}

rook_captures :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) {
  row := sq % 9;
  col := sq / 9;
  move: Move32;
  move.from = cast(u8) sq;
  move.piece = xiangqi.board[sq];

  rows_bits: u64 = ROOK_MAGICS[row][xiangqi.rows[col]] & xiangqi.rows[col]; // rows.
  cols_bits: u64 = ROOK_MAGICS[col][xiangqi.cols[row]] & xiangqi.cols[row];
  add_row_moves(xiangqi, moves, rows_bits, move, col);
  add_col_moves(xiangqi, moves, cols_bits, move, row);
}

xray :: (row: int, occ: u64) -> u64 {
  attacks: u64  = ROOK_MAGICS[row][occ];
  blockers: u64 = occ & attacks;
  occ ^= blockers;
  return (ROOK_MAGICS[row][occ] & occ) | (attacks & ~blockers);
}

xray_captures :: (row: int, occ: u64) -> u64 {
  attacks: u64  = ROOK_MAGICS[row][occ];
  blockers: u64 = occ & attacks;
  occ ^= blockers;
  return (ROOK_MAGICS[row][occ] & occ);
}

cannon_moves :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) {
  row := sq % 9;
  col := sq / 9;
  move: Move32;
  move.from = cast(u8) sq;
  move.piece = xiangqi.board[sq];
  rows_bits := xray(row, xiangqi.rows[col]) & 0b1_1111_1111;
  cols_bits := xray(col, xiangqi.cols[row]);
  add_row_moves(xiangqi, moves, rows_bits, move, col);
  add_col_moves(xiangqi, moves, cols_bits, move, row);
}

cannon_captures :: (xiangqi: *Xiangqi, moves: *Moves, sq: int) {
  row := sq % 9;
  col := sq / 9;
  move: Move32;
  move.from = cast(u8) sq;
  move.piece = xiangqi.board[sq];
  rows_bits := xray_captures(row, xiangqi.rows[col]);
  cols_bits := xray_captures(col, xiangqi.cols[row]);
  add_row_moves(xiangqi, moves, rows_bits, move, col);
  add_col_moves(xiangqi, moves, cols_bits, move, row);
}

gen_moves :: (xiangqi: *Xiangqi, moves: *Moves) {
  turn := xiangqi.turn;
  pieces := *xiangqi.pieces[turn];
  for kni : pieces.kni {
    kni_moves(xiangqi, moves, kni);
  }

  for rook : pieces.rook {
    rook_moves(xiangqi, moves, rook);
  }

  for can : pieces.cannon {
    cannon_moves(xiangqi, moves, can);
  }

  for pawn : pieces.pawn {
    pawn_moves(xiangqi, moves, pawn, turn);
  }

  king_moves(xiangqi, moves, pieces.king.array[0], turn);

  for adv : pieces.adv {
    advisor_moves(xiangqi, moves, adv);
  }

  for ele : pieces.ele {
    ele_moves(xiangqi, moves, ele);
  }
}

gen_quiets :: (xiangqi: *Xiangqi, moves: *Moves) {
  turn := xiangqi.turn;
  pieces := *xiangqi.pieces[turn];
  for kni : pieces.kni {
    kni_quiet_moves(xiangqi, moves, kni);
  }

  for rook : pieces.rook {
    rook_quiets(xiangqi, moves, rook);
  }

  for can : pieces.cannon {
    rook_quiets(xiangqi, moves, can);
  }

  for pawn : pieces.pawn {
    pawn_quiet_moves(xiangqi, moves, pawn, turn);
  }

  king_quiet_moves(xiangqi, moves, pieces.king.array[0], turn);

  for adv : pieces.adv {
    advisor_quiet_moves(xiangqi, moves, adv);
  }

  for ele : pieces.ele {
    ele_quiet_moves(xiangqi, moves, ele);
  }
}

dir_moves :: (xiangqi: *Xiangqi, moves: *Moves, ksq: int, TABLE: [90] u8, DIR: [] int) {
  move: Move32;
  move.from = cast(u8) ksq;
  move.piece = xiangqi.board[ksq];

  bits := cast(u64) TABLE[ksq];
  while bits {
    i := bit_scan_forward(bits);
    bits &= bits - 1;
    to := ksq + DIR[i];
    capture := xiangqi.board[to];
    move.to = cast(u8) to;
    move.capture = capture;
    append_move(moves, move);
  }
}

dir_quiet_moves :: (xiangqi: *Xiangqi, moves: *Moves, ksq: int, TABLE: [90] u8, DIR: [] int) {
  move: Move32;
  move.from = cast(u8) ksq;
  move.piece = xiangqi.board[ksq];

  bits := cast(u64) TABLE[ksq];
  while bits {
    i := bit_scan_forward(bits);
    bits &= bits - 1;
    to := ksq + DIR[i];
    capture := xiangqi.board[to];
    move.to = cast(u8) to;
    move.capture = capture;
    append_quiet_move(moves, move);
  }
}

dir_capture_moves :: (xiangqi: *Xiangqi, moves: *Moves, ksq: int, TABLE: [90] u8, DIR: [] int) {
  move: Move32;
  move.from = cast(u8) ksq;
  move.piece = xiangqi.board[ksq];
  bits := cast(u64) TABLE[ksq];
  while bits {
    i := bit_scan_forward(bits);
    bits &= bits - 1;
    to := ksq + DIR[i];
    capture := xiangqi.board[to];
    move.to = cast(u8) to;
    move.capture = capture;
    append_capture_move(moves, move);
  }
}

blocked_moves :: (xiangqi: *Xiangqi, moves: *Moves, ksq: int, TABLE: [90] u8, DIR: [] int, BLOCKS: [] int) {
  move: Move32;
  move.from = cast(u8) ksq;
  move.piece = xiangqi.board[ksq];

  bits := cast(u64) TABLE[ksq];
  while bits {
    i := bit_scan_forward(bits);
    bits &= bits - 1;
    to := ksq + DIR[i];

    blocking := ksq + BLOCKS[i];

    // piece blocking movement.
    if xiangqi.board[blocking] != 0 {
      continue; 
    }

    capture := xiangqi.board[to];
    move.to = cast(u8) to;
    move.capture = capture;
    append_move(moves, move);
  }
}

blocked_capture_moves :: (xiangqi: *Xiangqi, moves: *Moves, ksq: int, TABLE: [90] u8, DIR: [] int, BLOCKS: [] int) {
  move: Move32;
  move.from = cast(u8) ksq;
  move.piece = xiangqi.board[ksq];

  bits := cast(u64) TABLE[ksq];
  while bits {
    i := bit_scan_forward(bits);
    bits &= bits - 1;
    to := ksq + DIR[i];

    blocking := ksq + BLOCKS[i];

    // piece blocking movement.
    if xiangqi.board[blocking] != 0 {
      continue; 
    }

    capture := xiangqi.board[to];
    move.to = cast(u8) to;
    move.capture = capture;
    append_capture_move(moves, move);
  }
}

blocked_quiet_moves :: (xiangqi: *Xiangqi, moves: *Moves, ksq: int, TABLE: [90] u8, DIR: [] int, BLOCKS: [] int) {
  move: Move32;
  move.from = cast(u8) ksq;
  move.piece = xiangqi.board[ksq];

  bits := cast(u64) TABLE[ksq];
  while bits {
    i := bit_scan_forward(bits);
    bits &= bits - 1;
    to := ksq + DIR[i];

    blocking := ksq + BLOCKS[i];

    // piece blocking movement.
    if xiangqi.board[blocking] != 0 {
      continue; 
    }

    capture := xiangqi.board[to];
    move.to = cast(u8) to;
    move.capture = capture;
    append_quiet_move(moves, move);
  }
}

// magics initialization.
init_rook_magics :: () {

  compute_bitcolumn :: (index: u64, bits: u64) -> u16 {
    answer: u64 = 0;
    index_back := index;
    while index_back {
      index_back >>= 1;
      answer |= index_back;
      if index_back & bits then
        break;
    }

    index_forward := index;
    while index_forward {
      index_forward <<= 1;
      index_forward &= 0b11_1111_1111;
      answer |= index_forward;
      if index_forward & bits then
        break;
    }

    return cast, no_check(u16) answer;
  }

  bit: u64 = 1;
  for i : 0..9 {
    for j : 0..cast(u64)1023 {
      ROOK_MAGICS[i][j] = compute_bitcolumn(bit, j);
    }
    bit <<= 1;
  }
}

Moves :: struct {
  count: int;
  array: [127] struct {move: Move32; score: s32; };
}

PV :: struct {
  MAX_MOVES : s32 : 15;
  count: s32;
  moves: [MAX_MOVES] Move32;
}

move_swap :: inline (moves: *Moves, a: int, b: int) {
  moves.array[a], moves.array[b] = moves.array[b], moves.array[a];
}

erase_move :: inline (moves: *Moves, index: int) {
  moves.array[index].move = NULL_MOVE;
}

copy_pv :: (pv: *PV, child_pv: PV, mov: Move32) {
  // copy child pv. make sure we are still within array bounds.
  MAX_MOVES :: PV.MAX_MOVES;
  count := min(child_pv.count, MAX_MOVES);
  pv.count = count + 1;
  pv.moves[0] = mov;
  i := 1;
  j := 0;
  while i < count {
    pv.moves[i] = child_pv.moves[j];
    i += 1;
    j += 1;
  }
}

NULL_MOVE :: Move32.{0,0,0,0};

legal_moves :: (xiangqi: *Xiangqi, moves: *Moves) {
  gen_moves(xiangqi, moves);
  i := 0;
  att := attackers(xiangqi);
  while i < moves.count {
    move := moves.array[i].move;
    if !is_legal(xiangqi, att, move) {
      moves.count -= 1;
      moves.array[i] = moves.array[moves.count];
      continue;
    } 
    i += 1;
  }
}

// a version of movegen but for captures only. used for quiescene search.

gen_captures :: (xiangqi: *Xiangqi, moves: *Moves) {
  turn := xiangqi.turn;
  pieces := *xiangqi.pieces[turn];
  for kni : pieces.kni {
    kni_capture_moves(xiangqi, moves, kni);
  }

  for rook : pieces.rook {
    rook_captures(xiangqi, moves, rook);
  }

  for can : pieces.cannon {
    cannon_captures(xiangqi, moves, can);
  }

  for pawn : pieces.pawn {
    pawn_capture_moves(xiangqi, moves, pawn, turn);
  }

  king_capture_moves(xiangqi, moves, pieces.king.array[0], turn);

  for adv : pieces.adv {
    advisor_capture_moves(xiangqi, moves, adv);
  }

  for ele : pieces.ele {
    ele_capture_moves(xiangqi, moves, ele);
  }
}

// a version of movegen but for quiet moves that evade check. used for quiescene search during check.
gen_evasions :: (xiangqi: *Xiangqi, moves: *Moves) {
  turn := xiangqi.turn;
  pieces := *xiangqi.pieces[turn];
  for adv : pieces.adv {
    advisor_quiet_moves(xiangqi, moves, adv);
  }

  for ele : pieces.ele {
    ele_quiet_moves(xiangqi, moves, ele);
  }

  king_quiet_moves(xiangqi, moves, pieces.king.array[0], turn);
}

gen_blocks :: (xiangqi: *Xiangqi, moves: *Moves) {
  turn := xiangqi.turn;
  pieces := *xiangqi.pieces[turn];
  for kni : pieces.kni {
    kni_quiet_moves(xiangqi, moves, kni);
  }

  for rook : pieces.rook {
    rook_quiets(xiangqi, moves, rook);
  }

  for can : pieces.cannon {
    rook_quiets(xiangqi, moves, can);
  }

  for pawn : pieces.pawn {
    pawn_quiet_moves(xiangqi, moves, pawn, turn);
  }
}

reset :: (moves: *Moves) {
  moves.count = 0;
  memset(*moves.array[0], 0, size_of(type_of(moves.array)));
}

for_expansion :: (moves: *Moves, body: Code, f: For_Flags) #expand {
  `it_index := 0;
  while it_index < moves.count {
    `it := moves.array[it_index].move;
    defer {it_index += 1;}
    #insert body;
  }
}

append_move :: (moves: *Moves, move: Move32) {
  capture: int = move.capture;
  piece: int = move.piece;
  if ((capture ^ piece) & 0x3) then {
    moves.array[moves.count].move = move;
    moves.count += 1;
  }
}

append_quiet_move :: (moves: *Moves, move: Move32) {
  if move.capture == 0 then {
    moves.array[moves.count].move = move;
    moves.count += 1;
  }
}

append_capture_move :: (moves: *Moves, move: Move32) {
  capture: int = move.capture;
  piece: int = move.piece;
  if ((capture ^ piece) & 0x3) == 0x2 then {
    moves.array[moves.count].move = move;
    moves.count += 1;
  }
}

bit_scan_forward :: (value: u64) -> int #expand {
  #if CPU == .X64 {
    #assert(!is_constant(value));
    result := -1;
    #asm { bsf.q result, value; }
    return result;
  } else {
    // DeBruijn Multiplication.
    // https://www.chessprogramming.org/BitScan#DeBruijnMultiplation
    index64 :: int.[
       0,  1, 48,  2, 57, 49, 28,  3,
      61, 58, 50, 42, 38, 29, 17,  4,
      62, 55, 59, 36, 53, 51, 43, 22,
      45, 39, 33, 30, 24, 18, 12,  5,
      63, 47, 56, 27, 60, 41, 37, 16,
      54, 35, 52, 21, 44, 32, 23, 11,
      46, 26, 40, 15, 34, 20, 31, 10,
      25, 14, 19,  9, 13,  8,  7,  6,
    ];

    bit_scan_forward_inner :: (value: u64) -> int {
      DEBRUIJN64 : u64 : 0x03f79d71b4cb0a89;
      value = value & (cast(u64) -(cast(int)value));
      return index64[ (value * DEBRUIJN64) >> 58];
    }

    return bit_scan_forward_inner(value);
  }
}

Xiangqi :: struct {

  // xiangqi board grid.
  board: [90] u8;

  // xiangqi rows/cols represented as bits.
  rows: [10] u16;
  cols:  [9] u16;

  // piece arrays.
  pieces: [2] Pieces;

  turn: int;
  hash: u32;
  main_thread: bool = true;
  
  hashes: Board_Hash;
}

copy_board :: (dest: *Xiangqi, src: *Xiangqi) {
  memcpy(dest, src, size_of(Xiangqi));
}

get_king :: (xiangqi: *Xiangqi, turn: int) -> int {
  return xiangqi.pieces[turn].king.array[0];
}

Pieces :: struct {

  // padding out the arrays to the alignment.
  king:   Array_u8; // only be 1
  adv:    Array_u8; // at most 2
  ele:    Array_u8; // at most 2
  kni:    Array_u8; // at most 2
  rook:   Array_u8; // at most 2
  cannon: Array_u8; // at most 2
  pawn:   Array_u8; // at most 5

  #place king;
  piece: [7] Array_u8;

}

count_pieces :: (x: *Xiangqi) -> int {
  count := 2;
  count += x.pieces[0].adv.count;
  count += x.pieces[0].ele.count;
  count += x.pieces[0].kni.count;
  count += x.pieces[0].rook.count;
  count += x.pieces[0].cannon.count;
  count += x.pieces[0].pawn.count;
  count += x.pieces[1].adv.count;
  count += x.pieces[1].ele.count;
  count += x.pieces[1].kni.count;
  count += x.pieces[1].rook.count;
  count += x.pieces[1].cannon.count;
  count += x.pieces[1].pawn.count;
  return count;
}

Array_u8 :: struct {
  count: s8;
  array: [7] u8;
}

update_piece_array :: (arr: *Array_u8, from: u8, to: u8) {
  for item, index: arr {
    if item == from {
      arr.array[index] = to;
      break;
    }
  }
}

remove_piece_from_array :: (arr: *Array_u8, value: u8) {
  for item, index: arr {
    if item == value {
      end := arr.count-1;
      arr.array[index] = arr.array[end];
      arr.array[end] = 0;
      arr.count -= 1; // hack
      break;
    }
  }
}

reset :: (arr: *Array_u8) {
  arr.count = 0;
  data := arr.array.data;
  memset(data, 0, size_of(u8) * 7);
}

for_expansion :: (a: *Array_u8, body: Code, flags: For_Flags) #expand {
  `it_index := 0;
  count := a.count;
  while it_index < count {
    `it := a.array[it_index];
    defer it_index += 1;
    #insert body;
  }
}

append :: (a: *Array_u8, sq: int) #expand {
  a.array[a.count] = cast(u8) sq;
  a.count += 1;
}

add_piece :: (xiangqi: *Xiangqi, sq: int, piece: int, side: int) {
  xiangqi.board[sq] = cast(u8) ((piece << 2) | (side << 1) | 1);
  append(*xiangqi.pieces[side].piece[piece], sq);
}

hash_of :: (xiangqi: *Xiangqi) -> u32 {
  decode :: (piece: u8) -> u8, u8 #expand {
    return piece >> 2, (piece & 0b10) >> 1;
  }

  hash: u32 = 0;
  if xiangqi.turn == 1 then {
    hash ^= TURN_ZOBRIST;
  }
  for p, sq: xiangqi.board {
    if p == 0 then {
      continue;
    }
    piece, turn := decode(p);
    hash ^= ZOBRIST[turn][piece][sq];
  }
  return hash;
}

xiangqi_startpos :: (xiangqi: *Xiangqi) {
  memset(xiangqi, 0, size_of(Xiangqi));
  // red
  add_piece(xiangqi,  4, G, 0);
  add_piece(xiangqi,  3, A, 0);
  add_piece(xiangqi,  5, A, 0);
  add_piece(xiangqi,  2, E, 0);
  add_piece(xiangqi,  6, E, 0);
  add_piece(xiangqi,  1, H, 0);
  add_piece(xiangqi,  7, H, 0);
  add_piece(xiangqi,  0, R, 0);
  add_piece(xiangqi,  8, R, 0);
  add_piece(xiangqi, 19, C, 0);
  add_piece(xiangqi, 25, C, 0);
  add_piece(xiangqi, 27, S, 0);
  add_piece(xiangqi, 29, S, 0);
  add_piece(xiangqi, 31, S, 0);
  add_piece(xiangqi, 33, S, 0);
  add_piece(xiangqi, 35, S, 0);

  // black
  add_piece(xiangqi, 85, G, 1);
  add_piece(xiangqi, 84, A, 1);
  add_piece(xiangqi, 86, A, 1);
  add_piece(xiangqi, 83, E, 1);
  add_piece(xiangqi, 87, E, 1);
  add_piece(xiangqi, 82, H, 1);
  add_piece(xiangqi, 88, H, 1);
  add_piece(xiangqi, 81, R, 1);
  add_piece(xiangqi, 89, R, 1);
  add_piece(xiangqi, 64, C, 1);
  add_piece(xiangqi, 70, C, 1);
  add_piece(xiangqi, 54, S, 1);
  add_piece(xiangqi, 56, S, 1);
  add_piece(xiangqi, 58, S, 1);
  add_piece(xiangqi, 60, S, 1);
  add_piece(xiangqi, 62, S, 1);

  init_rows_and_cols(xiangqi);
  reset_hashes(xiangqi);
  xiangqi.hash = hash_of(xiangqi);
}

xiangqi_fen :: (xiangqi: *Xiangqi, fen: string) -> bool {
  memset(xiangqi, 0, size_of(Xiangqi));
  board_fen, success := parse_token(*fen);
  if success == false then
    return false;

  col: u8 = 9;
  while true {
    found, token, rest := split_from_left(board_fen, #char "/");
    array:[] u8; 
    array.data = token.data;
    array.count = token.count;
    defer {
      board_fen = rest;
      col -= 1;
      if found == false then {
        break;
      }
    }

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
        sq := row_col_to_index(row, col);
        add_piece(xiangqi, sq, piece, side);
      }
      row += 1;
    }

  }

  // get the turn.
  turn_fen, success= := parse_token(*fen);
  if success == false then
    return false;
  if equal(turn_fen, "w") {
    xiangqi.turn = 0;
  } else if equal(turn_fen, "b") {
    // xiangqi.hash ^= turn_zobrist;
    xiangqi.turn = 1;
  } else {
    return false;
  }

  init_rows_and_cols(xiangqi);
  reset_hashes(xiangqi);
  xiangqi.hash = hash_of(xiangqi);

  // we do not care about the rest of string, so return true.
  return true;
}

to_fenstring :: (xiangqi: *Xiangqi) -> string {

  piece_value :: (red: u8, black: u8, side: int) -> u8 {
    return ifx side == 0 red else black;
  }

  builder: String_Builder;
  builder.allocator = temp;
  i := 9;
  while i >= 0 {

    spaces := 0;
    for j: 0..8 {
      sq := row_col_to_index(j, i);
      piece := xiangqi.board[sq];
      if piece == 0 then {
        spaces += 1;
        continue;
      }

      if spaces > 0 {
        print_to_builder(*builder, "%", spaces);
        spaces = 0;
      }

      side := (piece >> 1) & 0x1;
      code := piece >> 2;
      value: u8;
      if code == {
      case G;
        value = piece_value(#char "K", #char "k", side);
      case A;
        value = piece_value(#char "A", #char "a", side);
      case E;
        value = piece_value(#char "B", #char "b", side);
      case H;
        value = piece_value(#char "N", #char "n", side);
      case R;
        value = piece_value(#char "R", #char "r", side);
      case C;
        value = piece_value(#char "C", #char "c", side);
      case S;
        value = piece_value(#char "P", #char "p", side);
      }
      append(*builder, value);
    }

    if spaces > 0 {
      print_to_builder(*builder, "%", spaces);
      spaces = 0;
    }

    if i > 0 then {
      append(*builder, #char "/");
    }

    i -= 1;
  }

  if xiangqi.turn == 0 {
    append(*builder, " w");
  } else {
    append(*builder, " b");
  }

  return builder_to_string(*builder, allocator = temp);

}

reset_hashes :: (xiangqi: *Xiangqi) {
  xiangqi.hashes.count = 0;
}

init_rows_and_cols :: (xiangqi: *Xiangqi) {
  for r: 0..9 {
    index := r * 9;
    for c: 0..8 {
      sq := index + c;
      piece := xiangqi.board[sq];
      if piece {
        xiangqi.rows[r] |= cast(u16)(1 << c);
        xiangqi.cols[c] |= cast(u16)(1 << r);
      }
    }
  }
}

// hmmm... could possibly try storing all of it in 8 bits.
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

Move32 :: struct {
  from: u8;
  to: u8;
  capture: u8;
  piece: u8;
  #place from;
  #as move: u32;
}

is_null :: (move: Move32) -> bool #expand {
  return move.move == 0;
}

operator == :: (mov1: Move32, mov2: Move32) -> bool #expand {
  return mov1.move == mov2.move;
}

print_pv :: (builder: *String_Builder, pv: *PV) {
  i: int = 0;
  count: int = max(pv.count - 1,1);
  while i < count {
    move := pv.moves[i];
    print_move32(builder, move);
    append(builder, " ");
    i += 1;
  }
}

print_move32 :: (builder: *String_Builder, move: Move32) {
  from: int = move.from;
  to: int   = move.to;

  from_row := (from / 9) + #char "0";
  from_col := (from % 9) + #char "a";
  to_col := (to % 9) + #char "a";
  to_row := (to / 9) + #char "0";

  append(builder, cast(u8) from_col);
  append(builder, cast(u8) from_row);
  append(builder, cast(u8) to_col);
  append(builder, cast(u8) to_row);
}

print_xiangqi_board :: (builder: *String_Builder, xiangqi: *Xiangqi) {
  
  get_piece_character :: (byte: u8, side: u8) -> u8 {
    if side == 0 then {
      return to_upper(byte);
    } else {
      return byte;
    }
  }

  piece_decode :: (byte: u8) -> u8 {
    if byte == 0 then {
      return #char "-";
    }

    side := byte & 2;
    byte >>= 2;

    if byte == {
    case G;
      return get_piece_character(#char "k", side);
    case A;
      return get_piece_character(#char "a", side);
    case E;
      return get_piece_character(#char "b", side);
    case H;
      return get_piece_character(#char "n", side);
    case R;
      return get_piece_character(#char "r", side);
    case C;
      return get_piece_character(#char "c", side);
    case S;
      return get_piece_character(#char "p", side);
    case;
      return #char "X";
    }
  }

  row := 81;
  col : u8 = #char "9";
  while row >= 0 {
    append(builder, col);
    for i: 0..8 {
      sq := row + i;
      p  := xiangqi.board[sq];
      append(builder, "  ");
      append(builder, piece_decode(p));
    }
    append(builder, #char "\n");
    row -= 9;
    col -= 1;
  }

  append(builder, "   a  b  c  d  e  f  g  h  i\n");
  if xiangqi.turn == 0 {
    append(builder, "Turn: Red\n");
  } else {
    append(builder, "Turn: Black\n");
  }

  print_to_builder(builder, "Hash: 0x%\n", formatInt(xiangqi.hash, 0x10));
}

xiangqi_printer :: (builder: *String_Builder, any: Any, struct_printer_data: *void) -> bool {
  if any.type.type == .STRUCT {
    info := cast(*Type_Info_Struct) any.type;
    if info.name == {
    case "Move32";
      move := (cast(*Move32) any.value_pointer);
      print_move32(builder, move);
      return true;

    case "Xiangqi";
      xiangqi_board := cast(*Xiangqi) any.value_pointer;
      print_xiangqi_board(builder, xiangqi_board);
      return true;

    case "PV";
      pv := cast(*PV) any.value_pointer;
      print_pv(builder, pv);
      return true;
    case; 

    }
  }

  return false;
}

perft_divide :: (xiangqi: *Xiangqi, depth: int) -> int {

  moves: Moves;
  time := current_time_monotonic();
  legal_moves(xiangqi, *moves);

  count := 0;
  for mov: moves {
    make_move(xiangqi, mov);
    num_moves := perft(xiangqi, depth-1);
    print("move %: %\n", mov, num_moves);
    count += num_moves;
    unmake_move(xiangqi, mov);
  }

  time = current_time_monotonic() - time;
  time_ns := to_nanoseconds(time);
  seconds := cast(float) time_ns / 1_000_000_000.0;
  nps := count * 1_000_000_000 / time_ns;
  print("Total Moves: %, Time Taken: %\n", count, formatFloat(seconds, trailing_width=5));
  print("Nodes per Second: %\n", nps);
  return count;

}

perft :: (xiangqi: *Xiangqi, depth: int) -> int {
  if depth <= 0 then
    return 1;

  moves: Moves;
  legal_moves(xiangqi, *moves);

  count := 0;
  if depth == 1 then {
    return moves.count;
  } else {
    for mov: moves {
      make_move(xiangqi, mov);
      count += perft(xiangqi, depth-1);
      unmake_move(xiangqi, mov);
    }
    return count;
  }

}

to_move32 :: (xiangqi: *Xiangqi, str: string) -> Move32 {
  row_from := str[0] - #char "a";
  col_from := str[1] - #char "0";
  row_to   := str[2] - #char "a";
  col_to   := str[3] - #char "0";
  from := cast(u8) row_col_to_index(row_from, col_from);
  to   := cast(u8) row_col_to_index(row_to, col_to);
  move: Move32;
  move.from = from;
  move.to   = to;
  move.piece = xiangqi.board[from];
  move.capture = xiangqi.board[to];
  return move;
}

perft_test_suite :: () {
  // Perft Test Results from: https://www.chessprogramming.org/Chinese_Chess_Perft_Results
  // Would be good to be able to find more perft results, so we can permutationally test
  // the movegen better. - Daniel (Feb 19. 2023)

  test :: (xiangqi: *Xiangqi, title: string, depth: int, expected: int) {
    time := current_time_monotonic();
    count := perft(xiangqi, depth);
    time = current_time_monotonic() - time;
    time_ns := to_nanoseconds(time);
    seconds := cast(float) time_ns / 1_000_000_000.0;
 
    if count == expected then {
      print("success for perft %1 in %2 seconds: %3\n", depth, seconds, count);
    } else {
      print("FAILED  for perft %1 in %2 seconds. got %3, expected %4\n", depth, seconds, count, expected);
    }
  }

  xiangqi: Xiangqi;
  xiangqi_startpos(*xiangqi);
  print("FEN [startpos]\n");
  test(*xiangqi, "startpos", 1, 44);
  test(*xiangqi, "startpos", 2, 1_920);
  test(*xiangqi, "startpos", 3, 79_666);
  test(*xiangqi, "startpos", 4, 3_290_240);
  test(*xiangqi, "startpos", 5, 133_312_995);

  fen := "r1ea1a3/4kh3/2h1e4/pHp1p1p1p/4c4/6P2/P1P2R2P/1CcC5/9/2EAKAE2 w - - 0 1";
  print("FEN [%]\n", fen);
  xiangqi_fen(*xiangqi, fen);
  test(*xiangqi, fen, 1, 38);
  test(*xiangqi, fen, 2, 1_128);
  test(*xiangqi, fen, 3, 43_929);
  test(*xiangqi, fen, 4, 1_339_047);

  fen = "1ceak4/9/h2a5/2p1p3p/5cp2/2h2H3/6PCP/3AE4/2C6/3A1K1H1 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, fen, 1, 7);
  test(*xiangqi, fen, 2, 281);
  test(*xiangqi, fen, 3, 8_620);
  test(*xiangqi, fen, 4, 326_201);
  test(*xiangqi, fen, 5, 10_369_923);
  test(*xiangqi, fen, 6, 380_156_340);

  fen = "5a3/3k5/3aR4/9/5r3/5h3/9/3A1A3/5K3/2EC2E2 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, fen, 1, 25);
  test(*xiangqi, fen, 2, 424);
  test(*xiangqi, fen, 3, 9_850);
  test(*xiangqi, fen, 4, 202_884);
  test(*xiangqi, fen, 5, 4_739_553);
  test(*xiangqi, fen, 6, 100_055_401);

  fen = "CRH1k1e2/3ca4/4ea3/9/2hr5/9/9/4E4/4A4/4KA3 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, fen, 1, 28);
  test(*xiangqi, fen, 2, 516);
  test(*xiangqi, fen, 3, 14_808);
  test(*xiangqi, fen, 4, 395_483);
  test(*xiangqi, fen, 5, 11_842_230);

  fen = "R1H1k1e2/9/3aea3/9/2hr5/2E6/9/4E4/4A4/4KA3 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, fen, 1, 21);
  test(*xiangqi, fen, 2, 364);
  test(*xiangqi, fen, 3, 7_626);
  test(*xiangqi, fen, 4, 162_837);
  test(*xiangqi, fen, 5, 3_500_505);
  test(*xiangqi, fen, 6, 81_195_154);

  fen = "C1hHk4/9/9/9/9/9/h1pp5/E3C4/9/3A1K3 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, fen, 1, 28);
  test(*xiangqi, fen, 2, 222);
  test(*xiangqi, fen, 3, 6_241);
  test(*xiangqi, fen, 4, 64_971);
  test(*xiangqi, fen, 5, 1_914_306);
  test(*xiangqi, fen, 6, 23_496_493);

  fen = "4ka3/4a4/9/9/4H4/p8/9/4C3c/7h1/2EK5 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, fen, 1, 23);
  test(*xiangqi, fen, 2, 345);
  test(*xiangqi, fen, 3, 8124);
  test(*xiangqi, fen, 4, 149_272);
  test(*xiangqi, fen, 5, 3_513_104);
  test(*xiangqi, fen, 6, 71_287_903);

  fen = "2e1ka3/9/e3H4/4h4/9/9/9/4C4/2p6/2EK5 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, fen, 1, 21);
  test(*xiangqi, fen, 2, 195);
  test(*xiangqi, fen, 3, 3_883);
  test(*xiangqi, fen, 4, 48_060);
  test(*xiangqi, fen, 5, 933_096);
  test(*xiangqi, fen, 6, 12_250_386);

  fen = "1C2ka3/9/C1Hae1h2/p3p3p/6p2/9/P3P3P/3AE4/3p2c2/c1EAK4 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, fen, 1, 30);
  test(*xiangqi, fen, 2, 830);
  test(*xiangqi, fen, 3, 22_787);
  test(*xiangqi, fen, 4, 649_866);
  test(*xiangqi, fen, 5, 17_920_736);

  fen = "ChH1k1e2/c3a4/4ea3/9/2hr5/9/9/4C4/4A4/4KA3 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, fen, 1, 19);
  test(*xiangqi, fen, 2, 583);
  test(*xiangqi, fen, 3, 11_714);
  test(*xiangqi, fen, 4, 376_467);
  test(*xiangqi, fen, 5, 8_148_177);

  print("Perft Test End.\n"); 
}

between_board :: (i: int, j: int) -> u16 {
  xboard: u64 = cast(u64) (1 << i);
  yboard: u64 = cast(u64) (1 << j);
  xboard -= 1;
  yboard |= yboard - 1;
  xboard ^= yboard;
  xboard <<= 1;
  return cast(u16) xboard;
}

between_table: [90][90] u16;

init_between_table :: () {
  for i: 0..8 {
    for j: i+1..8 {
      board := between_board(i, j);
      idx1 := i;
      idx2 := j;
      while idx1 < 89 {
        between_table[idx1][idx2] = board;
        between_table[idx2][idx1] = board;
        idx1 += 9;
        idx2 += 9;
      }
    }
  }

  for i: 0..9 {
    for j: i+1..9 {
      board := between_board(i, j) | 0x1;
      idx1 := i * 9;
      idx2 := j * 9;
      for 0..8 {
        between_table[idx1][idx2] = board;
        between_table[idx2][idx1] = board;
        idx1 += 1;
        idx2 += 1;
      }
    }
  }
}

rseedu32: u32 = 0x1517_11_31;

rand_u32 :: () -> u32 {
  rseedu32 ^= rseedu32 << 13;
  rseedu32 ^= rseedu32 >> 17;
  rseedu32 ^= rseedu32 << 5;
  return rseedu32;
}

ZOBRIST: [2][7][90] u32;
TURN_ZOBRIST: u32;

init_zobrist :: () {
  TURN_ZOBRIST = rand_u32();
  for i: 0..1 {
    for j: 0..6 {
      for k: 0..89 {
        ZOBRIST[i][j][k] = rand_u32();
      }
    }
  }
}

pop_hash :: (board_hash: *Board_Hash) -> u32 {
  board_hash.count -= 1;
  return board_hash.info[board_hash.count].hash;
}

add_hash :: (board_hash: *Board_Hash, hash: u32, move: Move32) {
  board_hash.info[board_hash.count].hash = hash;
  board_hash.info[board_hash.count].move = move;
  board_hash.count += 1;
}

mark_previous_move_check :: inline (xiangqi: *Xiangqi) {
  count := xiangqi.hashes.count - 1;
  xiangqi.hashes.info[count].status = .Check;
}

mark_previous_move :: inline (xiangqi: *Xiangqi, status: Status) {
  count := xiangqi.hashes.count - 1;
  xiangqi.hashes.info[count].status = status;
}

set_previous_chase_move :: inline (xiangqi: *Xiangqi, chase_move: Move32) {
  count := xiangqi.hashes.count - 1;
  xiangqi.hashes.info[count].chase_move = chase_move;
}

Board_Hash :: struct {
  count: int;
  info: [1024] Info;
}

Info :: struct {
  hash: u32;
  status: Status;
  move: Move32;
  chase_move: Move32;
}

is_chase :: inline (move: Move32) -> bool {
  piece := move.piece >> 2;
  return is_capture(move) && piece != G && piece != S;
}

// judge relative to the side playing the game.
judge :: (xiangqi: *Xiangqi) -> GameState {
  judge_one :: (hashes: Board_Hash, count: int) -> bool, Violations {
    if count < 0 then {
      return false, .PerpetualIdle;
    }
    
    if hashes.info[count].status == .Cancel then {
      return false, .PerpetualIdle;
    }

    hash := hashes.info[count].hash;

    count -= 2;
    status: Status = 0;
    repeating: bool = false;
    single_chase: bool = true;
    sq: int = -1;
    while count >= 0 {
      if hashes.info[count+1].status == .Cancel || hashes.info[count].status == .Cancel then {
        break;
      }

      if sq != -1 && hashes.info[count+1].move.to == sq {
        sq = hashes.info[count+1].move.from;
      }

      status |= hashes.info[count].status;

      if status == .Chase then {
        if sq == -1 {
          sq = hashes.info[count].move.to;
        }

        if hashes.info[count].move.to != sq then {
          single_chase = false;
        }
      }


      if hash == hashes.info[count].hash then {
        repeating = true;
        break;
      }
      count -= 2;
    }

    if repeating == false then {
      return false, .PerpetualIdle;
    }

    if status == .Check then {
      return true, .PerpetualCheck;
    }
    
    if status == .Chase && single_chase == true then {
      return true, .PerpetualChase;
    }

    return true, .PerpetualIdle;
  }
  
  count := xiangqi.hashes.count - 1;
  success, opps := judge_one(xiangqi.hashes, count);
  if success == false then {
    return .Undecided;
  }

  success=, ours := judge_one(xiangqi.hashes, count-1);
  if success == false then {
    return .Undecided;
  }

  if ours == opps then {
    return .Draw;
  } else if ours > opps then {
    return .Loss;
  } else {
    return .Win;
  }
}

// judge relative to the side playing the game.
judge_ntimes :: (xiangqi: *Xiangqi, ntimes: int) -> GameState, Violations #must {
  judge_one :: (hashes: Board_Hash, count: int, ntimes: int) -> bool, Violations {
    if count < 0 then {
      return false, .PerpetualIdle;
    }
    
    if hashes.info[count].status == .Cancel then {
      return false, .PerpetualIdle;
    }

    hash := hashes.info[count].hash;
    count -= 2;
    status: Status = 0;
    repeating: bool = false;
    single_victim: bool = true;
    sq: int = -1;
    while count >= 0 {
      if hashes.info[count+1].status == .Cancel || hashes.info[count].status == .Cancel then {
        break;
      }

      if sq != -1 && hashes.info[count+1].move.to == sq {
        //print("VICTIM MOVE\n");
        sq = hashes.info[count+1].move.from;
      }

      status |= hashes.info[count].status;

      if status == .Chase then {
        if sq == -1 {
          sq = hashes.info[count].chase_move.to;
          //print("CHASE: %, MOVE: %\n", hashes.info[count+1].chase_move, hashes.info[count+1].move);
        }

        else if sq != -1 && hashes.info[count].chase_move.to != sq then {
          single_victim = false;
        }
      }


      if hash == hashes.info[count].hash then {
        repeating = true;
        ntimes -= 1;
        if ntimes >= 0 then {
          break;
        }
      }
      count -= 2;
    }

    if repeating == false then {
      return false, .PerpetualIdle;
    }

    if status == .Check then {
      return true, .PerpetualCheck;
    }
    
    if status == .Chase then {
      if single_victim == true {
        return true, .PerpetualChase;
      }
    }

    return true, .PerpetualIdle;
  }
  
  count := xiangqi.hashes.count - 1;
  success, opps := judge_one(xiangqi.hashes, count, ntimes);
  if success == false then {
    return .Undecided, opps;
  }

  success=, ours := judge_one(xiangqi.hashes, count-1, ntimes);
  if success == false then {
    return .Undecided, opps;
  }

  print("REPETITION: OURS: [%].    OPPS: [%]\n", ours, opps);
  if ours == opps then {
    return .Draw, ours;
  } else if ours > opps then {
    return .Loss, ours;
  } else {
    return .Win, opps;
  }
}

Violations :: enum {
  PerpetualIdle :: 0;
  PerpetualChase :: 1;
  PerpetualCheck :: 2;
}

GameState :: enum {
  Undecided;
  Win;
  Draw;
  Loss;
}

Status :: enum_flags s32 {
  Idle;
  Cancel;
  Chase;
  Check;
}

init_xiangqi_tables :: () {
  init_zobrist();
  init_rook_magics();
  init_between_table();
  setup_xiangqi_print();
}

setup_xiangqi_print :: inline () {
  context.print_style.struct_printer = xiangqi_printer;
}

Stack :: struct {
  values: [8] s8;
  count:  int;
}

is_empty :: inline (stack: *Stack) -> bool {
  return stack.count <= 0;
}

push :: inline (stack: *Stack, value: s8) {
  stack.values[stack.count] = value;
  stack.count += 1;
}

pop :: inline (stack: *Stack) -> s8 {
  stack.count -= 1;
  return stack.values[stack.count];
}

dir_see :: (xiangqi: *Xiangqi, stack: *Stack, to: int, TABLE: [90] u8, DIR: [] int, code: int, turn: int, bitboard: Bitboard128) {
  bits: u64 = TABLE[to];
  piece_code := (code << 2) | (turn << 1) | 1;
  while bits {
    i := bit_scan_forward(bits);
    bits &= bits - 1;
    from := cast(s8)(to + DIR[i]);
    if is_set(bitboard, from) then {
      continue;
    }

    if xiangqi.board[from] == piece_code then {
      push(stack, from);
    }
  }
}

ele_see :: (xiangqi: *Xiangqi, stack: *Stack, to: int, TABLE: [90] u8, DIR: [] int, BLOCKS: [] int, code: int, turn: int, bitboard: Bitboard128) {
  bits: u64 = TABLE[to];
  piece_code := (code << 2) | (turn << 1) | 1;
  while bits {
    i := bit_scan_forward(bits);
    bits &= bits - 1;
    blocking := to + BLOCKS[i];

    from := cast(s8) (to + DIR[i]);
    if is_set(bitboard, from) then {
      continue;
    }

    // piece blocking movement.
    if xiangqi.board[blocking] != 0 {
      continue; 
    }

    if xiangqi.board[from] == piece_code then {
      push(stack, from);
    }
  }
}

is_attacked_by_knight :: (xiangqi: *Xiangqi, kni: int, diff: int, from: int, to: int, bitboard: Bitboard128) -> bool {
  bits := cast(u64) KNIGHT_TABLE[kni];
  if diff > 0 {
    bits &= 0xFF;
  } else {
    bits &= 0xFF00;
  }

  while bits {
    i := bit_scan_forward(bits);
    bits &= bits - 1;
    if diff == KNI_DIR[i] then {
      index := kni + KNI_BLK[i];
      if xiangqi.board[index] == 0 || is_set(bitboard, index) then {
        return true;
      }
    }
  }
  return false;
}

kni_see :: (xiangqi: *Xiangqi, stack: *Stack, to: int, turn: int, bitboard: Bitboard128) {
  for kni : xiangqi.pieces[turn].kni {
    if is_set(bitboard, kni) then {
      continue;
    }

    abs_diff, diff := index_abs_diff(to, kni);
    if abs_diff > 19 then {
      continue;
    }
  
    if is_attacked_by_knight(xiangqi, kni, diff, kni, to, bitboard) then {
      push(stack, cast(s8) kni);
    }
  }
}

sliding_see :: (pieces: Array_u8, stack: *Stack, arr: [2] u64, to: int, count: int, bitboard: Bitboard128) {
  for sq : pieces {
    if is_set(bitboard, sq) then {
      continue;
    }

    between, r := get_table_entry(sq, to);
    p := popcount(arr[r] & between);
    move: Move32;
    move.from = xx sq;
    move.to = xx to;
    if p == count then {
      push(stack, cast(s8) sq);
    }
  }
}

// static exchange evaluation. SEE.
// todo: maybe this function should handle pins also.
see :: (xiangqi: *Xiangqi, move: Move32) -> int {

  get_attackers :: (xiangqi: *Xiangqi, stack: *Stack, flags: SEE_Flags, turn: int, to: int, arr: [2] u64, bitboard: Bitboard128, flying_general: bool) -> int, SEE_Flags {
    if !is_empty(stack) {
      sq := pop(stack);
      return sq, flags;
    }

    if flags & .Adv then {
      dir_see(xiangqi, stack, to, DEFENSE_SQ_TABLE, ADV_DIR, 1, turn, bitboard);
      flags &= ~.Adv;
      if !is_empty(stack) {
        sq := pop(stack);
        return sq, flags;
      }
    }

    if flags & .Ele then {
      ele_see(xiangqi, stack, to, DEFENSE_SQ_TABLE, ELE_DIR, ADV_DIR, 2, turn, bitboard);
      flags &= ~.Ele;
      if !is_empty(stack) {
        sq := pop(stack);
        return sq, flags;
      }
    }

    if flags & .Pawn then {
      dir_see(xiangqi, stack, to, KP_TABLE[turn ^ 1], KING_DIR, 6, turn, bitboard);
      flags &= ~.Pawn;
      if !is_empty(stack) {
        sq := pop(stack);
        return sq, flags;
      }
    }

    if flags & .Cannon then {
      sliding_see(xiangqi.pieces[turn].cannon, stack, arr, to, 3, bitboard);
      flags &= ~.Cannon;
      if !is_empty(stack) {
        sq := pop(stack);
        return sq, flags;
      }
    }
 
    if flags & .Knight then {
      kni_see(xiangqi, stack, to, turn, bitboard);
      flags &= ~.Knight;
      if !is_empty(stack) {
        sq := pop(stack);
        return sq, flags;
      }
    }

    if flags & .Rook then {
      sliding_see(xiangqi.pieces[turn].rook, stack, arr, to, 2, bitboard);
      flags &= ~.Rook;
      if !is_empty(stack) {
        sq := pop(stack);
        return sq, flags;
      }
    }

    if flags & .King then {
      flags &= ~.King;
      dir_see(xiangqi, stack, to, KP_TABLE[turn], KING_DIR, 0, turn, bitboard);
      if !is_empty(stack) {
        sq := pop(stack);
        return sq, flags;
      }
    }

    if flying_general == true then {
      sliding_see(xiangqi.pieces[turn].king, stack, arr, to, 2, bitboard);
      while !is_empty(stack) {
        sq := pop(stack);
        if is_set(bitboard, sq) {
          continue;
        }
        return sq, flags;
      }
    }

    return -1, flags;
  }

  // values for SEE algorithm.
  VALUES :: int.[50000, 200, 200, 400, 800, 450, 200];

  // SQUARES
  turn: int = xiangqi.turn;
  from: int = move.from;
  to: int = move.to;

  if xiangqi.board[to] != 0 && VALUES[xiangqi.board[to] >> 2] > VALUES[xiangqi.board[from] >> 2] then {
    return VALUES[xiangqi.board[to] >> 2];
  }

  ours: SEE_Flags = SEE_TABLE[SQUARES[turn][to]] | SEE_Flags.Attacking;
  opps: SEE_Flags = SEE_TABLE[SQUARES[turn ^ 1][to]] | SEE_Flags.Attacking;
  row := to % 9;
  col := to / 9;
  occ_row: u64 = xiangqi.rows[col];
  occ_col: u64 = xiangqi.cols[row];
  arr: [2] u64 = .[occ_row, occ_col];
  arr[0] |= cast(u64)(1 << row);
  arr[1] |= cast(u64)(1 << col);
  our_stack: Stack;
  opp_stack: Stack;
  flying_general := false;

  piece_code := xiangqi.board[from] >> 2;
  bitboard: Bitboard128;

  gain: [16] int;

  vic := xiangqi.board[to];
  if vic != 0 then {
    gain[0] = VALUES[vic >> 2];
  } else {
    gain[0] = 0;
  }

  d := 0;
  while true {
    d += 1;
    turn ^= 1;

    gain[d] = VALUES[piece_code] - gain[d-1];
    // prune.
    if max(-gain[d-1], gain[d]) < 0 then {
      break; 
    }

    if piece_code == 1 then {
      // search for possible discovery knight.
      ours |= .Knight;
      opps |= .Knight;
    } else if piece_code == 5 {
      // search for possible cannon battery.
      ours |= .Cannon;
      opps |= .Cannon;
    } else if piece_code == 6 {
      // search for possible rook battery.
      ours |= .Rook;
      opps |= .Rook;
    } else if piece_code == 0 then {
      flying_general = true;
    }

    stack_to_pop := ifx turn == xiangqi.turn then *our_stack else *opp_stack;
    flags := ifx turn == xiangqi.turn then ours else opps;
    // consider x-rays
    // from.
    set_bit(*bitboard, from);
    from_r := from % 9;
    from_c := from / 9;

    // make sure this is not a diagonal capture.

    if from_r != row && from_c == col then {
      arr[0] ^= cast(u64)(1 << from_r);
    } 

    if from_c != col && from_r == row {
      arr[1] ^= cast(u64)(1 << from_c);
    }

    // get the next attacker.
    from, flags= = get_attackers(xiangqi, stack_to_pop, flags, turn, to, arr, bitboard, flying_general);
    if turn == xiangqi.turn then {
      ours = flags;
    } else {
      opps = flags;
    }
    
    if from == -1 then break;
    piece_code = xiangqi.board[from] >> 2;
  }

  for < i: d-2..0 {
    gain[i] = -max(-gain[i], gain[i+1]);
  }

  return gain[0];
}

Bitboard128 :: struct {
  board: [2] u64;
}

set_bit :: inline (bitboard: *Bitboard128, bit: int) {
  index := bit / 64;
  bit_index := bit % 64;
  bitboard.board[index] |= cast(u64) (1 << bit_index);
}

is_set :: inline (bitboard: Bitboard128, bit: int) -> bool {
  index := bit / 64;
  bit_index := bit % 64;
  return (bitboard.board[index] & cast(u64) (1 << bit_index)) != 0;
}

is_chase :: (xiangqi: *Xiangqi) -> bool, chase_move: Move32 #must {

  mvv_lva :: (move: Move32) -> s32 {
    victim := move.capture >> 2;
    attack := move.piece   >> 2;
    TABLE :: s32.[1000, 120, 120, 270, 600, 350, 30];
    return TABLE[victim] - (TABLE[attack] / 100);
  }

  sort :: (moves: *Moves) {
    i := 0;
    while i < moves.count {
      move := moves.array[i].move;
      moves.array[i].score = mvv_lva(move);
      i += 1;
    }

    for i: 0..moves.count-1 {
      for j: i+1..moves.count-1 {
        if moves.array[i].score < moves.array[j].score then {
          move_swap(moves, i, j);
        }
      }
    }
  }

  // is king-pawn move.
  is_kp :: inline (move: Move32) -> bool {
    piece_code := move.piece >> 2;
    return piece_code == 0 || piece_code == 6;
  }

  make_null_move(xiangqi);
  defer {
    unmake_null_move(xiangqi);
  }


  moves: Moves;
  gen_captures(xiangqi, *moves);
  sort(*moves);
  att := attackers(xiangqi);
  for move : moves {

    // prune out all king-pawn moves. if king or pawn is chasing, it should be classified as an 'idle' rather than a chase.
    // since king-pawn is allowed to chased with other pieces, and king-pawn can chase alone
    if is_kp(move) then {
      continue;
    }

    if !is_legal(xiangqi, att, move) then {
      continue;
    }

    // positive SEE = chase.
    if see(xiangqi, move) > 0 then {
      return true, move;
    }
  }

  return false, NULL_MOVE;
}



#import "Basic";
#import "String";
