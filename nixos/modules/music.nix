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
				enabled "no"
			}
		'';

		# Optional
		network = {
			listenAddress = "127.0.0.1";
			port = 6600;
		};
		startWhenNeeded = false; # systemd feature: only start MPD service upon connection to its socket
	};

	environment.systemPackages = 
		(with pkgs; [mpc rmpc]);
}
