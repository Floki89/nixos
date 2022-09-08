{ lib, config, pkgs, nixpkgs, flake-self, ... }:
with lib;
let cfg = config.luksab.common;

in {
  options.luksab.common = {
    enable = mkEnableOption "enable basics";
    disable-cache = mkEnableOption "not use binary-cache";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      flake-self.overlays.default
      flake-self.overlays.master
      flake-self.overlays.stable
    ];

    # home-manager.users.tobi.imports =
    #   [{ nixpkgs.overlays = [ flake-self.overlays.default ]; }];
    # already done in flake

    luksab = {
      openssh.enable = true;
      zsh.enable = true;
      wg_hosts.enable = true;

      user = {
        tobi = { enable = true; };
        root.enable = true;
      };
    };

    mayniklas.var.mainUser = "tobi";

    environment.systemPackages = with pkgs; [
      git
      nixfmt
      usbutils
      pciutils
      config.boot.kernelPackages.perf
      config.boot.kernelPackages.usbip
    ];
    boot.kernelModules = [ "vhci-hcd" ];

    programs.mtr.enable = true;

    # count total uptime
    services.tuptime.enable = true;
    services.tuptime.timer.enable = true;

    # Allow unfree at system level
    nixpkgs.config.allowUnfree = true;

    # Set your time zone.
    time.timeZone = "Europe/Amsterdam";

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };

    services.journald.extraConfig = ''
      SystemMaxUse=1G
    '';

    nix = {
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';

      settings = {
        # Save space by hardlinking store files
        auto-optimise-store = true;
      };

      # Clean up old generations after 30 days
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    environment.etc."nix/flake_inputs.prom" = {
      mode = "0555";
      text = ''
        # HELP flake_registry_last_modified Last modification date of flake input in unixtime
        # TYPE flake_input_last_modified gauge
        ${concatStringsSep "\n" (map (i:
          ''
            flake_input_last_modified{input="${i}",${
              concatStringsSep "," (mapAttrsToList (n: v: ''${n}="${v}"'')
                (filterAttrs (n: v: (builtins.typeOf v) == "string")
                  flake-self.inputs."${i}"))
            }} ${toString flake-self.inputs."${i}".lastModified}'')
          (attrNames flake-self.inputs))}
      '';
    };

    system.stateVersion = "21.11";
  };
}
