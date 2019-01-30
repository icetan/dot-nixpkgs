{ stdenv, pkgconfig, fetchFromGitHub, buildGoPackage }:

let
  owner = "docker";
  pname = "docker-credential-helpers";
  version = "0.6.1";
in
buildGoPackage rec {
  name = "docker-credential-pass-${version}";
  inherit version;

  src =  fetchFromGitHub {
    inherit owner;
    repo = pname;
    rev = "v${version}";
    sha256 = "1xcfgg1nwkff7nzpasrhclyk21yhz7p0cr3r44wypvihvjpaij9k";
  };

  goPackagePath = "github.com/${owner}/${pname}";
  subPackages = [ "pass" ];

  buildInputs = [ pkgconfig ];
  buildPhase = ''
    (cd go/src/${goPackagePath}
      make pass
      ln -s "$PWD/bin" "$NIX_BUILD_TOP/go/bin"
    )
  '';

  meta = with stdenv.lib; {
    description = ''
      docker-credential-helpers is a suite of programs to use native stores to
      keep Docker credentials safe.
    '';
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
    license = licenses.mit;
    homepage = https://github.com/docker/docker-credential-helpers;
  };
}
