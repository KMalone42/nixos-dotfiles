# modules/music.nix

{ lib, config, pkgs, ...}:
let
	digitalMedia = "/home/kmalone/Digital_Media";
in
{
  services.mpd = {
    enable = true;
    user = "kmalone";
    musicDirectory = "${digitalMedia}/Music";

      
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
        mixer_type "software"
      }
    '';

    network = {
      listenAddress = "127.0.0.1";
      port = 6600;
    };

    startWhenNeeded = false;
  };
  
  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.kmalone.uid}";
  };

  environment.systemPackages = with pkgs; [
    mpc
    rmpc
  ];
}
