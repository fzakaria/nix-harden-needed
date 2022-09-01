{ nixpkgs ? (import ./nix/sources.nix).nixpkgs
, system ? builtins.currentSystem
}:
let
  sources = import ./nix/sources.nix;
  pkgs = import nixpkgs {
    overlays = [
      (_: super: {
        niv = (import sources.niv { }).niv;
      })
      (import ./overlay.nix)
    ];
    inherit system;
  };
in
{
  nix-harden-needed-hook = pkgs.nix-harden-needed-hook;
}
    