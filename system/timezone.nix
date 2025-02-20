{
  host,
  ...
}:
let
  inherit (import ../hosts/${host}/variables.nix)
    timeZone
    keyboardLayout
    defaultLocale
    extraLocale
    ;
in
{
  # Set your time zone.
  time.timeZone = "${timeZone}";
  #services.automatic-timezoned.enable = true; #based on IP location

  # Select internationalisation properties.
  i18n.defaultLocale = "${defaultLocale}";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "${extraLocale}";
    LC_IDENTIFICATION = "${extraLocale}";
    LC_MEASUREMENT = "${extraLocale}";
    LC_MONETARY = "${extraLocale}";
    LC_NAME = "${extraLocale}";
    LC_NUMERIC = "${extraLocale}";
    LC_PAPER = "${extraLocale}";
    LC_TELEPHONE = "${extraLocale}";
    LC_TIME = "${extraLocale}";
  };

  # keyMap
  console.keyMap = "${keyboardLayout}";
}
