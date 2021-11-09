# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_5_14;
    #kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [ (acpi_call.overrideAttrs (old: {
      version = "1.2.2-pre";
      src = pkgs.fetchFromGitHub {
        owner = "nix-community";
        repo = "acpi_call";
        rev = "9f1c0b5d046bdfdec769809435257647fd475473";
        sha256 = "1s7h9y3adyfhw7cjldlfmid79lrwz3vqlvziw9nwd6x5qdj4w9vp";
      };
    })) ];

    plymouth.enable = true;

    cleanTmpDir = true;
  };

  nix = {
    package = pkgs.nix_2_4;
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
      experimental-features = nix-command flakes
      builders-use-substitutes = true
      netrc-file = /etc/netrc
    '';
  };

  #networking.resolvconf.dnsExtensionMechanism = false;

  networking.hostName = "x1"; # Define your hostname.
  networking.wireless = {
    enable = true; # Enables wireless support via wpa_supplicant.
    interfaces = [ "wlp0s20f3" ];
   # interfaces = [ "wlp0s20f0u2u3" ];
  };

  # Powersave
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      ENERGY_PERF_POLICY_ON_BAT = "power";
      START_CHARGE_THRESH_BAT0 = 60;
      STOP_CHARGE_THRESH_BAT0 = 85;
    };
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  #networking.useDHCP = false;
  #networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  services.avahi.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware = {
    trackpoint = {
      enable = true;
      emulateWheel = true;
      device = "TPPS/2 Elan TrackPoint";
      sensitivity = 255;
      speed = 255;
    };
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;

    opengl.extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  virtualisation.docker.enable = false;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.defaultNetwork.dnsname.enable = true;

  # additional groups for my user
  users.users.lblasc.extraGroups = [ "audio" "video" "podman" ];

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
    arion
    awscli
    docker-client
    firefox
    flameshot
    google-chrome
    remmina
    podman

    (pkgs.writeScriptBin "chromium"
    ''
      exec ${chromium}/bin/chromium \
        --enable-features=VaapiVideoDecoder
    '')

    (luajit.withPackages (ps: with ps; [ busted rapidjson lua-toml ]))
    (vscode-with-extensions.override {
      vscode = pkgs.vscodium;
      vscodeExtensions = (with pkgs.vscode-extensions; [
        ms-vscode-remote.remote-ssh
        sumneko.Lua
        jnoortheen.nix-ide
        vscodevim.vim
        redhat.vscode-yaml
        hashicorp.terraform
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "markdown-emoji";
        publisher = "bierner";
        version = "0.1.0";
        sha256 = "1y599hmi7ngamvvkwwi9ax4hyzc0hgzp51j52vlrwri6805fwr9y";
      }] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "rust";
        publisher = "rust-lang";
        version = "0.7.8";
        sha256 = "039ns854v1k4jb9xqknrjkj8lf62nfcpfn0716ancmjc4f0xlzb3";
      }] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "nix-env-selector";
        publisher = "arrterian";
        version = "0.1.2";
        sha256 = "1n5ilw1k29km9b0yzfd32m8gvwa2xhh6156d4dys6l8sbfpp2cv9";
      }] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "markdown-all-in-one";
        publisher = "yzhang";
        version = "3.3.0";
        sha256 = "0jq6zvppg6pagrzqisx3h3ra2x92x72xli41jmd464wr5jwrg0ls";
      }] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "spellright";
        publisher = "ban";
        version = "3.0.56";
        sha256 = "0y0plri6z7l49h4j4q071hn7khf9j9r9h3mhz0y96xd0na4f2k3v";
      }];
    })
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
      pinentryFlavor = "gnome3";
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

  # Enable sound.
  sound = {
    enable = true;
  };

  services = {
    fwupd.enable = true;
    physlock = {
      allowAnyUser = true;
      enable = true;
    };
    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      layout = "hr";
      xkbVariant = "us";
      dpi = 210;

      # Enable touchpad support.
      libinput.enable = true;

      xkbOptions = "eurosign:e";

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

      displayManager.defaultSession = "none+awesome";

    };

  };

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    secrets.wireguard-private-key = { };
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "fd::2/64" "fd00:b0a7::11/64" ];
      listenPort = 51820; # to match firewall allowedUDPPorts (without this wg uses random port numbers)
      privateKeyFile = config.sops.secrets.wireguard-private-key.path;
      peers = [
        {
          publicKey = "ENP/VXsNXT1mW9622KqsgNdbzxjXeIwQ3+TxTPx1lyI=";
          allowedIPs = [ "fd::/64" "fd00:b0a7::/64" ];
          endpoint = "168.119.229.37:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
