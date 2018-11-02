self: super: with super;
rec {
  signal-cli = callPackage (import ./signal-cli.nix) {};
  javacs = import ./javacs { inherit pkgs; };
  kak-lsp = (callPackage (import ./kak-lsp.nix) {}) {
    extraConfig = ''
      [language.typescript]
      extensions = ["ts", "tsx"]
      roots = ["tsconfig.json", "package.json"]
      command = "javascript-typescript-stdio"

      [language.java]
      extensions = ["java"]
      roots = ["pom.xml"]
      command = "javacs"

      [language.scala]
      extensions = ["scala", "sbt"]
      roots = ["build.sbt"]
      command = "coursier"
      args = ["launch", "-r", "bintray:scalameta/maven", "org.scalameta:metals_2.12:0.1.0-M1+262-5e24738b", "-M", "scala.meta.metals.Main"]

      [language.elm]
      extensions = ["elm"]
      roots = ["elm.json"]
      command = "elm-language-server"

      [language.nix]
      extensions = ["nix"]
      roots = [".git", ".hg"]
      command = "nix-lsp"
    '';
    # ${nodePackages.javascript-typescript-langserver}/bin/javascript-typescript-stdio
    # ${javacs}/bin/javacs
  };

  pairon = callPackage (import (fetchFromGitHub {
    owner = "icetan";
    repo = "pairon";
    rev = "87e15fedfcd496d070e4bee462dfa8f67c0a8530";
    sha256 = "0zzm0s0anb7d6lnbn28njvj6by3jday2jvd3lf135vara4gi1s5r";
  })) {};

  nix-lsp = import (fetchFromGitLab {
    owner = "jD91mZM2";
    repo = "nix-lsp";
    rev = "f0ad31d24e350adf52a3689812cecbcf6406d125";
    sha256 = "05l44wql2i5xa5ni9rqanqgm3iv32wkdi1acck0mbjrr5pkrzqqi";
  });
}
