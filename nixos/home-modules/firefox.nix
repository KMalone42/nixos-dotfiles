# /etc/nixos/home-modules/firefox.nix
{ config, pkgs, ... }:

let
  # Correct GitLab source for Rycee’s NUR expressions
  ffAddons = import
    (builtins.fetchTarball "https://gitlab.com/rycee/nur-expressions/-/archive/master/nur-expressions-master.tar.gz")
    { inherit pkgs; };
in
{
  programs.firefox = {
    enable = true;

    profiles.kmalone = {
      search.force = true;
      search.engines = {
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              { name = "type"; value = "packages"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };
      };

      #bookmarks = {
        #force = true;
        #settings = [
          #{
            #name = "wikipedia";
            #tags = [ "wiki" ];
            #keyword = "wiki";
            #url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
          #}
        #];
      #};

      # Find settings in about:config
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "always-show";
        "sidebar.maintools" = "{446900e4-71c2-419f-a6a7-df9c091e268b},simple-tab-groups@drive4ik,history,bookmarks";
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.newtabpage.activity-stream.feeds.system.topstories" = false;
      };

      userChrome = ''
        /* some css */
      '';

      # This now works — using Rycee’s NUR packages
      extensions.packages = with ffAddons.firefox-addons; [
        gruvbox-dark-theme
        bitwarden
        ublock-origin
        simple-tab-groups
        sponsorblock
        youtube-shorts-block
      ];
    };
  };
}

