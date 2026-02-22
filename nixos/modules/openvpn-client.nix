# Helpful commands
# systemctl start openvpn-Home.service
# systemctl list-unit-files | grep -i openvpn

{ lib, config, pkgs, ... }:

{
  # Create media dirs automatically with sane perms
  systemd.tmpfiles.rules = [
    "d /home/kmalone/OpenVpn        2755 kmalone users -"
    "d /home/kmalone/OpenVpn/config 2755 kmalone users -"
  ];

  services.openvpn.servers = {
    Home = { 
      config = '' config /home/kmalone/OpenVpn/config/Home/client.ovpn '';
      updateResolvConf = true;
    };
    MullvadUS = {
      config = '' config /home/kmalone/OpenVpn/config/Mullvad/mullvad_us_all.conf '';
      updateResolvConf = true;
    };
  };

  # For enabling on startup.
  #  services.openvpn.servers = {
  #    officeVPN  = {
  #      config = '' config /root/nixos/openvpn/officeVPN.conf '';
  #      updateResolvConf = true;
  #    };
  #  };
}
