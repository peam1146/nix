{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    literalExpression
    mdDoc
    mkEnableOption
    mkIf
    mkPackageOptionMD
    mkOption
    optionals
    types
    ;

  cfg = config.services.sketchybar;
in
{
  options.services.custom-sketchybar = {
    enable = mkEnableOption (mdDoc "sketchybar");

    package = mkPackageOptionMD pkgs "sketchybar" { };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExpression "[ pkgs.jq ]";
      description = mdDoc ''
        Extra packages to add to PATH.
      '';
    };

    configPath = mkOption {
      type = types.path;
      default = "";
      example = "/etc/sketchybar/sketchybarrc";
      description = mdDoc ''
        Contents of sketchybar's configuration file. If empty (the default), the configuration file won't be managed.

        See [documentation](https://felixkratz.github.io/SketchyBar/)
        and [example](https://github.com/FelixKratz/SketchyBar/blob/master/sketchybarrc).
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    launchd.user.agents.sketchybar = {
      path = [ cfg.package ] ++ cfg.extraPackages ++ [ config.environment.systemPath ];
      serviceConfig.ProgramArguments = [
        "${cfg.package}/bin/sketchybar"
      ]
      ++ optionals (cfg.config != "") [
        "--config"
        "${cfg.configPath}"
      ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };
  };
}
