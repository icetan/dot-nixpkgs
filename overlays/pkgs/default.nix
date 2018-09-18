self: super: with super;
rec {
  signal-cli = callPackage (import ./signal-cli.nix) {};
  javacs = import ./javacs { inherit pkgs; };
  kak-lsp = (callPackage (import ./kak-lsp.nix) {}) {
    extraConfig = ''
      [language.typescript]
      extensions = ["ts", "tsx"]
      roots = ["tsconfig.json", "package.json"]
      command = "${nodePackages.javascript-typescript-langserver}/bin/javascript-typescript-stdio"

      [language.java]
      extensions = ["java"]
      roots = ["pom.xml"]
      command = "${javacs}/bin/javacs"
    '';
  };
}
