self: super: with super; let
  androidsdk' = androidenv.androidsdk {
    platformVersions = [ "7" "25" ]; # Anything between 2 - 23
    abiVersions = [ "x86_64" ]; # Also possible: x86, mips, x86_64, armeabi-v7a
    useGoogleAPIs = true;
    useExtraSupportLibs = true;
    useGooglePlayServices = true;
  };
in {
  maven-oracle = (maven.override {
    jdk = oraclejdk8psu;
  }).overrideDerivation (_: {
    name = "maven-oracle";
  });

  maven-old = maven.overrideDerivation (_: rec {
    version = "3.0.5";
    name = "apache-maven-${version}";
    src = fetchurl {
      url = "mirror://apache/maven/maven-3/${version}/binaries/${name}-bin.tar.gz";
      sha256 = "1nbx6pmdgzv51p4nd4d3h8mm1rka8vyiwm0x1j924hi5x5mpd3fr";
    };
  });

  android-env = stdenv.lib.overrideDerivation (buildEnv {
    name = "android-env";
    ignoreCollisions = true;
    paths = [ androidsdk androidndk gradle ];
  }) (oldAttr: {
    shellHook = ''
      export ANDROID_HOME=${androidsdk}/libexec
    '';
  });
}
