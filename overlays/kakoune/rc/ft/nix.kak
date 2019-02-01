hook global BufCreate .*\.(nix) %{
  set buffer filetype nix
}
