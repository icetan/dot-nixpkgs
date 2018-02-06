{ pkgs ? import <nixpkgs> {} }: with pkgs;

let
  inherit (builtins) fromJSON readFile;

  git-src = (fromJSON (readFile ./deps.json)).kakoune;
  kakoune-git = kakoune.overrideDerivation (oldAttr: {
    name = "kakoune-git-${lib.substring 0 10 git-src.date}";
    src = fetchgit (lib.filterAttrs (k: v: k != "date") git-src);
    buildInputs = oldAttr.buildInputs ++ [ pkgconfig ];
  });
  kakix = callPackage (import ./kakix.nix) { kakoune = kakoune-git; };

  plugins = callPackage (import ./plugins.nix) {};
in kakix {
  deps = [
    ./rc/settings.kak
    ./rc/highlight.kak
    ./rc/map.kak

    ./rc/linenr.kak
    ./rc/search.kak
    ./rc/xsel.kak
    ./rc/expandtab.kak
    ./rc/fzf.kak
    ./rc/git-edit.kak
    ./rc/auto-mkdir.kak
    ./rc/mu.kak
  ] ++ plugins;
}
