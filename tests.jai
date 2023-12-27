// automated testing for SEE

#import "Math";
#load "board.jai";

total := 0;
success := 0;

main :: () {
  init_xiangqi_tables();

  see_test :: (fen: string, token: string, expected: int) {
    xiangqi: Xiangqi;
    xiangqi_fen(*xiangqi, fen);
    move := to_move32(*xiangqi, token);
    see_score := see(*xiangqi, move);
    total += 1;
    if see_score != expected then {
      print("-----------------------------\n");
      print("Error. Expected %. Got %\n", expected, see_score);
      print("%\n", xiangqi);
      print("MOVE: %.  FEN: %\n", token, to_fenstring(*xiangqi));
      print("-----------------------------\n");
    } else {
      success += 1;
    }
  }

  protection_test :: (fen: string, token: string, expected: bool) {
    xiangqi: Xiangqi;
    xiangqi_fen(*xiangqi, fen);
    move := to_move32(*xiangqi, token);
    value := is_protected(*xiangqi, move);
    total += 1;
    if value != expected then {
      print("-----------------------------\n");
      print("Error. Expected %. Got %\n", expected, value);
      print("%\n", xiangqi);
      print("MOVE: %.  FEN: %\n", token, to_fenstring(*xiangqi));
      print("-----------------------------\n");
    } else {
      success += 1;
    }
  }

  /*print("SEE Tests.\n");
  print("------------------------\n");
  see_test("2eak1er1/4a4/2h1c2ch/p1p1p1p2/8R/1R7/P1P1PrP2/2H1CCH2/4A4/2EAK1E2 b", "f3g3", 200);
  see_test("4kae2/4a4/4e1hC1/2H1p1p2/8p/P4HP2/4h4/4C4/4A4/2E1KAE1c b", "i5i4", 0);
  see_test("r2akae1r/3h5/2c1e1hc1/p1p1p1p1p/9/1HP6/P3P1P1P/1C2E1HC1/9/R2AKAE1R b", "g6g5", 0);
  see_test("4kae2/4a4/4e1hC1/2H1p1H2/9/P5P1p/4h4/4C4/4A4/2E1KAE1c b", "i4i3", 0);
  see_test("5k3/4a4/3a5/9/1P2H4/9/7p1/3KC2h1/4A3c/2E2A3 b", "h3g3", 0);
  see_test("2eakaer1/9/h3cc3/p8/9/4R1P2/P3pr2P/H2CE1H2/4A4/2EAK1C2 b",  "e3e2", 0);
  see_test("R4a3/3ka4/9/6p2/9/8r/P1h1P4/3C1R2C/2c2K3/3A2r2 b", "g0g1", 0);
  see_test("1r2ka1R1/4a4/4H4/ph3R2p/6p2/4c4/P7P/4C1r2/4A4/2EAK1E2 w", "h9f9", -400);
  see_test("3akae2/rr7/1h2e4/2p1p1H1H/9/3R2P1P/p2R5/3CE2C1/9/3AKAE2 w", "d4d9", 200);
  see_test("3a5/3Hak3/4e4/4p3p/9/2P1P4/4h3P/5rhR1/4K1C2/2EA2E2 b", "f2f1", 0);
  see_test("3a5/3Hak3/4e4/4p3p/9/2P1P4/8P/5rhR1/4K1C2/2EA2E2 b", "f2f1", 0);
  see_test("r1e1ka3/1R2a4/h2ce4/2p1C1p2/p7r/2P3P2/P3P3P/9/9/2EAKAER1 w",  "b8e8", -600);
  see_test("2Rak1e2/4ah3/4c4/p7p/5r3/4h1P2/P1P1r3P/4C1H2/9/1REAKAE2 b", "e3e2", -400);
  see_test("1C2k4/3PaR3/e8/p5h1p/9/4P4/P5P1P/3Ac1H2/9/1H1A1K3 w", "d8e8", 0);
  see_test("4k1e2/3R1R3/4e1r2/p3p3p/9/7r1/P7P/H3E4/4A4/2E1Kc3 w", "f8e8", 0);
  see_test("C1eak4/2R1a4/4Rc3/3r3rp/6p2/pp1h5/h3P3P/C3E1H2/4A4/3AK1E2 w", "c8e8", -600);
  see_test("2ek5/4a4/9/6HRp/3rH4/9/4P3P/4E4/9/1cEAK4 b", "d5d0", 200);
  see_test("2ek5/4a4/9/6HRp/3rH4/9/4P3P/4E4/9/2EAK4 b", "d5d0", 200);
  see_test("2ek5/4a4/9/6HRp/4H4/9/4P3P/4E4/9/1cEAK4 b", "b0d0", 200);
  see_test("4ka3/4a4/9/4p4/p1p3e2/4r4/c1P6/8R/4Ap3/4K4 b", "f1e1", 200);
  see_test("1hea1k3/4c1Hh1/9/5C3/2p6/P3R4/5r2P/9/4Ap3/2EAK1E2 b", "f1f0", -200);
  see_test("3ck4/1R2aH3/e8/p3R4/9/9/P8/4p4/4Ap3/4KA1r1 w", "b8e8", 200);
  see_test("3c1k3/4RH3/e8/p3R4/9/9/P8/4p4/4Ap3/4KA1r1 w", "e8e9", 0);
  see_test("4k1e2/5c3/3a1a3/p8/2e6/4H4/9/9/4K2h1/9 b", "h1f2", 0);
  see_test("2e1kae2/4a4/2h6/3R2p1p/p1H6/1c3hP2/2P1r4/4C4/4A4/2E1KAR2 w", "c5d7", -200);
  see_test("1R3ae2/3kaR3/4ec2h/p1p1r1p2/3H4p/6P2/2Pr4P/3C5/4A4/2E1KAE2 w", "d5c7", -400);
  see_test("2ea3r1/5k3/4eaR2/5H2p/p4C3/4P4/h7P/4E4/4A4/2EAK4 w", "g7f7", 200);
  see_test("5kC2/3R5/4c1h2/p5p1p/2P1H4/P5P1P/9/4p4/4A4/2EAKh2r b", "e2e1", 0);
  see_test("4k1e2/3PaR3/9/9/2e6/9/9/8p/5K3/4r4 w", "d8e8", 0);
  see_test("C4a3/3ka1c2/eHR1e4/8p/3rC1p2/4h4/P5P1P/4E4/4A4/1cEAK4 w", "c7c5", -800);
  see_test("2eak1e2/4a4/2R6/p3p4/6r1p/9/P4h2P/H3E4/3C1C3/1RE1KA1r1 b", "h0f0", -600);
  see_test("3R5/1C3k3/3P5/9/9/8P/5p3/4E4/4K4/2Er4c w", "d7d8", 0);
  see_test("2ek5/4R4/9/8p/2e6/9/3hCr2P/4EH3/3p1K3/9 b", "d1e1", -200);
  see_test("9/1H1ka2H1/5a3/3P5/2e6/c8/1p7/8E/9/2EAKA3 w", "d6d7", -200);
  see_test("2eakc3/3Ra2R1/h3e4/p3C3p/2p1P4/9/P5r1P/5A3/3K4c/5r3 w", "h8e8", -400);
  see_test("2ea1k3/4a4/4e4/3R4p/p1P3p2/3h1C2P/9/c1hr2H2/1c2K4/2E2AE2 b", "d2e2", -800);
  see_test("3akae2/9/4e4/p8/9/9/3R5/4rA3/r3A4/3RK4 w", "d3d9", 200);
  see_test("1Ccak1e2/3RaR3/5c3/p3r4/2e3p2/2P6/P3r4/4E3H/9/3AKAE2 w", "f8e8", -600);
  see_test("3aka3/4r4/4R4/p7p/2p3p2/4C4/P3R1P2/4E4/4A4/4KAE2 w", "e4e8", 400);
  see_test("9/3ka2H1/4h4/5C3/5C3/9/9/9/4A4/4K4 w", "h8f9", -400);
  see_test("9/3ka2H1/4ha3/5C3/5C3/9/9/9/4A4/4K4 w", "h8f9", -200);
  see_test("rnba1abnr/3k5/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/NC5C1/4A4/R1B1KABNR w", "e0d0", -50000);
  see_test("r1Na1a3/3k1n3/2n1b4/p1p1p1p1p/4c4/6P2/P1P2R2P/1CcC5/9/2BAKAB2 b", "d8d7", -50000);
  see_test("C1nNk4/9/9/9/9/9/n1p6/B3C4/3pA4/4K4 w", "e0d0", -50000);
  see_test("4k4/9/4b4/9/7P1/6P2/9/9/6R2/4K4 w - - 0 1", "g4g5", 0);
  see_test("4k4/9/4b4/9/7P1/6P2/9/9/6R2/4K4 w - - 0 1", "h5g5", 0);
  see_test("4k4/6n2/4b4/9/7P1/6P2/9/9/6R2/4K4 b - - 0 1", "g8h6", -400);
  see_test("4k4/9/9/4p4/9/9/9/9/3pA4/2pAK4 b - - 0 1", "c0d0", 0);
  print("% out of % tests successful\n", success, total);
  print("------------------------\n");*/

  success = 0;
  total = 0;
  print("Protection Tests.\n");
  print("------------------------\n");
  protection_test("2eak1er1/4a4/2h1c2ch/p1p1p1p2/8R/1R7/P1P1PrP2/2H1CCH2/4A4/2EAK1E2 b", "f3g3", false);
  protection_test("4kae2/4a4/4e1hC1/2H1p1p2/8p/P4HP2/4h4/4C4/4A4/2E1KAE1c b", "i5i4", false);
  protection_test("4kae2/4a4/4e1hC1/2H1p1p2/8p/P4HP2/4h4/4C4/4A4/2E1KAE1c b", "g6g5", true);
  protection_test("4k4/6n2/4b4/9/7P1/6P2/9/9/6R2/4K4 b - - 0 1", "g8h6", true);
  protection_test("4k4/9/4b4/9/7P1/6P2/9/9/6R2/4K4 w - - 0 1", "g4g5", false);
  protection_test("4k4/9/4b4/9/7P1/6P2/9/9/6R2/4K4 w - - 0 1", "h5g5", false);
  protection_test("9/3ka2H1/4h4/5C3/5C3/9/9/9/4A4/4K4 w", "h8f9", true);
  protection_test("9/3ka2H1/4ha3/5C3/5C3/9/9/9/4A4/4K4 w", "h8f9", true);
  protection_test("C1nNk4/9/9/9/9/9/n1p6/B3C4/3pA4/4K4 w", "e0d0", true);
  protection_test("r2akae1r/3h5/2c1e1hc1/p1p1p1p1p/9/1HP6/P3P1P1P/1C2E1HC1/9/R2AKAE1R b", "g6g5", false);
  protection_test("4kae2/4a4/4e1hC1/2H1p1H2/9/P5P1p/4h4/4C4/4A4/2E1KAE1c b", "i4i3", false);
  protection_test("5k3/4a4/3a5/9/1P2H4/9/7p1/3KC2h1/4A3c/2E2A3 b", "h3g3", false);
  protection_test("2eakaer1/9/h3cc3/p8/9/4R1P2/P3pr2P/H2CE1H2/4A4/2EAK1C2 b",  "e3e2", true);
  protection_test("R4a3/3ka4/9/6p2/9/8r/P1h1P4/3C1R2C/2c2K3/3A2r2 b", "g0g1", false);
  protection_test("1r2ka1R1/4a4/4H4/ph3R2p/6p2/4c4/P7P/4C1r2/4A4/2EAK1E2 w", "h9f9", true);
  protection_test("r1e1ka3/1R2a4/h2ce4/2p1C1p2/p7r/2P3P2/P3P3P/9/9/2EAKAER1 w",  "b8e8", true);
  protection_test("2Rak1e2/4ah3/4c4/p7p/5r3/4h1P2/P1P1r3P/4C1H2/9/1REAKAE2 b", "e3e2", true);
  protection_test("2e1kae2/4a4/2h6/3R2p1p/p1H6/1c3hP2/2P1r4/4C4/4A4/2E1KAR2 w", "c5d7", false);
  protection_test("1R3ae2/3kaR3/4ec2h/p1p1r1p2/3H4p/6P2/2Pr4P/3C5/4A4/2E1KAE2 w", "d5c7", false);
  protection_test("C1eak4/2R1a4/4Rc3/3r3rp/6p2/pp1h5/h3P3P/C3E1H2/4A4/3AK1E2 w", "c8e8", false);
  protection_test("C4a3/3ka1c2/eHR1e4/8p/3rC1p2/4h4/P5P1P/4E4/4A4/1cEAK4 w", "c7c5", false);
  protection_test("3akae2/rr7/1h2e4/2p1p1H1H/9/3R2P1P/p2R5/3CE2C1/9/3AKAE2 w", "d4d9", false);
  protection_test("3a5/3Hak3/4e4/4p3p/9/2P1P4/4h3P/5rhR1/4K1C2/2EA2E2 b", "f2f1", false);
  protection_test("3a5/3Hak3/4e4/4p3p/9/2P1P4/8P/5rhR1/4K1C2/2EA2E2 b", "f2f1", false);
  protection_test("1C2k4/3PaR3/e8/p5h1p/9/4P4/P5P1P/3Ac1H2/9/1H1A1K3 w", "d8e8", true);
  protection_test("4k1e2/3R1R3/4e1r2/p3p3p/9/7r1/P7P/H3E4/4A4/2E1Kc3 w", "f8e8", false);
  protection_test("2ek5/4R4/9/8p/2e6/9/3hCr2P/4EH3/3p1K3/9 b", "d1e1", false);
  protection_test("9/1H1ka2H1/5a3/3P5/2e6/c8/1p7/8E/9/2EAKA3 w", "d6d7", true);
  protection_test("2eakc3/3Ra2R1/h3e4/p3C3p/2p1P4/9/P5r1P/5A3/3K4c/5r3 w", "h8e8", true);
  protection_test("2ea1k3/4a4/4e4/3R4p/p1P3p2/3h1C2P/9/c1hr2H2/1c2K4/2E2AE2 b", "d2e2", false);
  protection_test("1Ccak1e2/3RaR3/5c3/p3r4/2e3p2/2P6/P3r4/4E3H/9/3AKAE2 w", "f8e8", true);
  protection_test("2ek5/4a4/9/6HRp/3rH4/9/4P3P/4E4/9/1cEAK4 b", "d5d0", false);
  protection_test("2ek5/4a4/9/6HRp/3rH4/9/4P3P/4E4/9/2EAK4 b", "d5d0", false);
  protection_test("2ek5/4a4/9/6HRp/4H4/9/4P3P/4E4/9/1cEAK4 b", "b0d0", false);
  protection_test("4ka3/4a4/9/4p4/p1p3e2/4r4/c1P6/8R/4Ap3/4K4 b", "f1e1", false);
  protection_test("3ck4/1R2aH3/e8/p3R4/9/9/P8/4p4/4Ap3/4KA1r1 w", "b8e8", false);
  protection_test("3c1k3/4RH3/e8/p3R4/9/9/P8/4p4/4Ap3/4KA1r1 w", "e8e9", false);
  protection_test("4k1e2/5c3/3a1a3/p8/2e6/4H4/9/9/4K2h1/9 b", "h1f2", false);
  protection_test("2ea3r1/5k3/4eaR2/5H2p/p4C3/4P4/h7P/4E4/4A4/2EAK4 w", "g7f7", false);
  protection_test("5kC2/3R5/4c1h2/p5p1p/2P1H4/P5P1P/9/4p4/4A4/2EAKh2r b", "e2e1", true);
  protection_test("4k1e2/3PaR3/9/9/2e6/9/9/8p/5K3/4r4 w", "d8e8", true);
  protection_test("3R5/1C3k3/3P5/9/9/8P/5p3/4E4/4K4/2Er4c w", "d7d8", false);
  protection_test("3akae2/9/4e4/p8/9/9/3R5/4rA3/r3A4/3RK4 w", "d3d9", false);
  protection_test("3aka3/4r4/4R4/p7p/2p3p2/4C4/P3R1P2/4E4/4A4/4KAE2 w", "e4e8", false);
  protection_test("4k4/9/9/4p4/9/9/9/9/3pA4/2pAK4 b - - 0 1", "c0d0", true);
  protection_test("2eak1e2/4a4/2R6/p3p4/6r1p/9/P4h2P/H3E4/3C1C3/1RE1KA1r1 b", "h0f0", true);
  print("% out of % tests successful\n", success, total);
  print("------------------------\n");


  repetition_test :: (fen: string, actual_state: GameState, moves: ..string) {
    xiangqi: Xiangqi;
    xiangqi_fen(*xiangqi, fen);
    chases: [8] Move32;
    chase_count := 0;
    victims: [6] u8;
    moves_made_count := 0;
    for move_string: moves {
      move := to_move32(*xiangqi, move_string);
      make_move(*xiangqi, move);
      victim_count := get_evade(*xiangqi, move, chases, chase_count, victims);
      if moves_made_count > 0 && victim_count > 0 then { 
        set_previous_chase_move(*xiangqi, victims, cast(s8) victim_count);
      } 

      att := attackers(*xiangqi);
      if incheck(*xiangqi, att) then {
        chase_count = 0;
        mark_previous_move_check(*xiangqi);
      } else if is_capture(move) || is_pawn_advance(move) {
        mark_previous_move(*xiangqi, .Cancel);
        chase_count = 0;
      } else if is_quiet(move) {
        chase_count = get_chases(*xiangqi, chases);
        mark_previous_move(*xiangqi, .Idle);
      } 
      moves_made_count += 1;
    }
    judge_state, violation_level := judge_ntimes(*xiangqi, 0);
    if judge_state != actual_state {
      print("-----------------------------\n");
      print("Error. Expected %. Got %\n", actual_state, judge_state);
      print("%\n", xiangqi);
      print("MOVES: %\n", moves);
      print("-----------------------------\n");
    } else {
      success += 1;
    }
    total += 1;
  }

  success = 0;
  total = 0;
  print("Xiangqi Repetition Tests.\n");
  print("------------------------\n");
  // ... nothing happens.
  repetition_test("4ka3/4a4/4b4/p7p/9/4C4/4P4/4B4/3K5/3Ac1B2 w - - 0 1", .Undecided);

  // perpetual check tests.
  repetition_test("c2a1k3/2c1a2R1/b6P1/8p/9/9/9/9/4K4/9 w - - 0 1", .Loss, "h8h9", "f9f8", "h9h8", "f8f9", "h8h9", "f9f8");
  repetition_test("c2a1k3/2c1a2R1/b6P1/8p/9/9/9/9/4K4/9 w - - 0 1", .Win, "h8h9", "f9f8", "h9h8", "f8f9", "h8h9", "f9f8", "h9h8");
  repetition_test("9/4k4/9/9/9/9/9/9/2p6/3K1RBc1 w - - 0 1", .Win, "f0e0", "e8f8", "e0f0", "f8e8", "f0e0", "e8f8", "e0f0");
  repetition_test("9/4k4/9/9/9/9/9/9/2p6/3K1RBc1 w - - 0 1", .Loss, "f0e0", "e8f8", "e0f0", "f8e8", "f0e0", "e8f8");
  repetition_test("4R4/3k5/5R3/9/9/2B6/n8/3pB4/4p4/3K5 w - - 0 1", .Loss, "e9d9", "d8e8", "d9e9", "e8d8", "e9d9", "d8e8");
  repetition_test("4R4/3k5/5R3/9/9/2B6/n8/3pB4/4p4/3K5 w - - 0 1", .Win,  "e9d9", "d8e8", "d9e9", "e8d8", "e9d9", "d8e8", "d9e9");
  repetition_test("3akr3/5c3/1P2b4/4R4/9/9/9/9/9/4CK3 w - - 0 1", .Draw, "e6e7", "f8e8", "e7f7", "e8f8", "f7e7", "f8e8", "e7f7");
  repetition_test("3akr3/5c3/1P2b4/4R4/9/9/9/9/9/4CK3 w - - 0 1", .Draw, "e6e7", "f8e8", "e7f7", "e8f8", "f7e7", "f8e8", "e7f7", "e8f8");

  // two-to-one check.
  repetition_test("5c3/8R/4k2P1/3P5/5P3/6P2/5pN2/5A3/4CK3/6rn1 w", .Win, "f5e5", "f3e3", "e5f5", "e3f3", "f5e5", "f3e3", "e5f5", "e3f3", "f5e5");
  repetition_test("5c3/8R/4k2P1/3P5/5P3/6P2/5pN2/5A3/4CK3/6rn1 w", .Loss, "f5e5", "f3e3", "e5f5", "e3f3", "f5e5", "f3e3");
  
  // alternate check and kill.
  // some perpetual chasing.
  repetition_test("3ak1b2/4a4/4b4/r3C2R1/p8/9/P8/4p4/4p4/5K3 w", .Draw, "h6g6", "g9i7", "g6h6", "i7g9", "h6g6", "g9i7");
  repetition_test("2b2k3/9/4b2P1/3N5/1R6p/6P2/5p2r/8n/4p4/5K3 w", .Draw, "d6c8", "f9f8", "c8d6", "f8f9", "d6c8", "f9f8", "c8d6");
  repetition_test("3aka3/4n4/4b4/4C4/p3p3p/9/2c6/2C6/4K4/9 w", .Draw, "c2g2", "c3g3", "g2c2", "g3c3", "c2g2", "c3g3");
  repetition_test("2bNka3/1N2aPP2/n3b4/p8/5c3/2C6/9/4B4/4A4/r1BK1A1n1 w", .Draw, "c4h4", "f5h5", "h4e4", "h5e5", "e4h4", "e5h5", "h4e4", "h5e5");
  repetition_test("5k3/2CPP4/9/9/9/9/9/B3p4/r8/4K4 w", .Draw, "e8f8", "f9e9", "e0f0", "e2f2", "f8e8", "e9f9", "f0e0", "f2e2", "e8f8", "f9e9");
  repetition_test("2bak4/4a4/4b4/8p/5R3/8P/n8/1r2C4/9/1cBAKAB2 w", .Draw, "f5h5", "e9f9", "h5f5", "f9e9", "f5h5", "e9f9", "h5f5", "f9e9", "f5h5");
  repetition_test("2ba1k3/4a4/b8/7R1/9/9/1r2p4/9/4A4/2B1KAB1c w", .Draw, "h6h9", "f9f8", "h9h0", "i0i1", "h0h8", "f8f9", "h8h1", "i1i0", "h1h9", "f9f8", "h9h0");
  repetition_test("2ba1k3/4a4/b8/7R1/9/9/1r2p4/9/4A4/2B1KAB1c w", .Win, "h6i6", "i0h0", "i6h6", "h0i0", "h6i6", "i0h0", "i6h6", "h0i0", "h6i6", "i0h0", "i6h6", "h0i0", "h6i6");
  repetition_test("2ba1k3/4a4/b8/7R1/9/9/1r2p4/9/4A4/2B1KAB1c w", .Loss, "h6i6", "i0h0", "i6h6", "h0i0", "h6i6", "i0h0", "i6h6", "h0i0", "h6i6", "i0h0");
  repetition_test("2bakab2/3r5/2n1c2c1/p1R1p1p2/7np/2P2CP2/P2rP3P/2N1C1N2/4A4/2B1KAB1R w", .Win, "f4f3", "d3d7", "f3f7", "d7d3", "f7f3", "d3d7", "f3f7");
  repetition_test("2bakab2/3r5/2n1c2c1/p1R1p1p2/7np/2P2CP2/P2rP3P/2N1C1N2/4A4/2B1KAB1R w", .Loss, "f4f3", "d3d7", "f3f7", "d7d3", "f7f3", "d3d7", "f3f7", "d7d3");
  repetition_test("2bak4/4a4/4b4/2p5p/6p2/2Pp5/4P4/2N4C1/2CrA4/3AK4 w - - 0 1", .Win, "h2h1", "d1d3", "h1h3", "d3d1", "h3h1", "d1d3", "h1h3");
  repetition_test("2bak4/4a4/4b4/8p/2p3p2/9/N2rP4/6NC1/C3A4/4K1B2 w - - 0 1", .Win, "h2h3", "d3d1", "h3h1", "d1d3", "h1h3", "d3d1", "h3h1");
  repetition_test("2c1kab2/4a4/4b4/9/9/9/P1p5P/2r1N1cC1/4A4/3ACK3 w - - 0 1", .Win, "e2d4", "g2g1", "d4e2", "g1g2", "e2d4", "g2g1", "d4e2");
  repetition_test("1r2kab2/4a4/4b4/p1p1p3p/5R3/2P2N3/PC2P3P/4Cr3/1R3c3/2B1KA3 w", .Win, "b3b2", "f2f3", "b2b3", "f3f2", "b3b2", "f2f3", "b2b3");
  repetition_test("4kab2/4a4/4b4/c3C1p1R/8P/2B6/9/3AB1p2/1pr1A4/4K4 w", .Win, "e6c6", "c1d1", "c6d6", "d1c1", "d6c6", "c1d1", "c6d6");
  repetition_test("2bak3r/4a4/4b1n2/P2rp3p/2p1c1p2/4R4/N3P3R/4BC1C1/N3A4/4KAB2 w", .Win, "f2f6", "d6d4", "f6f4", "d4d6", "f4f6", "d6d4", "f6f4");
  repetition_test("2ca1k3/4a4/b3b4/2P5P/6p2/1c7/9/B7N/2nR5/2BAK4 w", .Win, "c6b6", "e7c5", "b6c6", "c5e7", "c6b6", "e7c5", "b6c6");
  repetition_test("2bakab2/9/4c3n/p1prp3R/9/2P6/P3P1c1A/2N1BC2B/4A4/3AK4 w", .Win, "f2g2", "g3f3", "i2g4", "f3g3", "g4i2", "g3f3", "i2g4");
  repetition_test("4kab2/4a4/4b4/3rC2R1/9/9/4n4/4B4/4A4/4KAB1c w", .Win, "h6i6", "i0h0", "i6h6", "h0i0", "h6i6", "i0h0", "i6h6");
  repetition_test("1cbak4/R3a4/4b4/7P1/9/2P6/3pp4/8r/9/3AKA3 w", .Win, "a8b8", "b9a9", "b8a8", "a9b9", "a8b8", "b9a9", "b8a8");
  repetition_test("1cbak4/R3a4/4b2C1/7P1/9/2P6/3pp4/8r/9/3AKA3 w", .Win, "a8b8", "b9a9", "b8a8", "a9b9", "a8b8", "b9a9", "b8a8", "a9b9", "a8b8");
  repetition_test("1cbak4/R3a4/4b2C1/7P1/9/2P6/3pp4/8r/9/3AKA3 w", .Loss, "a8b8", "b9a9", "b8a8", "a9b9", "a8b8", "b9a9", "b8a8", "a9b9");
  repetition_test("3aka3/7R1/7c1/9/9/9/9/9/4A4/3AK1p2 b", .Win, "h7c7", "h8c8", "c7h7", "c8h8", "h7c7", "h8c8"); 
  repetition_test("4kab2/4a4/8b/p1p5p/4c1n2/6R2/P1P1P1P1P/4BC3/8N/2B1KA1r1 w", .Win, "i1g2", "h0g0", "g2i1", "g0h0", "i1g2", "h0g0", "g2i1");
  repetition_test("4k4/9/9/9/C8/9/pp5pp/4B4/9/r1BAKA2r w", .Draw, "a5i5", "i0h0", "i5a5", "a0b0", "a5h5", "h0i0", "h5b5", "b0a0", "b5i5", "i0h0", "i5a5");
  repetition_test("Cc1ak4/4a1P2/9/2p6/1P7/6C2/9/B2p5/2p2p3/4K4 w", .Win, "g4b4", "b9c9", "b4c4", "c9b9", "c4b4", "b9c9", "b4c4");
  repetition_test("1rb1kabr1/4a1c2/1cn3n2/p1C1p1R1p/9/9/P1P1P1P1P/2N1C1N2/9/R1BAKAB2 w", .Win, "g6f6", "g7h5", "f6g6", "h5g7", "g6f6", "g7h5");
  repetition_test("1rb1kabr1/4a1c2/1cn6/pRp1pR2p/7n1/2P2p3/P3P1P1P/C1N1C1N2/4A4/3AK1B2 w", .Win, "f6g6", "h5g7", "g6f6", "g7h5", "f6g6", "h5g7");
  repetition_test("r1b1kabr1/4a1c2/1cn6/p1p1pR2p/3NP2n1/9/P1P3p1P/1C2C4/4A4/RNBAK1B2 w", .Win, "f6g6", "h5g7", "g6f6", "g7h5", "f6g6", "h5g7");
  repetition_test("2bakab2/9/4c3n/p1prp3R/9/2P6/P3P1c1P/2N1BC2B/4A4/3AK4 w", .Win, "f2g2", "g3f3", "i2g4", "f3g3", "g4i2", "g3f3", "i2g4");

  // legal king-pawn chases. draws.
  repetition_test("4ka3/4a4/4b4/p7p/9/4C4/4P4/4B4/3K5/3Ac1B2 w", .Draw, "d1e1", "e0f0", "e1f1", "f0e0", "f1e1", "e0f0", "e1f1");
  repetition_test("3k2b1r/4a4/5a2b/3PP4/7P1/9/9/B4N2B/5K3/4p4 w", .Draw, "f1e1", "e0d0", "e1d1", "d0e0", "d1e1", "e0d0", "e1d1");
  repetition_test("4k1b1c/7P1/3a5/9/9/9/9/9/3K5/9 w", .Draw, "h8i8", "i9h9", "i8h8", "h9i9", "h8i8", "i9h9", "i8h8");
  repetition_test("4kab2/4a4/4b1n2/4p2P1/2p5P/9/9/7C1/4A4/4K4 w", .Draw, "h6g6", "g7h9", "g6h6", "h9g7", "h6g6", "g7h9");

  // exceptions to king-pawn chases.
  repetition_test("3a2b1r/4ak3/8p/7P1/9/9/9/B2NN3B/3K5/4p4 w", .Win, "d1e1", "e0d0", "e1d1", "d0e0", "d1e1", "e0d0", "e1d1");
  repetition_test("1c1ak4/N1PNa4/9/9/5P3/9/9/4Bp3/9/3p1K1p1 w", .Win, "c8b8", "b9c9", "b8c8", "c9b9", "c8b8", "b9c9", "b8c8");
  repetition_test("1Pbak2r1/4a4/4b4/2p6/9/3R5/2P6/4p2p1/3CC2N1/5K3 w", .Win, "d4e4", "e2d2", "e4d4", "d2e2", "d4e4", "e2d2", "e4d4", "d2e2", "d4e4"); 
  repetition_test("1Pbak2r1/4a4/4b4/2p6/9/3R5/2P6/4p2p1/3CC2N1/5K3 w", .Loss, "d4e4", "e2d2", "e4d4", "d2e2", "d4e4", "e2d2", "e4d4", "d2e2"); 

  repetition_test("3akab2/c2R1R2c/4b4/9/9/9/9/4B4/4K4/2B6 w", .Draw, "d8d6", "d9e8", "d6d8", "e8d9", "f8f6", "f9e8", "f6f8", "e8f9", "d8d6", "d9e8");

  // red attacks protected piece on one piece and chases on another. draw.
  repetition_test("3k1a1cC/4a4/4b4/9/6PP1/2C6/2p1p4/4B4/4A4/4KAB2 w", .Draw, "c4h4", "h9g9", "h4g4", "g9h9", "g4h4", "h9g9", "h4g4");

  // red chase on impaired horse
  repetition_test("5ab2/4k2P1/5an1b/p1p3p2/8p/2P4N1/6P1P/B8/5p2c/3KC4 w", .Win, "h4f5", "g7i6", "f5h4", "i6g7", "h4f5", "g7i6", "f5h4");

  // critical positions
  repetition_test("2bak4/RC2arN2/4b1n2/2p5p/6p2/2P6/4p1P1c/4B4/4A4/4KAB2 b", .Win, "e8f9", "b8b9", "f9e8", "b9b8", "e8f9", "b8b9");
  repetition_test("2baka3/C4rN2/4b1n2/1Rp5p/6p2/2P6/4c1P1c/4B3C/4A4/4KAB2 w", .Win, "b6b8", "f9e8", "b8b6", "e8f9", "b6b8", "f9e8", "b8b6");
  repetition_test("2baka3/C4rN2/4b1n2/1Rp5p/6p2/2P6/4c1P1c/4B3C/4A4/4KAB2 w", .Loss, "b6b8", "f9e8", "b8b6", "e8f9", "b6b8", "f9e8");
  repetition_test("3aka3/C4rN2/4b1n2/N7p/2p3p2/8P/2P3P2/9/4A4/4KA3 w", .Win, "a6b8", "f9e8", "b8a6", "e8f9", "a6b8", "f9e8", "b8a6");
  repetition_test("3aka3/C4rN2/4b1n2/N7p/2p3p2/8P/2P3P2/9/4A4/4KA3 w", .Loss, "a6b8", "f9e8", "b8a6", "e8f9", "a6b8", "f9e8");
  repetition_test("3akabC1/9/4b4/r3p4/p1p6/4P4/P1P5n/NCr1B4/4A4/R2AK1B2 w", .Win, "h9h2", "i3g2", "e2g4", "g2h4", "g4e2", "h4g2", "e2g4", "g2h4", "g4e2");
  repetition_test("3akabC1/9/4b4/r3p4/p1p6/4P4/P1P5n/NCr1B4/4A4/R2AK1B2 w", .Loss, "h9h2", "i3g2", "e2g4", "g2h4", "g4e2", "h4g2", "e2g4", "g2h4");

  // perpetual offer.
  repetition_test("4k4/3P2P1P/9/9/6b1c/5p1C1/9/9/4A4/3AK1p2 w", .Draw, "h4i4", "i5h5", "i4h4", "h5i5", "h4i4", "i5h5", "i4h4");
  repetition_test("4k4/3P2P1P/9/9/6b1c/5p1C1/9/9/4A4/3AK1p2 w", .Draw, "h4i4", "i5h5", "i4h4", "h5i5", "h4i4", "i5h5");
  repetition_test("2bak4/4a4/4b4/9/2p2r3/r8/1R7/4B4/9/1R2K1B2 w", .Draw, "b3b4", "a4a3", "b4b3", "a3a4", "b3b4", "a4a3");
  repetition_test("2bk5/3c5/4bN3/1R2p4/9/9/3r5/3R1p3/3K5/9 w", .Draw, "b6b3", "d3d4", "b3b4", "d4d3", "b4b3", "d3d4", "b3b4");
  repetition_test("2bak3r/4a4/4b4/p3C1R2/9/P8/5R3/9/4r4/5K3 w", .Draw, "g6i6", "i9g9", "i6g6", "g9i9", "g6i6", "i9g9");

  // red chases horse. black does alternative check & idle
  repetition_test("3akr3/n3a4/4b4/9/P1b6/9/1n7/4B4/3RA4/2BAK4 w", .Win, "d1d3", "b3c1", "d3d1", "c1b3", "d1d3", "b3c1", "d3d1");
  repetition_test("3akr3/n3a4/4b4/9/P1b6/9/1n7/4B4/3RA4/2BAK4 w", .Loss, "d1d3", "b3c1", "d3d1", "c1b3", "d1d3", "b3c1");

  // two-to-one chase.
  repetition_test("4ka3/1CP1a4/4b4/2p6/1cb1r4/4CN3/4Pp2P/4B4/4A4/2BAK4 w", .Win, "f4g6", "e5e6", "g6f4", "e6e5", "f4g6", "e5e6", "g6f4");
  repetition_test("4ka3/1CP1a4/4b4/2p6/1cb1r4/4CN3/4Pp2P/4B4/4A4/2BAK4 w", .Loss, "f4g6", "e5e6", "g6f4", "e6e5", "f4g6", "e5e6");

  // false roots chasing.
  repetition_test("3ak1b2/4a4/4b4/9/2c6/2R6/9/4C4/4A4/2BAK1B2 b", .Win, "c5g5", "c4g4", "g5c5", "g4c4", "c5g5", "c4g4"); 
  repetition_test("3ak1b2/4a4/4b4/9/2c6/2R6/9/4C4/4A4/2BAK1B2 b", .Loss, "c5g5", "c4g4", "g5c5", "g4c4", "c5g5", "c4g4", "g5c5");
  repetition_test("2baka3/9/4b4/9/6c2/3R5/4c4/4C4/4N4/3AKA3 w", .Win, "d4g4", "g5d5", "g4d4", "d5g5", "d4g4", "g5d5", "g4d4");
  repetition_test("2baka3/9/4b4/9/6c2/3R5/4c4/4C4/4N4/3AKA3 w", .Loss, "d4g4", "g5d5", "g4d4", "d5g5", "d4g4", "g5d5", "g4d4", "d5g5");
  repetition_test("1r2knb1C/4a4/5ac1b/7R1/p8/9/9/9/4A4/3AK4 w", .Win, "h6g6", "g7h7", "g6h6", "h7g7", "h6g6", "g7h7", "g6h6"); 
  repetition_test("1r2knb1C/4a4/5ac1b/7R1/p8/9/9/9/4A4/3AK4 w", .Loss, "h6g6", "g7h7", "g6h6", "h7g7", "h6g6", "g7h7");
  repetition_test("3aka3/r4rN2/6P2/p3P3p/9/6R2/P4c2P/4B4/4A4/3AK1B2 w", .Win, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4", "g3g4");
  repetition_test("3aka3/r4rN2/6P2/p3P3p/9/6R2/P4c2P/4B4/4A4/3AK1B2 w", .Loss, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4");
  repetition_test("4ka3/1r3cN2/5aP2/p3P3p/9/6R2/P4c2P/4B4/4A4/3AK1B2 w", .Win, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4", "g3g4");
  repetition_test("4ka3/1r3cN2/5aP2/p3P3p/9/6R2/P4c2P/4B4/4A4/3AK1B2 w", .Loss, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4");
  repetition_test("4ka3/2r2cN2/5aP2/p3P3p/9/6R2/P4c2P/9/4A4/2BAK1B2 w", .Win, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4", "g3g4");
  repetition_test("4ka3/2r2cN2/5aP2/p3P3p/9/6R2/P4c2P/9/4A4/2BAK1B2 w", .Loss, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4");

  // red chases cannon. perpetual chase even though cannon is being offered.
  repetition_test("2bak1r2/4a4/1C2b4/9/6p2/9/9/9/7R1/c1BAK4 w", .Win, "h1a1", "a0b0", "a1b1", "b0a0", "b1a1", "a0b0", "a1b1");
  repetition_test("2bak1r2/4a4/1C2b4/9/6p2/9/9/9/7R1/c1BAK4 w", .Loss, "h1a1", "a0b0", "a1b1", "b0a0", "b1a1", "a0b0", "a1b1", "b0a0");

  // non-perpetual chase.
  repetition_test("3k2b2/4P4/4b4/9/8p/6Bc1/6P1P/3AB4/4pp3/1p1K3R1 w", .Draw, "h0h1", "h4h3", "h1h0", "h3h4", "h0h1", "h4h3");
  repetition_test("3k2b2/4P4/4b4/9/8p/6Bc1/6P1P/3AB4/4pp3/1p1K3R1 w", .Draw, "h0h1", "h4h3", "h1h0", "h3h4", "h0h1", "h4h3", "h1h0");

  // mutual perpetual chase.
  repetition_test("3akab2/c2R1R2c/4b4/9/9/9/9/4B4/4K4/2B6 w", .Draw, "d8d6", "d9e8", "d6d8", "e8d9", "f8f6", "f9e8", "f6f8", "e8f9", "d8d6", "d9e8");
  print("% out of % tests successful\n", success, total);
  print("------------------------\n");

}
