# NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz;
in
{
  imports =
  [ 
    ./hardware-configuration.nix
    #./modules/nvidia.nix
    # ./modules/nvidia-legacy.nix
    #./modules/intel-igpu.nix
    ./modules/music.nix
    #./modules/gaming.nix
    ./modules/nvim.nix
    #./modules/printers.nix
    #./modules/octoprint.nix
    ./modules/keyboard.nix
    ./modules/polkit.nix
    #./modules/plex.nix
    #./modules/virt-host.nix
    ./modules/openvpn-client.nix
    ./modules/wireguard-client.nix
    (import "${home-manager}/nixos")
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Timezone
  time.timeZone = "America/New_York";

  # Internationalisation
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # X11 Configuration
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # X11 Display Manager - greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = ''
        exec ${pkgs.greetd-session-wayland-protocol}/bin/greetd --wayland-session ${pkgs.wlroots}/bin/wlroots -- \
          --wayland-session ${pkgs.sway}/bin/sway -- -C ${pkgs.home-manager}/share/home-manager/default.nix
      '';
    };
  };

  # User account
  users.users.kmalone = {
    isNormalUser = true;
    description = "kmalone";
    extraGroups = [ "networkmanager" "wheel" "uinput" "input" "libvirtd" "kvm" "video" ];
    packages = with pkgs; [ xorg.xauth ];
  };

  # BEGIN Home-Manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.kmalone = { pkgs, ... }: {
    imports = [./home-modules/firefox.nix];
    
    home.packages = with pkgs; [
      atool
      httpie
      xdotool
    ];

    home.stateVersion = "25.05";

    home.file = {
      ".config/i3".source = ./home-modules/i3;
      ".config/i3".recursive = true;
      
      ".config/greetd".source = ./home-modules/greetd;
      ".config/greetd".recursive = true;
    };

    programs.waybar.enable = true;
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      extraConfig = builtins.readFile ./home-modules/tmux.conf;
    };

    gtk = {
      enable = true;
      theme = {
        name = "Gruvbox-Dark";
        package = pkgs.gruvbox-gtk-theme;
      };
      iconTheme = {
        name = "Gruvbox-Material-Dark";
        package = pkgs.gruvbox-material-gtk-theme;
      };
      gtk3.extraConfig = {
        gtk-im-module = "fcitx";
      };
      gtk4.extraConfig = {
        gtk-im-module = "fcitx";
      };
    };

    qt.enable = true;
  };
  # END Home-Manager

  # BEGIN Packages

  nixpkgs.config.allowUnfree = true; # Allow unfree packages
  nixpkgs.config.android_sdk.accept_license = true; # Allow android-studio-full

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # X11 dependencies
    xdg-desktop-portal-gtk
    xdg-desktop-portal
    xwayland
    xwayland-support
    xorg.xauth
    
    # greetd dependencies
    greetd-session-wayland-protocol
    wlroots
    
    # Sway/i3 shared dependencies
    xorg.xserver
    xorg.xcbutilgeom
    xorg.xclip
    xorg.xdotool
    
    # Utility packages
    brightnessctl
    wl-clipboard
    dunst # notification daemon
    kitty # terminal emulator

    # Sway packages (for fallback/reference)
    sway
    swaybg
    swaylock
    swayidle
    # i3 packages
    i3-wm
    i3blocks
    dmenu
    rofi
    xorg.xrdb
    xorg.xsetroot

    # Productivity
    bitwarden-desktop # Password Manager
    chromium # Open source web browser from Google
    gimp3    # GNU Image Manipulation Program
    inkscape # Vector graphics editor
    neovim      # Vim-fork focused on extensbility and usability
    rclone      # Command line program to sync files and directories to and from major cloud storage
    thunderbird # Mozilla's "Full-featured e-mail client"
    tmux        # a terminal multiplexer
    vesktop     # Unofficial Discord Client
    libreoffice-qt6-fresh # Comprehensive, professional-quality productivity suite, a variant of openoffice.org
    newsflash
    cura-appimage
    prusa-slicer
    newsboat # Fork of Newsbeuter, an RSS/Atom feed reader for the text console
    sqlitebrowser # DB Browser for SQLite
    dbeaver-bin # Universal SQL Client for developers, DBA and analysts. Supports MySQL, PostgreSQL, MariaDB, SQLite, and more
    aider-chat # A basically universal ollama claude-code like client
    opencode # AI coding agent built for the terminal
    # android-studio-full # Official IDE for Android (stable channel)

    # Homelabbing
    syncthing
    syncthingtray
    openvpn
    virt-viewer
    # Rice
    kdePackages.qt6ct
    cava
    gotop
    fastfetch
    
    # common utilities (utils)
    wget
    gcc
    clang
    git
    mpv
    busybox
    scdoc
    cmake
    efibootmgr
    tlrc # tldr client written in rust
    man
    cyme # Modern cross-platform lsusb
    gnumake42 # Tool to control the generation of non-source files from sources
    parted # Create, destroy, resize, check, and copy partitions
    man-pages
    man-pages-posix
    linux-manual
    unzip
    bzip3
    nwg-look
    jq
    cups # Standards-based printing system for UNIX
    ffmpeg_7 # Complete, cross-platform solution to record, convert and stream audio and video
    ripgrep
    ripgrep-all
    stdenv.cc.cc
    zlib
    glibc
    flatpak # Linux application sandboxing and distribution framework
    flatpak-builder # Tool to build flatpaks from source

    # Security
    nmap

    # Browser tools
    steam-run
    nspr
    nss

    # Device utilities
    rpi-imager
    # android-tools

    # Programming languages
    nodejs
    electron_40
    #python315
    pipx
    (python313.withPackages (ps: with ps; [
      pip
    ]))
    cargo
    rustc

    # Screenshots
    grim
    slurp

    # Audio
    sof-firmware
    pavucontrol # maybe works better than pwvucontrol
    pwvucontrol # modern volume controller like pavucontrol 
    wireplumber # pipewire session manager
    easyeffects # pipewire audio effects, channel mixer
    alsa-utils  # troubleshooting, adds alsamixer

    # GTK
    gtk4 # Multi-platform toolkit for creating graphical user interfaces

    # KDE tools (optional but useful)
    qbittorrent # Torrent file manager
    kdePackages.qtsvg
    kdePackages.isoimagewriter
    kdePackages.kio-gdrive # KIO Worker to access Google Drive
    kdePackages.kio-fuse   # to mount remote filesystems via FUSE
    kdePackages.kio-extras # extra protocols support (sftp, fish and more)
    kdePackages.gwenview   # video and image viewer
    kdePackages.kdenlive   # Free and open source video editor, based on MLT Framework and KDE Frameworks
    kdePackages.breeze
    kdePackages.breeze-gtk
    kdePackages.breeze-icons
    bibata-cursors
    nemo
    kdePackages.qt6gtk2
    kdePackages.dolphin # file manager GUI using qt
    kdePackages.kamera
    kdePackages.kclock # Clock
    kronometer
    ktimetracker
    kdePackages.ktimer
    
    # GNOME tools
    kdePackages.qt6gtk2
    gnome-calculator
    gnome-decoder
    gtg
    gnome-frog
    gnome-online-accounts
    gnome-online-accounts-gtk
    cheese
    gnome-clocks
    gnome-solanum
    gnome-pomodoro
    # Development
    gitg # GNOME GUI client to view git repositories

    # PDF and OCR
    ocrfeeder          # an OCR GUI for GNOME (uses tesceract)
    evince             # a pdf reader for GNOME
    kdePackages.okular # a pdf reader for KDE
    karp               # pdf arranger for KDE

    # Gaming
    vulkan-tools
    prismlauncher

    # Recording
    obs-studio

    # AI
    ollama-cuda # Run large language models locally, using CUDA for NVIDIA GPU acceleration
    kdePackages.alpaka # Kirigami client for Ollama
    # File Manager
    nautilus
    # displaylink # drivers
    # Virtualization
    qemu_kvm virtio-win # Windows virtio drivers ISO
    qemu_full
    spice-gtk           # SPICE client libs
    quickemu quickgui   # zero-friction VM creation
    docker_28

    # OpenClaw
    chromium
    chromium-chromedriver
    python313.withPackages (ps: with ps; [
      selenium
      playwright-python
      beautifulsoup4
    ])
    
    # Sway/i3 specific
    slurp
    rofi-wayland
    feh
    picom
    libnotify
  ];
  # END Packages

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
    nerd-fonts.symbols-only
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    # Chinese
    wqy_zenhei
  ];

  # Environment Variables
  environment = {
    variables.WLR_NO_HARDWARE_CURSORS = "1";
    sessionVariables.NIXOS_OZONE_WL = "1"; # Hint Electron apps to use wayland
    sessionVariables.XDG_CURRENT_DESKTOP = "i3";
    sessionVariables.XDG_SESSION_TYPE = "x11";
    sessionVariables.DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
    variables.OPENCLAW_HOME = "${home.home}/.openclaw";
    variables.OPENCLAW_GATEWAY_URL = "http://127.0.0.1:18792";
    
    # i3 specific
    sessionVariables.I3GMODIFIED = "true";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Services
  services.displayManager.enable = true;
  services.displayManager.defaultSession = "none+i3";
  
  services.xserver.enable = true;
  #services.xserver.videoDrivers = [ "displaylink" "modesetting" ]; # display port output over usb-a
  services.libinput.enable = true;

  services.dbus.enable = true;
  services.udev.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
  };

  # Sound with pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pipewire.wireplumber.configPackages = [];

  # Miscellaneous Services
  documentation = {
    man = {
      enable = true;
      generateCaches = true; # builds the whatis/apropos cache at switch time
      man-db.enable = true;  # or mandoc.enable = true; pick one
    };
    dev.enable = true;       # for section 3 etc. (optional but nice)
  };

  services.blueman.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    settings = {
      General.Experimental = true;
      General.Enable = "Source,Sink,Media,Socket,HID";
    };
  };

  services.upower.enable = true;
  services.udisks2.enable = true;

  # Networking
  services.resolved.enable = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];
  networking.search = [ ];

  # Syncthing
  services.syncthing = {
    enable = true;
    package = pkgs.syncthing;
    user = "kmalone";
    dataDir = "/home/kmalone";
    configDir = "/home/kmalone/.config/syncthing";
    openDefaultPorts = true;
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  boot = {
    extraModulePackages = [ config.boot.kernelPackages.evdi ];
    initrd = {
      # List of modules that are always loaded by the initrd.
      kernelModules = [
        "evdi"
      ];
    };
  };

  # Experimental features
  # --extra-experimental-features nix-command
  # experimental-features = nix-command flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Don't change unless required
}
