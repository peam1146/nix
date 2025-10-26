{
  stdenv,
  pkgs,
}:
stdenv.mkDerivation {
  name = "sbar-lua";
  src = pkgs.fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SbarLua";
    rev = "437bd2031da38ccda75827cb7548e7baa4aa9978";
    hash = "sha256-F0UfNxHM389GhiPQ6/GFbeKQq5EvpiqQdvyf7ygzkPg=";
  };
  buildInputs = with pkgs; [
    lua54Packages.lua
    gcc
    readline
  ];

  buildPhase = ''
    echo "Building SbarLua..."
    make bin/sketchybar.so
  '';

  installPhase = ''
    echo "Installing to $out/bin..."
    mkdir -p $out/bin
    cp bin/sketchybar.so $out/bin/
  '';

  cleanPhase = ''
    make uninstall
    make clean
  '';
}
