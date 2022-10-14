# This is the setup-hook that gets installed automatically whenever a package
# takes a dependency on this package.
# TODO(fzakaria): Understand how to integrate shellcheck similar to
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/trivial-builders.nix#L274

nix-harden-needed-hook() {
    # TODO(fzakaria): Understand the difference between $out and $prefix
    local dir="$prefix"
    [ -e "$dir" ] || return 1

    header "Hardening the dynamic shared libraries in $dir"

    for i in $(find $dir -type f -name '*.so*'); do
        # sometimes there can be linker scripts matching *.so*
        if isELF "$i"; then
            patchelf --set-soname $i $i
        fi
    done
}

fixupOutputHooks+=(nix-harden-needed-hook)
