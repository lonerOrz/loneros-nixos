# Mime type associations for the system.
{ lib, ... }:
with lib;
let
  defaultApps = {
    browser = [ "zen-twilight.desktop" ];
    text = [ "nvim.desktop" ];
    image = [
      "org.gnome.eog.desktop"
      "swappy.desktop"
    ];
    audio = [ "mpv.desktop" ];
    video = [ "mpv.desktop" ];
    directory = [ "thunar.desktop" ];
    office = [ "libreoffice.desktop" ];
    pdf = [ "obsidian.desktop" ];
    terminal = [ "kitty.desktop" ];
    archive = [ "xarchiver.desktop" ];
  };

  mimeMap = {
    text = [
      "text/plain"
      "text/x-python"
      "text/x-shellscript"
    ];
    image = [
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/jpg"
      "image/png"
      "image/svg+xml"
      "image/tiff"
      "image/vnd.microsoft.icon"
      "image/webp"
    ];
    audio = [
      "audio/aac"
      "audio/mpeg"
      "audio/ogg"
      "audio/opus"
      "audio/wav"
      "audio/webm"
      "audio/x-matroska"
    ];
    video = [
      "video/mp2t"
      "video/mp4"
      "video/mpeg"
      "video/ogg"
      "video/webm"
      "video/x-flv"
      "video/x-matroska"
      "video/x-msvideo"
    ];
    directory = [ "inode/directory" ];
    browser = [
      "text/html"
      "x-scheme-handler/about"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/unknown"
    ];
    office = [
      "application/vnd.oasis.opendocument.text"
      "application/vnd.oasis.opendocument.spreadsheet"
      "application/vnd.oasis.opendocument.presentation"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "application/msword"
      "application/vnd.ms-excel"
      "application/vnd.ms-powerpoint"
      "application/rtf"
    ];
    pdf = [ "application/pdf" ];
    terminal = [
      "terminal"
      "x-terminal-emulator"
      "application/x-shellscript"
    ];
    archive = [
      "application/zip"
      "application/rar"
      "application/7z"
      "application/x-tar"
      "application/x-gtar"
      "application/x-bzip-compressed-tar"
      "application/x-xz-compressed-tar"
    ];
  };

  associations =
    with lists;
    listToAttrs (
      flatten (mapAttrsToList (key: map (type: attrsets.nameValuePair type defaultApps."${key}")) mimeMap)
    );
in
{
  xdg = {
    mime = {
      enable = true;
      defaultApplications = associations;
      addedAssociations = {
        "x-scheme-handler/clash" = [ "mihomo-party.desktop" ];
        "x-scheme-handler/mpv-handler" = [ "mpv-handler.desktop" ];
        "x-scheme-handler/mpv-handler-debug" = [ "mpv-handler-debug.desktop" ];
        "x-scheme-handler/discord" = [ "vesktop.desktop" ];
        "x-scheme-handler/tg" = [ "telegram.desktop" ];
      };
    };
  };
}
