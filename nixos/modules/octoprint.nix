# modules/octoprint.nix
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
    octoprint
  ];

  # For streaming webcam
  networking.firewall.allowedTCPPorts = [ 8090 ];
  services.octoprint = {
    enable = true;
    host = "0.0.0.0";
    port = 8090;
    user = "octoprint";
    group = "octoprint";
  };
  
  # Give OctoPrint access to serial device & webcam
  users.users.octoprint.extraGroups = [ "dialout" "video" ];
}


