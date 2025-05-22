{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;

    prime = {
      offload.enable = true;
      amdBusId = "PCI:100:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  environment.systemPackages = with pkgs; [
    nvidia-smi
    nvidia-settings
    glxinfo
  ];

  nixpkgs.config.allowUnfree = true;

  users.users.yourname = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ];
    packages = with pkgs; [ ];
  };

  system.stateVersion = "23.11"; # or match with your ISO version
}

///


{ config, pkgs, ... }:

let
unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config.allowUnfree = true;
};
in {
    imports = [ ./hardware-configuration.nix ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    nixpkgs.config.allowUnfree = true;

    services.xserver.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        prime = {
            offload.enable = true;
            amdBusId = "PCI:100:0:0";
            nvidiaBusId = "PCI:1:0:0";
        };
    };

    environment.systemPackages = with pkgs; [
        glxinfo
            alacritty
            neovim
            nvidia-smi
            nvidia-settings
            unstable.zen-browser
    ];

    users.users.wizard = {
        isNormalUser = true;
        extraGroups = [ "wheel" "video" ];
        packages = with pkgs; [ ];
    };

    system.stateVersion = "23.11";
}

