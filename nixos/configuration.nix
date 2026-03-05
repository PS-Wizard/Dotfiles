{ config, pkgs, ... }:
{
    imports = [
        ./hardware-configuration.nix
    ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.extraModulePackages = with config.boot.kernelPackages; [
        acer-wmi-battery
    ];

    boot.kernelModules = ["acer_wmi_battery"];
    networking.hostName = "nixos";
    networking.networkmanager.enable = true;

    time.timeZone = "Asia/Kathmandu";
    i18n.defaultLocale = "en_US.UTF-8";

    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };

    users.users.wizard = {
        isNormalUser = true;
        description = "wizard";
        extraGroups = [ "networkmanager" "wheel" "docker"];
        packages = with pkgs; [ ];
        shell = pkgs.zsh;
    };

    nixpkgs.config.allowUnfree = true;

    # Nix flake + mirror/caches.
    nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        substituters = [
            "https://cache.nixos.org"
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        ];
    };

    # Audio stack for wpctl + pavucontrol.
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
    };

    # powerprofilesctl command and daemon.
    services.power-profiles-daemon.enable = true;

    programs.niri.enable = true;
    programs.zsh = {
        enable = true;
        shellAliases = {
            rebuild = "sudo nixos-rebuild switch --flake .#";
            gc = "sudo nix-collect-garbage -d && sudo nixos-rebuild boot --flake .#";
        };
    };
    programs.zoxide.enable = true;

    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        noto-fonts-color-emoji
        noto-fonts
    ];

    xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
            xdg-desktop-portal-gnome
        ];
        config.common.default = [ "gnome" ];
    };

    environment.systemPackages = with pkgs; [
        bun
        neovim
        kitty
        git
        fzf
        zoxide
        tmux
        lazygit
        wlr-which-key
        waybar
        swaybg
        bemenu
        brightnessctl
        typst
        tokei
        gammastep
        pavucontrol
        wl-mirror
        gpu-screen-recorder
        grim
        slurp
        wl-clipboard
        jq
        psmisc
        trash-cli
        zathura
        tinymist
    ];

    virtualisation.docker = {
        enable = true;
        enableOnBoot = false;
        autoPrune = {
            enable = true;
            dates = "weekly";
        };
    };


    system.stateVersion = "25.11";
}
