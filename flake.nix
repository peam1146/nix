{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs;[
            neovim
            nixd
            nixfmt
            neofetch
            lsd
            gh
            git-town
            go
            fvm
            fzf
            bat
            nil
            glab
          ];

          fonts.packages = with pkgs; [
            nerd-fonts.fira-code
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          homebrew = {
            enable = true;

            onActivation = {
              cleanup = "zap";
            };

            taps = [
              "jorgelbg/tap"
            ];

            brews = [
              "btop"
              "gpg"
              "gpg2"
              "gnupg"
              "pinentry-mac"
              "pinentry-touchid"
            ];

            casks = [
              "font-hack-nerd-font"
              "karabiner-elements"
              "spotify"
              "discord"
              "figma"
              "1password"
              "shortcat"

              # Terminal
              "ghostty"

              # Git GUI Client
              "fork"

              # Text Editor
              "zed"

              # show keystrokes on screen
              "keycastr"
            ];
          };

          system.primaryUser = "peam";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          # system.defaults.NSGlobalDomain._HIHideMenuBar = true;

          environment.launchDaemons = {
            "com.github.peam.Karabiner-VirtualHIDDevice-Daemon" = {
              source = "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
            };
          };

          launchd.daemons = {
            "com.github.peam.kanata" = {
              script = ''
                /Users/peam/.config/kanata/kanata_macos_cmd_allowed_arm64 --cfg /Users/peam/dotfiles/.config/kanata/home-row-mod-advanced.kbd
              '';
              serviceConfig = {
                # EnvironmentVariables = {
                #   NB_CONFIG = "/var/lib/netbird/config.json";
                #   NB_LOG_FILE = "console";
                # };
                KeepAlive = true;
                RunAtLoad = true;
                StandardOutPath = "/var/log/kanata.out.log";
                StandardErrorPath = "/var/log/kanata.err.log";
              };
            };
          };

          services.yabai = {
            enable = true;
            enableScriptingAddition = true;

            config = {
              layout = "bsp";
              window_border = true;
              mouse_follows_focus = false;
              focus_follows_mouse = false;
              window_zoom_persist = false;
              window_placement = "second_child";
              window_topmost = false;
              window_shadow = "float";
              window_opacity = false;
              window_opacity_duration = 0.0;
              active_window_opacity = 1.0;
              normal_window_opacity = 0.0;
              window_border_width = 2;
              window_border_hidpi = false;
              window_border_radius = 11;
              window_border_blur = false;
              window_animation_duration = 0;
              active_window_border_color = "0xffe1e3e4";
              normal_window_border_color = "0xff494d64";
              insert_feedback_color = "0xff9dd274";
              split_ratio = 0.50;
              auto_balance = false;
              mouse_modifier = "fn";
              mouse_action1 = "move";
              mouse_action2 = "resize";
              mouse_drop_action = "swap";
              top_padding = 12;
              bottom_padding = 12;
              left_padding = 12;
              right_padding = 12;
              window_gap = 12;
            };

            extraConfig = ''
              yabai -m rule --add app="^System Settings$" manage=off
              yabai -m rule --add app="^Karabiner-Elements$" manage=off
              yabai -m rule --add app="^Raycast$" manage=off
              yabai -m rule --add app="^1Password$" manage=off

              # ## move some apps automatically to specific spaces
              yabai -m rule --add app="Arc" space=^1
              yabai -m rule --add app="WezTerm" space=2
              yabai -m rule --add app="Ghostty" space=2
              yabai -m rule --add app="Code" space=3
              yabai -m rule --add app="Windsurf" space=3
              yabai -m rule --add app="Zed" space=3
              yabai -m rule --add app="Discord" space=^4
              yabai -m rule --add app="Spotify" space=^5
            '';
          };


          services.skhd = {
            enable = true;
            skhdConfig = builtins.readFile ./skhdrc;
          };

          # services.sketchybar = {
          #   enable = true;
          # };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Supakarins-MacBook-Pro
      darwinConfigurations."Supakarins-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "peam";

              autoMigrate = true;
            };
          }
        ];
      };
    };
}
