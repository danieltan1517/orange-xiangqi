main :: () {
  board: [9][10] s8;
  advisor_moves(4, 1, board);
  advisor_moves(5, 2, board);
  advisor_moves(3, 0, board);
  advisor_moves(3, 2, board);
}

Move32 :: struct {
  from: s8;
  to: s8;
  capture: s8;
  piece: s8;
  #place from;
  #as move: s32;
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

  // horizontal row movements.
  bits1 := 1 << row;
  bits1 = (bits1 << 1) | (bits1 >> 1);
  bits1 &= row_mask;

  // vertical row movements.
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
