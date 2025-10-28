# NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  
in
{
  imports = [];
  environment pkgs [
    kdePackages.kdeconnect-kde
  ]
  # KDE Connect daemon/service
  programs.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
  };
  hardware.uinput.enable = true; # required for phone -> mouse input may not be required
  boot.kernelModules = [ "uinput" ];
  networking.firewall = {
    allowedTCPPorts = [ 1714 1764 ];
    allowedUDPPorts = [ 1714 1764 ];
  };
  # Needed for input plugin (uinput access)
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';



