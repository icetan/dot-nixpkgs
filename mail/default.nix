{ pkgs ? import <nixpkgs> {} }: with pkgs; let
  inherit (lib) optional concatMapStrings concatMapStringsSep concatStrings
    mapAttrsToList findFirst;

  setAccounts = accounts: let
    defaultOutlookAccount = findFirst
      (a: (a.type == "outlook" || a.type == "generic") && (a.name == "default")) null accounts;

    optionalPackages = [ ]
      ++ (optional (defaultOutlookAccount != null) (myMutt defaultOutlookAccount))
    ;

    myMutt = callPackage (import ../mutt) {
      isync = myIsync;
      msmtp = myMsmtp;
      my-mail-utils = utils;
    };

    myKhal = callPackage (import ../khal.nix) {};
    khalFormat = "» {start-end-time-style}{repeat-symbol} {title} @ {location}{description-separator}{description}";

    myIsync = (callPackage (import ../isync) {}) accounts;

    myMsmtp = (callPackage (import ../msmtp) {}) accounts;

    util-scripts = rec {
      mail-sync = writeScript "mail-sync" ''
        #!${dash}/bin/dash
        #set -e
        to_sync="''${1-${concatMapStringsSep " " (a: a.name) accounts}}"
        sync_account() {
          case "$1" in
            ${concatMapStrings (a: with a; ''
            ${name})
              echo SYNCING ACCOUNT: ${name} '<${email}>'
              mkdir -p "${root}/${dir}"
              ${myIsync}/bin/mbsync ${name}
              ${mu}/bin/mu index -m "${root}/${dir}" --my-address="${email}"
              ;;
            '') accounts}
            *)
              echo >&2 Error: $1 not a valid account name
              exit 1
          esac
        }

        for n in $to_sync; do
          sync_account "$n"
        done
      '';

      mail-view = writeScript "mail-view" ''
        #!${dash}/bin/dash
        set -e
        file=$3
        enc=$2
        conv() {
          iconv $([ "$enc" ] && echo -f$(echo "$enc" | tr [:lower:] [:upper:])) -tUTF8 < "$file" | tr -d \\r
        }
        case "$1" in
          text/html)
            conv | ${elinks}/bin/elinks -dump -force-html -dump-width 80
            ;;
          text/calendar|text/ics)
            conv | ${myKhal}/bin/khal printics --format '{start-date} ${khalFormat}' /dev/stdin
            ;;
          text/enriched)
            conv | pandoc -f rtf -t plain
            ;;
          image/*)
            echo "Can't display images"
            ${feh}/bin/feh "$3" 2> /dev/null &
            ;;
          *)
            conv | fmt -cs -w 100
            ;;
        esac
      '';

      mail-unread = writeScript "mail-unread" ''
        #!${dash}/bin/dash
        ${mu}/bin/mu find maildir:/Inbox flag:u >/dev/null 2>&1
      '';

      calendar-sync = writeScript "calendar-sync" ''
        #!${dash}/bin/dash
        curl -sL "''${1:-$ICS_SYNC_URL}" | ${myKhal}/bin/khal import --batch /dev/stdin
      '';

      agenda = writeScript "kagenda" ''
        #!${dash}/bin/dash
        watch -n 300 -ct '${myKhal}/bin/khal --color list --format "${khalFormat}" today ''${1:-20} days | fold -s; ${calendar-sync} >/dev/null 2>&1 &'
      '';
    };

    utils = runCommand "mail-utils" {} ''
      mkdir -p $out/bin
      ${concatStrings (mapAttrsToList (name: script: ''
        ln -s ${script} $out/bin/${name}
      '') util-scripts)}
    '';
  in (buildEnv {
    name = "mail-env";
    ignoreCollisions = true;
    paths = [
      myIsync
      myMsmtp
      myKhal
      mu
      utils
    ] ++ optionalPackages;
  }) // {
    inherit accounts setAccounts;
    addAccounts = a: setAccounts (accounts ++ a);
  };
in setAccounts []
