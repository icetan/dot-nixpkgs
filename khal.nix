{ khal, runCommand, makeWrapper, writeText }:

let
  config = writeText "config" ''
    [calendars]
    [[private]]
    path = ~/.local/share/khal/calendars/private
    type = calendar

    [default]
    default_calendar = private

    [locale]
    timeformat = %H:%M
    dateformat = %Y-%m-%d
    longdateformat = %Y-%m-%d
    datetimeformat = %Y-%m-%d %H:%M
    longdatetimeformat = %Y-%m-%d %H:%M
  '';
in runCommand "khal-wrapper" { buildInputs = [ makeWrapper ]; } ''
  makeWrapper ${khal}/bin/khal $out/bin/khal \
    --add-flags '-c ${config}'
  ln -s ${khal}/share $out
''
