{ stdenv, lib, buildGoPackage, fetchFromGitHub, pkgconfig, makeWrapper, cdrtools }:

# USAGE:
# install the following package globally or in nix-shell:
#
#   (terraform.withPlugins (p: [p.libvirt]))
#
# configuration.nix:
#
#   virtualisation.libvirtd.enable = true;
#
# terraform-provider-libvirt does not manage pools at the moment:
#
#   $ virsh --connect "qemu:///system" pool-define-as default dir - - - - /var/lib/libvirt/images
#   $ virsh --connect "qemu:///system" pool-start default
#
# pick an example from (i.e ubuntu):
# https://github.com/dmacvicar/terraform-provider-libvirt/tree/master/examples

buildGoPackage rec {
  name = "terraform-provider-virtualbox-${version}";
  version = "0.2.0";

  goPackagePath = "github.com/terra-farm/terraform-provider-virtualbox";

  src = fetchFromGitHub {
    owner = "terra-farm";
    repo = "terraform-provider-virtualbox";
    rev = "v${version}";
    sha256 = "09056iczw835mkrblgihzgki2n2mi4f8s04ljnk4hi6la7hbaj5c";
  };

  buildInputs = [ pkgconfig makeWrapper ];

  # mkisofs needed to create ISOs holding cloud-init data,
  # and wrapped to terraform via deecb4c1aab780047d79978c636eeb879dd68630
  #propagatedBuildInputs = [ cdrtools ];

  # Terraform allow checking the provider versions, but this breaks
  # if the versions are not provided via file paths.
  postBuild = "mv go/bin/terraform-provider-virtualbox{,_v${version}}";

  meta = with lib; {
    homepage = https://github.com/terra-farm/terraform-provider-virtualbox;
    description = "Terraform provider for VirtualBox";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}

#toDrv = data:
#    buildGoPackage rec {
#      inherit (data) owner repo version sha256;
#      name = "${repo}-${version}";
#      goPackagePath = "github.com/${owner}/${repo}";
#      subPackages = [ "." ];
#      src = fetchFromGitHub {
#        inherit owner repo sha256;
#        rev = "v${version}";
#      };
#
#
#      # Terraform allow checking the provider versions, but this breaks
#      # if the versions are not provided via file paths.
#      postBuild = "mv go/bin/${repo}{,_v${version}}";
#    };
