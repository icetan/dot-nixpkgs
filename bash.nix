{ pkgs } : with pkgs; let
in stdenv.mkDerivation {
  name = "bash-env";
  src = null;
  buildInputs = [
    bash
    bash-completion
  ];
  shellHook = ''
    PS1="\[\e[1;30m\]\h \[\e[0m\]\w"

    test -f ${bash-completion}/share/git/completion/git-prompt.sh && {
      . ${bash-completion}/share/git/completion/git-prompt.sh
      _git_prompt() {
        local git_status="''$(__git_ps1 '%s' | sed 's/\(.*\) /\1/')"
        if [ "''$git_status" ]; then
          if ( echo "''$git_status" | grep -q '[\+\*]%\?''$' ); then
              echo -en ''$'\001\e[31m\002'
          elif ( echo "''$git_status" | grep -q '%''$' ); then
              echo -en ''$'\001\e[33m\002'
          else
              echo -en ''$'\001\e[32m\002'
          fi
          echo -n " ''$git_status"
          echo -en ''$'\001\e[0m\002'
        fi
      }

      export GIT_PS1_SHOWDIRTYSTATE=true
      export GIT_PS1_SHOWUNTRACKEDFILES=true

      PS1="''$PS1\''$(_git_prompt)"
    }

    export PS1="''$PS1\[\e[0;37m\]\''$\[\e[0m\] "
  '';
}
