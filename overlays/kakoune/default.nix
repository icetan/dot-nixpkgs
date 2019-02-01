self: super: with super;

let
  inherit (lib) substring replaceStrings;
  git-src = (lib.importJSON ./deps.json).kakoune;
  kakoune-git = kakoune.overrideDerivation (oldAttr: rec {
    src = fetchgit { inherit (git-src) url rev sha256 fetchSubmodules; };
    version = "v${replaceStrings ["-"] ["."] (substring 0 10 git-src.date)}";
    name = "kakoune-git-${version}";
    buildInputs = oldAttr.buildInputs ++ [ pkgconfig ];
  });
  kakix = callPackage (import ./kakix.nix) { kakoune = kakoune-git; };

  plugins = callPackage (import ./plugins.nix) {};
in {
  inherit kakoune-git;
  kakoune-plugins = kakix {
    name = "${kakoune-git.name}-with-plugins";
    deps = [
      ./rc/settings.kak
      ./rc/highlight.kak
      ./rc/map.kak

      ./rc/linenr.kak
      ./rc/search.kak
      ./rc/xsel.kak
      ./rc/expandtab.kak (writeText "expandtab-enable.kak" "expandtab")
      ./rc/fzf.kak
      ./rc/git-edit.kak
      ./rc/auto-mkdir.kak
      ./rc/surround.kak
      ./rc/git.kak (writeText "git-enable.kak" "auto-git-show-global-enable")

      ./rc/ft/nix.kak
      ./rc/ft/xml.kak
      ./rc/ft/markdown.kak
      ./rc/ft/json.kak

      ./rc/mu.kak

      "${self.pairon}/src/editor-plugins/kakoune/pairon.kak"
      (writeText "pairon-enable.kak" "pairon-global-enable")
    ] ++ plugins;
    binDeps = [ self.pairon ];
  };
}
