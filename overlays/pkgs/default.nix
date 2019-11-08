self: super: with super;
let
  metals_version = "0.4.0";
  nightly = self.latest.rustChannels.nightly;
  nightlyRust = (nightly.rust.override {
    targets = [ "x86_64-unknown-linux-musl" ];
  });
  nightlyCargo = nightly.cargo;
  #nightlyBuildRustPackage = self.callPackage (import <nixpkgs/pkgs/build-support/rust>) {
  #  rust = {
  #    rustc = nightlyRust;
  #    cargo = nightlyCargo;
  #  };
  #};
  nightlyBuildRustPackage = self.rustPlatform.buildRustPackage.override {
    inherit (nightly) rustc cargo;
  };
  buildRustPackage = self.rustPlatform.buildRustPackage;
  binPackage = { name, src, ... }@args: stdenv.mkDerivation {
    inherit name src;
    installPhase = ''
      mkdir -p $out/bin
      cp ./bin/* $out/bin
    '';
  } // args;
  dhallHaskellPackage = { version, subName ? null, subVersion, sha256 }: let
    namePart = lib.optionalString (subName != null) "${subName}-";
    name = "dhall-${namePart}bin-${subVersion}";
  in binPackage {
    inherit name;
    src = fetchTarball {
      inherit sha256;
      url = "https://github.com/dhall-lang/dhall-haskell/releases/download/${version}/dhall-${namePart}${subVersion}-${builtins.currentSystem}.tar.bz2";
    };
  };

  deps = lib.importJSON ../deps.json;
  fetchdep = dep: fetchGit { inherit (dep) url rev; };
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

      #[language.dhall]
      #filetypes = ["dhall"]
      #roots = [".git", ".hg"]
      #command = "dhall-lsp-server"
    '';
    # ${nodePackages.javascript-typescript-langserver}/bin/javascript-typescript-stdio
    # ${javacs}/bin/javacs
  };

  pairon = callPackage (fetchGit {
    url = "https://github.com/icetan/pairon";
    ref = "v0.1.3";
    rev = "a01c6389fa1b3f3fdc8bcc4e843a1a0d1de08137";
  }) {};

  nix-lsp = nightlyBuildRustPackage {
    name = "nix-lsp";
    src = fetchGit {
      url = "git://github.com/jD91mZM2/nix-lsp";
      rev = "0db95183edf2f6be9bfff23e4a59a721d60628c7";
    };
    cargoSha256 = "1n01dzm0ngy1kn42xdmkcc83cxkk9552l5spd5a4ack4s4rdlrm2";

    # See https://github.com/NixOS/nixpkgs/issues/25863#issuecomment-302633494
    RUSTFLAGS="-L ${nightly.rust}/lib/rustlib/x86_64-unknown-linux-gnu/lib/";
  };

  grin-mw = with llvmPackages; buildRustPackage {
    name = "grin-mw";
    src = builtins.fetchGit {
      url = git://github.com/ignopeverell/grin;
      rev = "699d85a79987122d6839cbfd328da847c0b142eb";
    };
    cargoSha256 = "0dbd5jgxkbvsflrawqsj8szagrmhbx9r001zck15hl3zz1mz6jan";

    stdenv = clangStdenv;
    buildInputs = [
      cmake pkgconfig libclang clang llvm git openssl zlib
    ];
    LIBCLANG_PATH = "${libclang}/lib";
  };

  wallet713 = with llvmPackages; buildRustPackage {
    name = "wallet713";
    src = builtins.fetchGit {
      url = git://github.com/vault713/wallet713;
      rev = "34ee0cf132926185de7d5bc354d7a305696b2c34";
    };
    cargoSha256 = "0226188vgxpx9yq8fn2npczq8849pb3vkxk5y7mpj44a9ghqk1h4";

    stdenv = clangStdenv;
    buildInputs = [
      cmake pkgconfig libclang clang llvm git openssl zlib
    ];
    LIBCLANG_PATH = "${libclang}/lib";
  };

  parity-vdb = with super; nightlyBuildRustPackage rec {
    name = "parity-vdb";
    cargoSha256 = "0jc1x1x4svr121v1sdgnplkrvhvd92iv3dsac3pa7a3cxznqv0v6";

    #src = fetchGit {
    #  url = "https://github.com/vulcanize/parity-ethereum";
    #  ref = "master";
    #  rev = "7701f73cdfac34b2171c99b75184062271853991";
    #};

    src = ~/src/maker/parity-ethereum;

    buildInputs = [
      pkgconfig cmake perl mktemp
      systemd.lib systemd.dev openssl openssl.dev
    ];

    cargoBuildFlags = [ "--features final" ];

    #RUSTFLAGS="-L ${nightly.rust}/lib/rustlib/x86_64-unknown-linux-gnu/lib/ -Ctarget-feature=+aes,+sse2,+ssse3";
    RUSTFLAGS="-Ctarget-feature=+aes,+sse2,+ssse3";

    # test result: FAILED. 80 passed; 12 failed; 0 ignored; 0 measured; 0 filtered out
    doCheck = false;

    meta = with stdenv.lib; {
      description = "Fast, light, robust Ethereum implementation";
      homepage = "http://parity.io";
      license = licenses.gpl3;
      maintainers = [ maintainers.akru ];
      platforms = platforms.linux;
    };

    preConfigure = ''
      export HOME=`mktemp -d`
      export RUSTFLAGS="-L ${nightly.rust}/lib/rustlib/x86_64-unknown-linux-gnu/lib/ -Ctarget-feature=+aes,+sse2,+ssse3"
    '';
  };

  libgit2-romkatv = stdenv.mkDerivation {
    name = "libgit2-romkatv";
    src = builtins.fetchGit {
      url = "https://github.com/romkatv/libgit2";
      rev = "7a3b8bfa11084676f30358cba38feb1cd917788c";
    };
    buildInputs = [ cmake openssl python ];
    CMAKE_FLAGS = lib.concatStringsSep " " [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DTHREADSAFE=ON"
      "-DUSE_BUNDLED_ZLIB=ON"
      "-DUSE_ICONV=OFF"
      "-DBUILD_CLAR=OFF"
      "-DUSE_SSH=OFF"
      "-DUSE_HTTPS=OFF"
      "-DBUILD_SHARED_LIBS=OFF"
      "-DUSE_EXT_HTTP_PARSER=OFF"
    ];
  };

  gitstatus = stdenv.mkDerivation {
    name = "gitstatus";
    src = builtins.fetchGit {
      url = "https://github.com/romkatv/gitstatus";
      rev = "7b177d3df477a2df85ae747b90f3dd234c92f090";
    };
    buildInputs = [ clang libgit2-romkatv ];
    installPhase = ''
      mkdir -p $out/bin
      cp gitstatusd $out/bin
    '';
  };

  dhall-haskell = let
    version = "1.27.0";
  in self.buildEnv {
    name = "dhall-haskell-${version}";
    ignoreCollisions = true;
    paths = map (x: dhallHaskellPackage ({ inherit version; } // x)) [
      { subName = null        ; subVersion =  version; sha256 = "1qb4x6xsl5wnwnx4zbp2gnv653gf2fybdh1z27hmlxr4qv0kracv"; }
      { subName = "bash"      ; subVersion = "1.0.24"; sha256 = "0gmdmxlgz632v5rvi17i9lsqjcvbkdjchif6cvwjadfg9hq0c9xd"; }
      { subName = "json"      ; subVersion = "1.5.0" ; sha256 = "1ia9xafz0h0nr358j955yqlzv7h697hm5mk131smw3d49ffk0080"; }
      { subName = "lsp-server"; subVersion = "1.0.2" ; sha256 = "0vlnxmp78jna6bd0yhy8lh5c18lxcqvm9pcnmmrw4rdidy5ax0dj"; }
      { subName = "nix"       ; subVersion = "1.1.9" ; sha256 = "19sw5hvwipzyazlzfys1384pynbb5sfg9rnvbwn6gzd5ppgb0bm8"; }
    ];
  };

  #weechat-matrix-bridge = super.weechat-matrix-bridge.overrideDerivation (args: {
  #  src = fetchdep deps.weechat-matrix;
  #});

  terraform-provider-virtualbox = callPackage ./terraform-provider-virtualbox.nix {};

  pacman-undo = stdenv.mkDerivation {
    name = "pacman-undo";
    src = fetchGit {
      url = "https://github.com/giddie/bits-n-pieces";
      rev = "021a8f3ca949d9e322fc569463b522b36ffc77f3";
    };
    buildInputs = [ ruby ];
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cp pacman-undo/pacman-undo $out/bin/pacman-undo
    '';
  };
}
