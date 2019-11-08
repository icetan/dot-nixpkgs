{ lib, stdenv, makeOverridable, runCommand, fetchurl, makeWrapper, writeText }:
let
  version = "7.0.0";
  name = "kak-lsp-${version}";
  src' = runCommand "kak-lsp-unpack" {} ''
    mkdir -p $out
    ( cd $out
      tar xzvf ${fetchurl {
        url = "https://github.com/ul/kak-lsp/releases/download/v${version}/kak-lsp-v${version}-x86_64-unknown-linux-musl.tar.gz";
        sha256 = "0br4fyx706k4wjaql4a6lqj18vg0fhyfd7mh1x3nnljjg6i8q27r";
      }}
    )
  '';
  # XXX: Whyyyyyy wont this work?
  #src' = fetchTarball {
  #  url = "https://github.com/ul/kak-lsp/releases/download/v${version}/kak-lsp-v${version}-x86_64-unknown-linux-musl.tar.gz";
  #  sha256 = "0phf0bhmv0qgif1jgx5xnp9w8glxyw1yrdh1xcg7w590dhpdsplm";
  #};
in {
  kak-lsp = makeOverridable (
    { src ? src'
    , config ? (builtins.readFile "${src}/kak-lsp.toml")
    , extraConfig ? ""
    }: stdenv.mkDerivation {
      inherit name src;

      buildInputs = [ makeWrapper ];

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
    }
  ) {};
}
