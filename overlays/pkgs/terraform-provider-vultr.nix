{ buildGoPackage, fetchFromGitHub }:

let
  toDrv = data:
    buildGoPackage rec {
      inherit (data) owner repo version sha256;
      name = "${repo}-${version}";
      goPackagePath = "github.com/${owner}/${repo}";
      subPackages = [ "." ];
      src = fetchFromGitHub {
        inherit owner repo sha256;
        rev = "v${version}";
      };


      # Terraform allow checking the provider versions, but this breaks
      # if the versions are not provided via file paths.
      postBuild = "mv go/bin/${repo}{,_v${version}}";
    };
in toDrv {
  owner = "vultr";
  repo = "terraform-provider-vultr";
  version = "1.0.4";
  sha256 = "1p7rmz6v4i4w0jl1zh6bggr2ggh0x6g7xl5vcm78r0513idfwshx";
}
