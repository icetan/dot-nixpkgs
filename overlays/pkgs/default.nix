self: super: with super;
let
  metals_version = "0.4.0";
  nightly = self.latest.rustChannels.nightly;
  buildRustPackage = self.rustPlatform.buildRustPackage.override {
    inherit (nightly) rustc cargo;
  };
in rec {
  docker-credential-helpers = callPackage (import ./docker-credential-helpers.nix) {};
  signal-cli = callPackage (import ./signal-cli.nix) {};
  javacs = import ./javacs { inherit pkgs; };
  inherit (callPackage (import ./kak-lsp.nix) {}) kak-lsp;
  kak-lsp-extra = makeOverridable kak-lsp.override {
    extraConfig = ''
      [language.typescript]
      filetypes = ["ts", "tsx"]
      roots = ["tsconfig.json", "package.json"]
      command = "javascript-typescript-stdio"

      [language.java]
      filetypes = ["java"]
      roots = ["pom.xml"]
      command = "javacs"

      [language.scala]
      filetypes = ["scala", "sbt"]
      roots = ["build.sbt"]
      command = "coursier"
      args = ["launch"
             , "-r", "bintray:scalameta/maven"
             , "org.scalameta:metals_2.12:${metals_version}"
             , "-M", "scala.meta.metals.Main"]

      [language.elm]
      filetypes = ["elm"]
      roots = ["elm.json"]
      command = "elm-language-server"

      [language.nix]
      filetypes = ["nix"]
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

  nix-lsp = buildRustPackage {
    name = "nix-lsp";
    src = fetchFromGitLab {
      owner = "jD91mZM2";
      repo = "nix-lsp";
      rev = "0db95183edf2f6be9bfff23e4a59a721d60628c7";
      sha256 = "1b5m3ghb4a5pzn4nclzssqs9s3j4ks5nag0nrvlaz8r2ms2pv5qi";
    };
    cargoSha256 = "1n01dzm0ngy1kn42xdmkcc83cxkk9552l5spd5a4ack4s4rdlrm2";

    # See https://github.com/NixOS/nixpkgs/issues/25863#issuecomment-302633494
    RUSTFLAGS="-L ${nightly.rust}/lib/rustlib/x86_64-unknown-linux-gnu/lib/";
  };
}
