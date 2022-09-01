# This is the setup-hook that gets installed automatically whenever a package
# takes a dependency on this package.
# TODO(fzakaria): Understand how to integrate shellcheck similar to
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/trivial-builders.nix#L274

nix-harden-needed-hook() {
    # TODO(fzakaria): Understand the difference between $out and $prefix
    local dir="$prefix"
    [ -e "$dir" ] || return 1

    header "Hardening the dynamic shared libraries in $dir"

    local i
    while IFS= read -r -d $'\0' i; do

        # Optimization check -- just see if it's an ELF file
        if ! isELF "$i"; then continue; fi

        # Try to read the SONAME
        @ruby@/bin/ruby @nixHardenNeededScript@ "${i}"

    # The spacing in the find command is very important
    # especially for the brackets.
    done <  <(find $dir -type f \
            \( -name '*.so' -o -name '*.so.*' \) -print0)

}

fixupOutputHooks+=(nix-harden-needed-hook)