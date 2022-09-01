self: super: {
  nix-harden-needed-hook = self.callPackage ./derivation.nix { };
}
