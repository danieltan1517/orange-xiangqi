main :: () {
  xiangqi_startpos(*xiangqi);
  print_board(*xiangqi);
  while true {
    reset_temporary_storage();
    str := getline();
    if handle_command(str, *xiangqi) { break; }
  }
}

xiangqi: Xiangqi;

#import "Basic";
#import "String";
#import "Math";
#load "search.jai";
#load "cmdio.jai";


