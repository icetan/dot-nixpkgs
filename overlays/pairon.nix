self: super: with super; {
  pairon = callPackage (import (builtins.fetchTarball {
    url = "https://github.com/icetan/pairon/archive/143480fefc7a53e38dd199e7eb5cf3e14b24dbfa.tar.gz";
    sha256 = "029v9hb8rpa95l680s3zhi390a2i7mpql5nlj0lfq1hi74m961aa";
  })) {};
}
