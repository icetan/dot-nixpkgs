{ pkgs }: with pkgs;

{
  rtrav = runCommand "rtrav" {} ''
    mkdir -p $out/bin
    printf %s 'rtrav_() { test -e $2/$1 && printf %s "$2" || { test $2 != / && rtrav_ $1 `dirname $2`;}; }
    rtrav_ $@' > $out/bin/rtrav
    chmod +x $out/bin/rtrav
  '';
}
