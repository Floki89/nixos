{ lib, pkgs, config, ... }:
with lib;
let cfg = config.luksab.user.tobi;
in {
  options.luksab.user.tobi = { enable = mkEnableOption "activate user tobi"; };

  config = mkIf cfg.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.tobi = {
      isNormalUser = true;
      home = "/home/tobi";
      extraGroups = [
        "wheel"
        "video"
        "networkmanager"
        "docker"
        "dialout"
        "usb"
      ]; # Enable ‘sudo’ for the user.
      # password = "123"; # enable for testing in VM
      shell = pkgs.zsh;
      openssh.authorizedKeys.keyFiles = [
        (builtins.fetchurl {
          url = "https://github.com/luksab.keys";
          sha256 =
            "sha256:01mk365sgizs2iq4w7zjrxqc8jkaii82p7w5nhcjxpv8dzx24pda";
        })
      ];
    };

    nix.settings.allowed-users = [ "tobi" ];
  };
}
