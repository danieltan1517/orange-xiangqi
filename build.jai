#run {

  defer {
    set_build_options_dc(.{do_output=false});
  }

  install_bayesian_elo();

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




#import "Compiler";
#import "Process";
