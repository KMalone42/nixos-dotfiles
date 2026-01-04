# modules/printers.nix
{ lib, config, pkgs, ... }:
let
  webroot = "${pkgs.mjpg-streamer}/share/mjpg-streamer/www";
in
{
  environment.systemPackages = with pkgs; [
    # Packages for streaming webcam over network
    v4l-utils
    ffmpeg_6-full
    mjpg-streamer
  ];

  # For streaming webcam
  networking.firewall.allowedTCPPorts = [ 8090 ];
  systemd.services.mjpg-streamer = {
    description = "MJPG-Streamer";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.mjpg-streamer}/bin/mjpg_streamer \
          -i "input_uvc.so -d /dev/video0 -r 1280x720 -f 30" \
          -o "output_http.so -p 8090 -l 0.0.0.0 -w ${webroot}"
      '';
      User = "kmalone";
      Group = "video";
      Restart = "always";
    };
  };
}


