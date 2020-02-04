self: super: with super;

let
  mkBin = { name, script, buildInputs ? [] }:
    runCommand name { inherit buildInputs; } ''
      mkdir -p $out/bin
      cp ${script} $out/bin/${name}
      chmod +x $out/bin/${name}
      patchShebangs $out/bin
    '';
in rec {
  update-deps = writeScriptBin "update-deps" ''
    #!${dash}/bin/dash
    set -e

    GIT_JSON_FILTER='with_entries(select(.key | in({"url":0,"rev":0,"date":0})))'
    export PATH=${jq}/bin:${nix-prefetch-git}/bin:$PATH
    input=''${1-/dev/stdin}
    if test -n "$1"; then
      output=$(mktemp)
    else
      output=/dev/stdout
    fi
    cat $input \
      | jq -r '. as $o | keys | map(.+" "+$o[.].url)[]' \
      | while read k v; do echo "{\"$k\": $(nix-prefetch-git $v | jq -r "$GIT_JSON_FILTER")}"; done \
      | jq -s 'reduce .[] as $x ({}; . * $x)' > $output
    if { test $input != /dev/stdin && test $output != /dev/stdout; }; then
      mv $output $input
    fi
  '';

  rtrav = writeScriptBin "rtrav" ''
    #!${dash}/bin/dash
    set -e
    rtrav_() {
      test -e "$2/$1" && printf %s "$2" || { test "$2" != / && rtrav_ "$1" "$(dirname $2)"; }
    }
    rtrav_ $@
  '';

  src-block = mkBin {
    name = "src-block";
    script = ./src-block;
    buildInputs = [ perl ];
  };

  scut = writeScriptBin "scut" ''
    #!${dash}/bin/dash
    cut -c-$(tput cols)
  '';

  jwatch = writeScriptBin "jwatch" ''
    #!${dash}/bin/dash
    watch -n20 -tc 'echo $(tput bold)'"$2"'$(tput sgr0); echo; ${go-jira}/bin/jira '"$1"' </dev/null | ${scut}/bin/scut'
  '';

  pass-push = writeScriptBin "pass-push" ''
    #!${dash}/bin/dash
    git -C ~/.password-store commit -m "Update submodules" -a
    git -C ~/.password-store push --recurse-submodules=on-demand
  '';
}
