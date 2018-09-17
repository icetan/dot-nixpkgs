{ lib, stdenv, runCommand, fetchurl, makeWrapper, writeText }: let
  version = "5.2.2";
  name = "kak-lsp-${version}";
  src = runCommand "kak-lsp-unpack" {} ''
    mkdir -p $out
    ( cd $out
      tar xzvf ${fetchurl {
        url = "https://github.com/ul/kak-lsp/releases/download/v${version}/kak-lsp-v${version}-x86_64-unknown-linux-musl.tar.gz";
        sha256 = "0i7cm9ix3y2b4xky8jsxhxf0ffbpbl9287kpx5ah32spi654x4wr";
      }}
    )
  '';
  #src = fetchgit {
  #  url = "https://github.com/ul/kak-lsp";
  #  rev = "370281f4ebcb619cfbd474a8f99dbc158f568042";
  #  sha256 = "13lz1qgahwc6704k70ybrw00m0vww8n6slqr7rg220f5barhf1pf";
  #  fetchSubmodules = false;
  #};

  drv = ({
    config ? builtins.readFile "${src}/kak-lsp.toml",
    extraConfig ? ""
  }: stdenv.mkDerivation {
    inherit name src;

    buildInputs = [ makeWrapper ];
    #buildPhase = ''
    #  cargo build --release
    #'';

    installPhase = ''
      mkdir -p $out/bin # $out/share/examples
      cp kak-lsp $out/bin/kak-lsp
      wrapProgram $out/bin/kak-lsp \
        --add-flags "--config ${writeText "kak-lsp.toml" (config + ''
                                '' + extraConfig)}"
    '';

    meta = with stdenv.lib; {
      homepage = https://github.com/ul/kak-lsp;
      description = "Kakoune Language Server Protocol client";
      license = licenses.unlicense;
      maintainers = with maintainers; [ ];
      platforms = [ "x86_64-linux" ];
    };
  });
in drv
