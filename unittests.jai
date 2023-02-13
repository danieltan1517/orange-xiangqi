
xiangqi: Xiangqi;

test_move_gen1 :: () {
    reset_temporary_storage();
    handle_command("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1 moves h2e2 h7e7", *xiangqi);
    print_board(*xiangqi);
    move := search(*xiangqi, 3);
    tmp := u8.[0,0,0,0];
    print("Best move for Red: %1\n", to_string(move, tmp));
    make_move(*xiangqi, move);
    print_board(*xiangqi);

    move2 := search(*xiangqi, 3);
    tmp2 := u8.[0,0,0,0];
    print("Best move for Black: %1\n", to_string(move2, tmp2));
    make_move(*xiangqi, move2);
    print_board(*xiangqi);
}

main :: () {
    print("Unit Test for Xiangqi UCCI Engine\n");
    print("---------------------------------\n");
    
    test_move_gen1();

    print("Done.\n");
}

#import "Basic";
#import "String";
#import "Math";
#load "search.jai";
#load "cmdio.jai";