hook global BufWritePre .* %{ nop %sh{ dir=$(dirname $kak_buffile)
  [ -d $dir ] || mkdir --parents $dir
}}
