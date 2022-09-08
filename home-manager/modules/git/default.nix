{ config, pkgs, lib, ... }: {
  programs = {
    git = {
      enable = true;

      userEmail = "tobias.wissen@conversmail.de";
      userName = "Floki89";
      # signing = {
      #   key = "6F66F20BF7E9FDD4";
      #   signByDefault = true;
      # };
      lfs.enable = true;
    };
  };
}
