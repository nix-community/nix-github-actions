let
  inherit (builtins) attrValues mapAttrs attrNames;
  flatten = list: builtins.foldl' (acc: v: acc ++ v) [ ] list;

  self = {
    githubPlatforms = {
      "x86_64-linux" = "ubuntu-22.04";
      "x86_64-darwin" = "macos-12";
    };

    # Return a Gitub Actions matrix from a package set shaped like
    # the Flake attribute packages/checks.
    mkGithubMatrix =
      { checks # Takes an attrset shaped like { x86_64-linux = { hello = pkgs.hello; }; }
      , attrPrefix ? "githubActions"
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
                      os = [ (platforms.${system}) ];
                      attr = (
                        if attrPrefix != ""
                        then "${attrPrefix}.checks.${system}.${attr}"
                        else "checks.${system}.${attr}"
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
