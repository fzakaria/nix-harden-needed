# Nix Harden Needed Setup Hook

This repository contains the Nix equivalent of the idea proposed by [Harmen Stoppels](https://stoppels.ch/) in the blog post [Stop searching for shared libraries](https://stoppels.ch/2022/08/04/stop-searching-for-shared-libraries.html).

The idea of the blog post is that if you set the _SONAME_ of shared library to be the absolute path, it will get propagated as the _DT_NEEDED_ entry for the library or application which links against it.
Since in Nix it is always safe to link against the full _/nix/store/ path entry, this ultimately removes the need to have any _RPATH_ or _RUNPATH_ entries.

This setup-hook is used like any other setup-hook and you need only add it as a dependency for it to trigger.

## Why do this?

I have shown in another repository [Shrinkwrap](https://github.com/fzakaria/shrinkwrap) that the cost of walking _RPATH_ can be problematic for binaries that pull in many dependencies. The cost is even worse if you have your Nix store on something like NFS.
This is another attempt at solving the same problem of Shrinkwrap but takes more advantage of systems like Nix that build from the ground up. You only need to set the _SONAME_ correctly once and everything above it profits.

## Example

Imagine a library _libf_ that used this setup hook.
```nix
stdenv.mkDerivation rec {
  pname = "libf";
  version = "0.1";

  dontUnpack = true;

  buildInputs = [
    nix-harden-needed-hook
  ];

  buildPhase = ''
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
```

The _SONAME_ is modified to point to the absolute path of the file.

```console
❯ patchelf --print-soname /nix/store/zir4jfm86i3037lnsaz5br55iwavvhpz-libf-0.1/lib/libf.so
/nix/store/zir4jfm86i3037lnsaz5br55iwavvhpz-libf-0.1/lib/libf.so
```

If we then had a library or executable depend on it.
```nix
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
```

It would propagate the entry into the _DT_NEEDED_ entry correctly, making the need for _RPATH_ redundant.
```console
❯ patchelf --print-needed /nix/store/6pg9d3lwlmgcmmswv937fcy211vkqxch-app-0.1/bin/app
/nix/store/znxycsxlnx2s9zn6g0s0fl4z57ar7aps-libf-0.1/lib/libf.so
libc.so.6
```

## What's next?

It would be great to upstream this into Nixpkgs such that it is the default way of building with _stdenv_.
The benefit would be all binaries in Nix would load much quicker and managing RPATHs would no longer be necessary.