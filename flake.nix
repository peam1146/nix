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
          environment.systemPackages = with pkgs; [
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
            kanata
            gemini-cli
            just
            zig_0_14
            git-lfs
            xz
            volta
            livebook
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
              autoUpdate = true;
              upgrade = true;
            };

            taps = [
              "jorgelbg/tap"
            ];

            brews = [
              "btop" # Resource monitor with beautiful UI
              "gpg" # GNU Privacy Guard for encryption/signing
              "gpg2" # GNU Privacy Guard version 2
              "gnupg" # Complete GNU Privacy Guard suite
              "pinentry-mac" # GPG passphrase entry dialog for macOS
              "pinentry-touchid" # GPG passphrase entry using Touch ID
              "cocoapods" # Dependency manager for iOS/macOS projects
              "asdf" # Version manager for Elixir
            ];

            casks = [
              "basecamp" # Project management and collaboration tool
              "font-hack-nerd-font" # Hack font with Nerd Font icons
              "karabiner-elements" # Keyboard customization and remapping tool
              "spotify" # Music streaming service
              "discord" # Voice and text chat platform
              "figma" # Collaborative design and prototyping tool
              "1password" # Password manager and secure wallet
              "shortcat" # Mouseless interface for clicking with keyboard
              "ghostty" # Modern terminal emulator
              "fork" # Git client with merge conflict resolution
              "zed" # Collaborative code editor
              "keycastr" # Displays keystrokes on screen for presentations
            ];
          };

          system.primaryUser = "peam";
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          launchd.user.agents.kanata = {
            serviceConfig.ProgramArguments = [
              "sudo"
              "${pkgs.kanata}/bin/kanata"
              "--cfg"
              "/etc/nix-darwin/home-row-mod-advanced.kbd"
            ];
            serviceConfig = {
              KeepAlive = true;
              RunAtLoad = true;
              StandardOutPath = "/Users/peam/Library/Logs/org.nixos.kanata/kanata.out.log";
              StandardErrorPath = "/Users/peam/Library/Logs/org.nixos.kanata/kanata.err.log";
            };
          };

          environment.etc."sudoers.d/kanata".source = pkgs.runCommand "sudoers-kanata" { } ''
            KANATA_BIN="${pkgs.kanata}/bin/kanata"
            SHASUM=$(sha256sum "$KANATA_BIN" | cut -d' ' -f1)
            cat <<EOF >"$out"
            %admin ALL=(root) NOPASSWD: sha256:$SHASUM $KANATA_BIN
            EOF
          '';

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
              yabai -m rule --add app="^Phone$" manage=off

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
