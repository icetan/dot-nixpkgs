self: super: with super;

let
  git-src = (lib.importJSON ./deps.json).kakoune;
  kakoune-git = kakoune.overrideDerivation (oldAttr: {
    src = fetchgit { inherit (git-src) url rev sha256 fetchSubmodules; };
    name = "kakoune-git-${lib.substring 0 10 git-src.date}";
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

      ./rc/ft/xml.kak

      ./rc/mu.kak

      (writeText "pairon.kak" ''
        ${builtins.readFile "${self.pairon}/src/editor-plugins/kakoune/pairon.kak"}

        pairon-global-enable
      '')
    ] ++ plugins;
    binDeps = [ self.pairon ];
  };
}
