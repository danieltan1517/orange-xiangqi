main :: () {
  board: [9][10] s8;
  //advisor_moves(4, 1, board);
  //advisor_moves(5, 2, board);
  //advisor_moves(3, 0, board);
  //advisor_moves(3, 2, board);
  //advisor_moves(4, 8, board);
  elephant_moves(2, 0, board);
  elephant_moves(6, 4, board);
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

index_of :: (row: s8, col: s8) -> s8 #expand {
  return (row << 4) | col;
}

row_of :: (index: s8) -> s8 #expand {
  return index >> 4;
}

col_of :: (index: u8) -> u8 #expand {
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
