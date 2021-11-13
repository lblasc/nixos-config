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
