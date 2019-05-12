{ stdenv, pkgconfig, buildGoPackage }:

let
  owner = "docker";
  pname = "docker-credential-helpers";
  version = "0.6.1";
in buildGoPackage rec {
  name = "docker-credential-pass-${version}";
  inherit version;

  src = fetchTarball {
    url = "https://github.com/${owner}/${pname}/archive/v${version}.tar.gz";
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

  postInstall = ''
    mkdir -p $out/bin
    cp go/src/${goPackagePath}/bin/docker-credential-pass $out/bin
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
