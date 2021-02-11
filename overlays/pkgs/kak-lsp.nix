{ lib, stdenv, makeOverridable, runCommand, fetchurl, makeWrapper, writeText }:
let
  version = "9.0.0";
  name = "kak-lsp-${version}";
  src' = runCommand "kak-lsp-unpack" {} ''
    mkdir -p $out
    ( cd $out
      tar xzvf ${fetchurl {
        url = "https://github.com/ul/kak-lsp/releases/download/v${version}/kak-lsp-v${version}-x86_64-unknown-linux-musl.tar.gz";
        sha256 = "1g7gsb84zqr34829j5f2vhalshjxwfdwazcvrdksm7xgf7cwb8pi";
      }}
    )
  '';
in makeOverridable (
  { src ? src'
  #, config ? (builtins.readFile "${src}/kak-lsp.toml")
  #, extraConfig ? ""
  }: stdenv.mkDerivation {
    inherit name src;

    #buildInputs = [ makeWrapper ];
    #installPhase = ''
    #  mkdir -p $out/bin # $out/share/examples
    #  cp kak-lsp $out/bin/kak-lsp
    #  wrapProgram $out/bin/kak-lsp \
    #    --add-flags "--config ${writeText "kak-lsp.toml" (config + ''
    #                            '' + extraConfig)}"
    #'';

    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      ls -al
      mkdir -p $out/bin
      cp kak-lsp $out/bin/kak-lsp
      patchShebangs $out/bin/kak-lsp
    '';

    meta = with lib; {
      homepage = https://github.com/ul/kak-lsp;
      description = "Kakoune Language Server Protocol client";
      license = licenses.unlicense;
      maintainers = with maintainers; [ ];
      platforms = [ "x86_64-linux" ];
    };
  }
) {}
