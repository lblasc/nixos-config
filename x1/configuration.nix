# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, tvbeat-ssh, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_6_10;
    #kernelPackages = pkgs.linuxPackages_latest;
    #kernelParams = [ "i915.enable_psr=0" ];
    extraModulePackages = with config.boot.kernelPackages; [
      acpi_call
    ];

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

  networking.hostName = "x1"; # Define your hostname.
  networking.wireless = {
    enable = true; # Enables wireless support via wpa_supplicant.
    interfaces = [ "wlp0s20f3" ];
    # interfaces = [ "wlp0s20f0u2u3" ];
  };
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  #networking.useDHCP = false;
  #networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware = {
    trackpoint = {
      enable = true;
      emulateWheel = true;
      device = "TPPS/2 Elan TrackPoint";
      sensitivity = 255;
      speed = 255;
    };
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
    bluetooth.enable = true; # enables support for Bluetooth
    bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        (vaapiIntel.override { enableHybridCodec = true; })
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ];
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

  # Set your time zone.
  time.timeZone = "Europe/Zagreb";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    auto-cpufreq
    firefox
    flameshot
    nil
    remmina
    pavucontrol
    tvbeat-ssh.packages.${config.nixpkgs.system}.default

    (pkgs.writeScriptBin "chromium"
      ''
        exec ${chromium}/bin/chromium \
          --enable-features=VaapiVideoDecoder
      '')


    (pkgs.writeScriptBin "google-chrome"
      ''
        exec ${google-chrome}/bin/google-chrome-stable \
          --enable-features=VaapiVideoDecoder \
          --disable-gpu-driver-bug-workarounds \
          --enable-features=VaapiVideoEncoder,VaapiVideoDecoder,CanvasOopRasterization

      '')

    (luajit.withPackages (ps: with ps; [ busted rapidjson lua-toml ]))
    (pkgs.vscode.fhsWithPackages (ps: with ps; [ rustup zlib openssl.dev pkg-config ]))
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    })
    #(vscode-with-extensions.override {
    #  vscode =
    #  #vscode = pkgs.vscode-fhs;
    #  vscodeExtensions = (with pkgs.vscode-extensions; [
    #    (ms-vscode-remote.remote-ssh.override { useLocalExtensions = true; })
    #    sumneko.lua
    #    jnoortheen.nix-ide
    #    vscodevim.vim
    #    redhat.vscode-yaml
    #    hashicorp.terraform
    #    arrterian.nix-env-selector
    #    bierner.markdown-emoji
    #    yzhang.markdown-all-in-one
    #    streetsidesoftware.code-spell-checker
    #  ]);
    #})
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
    ];
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 3000 5556 5558 ];
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

  services = {
    blueman.enable = true;
    avahi.enable = true;

    throttled.enable = true;

    # battery charge threshold
    # echo 90 > /sys/class/power_supply/BAT0/charge_control_end_threshold
    # echo 75 > /sys/class/power_supply/BAT0/charge_control_start_threshold
    auto-cpufreq.enable = true;

    fwupd.enable = true;
    physlock = {
      allowAnyUser = true;
      enable = true;
    };
    #picom = {
    #  enable = true;
    #  vSync = true;
    #};

    # Enable touchpad support.
    libinput.enable = true;

    displayManager.defaultSession = "none+awesome";

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      xkb = {
        variant = "us";
        options = "eurosign:e";
        layout = "hr";
      };
      dpi = 210;
      #videoDrivers = [ "intel" ];
      #deviceSection = ''
      #  Option "DRI" "2"
      #  Option "TearFree" "true"
      #'';



      windowManager.awesome = {
        enable = true;
      };

      xautolock = {
        enable = true;
        enableNotifier = true;
        locker = ''${config.security.wrapperDir}/physlock'';
        notifier =
          ''${pkgs.libnotify}/bin/notify-send "Locking in 10 seconds"'';
      };

    };

  };

  xdg.mime.defaultApplications = {
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
