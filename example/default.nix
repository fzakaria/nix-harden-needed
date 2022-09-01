let pkgs = import <nixpkgs> {
  overlays = [
    (import ../overlay.nix)
  ];
};
in
with pkgs;
let libf = stdenv.mkDerivation rec {
  pname = "libf";
  version = "0.1";

  dontUnpack = true;

  buildInputs = [
    nix-harden-needed-hook
  ];

  buildPhase = ''
    # Enable if you'd like to see wrapper debug information
    # NIX_DEBUG=1 
    $CC -shared -o libf.so -Wl,-soname,libf.so -x c - <<EOF
        #include <stdio.h>
        void f() { puts("hello world"); }
    EOF
  '';

  installPhase = ''
    mkdir -p $out/lib
    mv libf.so $out/lib
  '';
};
in
stdenv.mkDerivation rec {
  pname = "app";

  version = "0.1";

  dontUnpack = true;

  buildInputs = [
    libf
  ];

  buildPhase = ''
    # Enable if you'd like to see wrapper debug information
    # NIX_DEBUG=1 
    $CC -o app -lf -x c - <<EOF
        void f();
        int main() { f(); }
    EOF
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv app $out/bin
  '';

}
