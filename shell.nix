let
  nixpkgs = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.05.tar.gz";
    sha256 = "1915r28xc4znrh2vf4rrjnxldw2imysz819gzhk9qlrkqanmfsxd";
  };
  pkgs = import nixpkgs {
    config.allowUnfreePredicate = pkg: pkgs.lib.getName pkg == "terraform";
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    awscli
    bash
    coreutils
    openssh
    python3
    rsync
    terraform
    tmux
  ];

  shellHook = ''
    echo "RonDB benchmark environment loaded"
  '';
}
