{
  description = "Generate Github Actions matrices from Nix Flakes";

  outputs = { self, nixpkgs }:
    let
      eachSystem = systems: fn: builtins.foldl' (acc: system: acc // { ${system} = (fn system); }) { } systems;
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];

    in
    {
      lib = import ./default.nix;

      githubActions = self.lib.mkGithubMatrix {
        # Inherit GHA actions matrix from a subset of platforms supported by hosted runners
        checks = {
          inherit (self.checks) x86_64-linux x86_64-darwin;
        };
      };

      # Just regular flake checks
      checks = eachSystem supportedSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          nixpkgs-fmt = pkgs.runCommand "nixpkgs-fmt-check" { nativeBuildInputs = [ pkgs.nixpkgs-fmt ]; } ''
            nixpkgs-fmt --check ${self}
            touch $out
          '';
        });

      # Development shell to hack on this
      devShells = eachSystem supportedSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.nixpkgs-fmt ];
          };
        });

    };
}
