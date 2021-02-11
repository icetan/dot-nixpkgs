{ stdenv, lib, makeWrapper, jre }:

let
  version = "0.6.0";
  name = "signal-cli-${version}";
  src = builtins.fetchTarball {
    url = "https://github.com/AsamK/signal-cli/releases/download/v${version}/signal-cli-${version}.tar.gz";
    sha256 = "0j18jg6g7lhb770jrv8zcf7jk4wlq1qplz85164rv6skmrx6v79i";
  };
in stdenv.mkDerivation {
  inherit name src;
  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r lib $out/lib
    cp bin/signal-cli $out/bin/signal-cli
    wrapProgram $out/bin/signal-cli \
      --prefix PATH : ${lib.makeBinPath [ jre ]} \
      --set JAVA_HOME ${jre}
  '';

  meta = with lib; {
    homepage = https://github.com/AsamK/signal-cli;
    description = "signal-cli (formerly textsecure-cli) provides a commandline and dbus interface for WhisperSystems/libsignal-service-java";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-darwin" "x86_64-linux" "i686-linux" ];
  };
}
