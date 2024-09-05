{
  config,
  pkgs,
  options,
  ...
}: let
  hostname = "proust";
in {
  networking.hostName = hostname;

  imports = [
    /etc/nixos/hardware-configuration.nix
    (/home/devoid/dotfiles/nixos + "/${hostname}.nix")
  ];
}
