# nixos-config

## wip

```$ cat ~/txt/nixos-x1
git clone https://github.com/NixOS/nixpkgs.git -b nixos-20.03

cd nixpkgs/nixos

$ git diff
diff --git a/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix b/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix
index e0b558dcb0d..c7cc0b3f2e5 100644
--- a/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix
+++ b/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix
@@ -8,6 +8,9 @@ with lib;
 {
   imports = [ ./installation-cd-base.nix ];

+  # helps in case of my x1 carbon
+  boot.kernelPackages = pkgs.linuxPackages_latest;
+
   # Whitelist wheel users to do anything
   # This is useful for things like pkexec
   #
@@ -38,6 +41,8 @@ with lib;
   environment.systemPackages = [
     # Include gparted for partitioning disks.
     pkgs.gparted
+    # I like to inspect stuff
+    pkgs.nvme-cli

     # Include some editors.
     pkgs.vim

$ nix-build -A config.system.build.isoImage -I nixos-config=modules/installer/cd-dvd/installation-cd-graphical-gnome.nix default.nix

$ ls -la result
lrwxrwxrwx 1 lblasc lblasc 79 Apr 22 10:15 result -> /nix/store/f6wnglqc7048gfcs8bls011j5h21gl3h-nixos-20.03pre-git-x86_64-linux.iso

$ sudo dd if=result/iso/nixos-20.03pre-git-x86_64-linux.iso of=/dev/sdX bs=1M


# boot

cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2

```
