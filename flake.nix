{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      configuration =
        {
          pkgs,
          config,
          ...
        }:
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
            btop
            sketchybar
            jira-cli-go
            stow
          ];

          fonts.packages = with pkgs; [
            nerd-fonts.fira-code
            sketchybar-app-font
          ];

          nixpkgs.overlays = [
            (self: super: {
              sketchybar-helpers = self.stdenv.mkDerivation {
                name = "sketchybar-helpers";
                src = ./home-manager/config;
                buildPhase = ''
                  echo "Building sketchybar helper..."
                  cd sketchybar/helpers && make all
                  cd ../../
                '';
                installPhase = ''
                  mv sketchybar $out
                '';
              };
            })
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes pipe-operators";

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
              "gpg" # GNU Privacy Guard for encryption/signing
              "gpg2" # GNU Privacy Guard version 2
              "gnupg" # Complete GNU Privacy Guard suite
              "pinentry-mac" # GPG passphrase entry dialog for macOS
              "pinentry-touchid" # GPG passphrase entry using Touch ID
              "cocoapods" # Dependency manager for iOS/macOS projects
              "asdf" # Version manager for Elixir
            ];

            casks = [
              "utm"
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

              # fonts
              "sf-symbols"
              "font-sf-mono"
              "font-sf-pro"
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

          security.pam.services.sudo_local.touchIdAuth = true;

          services.jankyborders = {
            enable = true;
            style = "round";
            width = 6.0;
            hidpi = true;
            active_color = "0xc0e2e2e3";
            inactive_color = "0xc02c2e34";
            background_color = "0x302c2e34";
            blur_radius = 5.0;
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
              top_padding = 16;
              bottom_padding = 12;
              left_padding = 12;
              right_padding = 12;
              external_bar = "all:40:0";
              window_gap = 12;
              # menubar_opacity = 0.0;
            };

            extraConfig = ''
              yabai -m rule --add app="^(LuLu|Calculator|Software Update|Dictionary|VLC|System Preferences|System Settings|zoom.us|Photo Booth|Archive Utility|Python|LibreOffice|App Store|Steam|Alfred|Activity Monitor|Phone|1Password|Raycast|Karabiner|AlDente)$" manage=off
              yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
              yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
              yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
              yabai -m rule --add label="Select file to save to" app="^Inkscape$" title="Select file to save to" manage=off

              ${
                pkgs.lua54Packages.lua.withPackages (ps: with ps; [ cjson ])
              }/bin/lua ${./scripts/enusure_yabai_space.lua}

              # ## move some apps automatically to specific spaces
              yabai -m space 1 --label "Browser"
              yabai -m space 2 --label "Terminal"
              yabai -m space 3 --label "Coding"
              yabai -m space 4 --label "Communication"
              yabai -m space 5 --label "Entertainment"
              yabai -m space 6 --label "Random"

              yabai -m rule --add app="Arc" space=1
              yabai -m rule --add app="WezTerm" space=2
              yabai -m rule --add app="Ghostty" space=2
              yabai -m rule --add app="Code" space=3
              yabai -m rule --add app="Windsurf" space=3
              yabai -m rule --add app="Zed" space=3
              yabai -m rule --add app="Discord" space=4
              yabai -m rule --add app="Instagram" space=5
              yabai -m rule --add app="Spotify" space=5
              yabai -m rule --add app="YouTube" space=5
            '';
          };

          services.skhd = {
            enable = true;
            skhdConfig = builtins.readFile ./skhdrc;
          };

          system.defaults.NSGlobalDomain._HIHideMenuBar = true;

          launchd.user.agents.sketchybar = {
            path =
              with pkgs;
              [
                lua54Packages.lua
                switchaudio-osx
                nowplaying-cli
                lua54Packages.cjson
              ]
              ++ [ config.environment.systemPath ];
            environment = {
              LUA_CPATH = "${pkgs.lua54Packages.cjson}/lib/lua/5.4/?.so;${pkgs.sbarlua}/lib/lua/5.4/sketchybar.so;$LUA_CPATH";
            };
            serviceConfig.ProgramArguments = [
              "${pkgs.sketchybar}/bin/sketchybar"
              "--config"
              "${pkgs.sketchybar-helpers}/sketchybarrc"
            ];
            serviceConfig = {
              KeepAlive = true;
              RunAtLoad = true;
              StandardErrorPath = "/Users/peam/Library/Logs/org.nixos.sketchybar/sketchybar.out.log";
              StandardOutPath = "/Users/peam/Library/Logs/org.nixos.sketchybar/sketchybar.err.log";
            };
          };
        };
    in
    {
      darwinConfigurations."Supakarins-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            users.users.peam.home = "/Users/peam";
            home-manager.users.peam = ./home-manager/home.nix;
          }
        ];
      };
    };
}
