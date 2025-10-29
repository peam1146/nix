{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) optionalString;
  cfg = config.programs.zsh.zinit;

  zinitPluginStr = (
    plugins:
    plugins
    |> lib.lists.imap1 (
      index: plugin:
      "  ${optionalString plugin.isLight "light-mode"} ${
          optionalString (plugin.depth != 0) "depth\"${builtins.toString plugin.depth}\""
        } ${plugin.repo} ${lib.optionalString (builtins.length plugins != index) "\\"}\n"
    )
    |> lib.concatStrings
  );

  zinitForSyntaxBuilder = (
    wait: plugins:
    lib.optionalString (plugins != [ ]) ''
      zinit lucid ${lib.optionalString (wait != "") "wait\"${wait}\" "}for \
      ${zinitPluginStr plugins}
    ''
  );

  groupedPlugins = (
    plugins:
    plugins
    |> map (
      plugin:
      if lib.isString plugin then
        {
          repo = plugin;
          isLight = true;
          wait = 0;
          depth = 0;
        }
      else
        plugin
    )
    |> lib.groupBy (plugin: builtins.toString plugin.wait)
    |> lib.attrsets.mapAttrs zinitForSyntaxBuilder
    |> lib.attrValues
  );

  stringPlugins =
    lib.optionalString (cfg.plugins != [ ])
      "${cfg.plugins |> groupedPlugins |> lib.concatStrings}";
in
{
  meta.maintainers = [ lib.maintainers.hitsmaxft ];

  options.programs.zsh.zinit = {
    enable = lib.mkEnableOption "antidote - a zsh plugin manager";

    plugins =
      let
        pkgWithOption = lib.types.submodule {
          options = {
            repo = lib.mkOption {
              type = lib.types.str;
              description = "The repository name for a package.";
            };
            isLight = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = ''
                zinit load  <repo/plugin> # Load with reporting/investigating.
                zinit light <repo/plugin> # Load without reporting/investigating.
              '';
            };
            wait = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = 0;
              description = "Turbo mode is the key to performance. It can be loaded asynchronously, which makes a huge difference when the amount of plugins increases.";
            };
            depth = lib.mkOption {
              type = lib.types.int;
              default = 0;
              description = "Pass --depth to git, i.e. limit how much of history to download. Does not work with snippets.";
            };
          };
        };
        pkgType = lib.types.oneOf [
          lib.types.str
          pkgWithOption
        ];
      in
      lib.mkOption {
        type = lib.types.listOf pkgType;
        default = [ ];
        example = [
          "zsh-users/zsh-autosuggestions"
          {
            repo = "zsh-users/zsh-autosuggestions";
            wait = 1;
            mode = "light";
          }
        ];
        description = "List of zinit plugins.";
      };

    useFriendlyNames = lib.mkEnableOption "friendly names";

    package = lib.mkPackageOption pkgs "zinit" { nullable = true; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    programs.zsh.initContent = (
      lib.mkOrder 550 ''
        source ${cfg.package}/share/zinit/zinit.zsh

        ${stringPlugins}

        ## home-manager/zinit end
      ''
    );
  };
}
