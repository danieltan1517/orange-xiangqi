// automated testing for SEE

#import "Math";
#load "board.jai";

total := 0;
success := 0;

main :: () {
  init_xiangqi_tables();
  //see_test_suite();
  //protection_test_suite();
  //perft_test_suite();
  repetition_test_suite();
}

perft_test_suite :: () {
  // Perft Test Results from: https://www.chessprogramming.org/Chinese_Chess_Perft_Results
  // Would be good to be able to find more perft results, so we can permutationally test
  // the movegen better. - Daniel (Feb 19. 2023)

  test :: (xiangqi: *Xiangqi, depth: int, expected: int) {
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
  test(*xiangqi, 1, 44);
  test(*xiangqi, 2, 1_920);
  test(*xiangqi, 3, 79_666);
  test(*xiangqi, 4, 3_290_240);
  test(*xiangqi, 5, 133_312_995);

  fen := "r1ea1a3/4kh3/2h1e4/pHp1p1p1p/4c4/6P2/P1P2R2P/1CcC5/9/2EAKAE2 w - - 0 1";
  print("FEN [%]\n", fen);
  xiangqi_fen(*xiangqi, fen);
  test(*xiangqi, 1, 38);
  test(*xiangqi, 2, 1_128);
  test(*xiangqi, 3, 43_929);
  test(*xiangqi, 4, 1_339_047);

  fen = "1ceak4/9/h2a5/2p1p3p/5cp2/2h2H3/6PCP/3AE4/2C6/3A1K1H1 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, 1, 7);
  test(*xiangqi, 2, 281);
  test(*xiangqi, 3, 8_620);
  test(*xiangqi, 4, 326_201);
  test(*xiangqi, 5, 10_369_923);
  test(*xiangqi, 6, 380_156_340);

  fen = "5a3/3k5/3aR4/9/5r3/5h3/9/3A1A3/5K3/2EC2E2 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, 1, 25);
  test(*xiangqi, 2, 424);
  test(*xiangqi, 3, 9_850);
  test(*xiangqi, 4, 202_884);
  test(*xiangqi, 5, 4_739_553);
  test(*xiangqi, 6, 100_055_401);

  fen = "CRH1k1e2/3ca4/4ea3/9/2hr5/9/9/4E4/4A4/4KA3 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, 1, 28);
  test(*xiangqi, 2, 516);
  test(*xiangqi, 3, 14_808);
  test(*xiangqi, 4, 395_483);
  test(*xiangqi, 5, 11_842_230);

  fen = "R1H1k1e2/9/3aea3/9/2hr5/2E6/9/4E4/4A4/4KA3 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, 1, 21);
  test(*xiangqi, 2, 364);
  test(*xiangqi, 3, 7_626);
  test(*xiangqi, 4, 162_837);
  test(*xiangqi, 5, 3_500_505);
  test(*xiangqi, 6, 81_195_154);

  fen = "C1hHk4/9/9/9/9/9/h1pp5/E3C4/9/3A1K3 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, 1, 28);
  test(*xiangqi, 2, 222);
  test(*xiangqi, 3, 6_241);
  test(*xiangqi, 4, 64_971);
  test(*xiangqi, 5, 1_914_306);
  test(*xiangqi, 6, 23_496_493);

  fen = "4ka3/4a4/9/9/4H4/p8/9/4C3c/7h1/2EK5 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, 1, 23);
  test(*xiangqi, 2, 345);
  test(*xiangqi, 3, 8124);
  test(*xiangqi, 4, 149_272);
  test(*xiangqi, 5, 3_513_104);
  test(*xiangqi, 6, 71_287_903);

  fen = "2e1ka3/9/e3H4/4h4/9/9/9/4C4/2p6/2EK5 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, 1, 21);
  test(*xiangqi, 2, 195);
  test(*xiangqi, 3, 3_883);
  test(*xiangqi, 4, 48_060);
  test(*xiangqi, 5, 933_096);
  test(*xiangqi, 6, 12_250_386);

  fen = "1C2ka3/9/C1Hae1h2/p3p3p/6p2/9/P3P3P/3AE4/3p2c2/c1EAK4 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, 1, 30);
  test(*xiangqi, 2, 830);
  test(*xiangqi, 3, 22_787);
  test(*xiangqi, 4, 649_866);
  test(*xiangqi, 5, 17_920_736);

  fen = "ChH1k1e2/c3a4/4ea3/9/2hr5/9/9/4C4/4A4/4KA3 w - - 0 1";
  xiangqi_fen(*xiangqi, fen);
  print("FEN [%]\n", fen);
  test(*xiangqi, 1, 19);
  test(*xiangqi, 2, 583);
  test(*xiangqi, 3, 11_714);
  test(*xiangqi, 4, 376_467);
  test(*xiangqi, 5, 8_148_177);

  print("Perft Test End.\n"); 
}

protection_test_suite :: () {
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
}

see_test_suite :: () {

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

  print("SEE Tests.\n");
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
  print("------------------------\n");

}

repetition_test_suite :: () {
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

  time := current_time_monotonic();
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
  repetition_test("4R4/3k5/5R3/9/9/2B6/n8/3pB4/4p4/3K5 w", .Win,  "f7f8", "d8d7", "f8f7", "d7d8", "f7f8", "d8d7", "f8f7");
  repetition_test("4R4/3k5/5R3/9/9/2B6/n8/3pB4/4p4/3K5 w", .Loss, "f7f8", "d8d7", "f8f7", "d7d8", "f7f8", "d8d7", "f8f7", "d7d8");
  repetition_test("3akr3/5c3/1P2b4/4R4/9/9/9/9/9/4CK3 w - - 0 1", .Draw, "e6e7", "f8e8", "e7f7", "e8f8", "f7e7", "f8e8", "e7f7");
  repetition_test("3akr3/5c3/1P2b4/4R4/9/9/9/9/9/4CK3 w - - 0 1", .Draw, "e6e7", "f8e8", "e7f7", "e8f8", "f7e7", "f8e8", "e7f7", "e8f8");

  // two-to-one check.
  repetition_test("5c3/8R/4k2P1/3P5/5P3/6P2/5pN2/5A3/4CK3/6rn1 w", .Win, "f5e5", "f3e3", "e5f5", "e3f3", "f5e5", "f3e3", "e5f5", "e3f3", "f5e5");
  repetition_test("5c3/8R/4k2P1/3P5/5P3/6P2/5pN2/5A3/4CK3/6rn1 w", .Loss, "f5e5", "f3e3", "e5f5", "e3f3", "f5e5", "f3e3");
  
  // perpetual kill.
  repetition_test("3ak1b2/4a4/4b4/r3C2R1/p8/9/P8/4p4/4p4/5K3 w", .Draw, "h6g6", "g9i7", "g6h6", "i7g9", "h6g6", "g9i7");
  repetition_test("2b2k3/9/4b2P1/3N5/1R6p/6P2/5p2r/8n/4p4/5K3 w", .Draw, "d6c8", "f9f8", "c8d6", "f8f9", "d6c8", "f9f8", "c8d6");
  repetition_test("3aka3/4n4/4b4/4C4/p3p3p/9/2c6/2C6/4K4/9 w", .Draw, "c2g2", "c3g3", "g2c2", "g3c3", "c2g2", "c3g3");
  repetition_test("2bNka3/1N2aPP2/n3b4/p8/5c3/2C6/9/4B4/4A4/r1BK1A1n1 w", .Draw, "c4h4", "f5h5", "h4e4", "h5e5", "e4h4", "e5h5", "h4e4", "h5e5");
  repetition_test("5k3/2CPP4/9/9/9/9/9/B3p4/r8/4K4 w", .Draw, "e8f8", "f9e9", "e0f0", "e2f2", "f8e8", "e9f9", "f0e0", "f2e2", "e8f8", "f9e9");
  repetition_test("2bak4/4a4/4b4/8p/5R3/8P/n8/1r2C4/9/1cBAKAB2 w", .Draw, "f5h5", "e9f9", "h5f5", "f9e9", "f5h5", "e9f9", "h5f5", "f9e9", "f5h5");
  repetition_test("2ba1k3/4a4/b8/7R1/9/9/1r2p4/9/4A4/2B1KAB1c w", .Draw, "h6h9", "f9f8", "h9h0", "i0i1", "h0h8", "f8f9", "h8h1", "i1i0", "h1h9", "f9f8", "h9h0");
  repetition_test("2bak3r/2R1a2C1/2Rcb4/2N2P3/5C2p/9/9/4p4/4p2p1/5K3 w", .Draw, "f5e5", "e9f9", "e5f5", "f9e9", "f5e5", "e9f9");

  // alternate check and chase.
  repetition_test("4ka3/2R1a4/C8/p7p/1P5n1/9/4n4/4B4/9/4K1B2 w", .Draw, "c8c9", "e8d9", "c9c8", "d9e8", "c8c9", "e8d9");
  repetition_test("1R1C1abr1/4k4/4b4/p7p/2p6/9/r1P3P2/B8/9/2B1KA3 w", .Draw, "b9b8", "e8e9", "b8b9", "e9e8", "b9b8", "e8e9");
  repetition_test("N1ra1a3/3nk4/4b4/p1p6/6b1p/2P6/P2R4P/4B4/4A4/2B1KA3 w", .Draw, "d3h3", "e8e9", "h3d3", "e9e8", "d3h3", "e8e9");
  repetition_test("3k1a3/4a1P2/8r/9/2R6/9/2P6/1p7/4An2n/3CKA3 w", .Draw, "c5c9", "d9d8", "c9c5", "d8d9", "c5c9", "d9d8");

  // perpetual chasing.
  repetition_test("2c1kab2/4a4/4b4/9/9/9/P1p5P/2r1N1cC1/4A4/3ACK3 w", .Win, "e2d4", "c2c1", "h2h1", "g2g1", "e1d2", "g1g0", "d2e1", "g0g1", "e1d2", "g1g0", "d2e1");
  repetition_test("2c1kab2/4a4/4b4/9/9/9/P1p5P/2r1N1cC1/4A4/3ACK3 w", .Loss, "e2d4", "c2c1", "h2h1", "g2g1", "e1d2", "g1g0", "d2e1", "g0g1", "e1d2", "g1g0", "d2e1", "g0g1");

  // some perpetual chasing.
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

  // chasing with two different pieces against one piece.
  // perpetual chase. bug fixed. critical position :) diagram 24.
  repetition_test("2bak3r/4a4/4b1n2/P2rp3p/2p1c1p2/4R4/N3P3R/4BC1C1/N3A4/4KAB2 w", .Win, "h2h6", "d6d3", "f2f3", "d3d1", "h6h1", "d1d6", "f3f6", "d6d3", "h1h3", "d3d1", "f6f1", "d1d6", "h3h6", "d6d3", "f1f3", "d3d1", "h6h1");

  // similar position to the chase above. diagram 25.
  repetition_test("2bck3r/4a4/3ab4/P2rp3p/2p1c4/4R4/N3P3P/4BC1C1/N3A4/4KAB2 w", .Win, "h2h6", "d6d3", "f2f3", "d3d1", "h6h1", "d1d6", "f3f6", "d6d3", "h1h3", "d3d1", "f6f1", "d1d6", "h3h6", "d6d3", "f1f3", "d3d1", "h6h1");
  
  // one cannon alternating chases between two different chariots. diagram 26.
  repetition_test("4k4/9/9/9/C8/9/pp5pp/4B4/9/r1BAKA2r w", .Draw, "a5i5", "i0h0", "i5a5", "a0b0", "a5h5", "h0i0", "h5b5", "b0a0", "b5i5", "i0h0", "i5a5");
  
  // diagram 27. cannon chases two black chariots on alternate moves.
  repetition_test("2b1ka3/4a4/4b4/p2rp4/4n4/4R4/Pr2P2p1/4BC3/4A4/R3KAB2 w", .Draw, "f2f3", "b3b1", "f3f6", "d6d3", "f6f1", "b1b6", "f1f3", "d3d1", "f3f6", "b6b3", "f6f1", "d1d6", "f1f3", "b3b1", "f3f6");

  // diagram 28. two-to-two chase. two cannons chase two chariots.
  repetition_test("2bak4/4a4/4b3n/p3p4/4n3p/4R4/Pr2P4/4BC1C1/3rA4/R3KAB2 w", .Draw, "f2f3", "b3b6", "h2h1", "d1d5", "f3f6", "b6b2", "h1h5", "d5d3", "f6f2", "b2b1", "h5h3", "d3d5", "f2f1", "b1b6", "f1f6", "b6b1", "h3h5", "d5d3", "f6f1", "b1b6", "h5h3", "d3d5", "f1f6", "b6b1");

  // protected pieces..
  // diagram 29. protected cannon . draw.
  repetition_test("2b1ka3/4a4/4b4/9/9/9/9/4B3R/4A1rc1/4KA3 w", .Draw, "i2h2", "h1i1", "h2i2", "i1h1", "i2h2", "h1i1");

  // diagram 30. protected cannon. draw.
  repetition_test("2bak4/4a4/4b4/9/6c2/5R3/4c4/4C4/4N4/3AKA3 w", .Draw, "f4g4", "g5c5", "g4c4", "c5g5", "c4g4", "g5c5", "g4c4");

  // diagram 31. protected cannon. draw.
  repetition_test("3k1a3/4a4/9/p1N3n2/4p1b1c/4c2R1/P8/4C4/4A4/2B1K1p2 w", .Draw, "h4i4", "i5h5", "i4h4", "h5i5", "h4i4", "i5h5");

  // diagram 32. chasing a cannon. cannon making perpetual kill.
  repetition_test("2bk1a3/4a4/4b4/9/c8/1R7/3r5/4B4/4A4/4KAB2 w", .Win, "b4a4", "a5e5", "a4e4", "e5a5", "e4a4", "a5e5", "a4e4");
  repetition_test("2bk1a3/4a4/4b4/9/c8/1R7/3r5/4B4/4A4/4KAB2 w", .Loss, "b4a4", "a5e5", "a4e4", "e5a5", "e4a4", "a5e5", "a4e4", "e5a5");

  // diagram 33. red chase on unprotected cannon.
  repetition_test("4kab2/4a4/4b4/3rC2R1/9/9/4n4/4B4/4A4/4KAB1c w", .Win, "h6i6", "i0h0", "i6h6", "h0i0", "h6i6", "i0h0", "i6h6"); 
  repetition_test("4kab2/4a4/4b4/3rC2R1/9/9/4n4/4B4/4A4/4KAB1c w", .Loss, "h6i6", "i0h0", "i6h6", "h0i0", "h6i6", "i0h0", "i6h6", "h0i0"); 

  // diagram 34. red chase. black kill.
  repetition_test("3aka3/7R1/7c1/9/9/9/9/9/4A4/3AK1p2 b", .Win, "h7c7", "h8c8", "c7h7", "c8h8", "h7c7", "h8c8"); 

  // diagram 35. red chase. black kill.
  repetition_test("4k4/4a4/4b4/6c2/9/3R5/4c4/4C4/4N4/3AKA3 w", .Win, "d4g4", "g6c6", "g4c4", "c6g6", "c4g4", "g6c6", "g4c4");

  // diagram 36.
  repetition_test("1rbakab2/9/2c5n/4p3p/p8/7R1/P1P1P1P1P/2N3N2/4A4/2BAK1B2 w", .Win, "h4c4", "c7g7", "c4g4", "g7c7", "g4c4", "c7g7", "c4g4");
  repetition_test("1rbakab2/9/2c5n/4p3p/p8/7R1/P1P1P1P1P/2N3N2/4A4/2BAK1B2 w", .Loss, "h4c4", "c7g7", "c4g4", "g7c7", "g4c4", "c7g7", "c4g4", "g7c7");

  // diagram 37.
  repetition_test("3ak4/4a4/4b4/p8/2p3n2/9/P1P3r2/3AB4/c3N3N/1RB1KA3 w", .Win, "b0b1", "a1a0", "b1b0", "a0a1", "b0b1", "a1a0", "b1b0");

  // diagram 38.
  repetition_test("2bakar2/9/2c6/8R/p3p1p2/9/P1P1P1P1P/B1N6/1r2A4/2B1KA3 w", .Win, "i6c6", "c7h7", "c6h6", "h7c7", "h6c6", "c7h7", "c6h6");

  // diagrams 39-41. critical positions
  // red chasing black rook. black rook pinned by horse. 
  repetition_test("2bak4/RC2arN2/4b1n2/2p5p/6p2/2P6/4p1P1c/4B4/4A4/4KAB2 b", .Win, "e8f9", "b8b9", "f9e8", "b9b8", "e8f9", "b8b9");
  repetition_test("2baka3/C4rN2/4b1n2/1Rp5p/6p2/2P6/4c1P1c/4B3C/4A4/4KAB2 w", .Win, "b6b8", "f9e8", "b8b6", "e8f9", "b6b8", "f9e8", "b8b6");
  repetition_test("2baka3/C4rN2/4b1n2/1Rp5p/6p2/2P6/4c1P1c/4B3C/4A4/4KAB2 w", .Loss, "b6b8", "f9e8", "b8b6", "e8f9", "b6b8", "f9e8");
  repetition_test("3aka3/C4rN2/4b1n2/N7p/2p3p2/8P/2P3P2/9/4A4/4KA3 w", .Win, "a6b8", "f9e8", "b8a6", "e8f9", "a6b8", "f9e8", "b8a6");
  repetition_test("3aka3/C4rN2/4b1n2/N7p/2p3p2/8P/2P3P2/9/4A4/4KA3 w", .Loss, "a6b8", "f9e8", "b8a6", "e8f9", "a6b8", "f9e8");

  // diagram 42. 
  repetition_test("1rb1kabr1/4a1c2/1cn3n2/p1C1p1R1p/9/9/P1P1P1P1P/2N1C1N2/9/R1BAKAB2 w", .Win, "g6f6", "g7h5", "f6g6", "h5g7", "g6f6", "g7h5");

  // diagram 43.
  repetition_test("1rb1kabr1/4a1c2/1cn6/pRp1pR2p/7n1/2P2p3/P3P1P1P/C1N1C1N2/4A4/3AK1B2 w", .Win, "f6g6", "h5g7", "g6f6", "g7h5", "f6g6", "h5g7");

  // diagram 44.
  repetition_test("r1b1kabr1/4a1c2/1cn6/p1p1pR2p/3NP2n1/9/P1P3p1P/1C2C4/4A4/RNBAK1B2 w", .Win, "f6g6", "h5g7", "g6f6", "g7h5", "f6g6", "h5g7");

  // diagram 45.
  // two-to-one chase.
  repetition_test("4ka3/1CP1a4/4b4/2p6/1cb1r4/4CN3/4Pp2P/4B4/4A4/2BAK4 w", .Win, "f4g6", "e5e6", "g6f4", "e6e5", "f4g6", "e5e6", "g6f4");
  repetition_test("4ka3/1CP1a4/4b4/2p6/1cb1r4/4CN3/4Pp2P/4B4/4A4/2BAK4 w", .Loss, "f4g6", "e5e6", "g6f4", "e6e5", "f4g6", "e5e6");

  // diagram 46.
  // two-to-one chase.
  repetition_test("3ak1br1/4a4/4b4/p8/6p2/9/P7P/n7B/4A4/2R1KA3 w", .Win, "c0c2", "a2b0", "c2c1", "b0a2", "c1c2", "a2b0", "c2c1", "b0a2");
  repetition_test("3ak1br1/4a4/4b4/p8/6p2/9/P7P/n7B/4A4/2R1KA3 w", .Loss, "c0c2", "a2b0", "c2c1", "b0a2", "c1c2", "a2b0", "c2c1");

  // diagram 47.
  // two-to-one chase.
  repetition_test("4kab2/4a4/8b/p1p5p/4c1n2/6R2/P1P1P1P1P/4BC3/8N/2B1KA1r1 w", .Win, "i1g2", "h0g0", "g2i1", "g0h0", "i1g2", "h0g0", "g2i1");

  // diagram 48.
  // mutual perpetual chase.
  repetition_test("3akc3/4a4/9/9/3n5/1R7/9/9/4A4/4KAB2 w", .Draw, "b4b5", "d5c3", "b5c5", "c3e4", "c5c4", "e4d6", "c4d4", "d6f5", "d4d5", "f5e3", "d5e5", "e3c4", "e5e4", "c4d6", "e4d4", "d6f5", "d4d5");

  // diagram 49.
  // chariot chases horse
  repetition_test("4ka3/4a4/3Pb4/2p1r3p/2b6/2R6/1n7/4B4/4A4/4KAB2 w", .Win, "c4c3", "b3a1", "c3c1", "a1b3", "c1c3", "b3a1", "c3c1");
  repetition_test("4ka3/4a4/3Pb4/2p1r3p/2b6/2R6/1n7/4B4/4A4/4KAB2 w", .Loss, "c4c3", "b3a1", "c3c1", "a1b3", "c1c3", "b3a1", "c3c1", "a1b3");

  // diagram 50.
  // red chases horse. black does alternative check & idle
  repetition_test("3akr3/n3a4/4b4/9/P1b6/9/1n7/4B4/3RA4/2BAK4 w", .Win, "d1d3", "b3c1", "d3d1", "c1b3", "d1d3", "b3c1", "d3d1");
  repetition_test("3akr3/n3a4/4b4/9/P1b6/9/1n7/4B4/3RA4/2BAK4 w", .Loss, "d1d3", "b3c1", "d3d1", "c1b3", "d1d3", "b3c1");

  // PERPETUAL OFFER.
  // 51. red perpetual offer.
  repetition_test("2bak3r/4a4/4b4/p3C1R2/9/P8/5R3/9/4r4/5K3 w", .Draw, "g6i6", "i9g9", "i6g6", "g9i9", "g6i6", "i9g9");

  // 52. offer chariot.
  repetition_test("2b1ka3/4a4/4b4/p3r3p/9/1R7/P7P/2p1CpC2/4A1n2/2BK1AB1c w", .Draw, "b4b6", "e6e3", "b6b3", "e3e6", "b3b6", "e6e3", "b6b3");
  repetition_test("2b1ka3/4a4/4b4/p3r3p/9/1R7/P7P/2p1CpC2/4A1n2/2BK1AB1c w", .Draw, "b4b6", "e6e3", "b6b3", "e3e6", "b3b6", "e6e3", "b6b3", "e3e6");

  // 53. cannon chasing pinned cannon. not an offer.
  repetition_test("Cc1ak4/4a1P2/9/2p6/1P7/6C2/9/B2p5/2p2p3/4K4 w", .Win, "g4b4", "b9c9", "b4c4", "c9b9", "c4b4", "b9c9", "b4c4");

  // 54. cannon chasing pinned cannon
  // red attacks protected piece on one piece and chases on another. draw.
  repetition_test("3k1a1cC/4a4/4b4/9/6PP1/2C6/2p1p4/4B4/4A4/4KAB2 w", .Draw, "c4h4", "h9g9", "h4g4", "g9h9", "g4h4", "h9g9", "h4g4");

  // 55. red horsechase on impaired horse
  repetition_test("5ab2/4k2P1/5an1b/p1p3p2/8p/2P4N1/6P1P/B8/5p2c/3KC4 w", .Win, "h4f5", "g7i6", "f5h4", "i6g7", "h4f5", "g7i6", "f5h4");

  // 56. gunmount unprotected piece.
  repetition_test("4ka1nC/3Pa4/9/8p/8P/4c4/9/7C1/3p1p3/4K4 w", .Win, "i5h5", "e4h4", "h5g5", "h4g4", "g5h5", "g4h4", "h5g5", "h4g4", "g5h5");
  repetition_test("4ka1nC/3Pa4/9/8p/8P/4c4/9/7C1/3p1p3/4K4 w", .Loss, "i5h5", "e4h4", "h5g5", "h4g4", "g5h5", "g4h4", "h5g5", "h4g4");
 
  // 57. gunmount unprotected piece.
  repetition_test("4k1b2/4n4/3aba3/4p4/9/8P/P2nP4/2N1BA3/8c/2BK2C2 w", .Win, "g0f0", "i1f1", "f2e1", "f1h1", "e1f2", "h1f1", "f2e1", "f1h1", "e1f2");
  repetition_test("4k1b2/4n4/3aba3/4p4/9/8P/P2nP4/2N1BA3/8c/2BK2C2 w", .Loss, "g0f0", "i1f1", "f2e1", "f1h1", "e1f2", "h1f1", "f2e1", "f1h1");

  // 58. gunmount cannon chases.
  repetition_test("2bakab2/9/4c3n/p1prp3R/9/2P6/P3P1c1P/2N1BC2B/4A4/3AK4 w", .Win, "f2g2", "g3f3", "i2g4", "f3g3", "g4i2", "g3f3", "i2g4");

  // 59. red chase on pawn crossing river.
  repetition_test("3akabC1/9/4b4/7P1/2n6/8p/3p5/9/4A1c2/2BAK1B1C w", .Win, "g0i2", "g1i1", "i2g0", "i1g1", "g0i2", "g1i1", "i2g0");

  // 60. red chase on pawn that didn't cross river.
  repetition_test("3akabC1/9/4b4/7P1/2n5p/9/3p5/9/4A1c2/2BAK1B1C w", .Draw, "g0i2", "g1i1", "i2g0", "i1g1", "g0i2", "g1i1", "i2g0");

  // 61. red chase using cannon on black rook 
  repetition_test("3akabC1/9/4b4/r3p4/p1p6/4P4/P1P5n/NCr1B4/4A4/R2AK1B2 w", .Win, "h9h2", "i3g2", "e2g4", "g2h4", "g4e2", "h4g2", "e2g4", "g2h4", "g4e2");
  repetition_test("3akabC1/9/4b4/r3p4/p1p6/4P4/P1P5n/NCr1B4/4A4/R2AK1B2 w", .Loss, "h9h2", "i3g2", "e2g4", "g2h4", "g4e2", "h4g2", "e2g4", "g2h4");

  // 62. red chase on black chariot.
  repetition_test("4kab2/4a4/4b3n/2r3p1p/2p2N3/9/1RP3P1P/4B3C/2r1A4/2N1KABc1 w", .Win, "i2i1", "c1c2", "i1i2", "c2c1", "i2i1", "c1c2", "i1i2");
  repetition_test("4kab2/4a4/4b3n/2r3p1p/2p2N3/9/1RP3P1P/4B3C/2r1A4/2N1KABc1 w", .Loss, "i2i1", "c1c2", "i1i2", "c2c1", "i2i1", "c1c2");
  repetition_test("4kab2/4a4/4b3n/2r3p1p/2p2N3/9/1RP3P1P/4B3C/2r1A4/2N1KABc1 w", .Win, "i2i1", "h0h1", "e1d0", "h1h0", "d0e1", "h0h1", "e1d0");
  repetition_test("4kab2/4a4/4b3n/2r3p1p/2p2N3/9/1RP3P1P/4B3C/2r1A4/2N1KABc1 w", .Loss, "i2i1", "h0h1", "e1d0", "h1h0", "d0e1", "h0h1", "e1d0", "h1h0");

  // 63. chariot pinned by cannon. chariot cannot chase. draw.
  repetition_test("4ka3/4a4/9/4r4/9/9/9/1C2C4/p3A4/3K1AB1n w", .Draw, "b2b6", "e6e5", "b6b5", "e5e6", "b5b6", "e6e5", "b6b5");

  // 64. chariot pinned by cannon. red chariot chases. loss for red.
  repetition_test("3aka3/4c4/4r4/9/9/9/PR7/2p1CA3/7p1/2B2K3 w", .Win, "b3b7", "e7e3", "b7b3", "e3e4", "b3b4", "e4e3", "b4b3", "e3e4", "b3b4");
  repetition_test("3aka3/4c4/4r4/9/9/9/PR7/2p1CA3/7p1/2B2K3 w", .Loss, "b3b7", "e7e3", "b7b3", "e3e4", "b3b4", "e4e3", "b4b3", "e3e4", "b3b4", "e4e3");

  // 65. black chariot pinned by red cannon. red violated perpetual chase.
  repetition_test("5kb2/4a4/4ba3/5r3/9/P6R1/3cpCpc1/4BA3/4A4/2BK5 w", .Win, "h4h6", "f6f5", "h6h5", "f5f6", "h5h6", "f6f5", "h6h5");
  repetition_test("5kb2/4a4/4ba3/5r3/9/P6R1/3cpCpc1/4BA3/4A4/2BK5 w", .Loss, "h4h6", "f6f5", "h6h5", "f5f6", "h5h6", "f6f5", "h6h5", "f5f6");

  // 66. black chariot chased on one move. protected on another.
  repetition_test("2bk1a1rC/4a1R2/4b4/9/9/4cp3/9/4B4/N3Ap3/2BAK4 w", .Draw, "g8h8", "h9g9", "h8g8", "g9h9", "g8h8", "h9g9", "h8g8", "g9h9", "g8h8");

  // legal king-pawn chases. draws.
  // diagrams 67 - 70.
  repetition_test("4ka3/4a4/4b4/p7p/9/4C4/4P4/4B4/3K5/3Ac1B2 w", .Draw, "d1e1", "e0f0", "e1f1", "f0e0", "f1e1", "e0f0", "e1f1");
  repetition_test("3k2b1r/4a4/5a2b/3PP4/7P1/9/9/B4N2B/5K3/4p4 w", .Draw, "f1e1", "e0d0", "e1d1", "d0e0", "d1e1", "e0d0", "e1d1");
  repetition_test("4k1b1c/7P1/3a5/9/9/9/9/9/3K5/9 w", .Draw, "h8i8", "i9h9", "i8h8", "h9i9", "h8i8", "i9h9", "i8h8");
  repetition_test("4kab2/4a4/4b1n2/4p2P1/2p5P/9/9/7C1/4A4/4K4 w", .Draw, "h6g6", "g7h9", "g6h6", "h9g7", "h6g6", "g7h9");

  // exceptions to king-pawn chases.
  // diagrams 71-75
  repetition_test("3a2b1r/4ak3/8p/7P1/9/9/9/B2NN3B/3K5/4p4 w", .Win, "d1e1", "e0d0", "e1d1", "d0e0", "d1e1", "e0d0", "e1d1");
  repetition_test("1c1ak4/N1PNa4/9/9/5P3/9/9/4Bp3/9/3p1K1p1 w", .Win, "c8b8", "b9c9", "b8c8", "c9b9", "c8b8", "b9c9", "b8c8");
  repetition_test("1Pbak2r1/4a4/4b4/2p6/9/3R5/2P6/4p2p1/3CC2N1/5K3 w", .Win, "d4e4", "e2d2", "e4d4", "d2e2", "d4e4", "e2d2", "e4d4", "d2e2", "d4e4"); 
  repetition_test("1Pbak2r1/4a4/4b4/2p6/9/3R5/2P6/4p2p1/3CC2N1/5K3 w", .Loss, "d4e4", "e2d2", "e4d4", "d2e2", "d4e4", "e2d2", "e4d4", "d2e2"); 

  repetition_test("3akab2/c2R1R2c/4b4/9/9/9/9/4B4/4K4/2B6 w", .Draw, "d8d6", "d9e8", "d6d8", "e8d9", "f8f6", "f9e8", "f6f8", "e8f9", "d8d6", "d9e8");
  repetition_test("2bak4/4a4/4b4/1rp6/P2R5/4pp3/9/CC7/4p4/5K3 w", .Win, "a5b5", "b6a6", "b5a5", "a6b6", "a5b5", "b6a6", "b5a5");
  repetition_test("2bak4/4a4/4b4/1rp6/P2R5/4pp3/9/CC7/4p4/5K3 w", .Loss, "a5b5", "b6a6", "b5a5", "a6b6", "a5b5", "b6a6", "b5a5", "a6b6");
  repetition_test("3rk1b2/4a4/3ab2r1/5R1N1/9/4p4/9/4B4/4A4/3AK1B2 w", .Win, "f6e6", "e4f4", "e6f6", "f4e4", "f6e6", "e4f4", "e6f6");
  repetition_test("3rk1b2/4a4/3ab2r1/5R1N1/9/4p4/9/4B4/4A4/3AK1B2 w", .Loss, "f6e6", "e4f4", "e6f6", "f4e4", "f6e6", "e4f4");

  repetition_test("1Pbak2r1/4a4/4b4/2p6/9/3R5/2P6/4p2p1/3CC2N1/5K3 w", .Win, "d4e4", "e2d2", "e4d4", "d2e2", "d4e4", "e2d2", "e4d4");
  repetition_test("1Pbak2r1/4a4/4b4/2p6/9/3R5/2P6/4p2p1/3CC2N1/5K3 w", .Loss, "d4e4", "e2d2", "e4d4", "d2e2", "d4e4", "e2d2");

  // river pawn chase diagram 77
  repetition_test("4kab2/4a4/3rb4/9/9/9/8R/1p5p1/4A4/3AK1B2 w", .Win, "i3h3", "h2g2", "h3g3", "g2h2", "g3h3", "h2g2", "h3g3");

  // rook chases 3 pieces diagram 78
  repetition_test("2rakab2/9/8b/2NPP1p2/9/2P1c1P2/7R1/2n1B1p2/4A4/3AK1B2 w", .Draw, "h3c3", "c2a1", "c3e3", "e4f4", "e3f3", "f4e4", "f3g3", "g2h2", "g3a3", "a1c0", "a3c3", "c0a1", "c3e3", "e4f4", "e3f3", "f4e4", "f3h3", "h2g2", "h3a3", "a1c0", "a3c3", "c0a1", "c3e3", "e4f4");
  repetition_test("2rakab2/9/8b/2NPP1p2/9/2P1c1P2/7R1/2n1B1p2/4A4/3AK1B2 w", .Win, "h3c3", "c2a1", "c3a3", "a1c2", "a3c3", "c2a1", "c3a3");

  // rook chase cannon, cannon chase two pawns. diagram 79
  repetition_test("3aka3/9/4b4/p8/2b6/2N3B2/4P3p/2C1B4/3rA1p2/3AK4 w", .Win, "c2c3", "d1d3", "c3c1", "d3d1", "c1c3", "d1d3", "c3c1", "d3d1");

  // diagram 80. two chariots chase two cannons
  repetition_test("3rkabc1/4a3R/4b4/9/9/9/9/B8/1R2A4/c1BAK4 w", .Draw, "i8h8", "h9i9", "b1a1", "a0b0", "h8i8", "i9h9", "i8h8", "h9i9", "a1b1", "b0a0", "b1a1", "a0b0");
  repetition_test("3rkabc1/4a3R/4b4/9/9/9/9/B8/1R2A4/c1BAK4 w", .Win, "b1a1", "a0b0", "a1b1", "b0a0", "b1a1", "a0b0", "a1b1");

  // diagram 81. two chariots chase one cannon.
  repetition_test("2b1ka1P1/4a4/b8/p5R2/8c/7R1/P1p3p2/3rBn3/N2C2n1C/3K1NB2 w", .Win, "h4h5", "i5i7", "g6g7", "i7i6", "h5h6", "i6i5", "g7g5", "i5i7", "h6h7", "i7i6", "g5g6", "i6i5", "h7h5", "i5i7", "h5h7");

  // diagram 82. 
  repetition_test("4k4/9/9/9/3P5/4C4/2N6/6ppc/4p4/5K3 w", .Win, "c3e2", "e1d1", "e2c3", "d1e1", "c3e2", "e1d1", "e2c3");
  repetition_test("4k4/9/9/9/3P5/4C4/2N6/6ppc/4p4/5K3 w", .Loss, "c3e2", "e1d1", "e2c3", "d1e1", "c3e2", "e1d1");

  // false roots. diagram 83-85
  // diagram 83.
  repetition_test("2baka3/9/4b4/9/6c2/3R5/4c4/4C4/4N4/3AKA3 w", .Win, "d4g4", "g5d5", "g4d4", "d5g5", "d4g4", "g5d5", "g4d4");
  repetition_test("2baka3/9/4b4/9/6c2/3R5/4c4/4C4/4N4/3AKA3 w", .Loss, "d4g4", "g5d5", "g4d4", "d5g5", "d4g4", "g5d5", "g4d4", "d5g5");

  // diagram 84.
  repetition_test("1r2knb1C/4a4/5ac1b/7R1/p8/9/9/9/4A4/3AK4 w", .Win, "h6g6", "g7h7", "g6h6", "h7g7", "h6g6", "g7h7", "g6h6"); 
  repetition_test("1r2knb1C/4a4/5ac1b/7R1/p8/9/9/9/4A4/3AK4 w", .Loss, "h6g6", "g7h7", "g6h6", "h7g7", "h6g6", "g7h7");

  // diagram 85.
  repetition_test("2bakab2/r4rN2/6P2/p3P3p/9/P5R2/5c2P/4B4/4A4/3AK1B2 w", .Win, "g4g3", "f3f6", "g3g6", "f6f3", "g6g3", "f3f6", "g3g6");

  // PROTECTED and ROOTED.
  // diagram 86. protected cannon. draw.
  repetition_test("3akab2/9/4b3r/8c/p8/7R1/P8/9/4A4/r1BAK3R w", .Draw, "h4h6", "i6i3", "h6h3", "i3i6", "h3h6", "i6i3", "h6h3");

  // diagram 87. protected cannon. draw.
  repetition_test("1r2kab2/4a4/4b4/4R3p/5P3/2R6/4c4/4r4/4A4/2B1KA3 w", .Draw, "c4c3", "e3e4", "c3c4", "e4e3", "c4c3", "e3e4");

  // diagram 88. draw
  repetition_test("2b1ka2c/4a4/4b3r/8c/p8/9/P4R3/8R/4A4/r1BAK3C w", .Draw, "f3f6", "i6i5", "f6f5", "i5i4", "f5f4", "i4i6", "f4f6", "i6i5", "f6f5");

  // diagram 89. draw
  repetition_test("4kab2/4a3c/2n1bc3/2R6/8p/C8/8P/3CB4/4A4/4KAB2 w", .Draw, "d2c2", "c7a8", "c6a6", "a8c7", "a6c6", "c7a8", "c6a6");

  // diagram 90 & 91. red chases cannon. perpetual chase even though cannon is being offered.
  repetition_test("2bak1r2/4a4/1C2b4/9/6p2/9/9/9/7R1/c1BAK4 w", .Win, "h1a1", "a0b0", "a1b1", "b0a0", "b1a1", "a0b0", "a1b1");
  repetition_test("2bak1r2/4a4/1C2b4/9/6p2/9/9/9/7R1/c1BAK4 w", .Loss, "h1a1", "a0b0", "a1b1", "b0a0", "b1a1", "a0b0", "a1b1", "b0a0");
  repetition_test("2bak4/4a4/4b4/CC7/3r5/1R7/5r3/4B4/4A4/c3KAB2 w", .Win, "b4a4", "a0b0", "a4b4", "b0a0", "b4a4", "a0b0", "a4b4");
  repetition_test("2bak4/4a4/4b4/CC7/3r5/1R7/5r3/4B4/4A4/c3KAB2 w", .Loss, "b4a4", "a0b0", "a4b4", "b0a0", "b4a4", "a0b0");

  // diagram 92. rook offer. red using pieces to chase black chariot.
  repetition_test("2bak4/4a4/4b1n2/4p3p/9/1p1r5/c3RR3/B2CC3B/4p4/2p2K3 w", .Win, "e3d3", "d4e4", "d3e3", "e4d4", "e3d3", "d4e4", "d3e3");
  repetition_test("2bak4/4a4/4b1n2/4p3p/9/1p1r5/c3RR3/B2CC3B/4p4/2p2K3 w", .Loss, "e3d3", "d4e4", "d3e3", "e4d4", "e3d3", "d4e4", "d3e3", "e4d4");

  // diagram 93 - 95. knight discovered attack. rook offer. Loss
  repetition_test("1r1ak1b2/N1RNC4/4b4/9/9/9/4P4/9/4p4/5K3 w", .Win, "c8b8", "b9c9", "b8c8", "c9b9", "c8b8", "b9c9", "b8c8");
  repetition_test("5k3/4P4/9/9/9/9/9/5N3/9/3KRr1c1 w", .Win, "f2h1", "f0g0", "h1f2", "g0f0", "f2h1", "f0g0", "h1f2");
  repetition_test("4k4/9/4c4/6PC1/9/9/9/4BN3/4A4/3AKR1rc w", .Win, "f2h1", "h0g0", "h1f2", "g0h0", "f2h1", "h0g0", "h1f2");

  // diagram 96 - cannon chase chariot.
  repetition_test("C4k3/3P5/9/5c3/1P7/2B6/2P2r3/3p1R3/5K3/9 w", .Win, "a9a3", "f3f5", "a3a5", "f5f3", "a5a3", "f3f5", "a3a5");

  // diagram 97 & 98 - perpetual threat to capture after check. draw.
  repetition_test("C1Na5/3Rak3/4bc3/2p6/n5b2/9/1p6r/4B4/4A4/2B1KA3 w", .Draw, "a9a8", "f8f9", "a8a9", "f9f8", "a9a8", "f8f9");
  repetition_test("5k3/1n7/9/3P5/P1r5c/2B5R/6P2/4B4/4A4/3AK4 w", .Draw, "i4h4", "i5h5", "h4g4", "h5g5", "g4i4", "g5i5", "i4h4", "i5h5");

  // diagram 99
  repetition_test("4k4/3P2P1P/9/9/6b1c/5p1C1/9/9/4A4/3AK1p2 w", .Draw, "h4i4", "i5h5", "i4h4", "h5i5", "h4i4", "i5h5");
  repetition_test("4k1b2/3P5/c3b2c1/7R1/9/9/9/9/4K4/9 w", .Draw, "h6f6", "h7f7", "f6i6", "f7i7", "i6b6", "a7b7", "b6g6", "i7g7", "g6f6", "g7f7", "f6h6", "f7h7", "h6b6", "b7a7", "b6h6", "h7f7", "h6f6", "f7h7", "f6h6", "h7f7", "h6f6");

  // diagram 100 - 103. perpetual offer.
  repetition_test("4k4/3P2P1P/9/9/6b1c/5p1C1/9/9/4A4/3AK1p2 w", .Draw, "h4i4", "i5h5", "i4h4", "h5i5", "h4i4", "i5h5", "i4h4");
  repetition_test("4k4/3P2P1P/9/9/6b1c/5p1C1/9/9/4A4/3AK1p2 w", .Draw, "h4i4", "i5h5", "i4h4", "h5i5", "h4i4", "i5h5");
  repetition_test("2bak4/4a4/4b4/9/2p2r3/r8/1R7/4B4/9/1R2K1B2 w", .Draw, "b3b4", "a4a1", "b4b1", "a1a3", "b1b3", "a3a6", "b3b6", "a6a8", "b6b8", "a8a1", "b8b1", "a1a3", "b1b3");
  repetition_test("3r1k3/4P4/9/c1p2r3/9/2R6/9/4B4/4A4/4K1B2 w", .Draw, "c4g4", "f6g6", "g4h4", "g6h6", "h4f4", "h6f6", "f4i4", "f6i6", "i4h4", "i6h6", "h4g4", "h6g6", "g4h4", "g6h6");
  repetition_test("2bk5/3c5/4bN3/1R2p4/9/9/3r5/3R1p3/3K5/9 w", .Draw, "b6b3", "d3d4", "b3b4", "d4d6", "b4b6", "d6d3", "b6b3", "d3d4");
  repetition_test("2bk5/3c5/4bN3/1R2p4/9/9/3r5/3R1p3/3K5/9 w", .Draw, "b6b3", "d3d4", "b3b4", "d4d3", "b4b3", "d3d4", "b3b4");
  repetition_test("1r1ak4/4aP3/b1P1b4/4C4/9/3R5/9/9/4p4/3K5 w", .Draw, "c7b7", "b9c9", "b7c7", "c9b9", "c7b7", "b9c9");

  // Addition illustrations.
 
  // Perpetual Chase:
  repetition_test("2ca1k3/4a4/b3b4/2P5P/6p2/1c7/9/B7N/2nR5/2BAK4 w", .Win, "c6b6", "e7c5", "b6c6", "c5e7", "c6b6", "e7c5", "b6c6");

  // non-perpetual chase.
  repetition_test("3k2b2/4P4/4b4/9/8p/6Bc1/6P1P/3AB4/4pp3/1p1K3R1 w", .Draw, "h0h1", "h4h3", "h1h0", "h3h4", "h0h1", "h4h3");
  repetition_test("3k2b2/4P4/4b4/9/8p/6Bc1/6P1P/3AB4/4pp3/1p1K3R1 w", .Draw, "h0h1", "h4h3", "h1h0", "h3h4", "h0h1", "h4h3", "h1h0");

  // mutual perpetual chase.
  repetition_test("3akab2/c2R1R2c/4b4/9/9/9/9/4B4/4K4/2B6 w", .Draw, "d8d6", "d9e8", "d6d8", "e8d9", "f8f6", "f9e8", "f6f8", "e8f9", "d8d6", "d9e8");

  // false roots chasing.
  repetition_test("3ak1b2/4a4/4b4/9/2c6/2R6/9/4C4/4A4/2BAK1B2 b", .Win, "c5g5", "c4g4", "g5c5", "g4c4", "c5g5", "c4g4"); 
  repetition_test("3ak1b2/4a4/4b4/9/2c6/2R6/9/4C4/4A4/2BAK1B2 b", .Loss, "c5g5", "c4g4", "g5c5", "g4c4", "c5g5", "c4g4", "g5c5");
  repetition_test("3aka3/r4rN2/6P2/p3P3p/9/6R2/P4c2P/4B4/4A4/3AK1B2 w", .Win, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4", "g3g4");
  repetition_test("3aka3/r4rN2/6P2/p3P3p/9/6R2/P4c2P/4B4/4A4/3AK1B2 w", .Loss, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4");
  repetition_test("4ka3/1r3cN2/5aP2/p3P3p/9/6R2/P4c2P/4B4/4A4/3AK1B2 w", .Win, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4", "g3g4");
  repetition_test("4ka3/1r3cN2/5aP2/p3P3p/9/6R2/P4c2P/4B4/4A4/3AK1B2 w", .Loss, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4");
  repetition_test("4ka3/2r2cN2/5aP2/p3P3p/9/6R2/P4c2P/9/4A4/2BAK1B2 w", .Win, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4", "g3g4");
  repetition_test("4ka3/2r2cN2/5aP2/p3P3p/9/6R2/P4c2P/9/4A4/2BAK1B2 w", .Loss, "g4g3", "f3f4", "g3g4", "f4f3", "g4g3", "f3f4");

  // Chases:
  repetition_test("4kab2/4a4/4b4/3rC2R1/9/9/4n4/4B4/4A4/4KAB1c w", .Win, "h6i6", "i0h0", "i6h6", "h0i0", "h6i6", "i0h0", "i6h6");

  // simple chases. chariot chases unprotected cannon
  repetition_test("1cbak4/R3a4/4b4/7P1/9/2P6/3pp4/8r/9/3AKA3 w", .Win, "a8b8", "b9a9", "b8a8", "a9b9", "a8b8", "b9a9", "b8a8");
  repetition_test("1cbak4/R3a4/4b2C1/7P1/9/2P6/3pp4/8r/9/3AKA3 w", .Win, "a8b8", "b9a9", "b8a8", "a9b9", "a8b8", "b9a9", "b8a8", "a9b9", "a8b8");


  repetition_test("1cbak4/R3a4/4b2C1/7P1/9/2P6/3pp4/8r/9/3AKA3 w", .Loss, "a8b8", "b9a9", "b8a8", "a9b9", "a8b8", "b9a9", "b8a8", "a9b9");
  repetition_test("2b1k1r2/9/4b4/9/9/2P3P2/1R7/2n1B4/4A4/4KABC1 w", .Win, "b3c3", "c2b0", "c3b3", "b0c2", "b3c3", "c2b0", "c3b3");
  repetition_test("2bak4/4a4/4b4/9/2p2r3/r8/1R7/4B4/9/1R2K1B2 w", .Draw, "b3b4", "a4a3", "b4b3", "a3a4", "b3b4", "a4a3");

  // 2023 Xiangqi Champion -- black chases chariot. red wins.
  repetition_test("2bakab2/6c2/2C3c2/p1N1p3p/1R1P5/5r3/P2CP1n1P/4B1p2/4A4/4KAB2 w", .Win, "b5b8", "f9e8", "c7c8", "e8f9", "c8c7", "f9e8", "c7c8", "e8f9", "c8c7", "f9e8");
  repetition_test("2bakab2/6c2/2C3c2/p1N1p3p/1R1P5/5r3/P2CP1n1P/4B1p2/4A4/4KAB2 w", .Loss, "b5b8", "f9e8", "c7c8", "e8f9", "c8c7", "f9e8", "c7c8", "e8f9", "c8c7");

  time = current_time_monotonic() - time;
  print("% out of % tests successful\n", success, total);
  print("------------------------\n");
  print("Chasing Time taken: % nanoseconds\n", to_nanoseconds(time));
}

