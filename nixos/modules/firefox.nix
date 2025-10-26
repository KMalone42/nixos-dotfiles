# modules/firefox.nix
{ lib, config, pkgs, ... }:
let
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-esr;  # or pkgs.firefox if you prefer
    policies = {
      ExtensionSettings = {
        # convert a url such as 'https://addons.mozilla.org/en-US/firefox/addon/measure-it/' to these blocks
        # s/\(https.*addon\/\(.*\)\/\)/"\2@addons.mozilla.org" = {\r\tinstallation_mode = "force_installed";\r\tinstall_url = "https:\/\/addons.mozilla.org\/firefox\/downloads\/latest\/\2\/latest.xpi";\r};

        # Theme
        "gruvboxgruvboxgruvboxgruvboxgr@addons.mozilla.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/gruvboxgruvboxgruvboxgruvboxgr/latest.xpi";
        };
        # Ad Blocking
        "ublock-origin@addons.mozilla.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        "video-downloadhelper@addons.mozilla.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/video-downloadhelper/latest.xpi";
        };
        "measure-it@addons.mozilla.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/measure-it/latest.xpi";
        };
      };
      # keep your other policy toggles here
      DisableTelemetry = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
    };
  };
}
