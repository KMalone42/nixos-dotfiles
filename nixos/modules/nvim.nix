# modules/nvim.nix
{ config, pkgs, lib, ... }:
let
in
{
  environment.systemPackages = with pkgs; [
    neovim      # Vim-fork focused on extensbility and usability
    tree-sitter # CLI for :TSInstallFromGrammar

    # LSPs
      pyright
      lua-language-server
      systemd-language-server
      vim-language-server
      typescript-language-server
      kotlin-language-server
      java-language-server
      docker-language-server
      bash-language-server
      rust-analyzer
      awk-language-server
      vscode-langservers-extracted # HTML/CSS/JSON/ESLint language servers extracted from vscode
      tailwindcss-language-server
      ccls # C/c++ language server powered by clang
      clang-tools # clangd?
      libclang # clangd

      # Dependencies   
      nodejs
      typescript
      tailwindcss
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  environment = {
    variables.EDITOR = "nvim";
    variables.SUDO_EDITOR = "nvim";
    variables.VISUAL = "nvim";
  };
}
