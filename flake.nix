{
  description = "IHP Dev Environment for Codespaces";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.devenv
            pkgs.cachix
            pkgs.direnv
            pkgs.ihp-new
            pkgs.git
          ];

          shellHook = ''
            # Setup direnv
            eval "$(direnv hook bash)"
            # Direnv whitelist (Codespaces workspaces mount here)
            mkdir -p ~/.config/direnv
            echo -e "[whitelist]\nprefix = ['/workspaces/']" > ~/.config/direnv/direnv.toml

            # add cachix
            cachix use cachix
            cachix use digitallyinduced

            # Codespaces-aware URLs
            export IHP_BASEURL=$(
              if [ -n "$CODESPACE_NAME" ]; then
                echo "https://$CODESPACE_NAME-8000.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
              else
                echo "http://localhost:8000"
              fi
            )
            export IHP_IDE_BASEURL=$(
              if [ -n "$CODESPACE_NAME" ]; then
                echo "https://$CODESPACE_NAME-8001.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
              else
                echo "http://localhost:8001"
              fi
            )

            echo "✅ IHP dev shell is active"
          '';
        };
      });
}

