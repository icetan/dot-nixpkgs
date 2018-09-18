{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
, mavenix ? pkgs.callPackage (import ./mavenix.nix) {}
, maven ? pkgs.maven.override { jdk = pkgs.oraclejdk10; }
, src ? pkgs.fetchFromGitHub {
    owner = "georgewfraser";
    repo = "vscode-javac";
    rev = "52145590facdc609dc8c39babcff741044e7848e";
    sha256 = "08h4yrrryarxrsljcrjxm47qzl7aw3lgk1ga32fpih56mlkd4lq1";
  }
}: let
  jar = mavenix {
    inherit maven src;
    infoFile = ./mavenix-info.json;
    MAVEN_OPTS = " -DskipTests=true -Dfile.encoding=UTF-8";
    postInstall = ''
      mkdir -p $out/share/java
      cp out/fat-jar.jar $out/share/java/
    '';
  };
in pkgs.runCommand "javacs" {
  buildInputs = with pkgs; [ makeWrapper ];
  meta = with pkgs.stdenv.lib; {
    homepage = https://github.com/georgewfraser/vscode-javac;
    description = "Java Compiler API Language Server";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
} ''
  mkdir -p $out/bin
  makeWrapper ${maven.jdk}/bin/java $out/bin/javacs \
    --add-flags "-jar ${jar.build}/share/java/fat-jar.jar" \
    --add-flags "-Xverify:none" \
    --set JAVA_HOME "${maven.jdk}/jre" \
    --prefix PATH : ${maven}/bin
''
