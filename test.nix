let
  plugins = [
    "joshskidmore/zsh-fzf-history-search"
    "hlissner/zsh-autopair"
    {
      repo = "zinit/zinit";
      isLight = false;
      wait = 0;
    }
    {
      repo = "zinit/zinit2";
      isLight = false;
      wait = 1;
    }
  ];
  lib = import <nixpkgs/lib>;

  zinitPluginStr = (
    pluigns:
    pluigns
    |> lib.lists.imap1 (
      index: plugin: ''
        ${lib.optionalString plugin.isLight "light-mode"} ${plugin.repo} ${
          lib.optionalString (builtins.length plugins != index + 1) "\\"
        }
      ''
    )
    |> lib.concatStrings
  );

  zinitForSyntaxBuilder = (
    wait: plugins:
    lib.optionalString (plugins != [ ]) ''
      zinit lucid wait"${wait}" for \
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
        }
      else
        plugin
    )
    |> lib.groupBy (plugin: plugin.mode)
    |> lib.attrsets.mapAttrs (
      name: value:
      value |> lib.groupBy (v: builtins.toString v.wait) |> lib.mapAttrs (n: v: v |> map (v: v.repo))
    )
    |> lib.mapAttrsToList (
      mode: groupsOfWait:
      groupsOfWait |> lib.mapAttrs (wait: plugins: zinitForSyntaxBuilder plugins mode wait)
      # |> lib.attrValues
    )
  );

  groupedPluginsV2 = (
    plugins:
    plugins
    |> map (
      plugin:
      if lib.isString plugin then
        {
          repo = plugin;
          isLight = true;
          wait = 0;
        }
      else
        plugin
    )
    |> lib.groupBy (plugin: builtins.toString plugin.wait)
    |> lib.attrsets.mapAttrs zinitForSyntaxBuilder
    |> lib.attrValues
  );

  stringPlugins = lib.optionalString (plugins != [ ]) "${plugins |> groupedPluginsV2}";
in
{
  stringPlugins = stringPlugins;
  groupedPluginsV2 = plugins |> groupedPluginsV2;
}
