# modules/gaming.nix

{ lib, config, pkgs, ...}:
let
	digitalMedia = "/home/kmalone/Digital_Media";
	games = "${digitalMedia}/Games";

	# Use `strace steam` to find missing deps
	steamRuntimeLibs = with pkgs; [
		SDL2
		dbus
		libjpeg
		mono
		openal
		vulkan-loader
	];
in
{
  programs.gamemode.enable = true;

	# Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Required for Steam Remote Play
    dedicatedServer.openFirewall = true; # Required for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Required for Steam Local Network Transfers
    extraPackages = steamRuntimeLibs;
  };
}
