{ pkgs }: with pkgs;

lib.mapAttrs (name: script:
  runCommand name {} ''
    mkdir -p $out/bin
    ln -s ${script} $out/bin/${name}
  ''
) {
  update-deps = writeScript "update-deps" ''
    #!${dash}/bin/dash
    set -e

    export PATH=${jq}/bin:${nix-prefetch-git}/bin:$PATH
    input=''${1-/dev/stdin}
    if [ "$1" ]; then
      output=$(mktemp)
    else
      output=/dev/stdout
    fi
    cat $input \
      | jq -r '. as $o | keys | map(.+" "+$o[.].url)[]' \
      | while read k v; do echo "{\"$k\": $(nix-prefetch-git $v)}"; done \
      | jq -s 'reduce .[] as $x ({}; . * $x)' > $output
    if [[ $input != /dev/stdin && $output != /dev/stdout ]]; then
      mv $output $input
    fi
  '';

  rtrav = writeScript "rtrav" ''
    #!${dash}/bin/dash
    set -e
    rtrav_() {
      test -e $2/$1 && printf %s "$2" || { test $2 != / && rtrav_ $1 `dirname $2`;}
    }
    rtrav_ $@
  '';
}
