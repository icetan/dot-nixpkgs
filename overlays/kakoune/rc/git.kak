# TODO: change show-diff to update-diff and figure out how to do show-diff on
#       BufCreate

def -docstring %{auto-git-show-enable: enable showing git diff gutter on buffer
write} \
auto-git-show-enable %{ eval %sh{
  ( test -n "${kak_buffile}" \
    && git ls-files --error-unmatch "${kak_buffile}" \
  ) > /dev/null 2>&1 \
    && printf %s\\n '
      hook -group auto-git buffer BufWritePost .* "git show-diff"
      hook -group auto-git buffer BufReload .* "git show-diff"
    '
}}

def -docstring %{auto-git-show-disable: disable auto git show-diff} \
auto-git-show-disable %{
  remove-hooks buffer auto-git
  try %{
    remove-highlighter window/hlflags_git_diff_flags
  }
}

def -docstring %{auto-git-show-enable: enable showing git diff gutter on buffer
write} \
auto-git-show-global-enable %{
  hook -group auto-git global BufCreate .* auto-git-show-enable
  eval -buffer %sh{ echo "${kak_buflist}" | sed "s/'//g;s/ /,/g" } %{
    auto-git-show-enable
  }
}

def -docstring %{auto-git-show-disable: disable auto git show-diff} \
auto-git-show-global-disable %{
  remove-hooks global auto-git
  eval -buffer %sh{ echo "${kak_buflist}" | sed "s/'//g;s/ /,/g" } %{
    auto-git-show-disable
  }
}
