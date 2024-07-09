#run {
  defer {
    set_build_options_dc(.{do_output=false});
  }

  w := compiler_create_workspace("workspace");
  target_options := get_build_options(w);
  args := target_options.compile_time_command_line;
  if args.count == 1 {
    print("Type 'install_bayeselo' to install BayesianElo\n");
    print("Type 'elo' to calculate the elo\n");
    print("Type 'games' to download a set of grandmaster games\n");
    print("Type 'ai' to build the ai\n");
    print("Type 'ui' to build the ui\n");
    print("Type 'nnue' to download the NNUE model.\n");
    print("Type 'release' to build an optimized build\n");
    print("Type 'avx2' to build NNUE with AVX2 instructions\n");
    print("Type 'sse' to build NNUE with SSE instructions\n");
    print("Type 'cpu' to build NNUE with CPU instructions\n");
    print("Type 'clean' to clean the build.\n");
    return;
  }

  build_dataset := false;
  build_ai    := false;
  build_ui    := false;
  release     := false;
  clean_build := false;
  nnue_type = .auto;
  for arg: args {
    if arg == {
    case "nnue";
      download_nnue_model();
    case "install_bayeselo"; 
      install_bayesian_elo();
    case "elo";
      bayeselo_run_pgn("ratings.txt", "game.pgn");
    case "games";
      download_xiangqi_games();
    case "all";
      build_ai = true;
      build_ui = true;
    case "ai";
      build_ai = true;
    case "ui";
      build_ui = true;
    case "dataset";
      build_dataset = true;
    case "release";
      release = true;
    case "avx2";
      nnue_type = .avx2;
    case "sse";
      nnue_type = .sse;
    case "cpu";
      nnue_type = .cpu;
    case "clean";
      clean_build = true;
    }
  }
  
  if clean_build == true {
    clean();
  }

  if build_ai == true {
    build("orange", add_ai_files, release);
  }

  if build_ui == true {
    build("xiangqi", add_ui_files, release);
  }

  if build_dataset == true {
    build("dataset", add_dataset_files, release);
  }

}

nnue_type: NNUE_Type;

nnue_file :: (w: Workspace) {
  cpu_info := get_cpu_info();
  if nnue_type == .auto {
    print("Detecting CPU instruction set...\n");
    if check_feature(cpu_info.feature_leaves, .AVX2) {
      nnue_type = .avx2;
    } else if check_feature(cpu_info.feature_leaves, .SSE) {
      nnue_type = .sse;
    } else {
      nnue_type = .cpu;
    }
  }

  if #complete nnue_type == {
  case .auto;
    assert(false);
  case .cpu;
    print("Building Engine with NNUE CPU\n");
    add_build_file("nnue_cpu.jai", w);  
  case .sse;
    print("Building Engine with NNUE SSE\n");
    add_build_file("nnue_sse.jai", w);  
  case .avx2; 
    print("Building Engine with NNUE AVX2\n");
    add_build_file("nnue_avx2.jai", w);
  }
}


add_ui_files :: (w: Workspace) {
  add_build_file("ui.jai", w);  
  add_build_file("board.jai", w);  
  add_build_file("opening_book.jai", w);
}

add_ai_files :: (w: Workspace) {
  add_build_file("eval.jai", w);
  nnue_file(w);
  add_build_file("ucci.jai", w);  
  add_build_file("board.jai", w);
  add_build_file("search.jai", w);
}

add_dataset_files :: (w: Workspace) {
  add_build_file("eval.jai", w);  
  nnue_file(w);
  add_build_file("dataset.jai", w);  
  add_build_file("board.jai", w);
  add_build_file("search.jai", w);
}

build :: (exe_name: string, $add_files: #type (Workspace), release: bool) -> w: Workspace {
  w := compiler_create_workspace();
  target_options := get_build_options(w);
  target_options.output_executable_name = exe_name;

  if release == true {
    set_optimization(*target_options, .VERY_OPTIMIZED);
    target_options.stack_trace = false;
  } else {
    target_options.backend = .X64;
    target_options.stack_trace = true;
  }

  set_build_options(target_options, w);
  add_files(w);
  return w;
}

remove_file :: (path: string) {
  if file_exists(path) {
    #if OS == .WINDOWS {
      run_command("powershell", "-Command", sprint("rm -R -Fo %", path));
    } else {
      run_command("rm", "-rf", path);
    }
  }
}

clean :: () {
  remove_file(".build");
  #if OS == .WINDOWS {
    remove_file("orange.exe");
    remove_file("orange.pdb");
    remove_file("xiangqi.exe");
    remove_file("xiangqi.pdb");
  } else {
    remove_file("orange");
    remove_file("xiangqi");
  }
}

install_bayesian_elo :: () {
  // (Daniel) Feb 20, 2023
  // install/make Bayesian Elo by Remi Coulom.
  // used to estimate the elo, i.e. the playing strength of the engine
  // https://www.remi-coulom.fr/Bayesian-Elo/ for more information.
  // assumes you have git/make installed.

  run_command("git", "clone", "https://github.com/ddugovic/BayesianElo");
  run_command("make", "--directory=BayesianElo/src");
}

bayeselo_run_pgn :: (output_file: string, pgn_files: ..string) {

  read_bayeselo :: () #expand {
    while true {
      success = read_from_process(*process, output, error, timeout_ms=500);
      str: string;
      str.data = output.data;
      str.count = output.count;
      print("%", str);
      if success == true 
        break;
    }
  }

  write_bayeselo :: (command: string) #expand {
    bytes: [] u8;
    bytes.data = command.data;
    bytes.count = command.count;
    success = write_to_process(*process, bytes);
    print(command);
    if success == false then {
      compiler_report("bayeselo error.", mode=Report.INFO);
      `return;
    }
    read_bayeselo();
  }

  process: Process;
  success: bool;
  output: [512] u8;
  error:  [512] u8;
  success = create_process(*process, "BayesianElo/src/bayeselo");
  if success == false then {
    compiler_report("bayeselo cannot be found.", mode=Report.INFO);
    return;
  }

  read_bayeselo();

  defer {
    deinit(*process);
    kill_process(*process);
  }

  for pgn_file: pgn_files {
    print("Writing pgn file: %\n", pgn_file);
    command := tprint("readpgn %1%2", pgn_file, NEWLINE);
    write_bayeselo(command);
  }

  command := tprint("elo%1", NEWLINE);
  write_bayeselo(command);

  command = tprint("mm%1", NEWLINE);
  write_bayeselo(command);

  command = tprint("exactdist%1", NEWLINE);
  write_bayeselo(command);

  command = tprint("ratings>%1%2", output_file, NEWLINE);
  write_bayeselo(command);

  command = tprint("x%1", NEWLINE);
  write_bayeselo(command);
  write_bayeselo(command);

  // output the elo results to the screen.
  print("\n");
  run_command("cat", output_file);
}

download_file :: (link: string, output_file: string) {
  #if OS == .WINDOWS {
    run_command("powershell", "-Command", sprint("Invoke-WebRequest \"%\" -O %", link, output_file));
  } else {
    run_command("wget", link, "-O", output_file);
  }
}

unzip_file :: (zip_file: string) {
  #if OS == .WINDOWS {
    run_command("powershell", "-Command", sprint("Expand-Archive % -DestinationPath .", zip_file));
  } else {
    run_command("unzip", zip_file);
  }
}

// how to download something from the command line using "wget".
download_xiangqi_games :: () {
  fileId :: "14h_pI8Tel_Z6NV2SL9Z7_Y2hNdvC7-26";
  link := tprint("https://drive.google.com/uc?export=download&id=%1", fileId);
  download_file(link, "xiangqi_games.zip");
  unzip_file("xiangqi_games.zip");
  remove_file("xiangqi_games.zip");
}

download_nnue_model :: () {
  fileId :: "1fbj9kK0zx29D9VgJFLtfcIbJ82rWVClR";

  link := tprint("https://drive.google.com/uc?export=download&id=%1", fileId);
  download_file(link, "orange7_8_24.zip");
  unzip_file("orange7_8_24.zip");
  remove_file("orange7_8_24.zip");
}

NNUE_Type :: enum {
  auto;
  cpu;
  sse;
  avx2;
}

#if OS == .WINDOWS {
  NEWLINE :: "\r\n";
} else {
  NEWLINE :: "\n";
}

#import "Basic";
#import "Compiler";
#import "Process";
#import "Machine_X64";
#import "File_Utilities";
