main :: () {
  xiangqi := xiangqi_startpos();
  
}

xiangqi_startpos :: () -> Xiangqi {
  xiangqi: Xiangqi;
  add_piece(*xiangqi, 0, 0, 4);
  return xiangqi;

  add_piece :: (xiangqi: *Xiangqi, piece: s8, side: s8, row: s8, col: s8) {
    piece_code := encode_piece(piece, side);
    xiangqi.board_9x10[row][col] = piece_code;
    xiangqi.board_10x9[col][row] = piece_code;
    xiangqi.pieces[side].piece[piece] = index_of(row, col);
  }
}

encode_piece :: (piece: s8, side: s8) -> s8 #expand {
  return (piece << 2) | (side << 1) | 1;
}

print_board :: (xiangqi: Xiangqi) {
  for row: board_10x9 {
    for piece: row {
    }
  }
}

Xiangqi :: struct {
  board_9x10: [9][10] s8;
  board_10x9: [10][9] s8;
  pieces: [2] Pieces;
  #place pieces;
  red: Pieces;
  black: Pieces;
  turn: s8;
}

Move32 :: struct {
  from: s8;
  to: s8;
  capture: s8;
  piece: s8;
  #place from;
  #as move: s32;
}

Pieces :: struct {
/*
  general: s8;
  advisors: Array(2, s8);
  elephants: Array(2, s8);
  knights: Array(2, s8);
  cannons: Array(2, s8);
  rook: Array(2, s8);
  soldier: Array(5, s8); 
*/
  general:   Array(7, s8);
  advisors:  Array(7, s8);
  elephants: Array(7, s8);
  knights:   Array(7, s8);
  cannons:   Array(7, s8);
  rook:      Array(7, s8);
  soldier:   Array(7, s8); 

  #place general;
  piece: [7] Array(7, s8);
}

G :: 0; // general
A :: 1; // advisor
E :: 2; // elephant
H :: 3; // horse / knight
R :: 4; // rook / chariot
C :: 5; // cannon
S :: 6; // soldier

RED :: 0;   // red goes first...
BLACK :: 2; // black goes second...

NONE :: 0;
OCCUPIED :: 1;

Array :: struct(capacity: int, T: Type) {
  count: s8;
  array: [capacity] T;
}

append :: (a: *Array($N, $T), item: T) #expand {
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

general_moves :: (row: s8, col: s8, board: [9][10] s8) {
  row_mask :: 0b000_111_000;
  col_mask :: 0b111_00_00_111;
  piece := board[row][col];
  print("from (%,%)\n", row, col);

  // horizontal row movements.
  bits := 1 << row;
  bits = (bits << 1) | (bits >> 1);
  bits &= row_mask;
  while bits {
    row_to: s8;
    #asm BMI1 {
      bsf row_to, bits; 
      blsr bits, bits;
    }
    from := index_of(row, col);
    to := index_of(row_to, col);
    capture := board[row_to][col];
    move := Move32.{from, to, capture, piece};
    print("to (%,%)\n", row_of(move.to), col_of(move.to));
  } 

  // vertical row movements.
  bits = 1 << col;
  bits = (bits << 1) | (bits >> 1);
  bits &= col_mask;
  while bits {
    col_to: s8;
    #asm BMI1 {
      bsf col_to, bits; 
      blsr bits, bits;
    }
    from := index_of(row, col);
    to := index_of(row, col_to);
    capture := board[row][col_to];
    move := Move32.{from, to, capture, piece};
    print("to (%,%)\n", row_of(move.to), col_of(move.to));
  } 

}

advisor_moves :: (row: s8, col: s8, board: [9][10] s8) {
  row_mask :: 0b000_111_000;
  col_mask :: 0b111_00_00_111;
  piece := board[row][col];
  print("from (%,%)\n", row, col);

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
      from := index_of(row, col);
      to := index_of(row_to, col_to);
      capture := board[row_to][col_to];
      move := Move32.{from, to, capture, piece};
      print("to (%,%)\n", row_of(move.to), col_of(move.to));
    }
  }

}

elephant_moves :: (row: s8, col: s8, board: [9][10] s8) {
  print("from (%,%)\n", row, col);
  row_mask :: 0b1_1111_1111;
  col_mask :: 0b_00000_11111;
  // col_mask :: 0b_11111_00000;

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
        from := index_of(row, col);
        to := index_of(row_to2, col_to2);
        capture := board[row_to2][col_to2];
        move := Move32.{from, to, capture, piece};
        //print("to (%,%)\n", formatInt(row_of(move.to), 2), formatInt(col_of(move.to),2));
        //print("to (%,%)\n", row_of(move.to), col_of(move.to));
        print("to (%,%)\n", row_to2, col_to2);
      }
    }
  }
}

soldier_moves :: (row: s8, col: s8, board: [9][10] s8) {
  // TODO: Make sure BSF works correctly...
  print("from (%,%)\n", row, col);
  row_mask :: 0b1_1111_1111;
  // col_mask :: 0b_00000_11111;
  // row >= 1 && row <= 6
  // col_mask :: 0b_00011_11110;
  col_mask :: 0b_01111_11000;
  horizontal_mask :: 0b_11111_00000;
  col_bit := 1 << col;
  piece := board[row][col];

  if col_bit & col_mask {
    from := index_of(row, col);
    col_to := col + 1;
    to := index_of(row, col_to);
    capture := board[row][col_to];
    move := Move32.{from, to, capture, piece};
    print("to (%,%)\n", row, col_to);
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
      from := index_of(row, col);
      to := index_of(row_to, col);
      capture := board[row_to][col];
      move := Move32.{from, to, capture, piece};
      print("to (%,%)\n", row_to, col);
    }
  }
}

knight_moves :: (row: s8, col: s8, board: [9][10] s8) {

}

index_of :: (row: s8, col: s8) -> s8 #expand {
  return (row << 4) | col;
}

row_of :: (index: s8) -> s8 #expand {
  return index >> 4;
}

col_of :: (index: s8) -> s8 #expand {
  return index & 0xF;
}

row_bits :: (row: [9] s8) -> u64 {
  data := row.data;
  value: u64;
  #asm BMI2 {
    mov.q  value, [data];
    mov.q  reg1: gpr, [data + 1];
    mov.q  mask0: gpr, 0x0101_0101_0101_0101;
    mov.q  mask1: gpr, 0x0100_0000_0000_00FF;
    pext.q value, value, mask0;
    pext.q reg1, reg1, mask1;
    and.q  reg1, 0x100;
    or.q   value, reg1;
  } 

  return value;
}

col_bits :: (col: [10] s8) -> u64 {
  data := col.data;
  value: u64;
  #asm BMI2 {
    mov.q  value, [data];
    mov.q  reg1: gpr, [data + 2];
    mov.q  mask0: gpr, 0x0101_0101_0101_0101;
    mov.q  mask1: gpr, 0x0100_0000_0000_01FF;
    pext.q value, value, mask0;
    pext.q reg1, reg1, mask1;
    and.q  reg1, 0x200;
    or.q   value, reg1;
  } 

  return value;
}

max :: (a: int, b: int) -> int {
  c: int;
  #asm {
    cmp a, b;
    mov c, a;
    cmovle c, b;
  }
  return c;
}

min :: (a: int, b: int) -> int {
  c: int;
  #asm {
    cmp a, b;
    mov c, a;
    cmovge c, b;
  }
  return c;
}

#import "Basic";
