# wating-pr https://github.com/NixOS/nixpkgs/pull/523157
final: prev:
let
  version = "4.3.6";
  src = final.fetchurl {
    url = "https://rubygems.org/downloads/glib2-${version}.gem";
    hash = "sha256-0hzsdthHNjtMGGSuuEgTPnBaDbw128R1MBaCLc+A4cw=";
  };

  fixSet =
    rubySet:
    let
      newGlib2 = rubySet.glib2.overrideAttrs (old: {
        inherit src version;
      });

      newGID = rubySet.gobject-introspection.overrideAttrs (old: {
        propagatedBuildInputs =
          builtins.filter (x: x.pname or null != "glib2") old.propagatedBuildInputs
          ++ [ newGlib2 ];

        propagatedUserEnvPkgs = [ newGlib2 ];

        gemPath = newGlib2;
      });
    in
    rubySet
    // {
      glib2 = newGlib2;
      gobject-introspection = newGID;
    };

in
{
  rubyPackages = fixSet prev.rubyPackages;
  rubyPackages_3_4 = fixSet prev.rubyPackages_3_4;
}
