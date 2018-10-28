{ lib, stdenv, runCommand, fetchurl, makeWrapper, writeText }: let
  version = "5.9.0";
  name = "kak-lsp-${version}";
  src = runCommand "kak-lsp-unpack" {} ''
    mkdir -p $out
    ( cd $out
      tar xzvf ${fetchurl {
        url = "https://github.com/ul/kak-lsp/releases/download/v${version}/kak-lsp-v${version}-x86_64-unknown-linux-musl.tar.gz";
        sha256 = "1ny11jx75x7m936ndnn7v96zipj9zs8i43zqpr81k5fdgwgy43bb";
      }}
    )
  '';
  # XXX: Why wont this work?
  #src = fetchTarball {
  #  url = "https://github.com/ul/kak-lsp/releases/download/v${version}/kak-lsp-v${version}-x86_64-unknown-linux-musl.tar.gz";
  #  sha256 = "1vrjy30wcs63i7ja2knyq3m09fy0qyic9141nwb7w6ildbmkrqb0";
  #};
in
{ config ? (builtins.readFile "${src}/kak-lsp.toml")
, extraConfig ? ""
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
}
