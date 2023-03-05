# nixos-config

Personal nixos configurations.

# Quickstart

Install nixos in any way you like it.

Then simply clone this repo directly to `/etc/nixos`.

* **x1** the notebook
* **merovingian** the server

```
sudo -i
mv /etc/nixos /etc/nixos.old # just in case
git clone git@github.com:lblasc/nixos-config.git /etc/nixos
```

Update `hardware-configuration.nix` if needed, generated one
can be found in `/etc/nixos.old`

```
nixos-rebuild switch
```

At this point we should have our system up and running!

It is a good practice to edit and commit files with
unprivileged user not root account.
```
chown -R lblasc: -R /etc/nixos
```

# OpenWRT tl-mr3020 v1 access point only

This old mini-router can be revieved with 22.03 openwrt release as a simple access point,
for new openwrt standards flash and ram size is not enough for anything more advanced.

shell.nix
```
https://github.com/nix-community/nix-environments/blob/master/envs/openwrt/shell.nix
```

image builder
```
https://downloads.openwrt.org/releases/22.03.3/targets/ath79/tiny/openwrt-imagebuilder-22.03.3-ath79-tiny.Linux-x86_64.tar.xz
```

Build minimal image
```
make image \
  PROFILE="tplink_tl-mr3020-v1" \
  PACKAGES="base-files -ca-bundle dropbear fstools libc libgcc -libustream-wolfssl logd mtd netifd -opkg uci uclient-fetch urandom-seed urngd busybox procd procd-seccomp kmod-gpio-button-hotplug -swconfig kmod-ath9k uboot-envtools -wpad-basic-wolfssl -dnsmasq -firewall4 -nftables -kmod-nft-offload -odhcp6c -odhcpd-ipv6only -ppp -ppp-mod-pppoe wpad-mini -kmod-usb-chipidea2 -kmod-usb-ledtrig-usbport"
```
