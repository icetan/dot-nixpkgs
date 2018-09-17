self: super: with super;
rec {
  signal-cli = callPackage (import ./signal-cli.nix) {};
  kak-lsp = makeOverridable (callPackage (import ./kak-lsp.nix) {}) {
    extraConfig = ''
      [language.typescript]
      extensions = ["ts", "tsx"]
      roots = ["tsconfig.json", "package.json"]
      command = "${nodePackages.javascript-typescript-langserver}/bin/javascript-typescript-stdio"
    '';
  };
}
