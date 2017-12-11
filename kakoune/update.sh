#!/bin/bash

jq -r '. as $o | keys | map(.+" "+$o[.].url)[]' \
  | while read k v; do echo "{\"$k\": $(nix-prefetch-git $v)}"; done \
  | jq -s 'reduce .[] as $x ({}; . * $x)'
