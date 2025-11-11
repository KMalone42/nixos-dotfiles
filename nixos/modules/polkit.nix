# modules/polkit.nix
{ config, pkgs, ... }:
{
  security.polkit.enable = true;
  services.dbus.enable = true;  # generally good to have

  environment.systemPackages = [ pkgs.polkit_gnome ];

  services.udisks2.enable = true;
  services.gvfs.enable = true; # optional but helps with removable media

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome authentication agent";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };
}

