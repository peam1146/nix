{ config, pkgs, ... }:
let
  username = "peam";
in
{
  imports = [
    ../modules/zinit
  ];

  home.username = username;
  home.stateVersion = "25.05";

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/nvim" = {
      source = ./config/nvim;
      recursive = true;
    };
    ".config/lvim".source = ./config/lvim;
    ".config/neofetch".source = ./config/neofetch;
    ".config/starship.toml".source = ./config/starship.toml;
  };

  # home.packages = with pkgs; [
  #   (writeShellApplication {
  #     name = "nst";
  #     runtimeInputs = with pkgs; [
  #       fzf
  #       nix-search-tv
  #     ];
  #     text =
  #       builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh"
  #       |>
  #         builtins.replaceStrings
  #           [
  #             "NIX_SHELL_CMD='nix-shell --run $SHELL -p $(echo \"{}\" | sed \"s:nixpkgs/::g\"'"
  #             "NIX_SHELL_CMD=\"$NIX_SHELL_CMD | tr -d \\\"\\\'\\\")\""
  #           ]
  #           [
  #             "NIX_SHELL_CMD=\"nix-shell --run $SHELL -p $(echo \\\"{}\\\" | sed \\\"s:nixpkgs/::g\\\"\""
  #             "NIX_SHELL_CMD=\"$NIX_SHELL_CMD | tr -d \\\"\\\'\\\")\""
  #           ];
  #   })
  # ];

  home.sessionVariables = {
    EDITOR = "windsurf";
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
    GPG_TTY = "$(tty)";
    JAVA_HOME = "$HOME/Library/Java/JavaVirtualMachines/jdk-21.0.1.jdk/Contents/Home/";
    CRYPTO_DIR = "/usr/local";
    USE_GKE_GCLOUD_AUTH_PLUGIN = "True";
    CAPACITOR_ANDROID_STUDIO_PATH = "$HOME/Library/Android/sdk";
    VOLTA_HOME = "$HOME/.volta";
    VOLTA_FEATURE_PNPM = "1";
    PNPM_HOME = "$HOME/Library/pnpm";
    GOOGLE_APPLICATION_CREDENTIALS = "$HOME/.config/gcloud/application_default_credentials.json";
    BUN_INSTALL = "$HOME/.bun";
    PERL5LIB = "$HOME/perl5/lib/perl5";
    PERL_LOCAL_LIB_ROOT = "$HOME/perl5";
    PERL_MB_OPT = "--install_base \"$HOME/perl5\"";
    PERL_MM_OPT = "INSTALL_BASE=$HOME/perl5";
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
    "$HOME/go/bin"
    "$HOME/.local/bin"
    "$HOME/.pub-cache/bin"
    "/opt/homebrew/sbin"
    "/opt/homebrew/bin"
    "$HOME/.asdf/shims"
    "$HOME/fvm/default/bin"
    "$HOME/.rvm/bin"
    "$HOME/.volta/bin"
    "$HOME/Library/pnpm"
    "$HOME/.bun/bin"
    "$HOME/.codeium/windsurf/bin"
    "$HOME/.antigravity/antigravity/bin"
    "$HOME/perl5/bin"
    "$HOME/.lmstudio/bin"
  ];

  programs.home-manager.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.nix-search-tv = {
    enable = true;
    settings = {
      experimental = {
        render_docs_indexes = {
          plasma = "https://nix-community.github.io/plasma-manager/options.xhtml";
        };
      };
    };
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = false;
    autosuggestion.enable = true;
    history.size = 1000000;
    history.saveNoDups = true;

    plugins = [
      {
        name = "jira-git-town-hack";
        src = ./scripts;
        file = "jira-hack.sh";
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];

    envExtra = ''
      skip_global_compinit=1
    '';

    zinit = {
      enable = true;
      plugins = [
        "joshskidmore/zsh-fzf-history-search"
        "hlissner/zsh-autopair"
        "akash329d/zsh-alias-finder"
        "chitoku-k/fzf-zsh-completions"
        {
          repo = "marlonrichert/zsh-autocomplete";
          wait = null;
        }
      ];
    };

    initContent = ''
      # TODO: migrate to SOPS
      source $HOME/.secret.sh

      # create hash for all directory in work
      for d in $HOME/work/*; do
        hash -d $(basename $d)="$d"
      done
    '';

    shellAliases = {
      ls = "lsd";
      work = "cd ~/work";
      snt = "cd ~/work/softnetics";
      reload = "source ~/.zshrc && echo 'Reloaded ~/.zshrc'";
      g = "git";
      tableplus = "open -a TablePlus";
      k = "kubectl";
    };

    dirHashes = {
      snt = "$HOME/work/softnetics";
      work = "$HOME/work";
      dl = "$HOME/Downloads";
    };
  };
}
