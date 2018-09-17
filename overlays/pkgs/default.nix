self: super: with super;
rec {
  signal-cli = callPackage (import ./signal-cli.nix) {};
  kak-lsp = callPackage (import ./kak-lsp.nix) {};
}
