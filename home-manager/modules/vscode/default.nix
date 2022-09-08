{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.luksab.programs.vscode;
  my-python-packages = python-packages:
    with python-packages; [
      pandas
      requests
      numpy
      # other python packages you want
    ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;
in {
  options.luksab.programs.vscode.enable = mkEnableOption "enable vscode";
  config = mkIf cfg.enable {
    home.packages = [ python-with-my-packages ];

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions;
        [
          # arrterian.nix-env-selector
          #   eamodio.gitlens
          #   bbenoist.nix
          #   brettm12345.nixfmt-vscode
          #   arrterian.nix-env-selector
          #   ms-vscode-remote.remote-ssh
          #   matklad.rust-analyzer
          #   serayuzgur.crates
          #   (lib.mkIf (config.luksab.arch == "x86_64") pkgs.vsliveshare-new)
          #   james-yu.latex-workshop
          #   valentjn.vscode-ltex
          #   (lib.mkIf (config.luksab.arch == "x86_64") ms-python.python)

          #   (lib.mkIf (config.luksab.arch == "x86_64") ms-vscode.cpptools)
          #   esbenp.prettier-vscode
          #   tamasfe.even-better-toml
          # ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
          #   name = "errorlens";
          #   publisher = "usernamehw";
          #   version = "3.5.1";
          #   sha256 = "sha256-DjmCjwX6gEtloPZKxpTl485FacRpsfiVP0ZnCUteq58=";
          # }] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
          #   name = "liveserver";
          #   publisher = "ritwickdey";
          #   version = "5.7.5";
          #   sha256 = "sha256-rKe746kwXoJx46K7+beBrjTPUCt8IgyeGg7okCW60ik=";
          # }] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
          #   name = "remote-containers";
          #   publisher = "ms-vscode-remote";
          #   version = "0.240.0";
          #   sha256 = "sha256-/GcWLTC4aXN+9Ld85szfW8V+PKcxE+qZOX7OrXHCqrM=";
          # }
        ];
    };
  };
}
