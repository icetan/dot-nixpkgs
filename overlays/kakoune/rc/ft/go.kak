hook global WinSetOption filetype=go %{
  set window formatcmd "gofmt"
  set window lintcmd "golangci-lint run --enable-all --skip-dirs vendor,version,pkg/gen"
  lint-enable
}
