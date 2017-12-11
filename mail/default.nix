{ pkgs ? import <nixpkgs> {} }: with pkgs; let
  inherit (lib) optional concatMapStrings concatMapStringsSep concatStrings
    mapAttrsToList findFirst;

  setAccounts = accounts: let
    defaultOutlookAccount = findFirst
      (a: (a.type == "outlook") && (a.name == "default")) null accounts;

    optionalPackages = [ ]
      ++ (optional (defaultOutlookAccount != null) (myMutt defaultOutlookAccount))
    ;

    myMutt = callPackage (import ../mutt) {};

    myKhal = callPackage (import ../khal.nix) {};
    khalFormat = "{start-end-time-style}{repeat-symbol} {title} @ {location}{description-separator}{description}";

    myIsync = (callPackage (import ../isync) {}) accounts;

    myMsmtp = (callPackage (import ../msmtp) {}) accounts;

    util-scripts = rec {
      mail-sync = writeScript "mail-sync" ''
        set -e
        to_sync="''${1-${concatMapStringsSep " " (a: a.name) accounts}}"
        sync-account() {
          case "$1" in
            ${concatMapStrings (a: with a; ''
            ${name})
              echo SYNCING ACCOUNT: ${name} '<${email}>'
              ${myIsync}/bin/mbsync ${name}
              ${mu}/bin/mu index -m "${dir}" --my-address="${email}"
              ;;
            '') accounts}
            *)
              echo >&2 Error: $1 not a valid account name
              exit 1
          esac
        }

        for n in $to_sync; do
          sync-account "$n"
        done
      '';

      mail-view = writeScript "mail-view" ''
        case "$1" in
          text/html)
            ${elinks}/bin/elinks -dump -force-html -dump-width 80 < "$2"
            ;;
          text/calendar|text/ics)
            ${myKhal}/bin/khal printics --format '{start-date} ${khalFormat}' "$2"
            ;;
          image/*)
            echo "Can't display images"
            ${feh}/bin/feh "$2" 2> /dev/null &
            ;;
          *)
            cat "$2"
            ;;
        esac
      '';

      calendar-sync = writeScript "calendar-sync" ''
        curl -sL "''${1:-$ICS_SYNC_URL}" | ${myKhal}/bin/khal import --batch /dev/stdin
      '';

      agenda = writeScript "kagenda" ''
        watch -n 300 -ct '${calendar-sync}; ${myKhal}/bin/khal --color list --format "${khalFormat}" today ''${1:-20} days'
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
