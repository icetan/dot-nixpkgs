with builtins;
let git-src = fromJSON (readFile ./deps.json);
in  import ((fetchGit { inherit (git-src.mavenix) url rev; }) + "/overlay.nix")
