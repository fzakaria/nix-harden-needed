{ makeSetupHook
, ruby
, patchelf
, substituteAll
}:
makeSetupHook
{
  name = "nix-harden-needed.sh";
  deps = [ ];
  substitutions = {
    ruby = ruby;
    nixHardenNeededScript = substituteAll { src = ./nix-harden-needed.rb; inherit patchelf ruby; };
  };
} ./nix-harden-needed.sh
    
