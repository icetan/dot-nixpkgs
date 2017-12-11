{ haskellPackages }:

haskellPackages.ghcWithPackages (haskellPackages: with haskellPackages; [
  mtl
  QuickCheck
  random
  text
  alex
  cabal-install
  cpphs
  happy
  ghc-paths
  hdevtools
])
