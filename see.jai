// automated testing for SEE

#import "Math";
#load "board.jai";

main :: () {
  total := 0;
  success := 0;


  init_xiangqi_tables();
  xiangqi: Xiangqi;

  see_test :: (fen: string, token: string, expected: int) #expand {
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

  protection_test :: (fen: string, token: string, expected: bool) #expand {
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
  protection_test("2ek5/4R4/9/8p/2e6/9/3hCr2P/4EH3/3p1K3/9 b", "d1e1", true);
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
