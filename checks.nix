{ system }:
{ self, nixpkgs, emacs-overlay, ... }@inputs:

let
  inherit (self.outputs.packages.${system}) doom-emacs-example;
  pkgs = import nixpkgs {
    inherit system;
    # we are not using emacs-overlay's flake.nix here,
    # to avoid unnecessary inputs to be added to flake.lock;
    # this means we need to import the overlay in a hack-ish way
    overlays = [ (import emacs-overlay) ];
  };
  # we are cloning HM here for the same reason as above, to avoid
  # an extra additional input to be added to flake
  home-manager = builtins.fetchTarball {
    # 2023-09-30: tracking 'master'.
    url = "https://github.com/nix-community/home-manager/tarball/4f02e35f9d150573e1a710afa338846c2f6d850c";
    sha256 = "sha256:08yqd5ya7pk3haf9a1br0qbwkq2xa167zaqnfc4fj54sls0hl31d";
  };
in
{
  home-manager-module = (import "${home-manager}/modules" {
    inherit pkgs;
    configuration = {
      imports = [ self.outputs.hmModule ];
      home = {
        username = "nix-doom-emacs";
        homeDirectory = "/tmp";
        stateVersion = "23.05";
      };
      programs.doom-emacs = {
        enable = true;
        doomPrivateDir = ./test/doom.d;
      };
    };
  }).activationPackage;
  init-example-el = doom-emacs-example;
  init-example-el-emacsGit = doom-emacs-example.override {
    emacsPackages = with pkgs; emacsPackagesFor emacsGit;
  };
  init-example-el-emacs29 = doom-emacs-example.override {
    emacsPackages = with pkgs; emacsPackagesFor emacs29;
  };
  init-example-el-splitdir = self.outputs.package.${system} {
    dependencyOverrides = inputs;
    doomPrivateDir = pkgs.linkFarm "my-doom-packages" [
         { name = "config.el"; path = ./test/doom.d/config.el; }
         { name = "init.el"; path = ./test/doom.d/init.el; }
         # Should *not* fail because we're building our straight environment
         # using the doomPackageDir, not the doomPrivateDir.
         {
           name = "packages.el";
           path = pkgs.writeText "packages.el" "(package! not-a-valid-package)";
         }
       ];
    doomPackageDir = pkgs.linkFarm "my-doom-packages" [
         # straight needs a (possibly empty) `config.el` file to build
         { name = "config.el"; path = pkgs.emptyFile; }
         { name = "init.el"; path = ./test/doom.d/init.el; }
         {
           name = "packages.el";
           path = pkgs.writeText "packages.el" "(package! inheritenv)";
         }
       ];
  };
}
