{ config, lib, ... }:

let
  pkgs = import /etc/nixos/pkgs {
    #config.allowUnfree = true;
  };
in {
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4ce808f4-f3e0-48e7-a5f5-29aa1a8ddcd4";
      fsType = "xfs";
    };

  boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/42d44c87-3a48-4075-a5c7-a6a0864a2a8d";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/71FE-3463";
      fsType = "vfat";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 0;
  nix.buildCores = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
