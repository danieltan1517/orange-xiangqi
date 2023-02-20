
xiangqi: Xiangqi;

debug := false;

test_move_gen1 :: () {
    print("Testing move generation 1...\n");
    reset_temporary_storage();
    handle_command("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1 moves h2e2 h7e7", *xiangqi);
    if (debug) print_board(*xiangqi);
    move := search(*xiangqi, 3);
    tmp := u8.[0,0,0,0];
    if (debug) print("Best move for Red: %1\n", to_string(move, tmp));
    make_move(*xiangqi, move);
    if (debug) print_board(*xiangqi);

    move2 := search(*xiangqi, 3);
    tmp2 := u8.[0,0,0,0];
    if (debug) print("Best move for Black: %1\n", to_string(move2, tmp2));
    make_move(*xiangqi, move2);
    if (debug) print_board(*xiangqi);
}


test_general_move :: () {
    print("Testing general move generation...\n");
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
                        "e0", string.["e0e1"]);
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/4K4/RNBA1ABNR w - - 0 1",
                        "e1", string.["e1d1", "e1e0", "e1e2", "e1f1"]);
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C1K3C1/9/RNBA1ABNR w - - 0 1",
                        "d2", string.["d2d1", "d2e2"]);                        
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C3K1C1/9/RNBA1ABNR w - - 0 1",
                        "f2", string.["f2e2", "f2f1"]);                   
}

test_advisor_move :: () {
    print("Testing advisor move generation...\n");
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
                        "d0", string.["d0e1"]);
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
                        "f0", string.["f0e1"]);
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C1A3C1/4A4/RNB1K1BNR w - - 0 1",
                        "d2", string.[]);
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C1A3C1/4A4/RNB1K1BNR w - - 0 1",
                        "e1", string.["e1d0", "e1f0", "e1f2"]);
}

test_cannon_move :: () {
    print("Testing cannon move generation...\n");
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
                        "b2", string.["b2a2","b2b1","b2b3","b2b4","b2b5","b2b6","b2b9","b2c2","b2d2","b2e2","b2f2","b2g2"]);
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
                        "h2", string.["h2c2","h2d2","h2e2","h2f2","h2g2","h2h1","h2h3","h2h4","h2h5","h2h6","h2h9","h2i2"]);
}

test_rook_move :: () {
    print("Testing rook move generation...\n");
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
                        "a0", string.["a0a1","a0a2"]);
}

test_elephant_move :: () {
    print("Testing elephant move generation...\n");
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
                        "c0", string.["c0a2","c0e2"]);
}

test_knight_move :: () {
    print("Testing knight move generation...\n");
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
                        "b0", string.["b0a2","b0c2"]);
    test_one_piece_move("position fen rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/2N1C2C1/9/R1BAKABNR w - - 0 1",
                        "c2", string.["c2a1","c2b0","c2e1"]);
}

main :: () {
    print("Unit Test for Xiangqi UCCI Engine\n");
    print("---------------------------------\n");
    
    test_move_gen1();
    test_general_move();
    test_advisor_move();
    test_cannon_move();
    test_rook_move();
    test_elephant_move();
    test_knight_move();

    print("Done.\n");
}

str2pos :: (str: string) -> u8, u8 #expand {
    row := str[0] - #char "a";
    col := str[1] - #char "0";
    return row, col;
}


bubble_sort :: (arr: *Moves, compare_code: Code) #expand {
  for 0..arr.count-1 {
    for i: 1..arr.count-1 {
      a := arr.array[i-1];
      b := arr.array[i];
      if !(#insert,scope() compare_code) {
        t := arr.array[i];
        arr.array[i] = arr.array[i-1];
        arr.array[i-1] = t;
      }
    }
  }
}


test_one_piece_move :: (fen: string, piece: string, expected_moves: []string) {
    reset_temporary_storage();
    handle_command(fen, *xiangqi);
    if (debug) print_board(*xiangqi);
    moves: Moves;
    tmp := u8.[0,0,0,0];

    turn := xiangqi.turn;
    piece_array := *xiangqi.pieces[turn];
    row, col := str2pos(piece);

    generate_moves_for_piece(*xiangqi, *moves, row, col);
    bubble_sort(*moves, #code (a.to < b.to));
    for move: moves {
        print("  %1", to_string(move, tmp));
        if (debug) print("\n");
        make_move(*xiangqi, move);
        if (debug) print_board(*xiangqi);
        unmake_move(*xiangqi, move);
    }
    if (moves.count == 0) {
        print("  no moves\n");
    }
    print("\n");

    if (moves.count != expected_moves.count) {
        print("Error: move count is not %1.\n", expected_moves.count);
        print("expected moves: %.\n", expected_moves);
        return;
    }
    
    for i: 0..moves.count-1 {
        if (to_string(moves.array[i], tmp) != expected_moves[i]) {
            print("Error, not match with expected moves.\n");
            print("expected moves: %.\n", expected_moves);
            return;
        }
    }
}


#import "Basic";
#import "String";
#import "Math";
#load "search.jai";
#load "cmdio.jai";