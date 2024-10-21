{
  description = "A factorio server flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    factorio-headless-src = {
      url = "tarball+https://www.factorio.com/get-download/stable/headless/linux64";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    packages.x86_64-linux.factorio-headless = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
      pkgs.stdenv.mkDerivation {
        name = "factorio-headless";
        src = inputs.factorio-headless-src;
        preferLocalBuild = true;
        dontBuild = true;
        installPhase = ''
          mkdir -p $out/{bin,share/factorio}
          cp -a data $out/share/factorio
          cp -a bin/x64/factorio $out/bin/factorio
          patchelf \
            --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
            $out/bin/factorio
        '';
      };

    packages.x86_64-linux.default = self.packages.x86_64-linux.factorio-headless;
  };
}
