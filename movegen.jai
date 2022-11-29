main :: () {
  row := s8.[1, 0, 1,
             1, 0, 1, 
             1, 0, 1];
  val := row_bits(row);
  print("%\n", formatInt(val, 2));

  col := s8.[1, 1, 1,
             1, 1, 1, 
             1, 1, 0, 1];
  val = col_bits(col);
  print("%\n", formatInt(val, 2));
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

#import "Basic";
