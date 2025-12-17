# modules/plex.nix
{ lib, config, pkgs, ... }:
let
in
{
  # Create media dirs automatically with sane perms
  systemd.tmpfiles.rules = [
    "d /srv/media        2755 kmalone users -"
    "d /srv/media/movies 2755 kmalone users -"
    "d /srv/media/tv     2755 kmalone users -"
    "d /srv/media/music  2755 kmalone users -"
  ];

  # Plex
  services.plex = {
    enable = true;
    openFirewall = true;
    user="kmalone";
  };
}
