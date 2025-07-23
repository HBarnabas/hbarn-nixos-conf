{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
    nerd-fonts.droid-sans-mono
    dejavu_fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    source-han-sans
    source-han-sans-japanese
    source-han-serif-japanese
    roboto-mono
  ];
}
