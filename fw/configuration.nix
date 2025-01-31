# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, tvbeat-ssh, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_6_12;
    tmp.cleanOnBoot = true;
  };

  nix = {
    buildMachines = [{
      hostName = "builder";
      system = "x86_64-linux";
      maxJobs = 20;
      speedFactor = 2;
      supportedFeatures = [ "benchmark" "big-parallel" ];
      mandatoryFeatures = [ ];
    }];
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
    '';
    settings.trusted-public-keys = [
      "hydra.tvbeat.com:4iHmKDd95QN9Po2FzqmfUD11Wk0/ln1oLlaLXDaIsNE="
    ];
    settings.substituters = [
      "https://tvbeat-nixpkgs-cache.s3-eu-west-1.amazonaws.com/"
    ];
  };

  networking.hostName = "fw"; # Define your hostname.
  networking.wireless = {
    enable = true; # Enables wireless support via wpa_supplicant.
    interfaces = [ "wlp170s0" ];
    # interfaces = [ "wlp0s20f0u2u3" ];
  };
  networking.interfaces.wlp170s0.useDHCP = lib.mkDefault true;
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware = {
    bluetooth.enable = true; # enables support for Bluetooth
    bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

    graphics = {
      enable = true;
    };
  };

  # additional groups for my user
  users.users.lblasc.extraGroups = [ "audio" "video" ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "latarcyrheb-sun32";
    keyMap = "us";
    earlySetup = true;
  };

  fonts.packages = with pkgs; [
    cascadia-code
    maple-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    jetbrains-mono
    dina-font
    proggyfonts
  ];

  # Set your time zone.
  time.timeZone = "Europe/Zagreb";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    auto-cpufreq
    firefox
    grimblast
    nil
    remmina
    pavucontrol
    kitty
    tvbeat-ssh.packages.${config.nixpkgs.system}.default
    fuzzel
    waybar
    hyprpaper
    gparted
    zed-editor
    google-chrome
    (pkgs.writeScriptBin "chromium"
      ''
        exec ${ungoogled-chromium}/bin/chromium \
          --enable-features=VaapiVideoDecodeLinuxGL
      '')


    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    })
  ];

  # needed for gparted
  security.polkit.enable = true;

  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    hyprland.enable = true; # enable Hyprland
  };

  programs.light.enable = true;
  #services.actkbd = {
  #  enable = true;
  #  bindings = [
  #    { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
  #    { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
  #  ];
  #};
  services.logind = {
    powerKey = "suspend";
    powerKeyLongPress = "poweroff";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 3000 5556 5558 4455 ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ]; # Clients and peers can use the same port, see listenport
  };
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  #services.printing.enable = true;
  #services.printing.drivers = [ pkgs.xerox-workcentre-3045b-3045ni ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd Hyprland";
      };
    };
  };

  services = {
    blueman.enable = true;
    avahi.enable = true;
    hypridle.enable = true;

    #throttled.enable = true;

    # battery charge threshold
    # echo 90 > /sys/class/power_supply/BAT1/charge_control_end_threshold
    auto-cpufreq.enable = true;

    fwupd.enable = true;

    physlock = {
      allowAnyUser = true;
      enable = true;
    };

    # Enable touchpad support.
    libinput.enable = true;
  };
}

