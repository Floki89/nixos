{ lib, config, pkgs, ... }: {
  # For suspending to RAM, set Config -> Power -> Sleep State to "Linux" in EFI.

  # amdgpu.backlight=0 makes the backlight work
  # acpi_backlight=none allows the backlight save/load systemd service to work.
  boot.kernelParams = [
    "amdgpu.backlight=0"
    "acpi_backlight=none"
    # blacklist acpi_cpufreq to use amd p states
    "initcall_blacklist=acpi_cpufreq_init"
  ];

  boot.blacklistedKernelModules = [ "raydium_i2c_ts" ];

  systemd.user.services.configure_touch = {
    path = [ pkgs.xorg.xinput ];
    script = builtins.readFile ./configure_touch.sh;
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
  };

  systemd.services.disable_bt = {
    path = [ pkgs.bluez ];
    script = builtins.readFile ./disable_bt.sh;
    wantedBy = [ "multi-user.target" ];
  };

  networking.networkmanager.enableFccUnlock = true;
  systemd.services.ModemManager.enable = true;

  # environment.systemPackages = [ pkgs.jool-cli ];
  # systemd.services.jool = {
  #   serviceConfig = {
  #     ExecStartPre = "${pkgs.kmod}/bin/modprobe jool";
  #     ExecStart =
  #       "${pkgs.jool-cli}/bin/jool instance add default --netfilter --pool6 64:ff9b::/96";
  #     ExecStop = "${pkgs.jool-cli}/bin/jool instance remove default";
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #   };
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  # };

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "conservative";

  boot = {
    kernelModules = [ "acpi_call" "amd-pstate" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };
}
