# modules/keyboard.nix
{ lib, config, pkgs, ... }:
let
in
{
  # Use keyd monitor to find keyids
  environment.systemPackages = [
    pkgs.keyd
  ];

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            sysrq = "leftmeta";
          };
          otherlayer = {};
        };
        extraConfig = ''
        '';
      };
    };
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk             # alternatively, kdePackages.fcitx5-qt
      fcitx5-nord            # a color theme
      qt6Packages.fcitx5-chinese-addons # table input method support
    ];
  };

   
  # Wayland-friendly env: unset GTK_IM_MODULE, keep QT using fcitx.
  #environment.sessionVariables = {
    #QT_IM_MODULE  = lib.mkDefault "fcitx";
    #XMODIFIERS    = lib.mkDefault "@im=fcitx";
  #};

  # Fonts so CJK renders nicely
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
  ];
}
