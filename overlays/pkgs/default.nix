self: super: with super;
rec {
  signal-cli = callPackage (import ./signal-cli.nix) {};
}
