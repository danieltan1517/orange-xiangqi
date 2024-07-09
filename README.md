# Orange, A Xiangqi Chinese Chess Engine

Authors: Daniel Tan, Xiaofan Sun

This Xiangqi Chinese Chess Engine is named after the famous ancient Chinese manual "Secret of the Orange".
This project has both a Xiangqi Graphical User Interface and a UCCI (Universal Chinese Chess Interface)
protocol complaint Xiangqi Engine. This project supports Windows, Mac, and Linux.

## Graphical User Interface Features
* Drag and Drop to move pieces
* Click to move pieces
* Psuedo Legal Move Generation
* Implements UCI (Universal Chess Interface) Protocol as well as UCCI (Universal Chinese Chess Interface)
* Can do human vs computer, computer vs computer
* Parse and load FEN strings
* Multi engine support
* UCI/UCCI Engine Options
* Windows, Mac, and Linux support
* Chess Clock with Increment
* Blindfold Mode
* Drawing Arrows with Right Click
* Display Engine Lines
* English/Chinese Language Options

## Xiangqi Artificial Intelligence Engine
* Approximately 2560+ rating
* UCCI Protocol

### Board Representation
* 90 square board
* Piece Lists
* Magic Sliding Bit Rows and Columns
* Pseudo Legal Move Generation
* Staged Move Generation

### Threading
* Supports up to 256 Threads
* Lazy Shared Memory Processing Parallel Search

### Search
* Negamax Search with Alpha Beta Pruning
* Principle Variation Search
* Iterative Deepening
* Aspiration Window Search

### Pruning
* Reverse Futility Pruning
* Null Move Pruning w/ Endgame Verification
* Delta Pruning
* Razoring
* Mate Distance Pruning

### Extensions
* Singular Search Extensions
* Check Extensions

### Transposition Table
* 16-byte transposition table hash entries
* Zobrist Hashing with Incremental Update
* Prefetch Transposition Table Entries
* Depth Preferred + Random Replacement Scheme

### Move Ordering
* Principle Variation Move Ordering
* MVV-LVA (Most Valuable Victim, Least Valuable Attacker)
* Killer Move Ordering
* Countermove Move Ordering
* History Move Ordering
* Countermove History Move Ordering

### Evaluation
* Efficiently Updatable Neural Networks with Incremental Update
* 2 Layer Neural Network (2 x (1620 x 128) -> 1)
* Supports AVX2, SSE, and CPU without SIMD
* Trained on 40000 Grandmaster Games + 20000 Synthetic Games. 90 Million Positions

### Repetition Rules
* 100% World Xiangqi Federation Repetition Rules Coverage
* Full Chasing Rule Coverage
* Understands Perpetual Check, Kill, Chase, Exhange, Block, Offer, Idle, etc.



