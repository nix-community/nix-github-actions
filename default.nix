let
  inherit (builtins) attrValues mapAttrs attrNames;
  flatten = list: builtins.foldl' (acc: v: acc ++ v) [ ] list;

  self = {
    githubPlatforms = {
      "x86_64-linux" = "ubuntu-22.04";
      "x86_64-darwin" = "macos-12";
      "aarch64-darwin" = "macos-14";
    };

    # Return a GitHub Actions matrix from a package set shaped like
    # the Flake attribute packages/checks.
    mkGithubMatrix =
      { checks # Takes an attrset shaped like { x86_64-linux = { hello = pkgs.hello; }; }
      , attrPrefix ? "githubActions.checks"
      , platforms ? self.githubPlatforms
      }: {
        inherit checks;
        matrix = {
          include = flatten (attrValues (
            mapAttrs
              (
                system: pkgs: builtins.map
                  (attr:
                    {
                      name = attr;
                      inherit system;
                      os =
                        let
                          os = platforms.${system};
                        in
                        if builtins.typeOf os == "list" then os else [ os ];
                      attr = (
                        if attrPrefix != ""
                        then "${attrPrefix}.${system}.\"${attr}\""
                        else "${system}.\"${attr}\""
                      );
                    })
                  (attrNames pkgs)
              )
              checks));
        };
      };
  };

in
self
