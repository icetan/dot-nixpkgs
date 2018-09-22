self: super: with super;
rec {
  signal-cli = callPackage (import ./signal-cli.nix) {};
  javacs = import ./javacs { inherit pkgs; };
  kak-lsp = (callPackage (import ./kak-lsp.nix) {}) {
    extraConfig = ''
      [language.typescript]
      extensions = ["ts", "tsx"]
      roots = ["tsconfig.json", "package.json"]
      command = "javascript-typescript-stdio"

      [language.java]
      extensions = ["java"]
      roots = ["pom.xml"]
      command = "javacs"

      [language.scala]
      extensions = ["scala", "sbt"]
      roots = ["build.sbt"]
      command = "coursier"
      args = ["launch", "-r", "bintray:scalameta/maven", "org.scalameta:metals_2.12:0.1.0-M1+262-5e24738b", "-M", "scala.meta.metals.Main"]
    '';
    # ${nodePackages.javascript-typescript-langserver}/bin/javascript-typescript-stdio
    # ${javacs}/bin/javacs
  };
}
