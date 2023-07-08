# nix-github-actions
This is a library to turn Nix Flake attribute sets into Github Actions matrices.

**Features:**

- Unopinionated

Install Nix using any method you like

- Flexible

Nix-github-actions is not an action in itself but a series of templates and a Nix library to build your own CI.

- Parallel job execution

Use one Github Actions runner per package attribute

## Usage

### Quickstart
nix-github-actions comes with a quickstart script that interactively guides you through integrating it:
``` bash
$ nix run github:nix-community/nix-github-actions
```

### Manual

1. Find a CI template in [./.github/workflows](./.github/workflows) and copy it to your project

2. Integrate into your project

#### Using Flake atttribute packages

- `flake.nix`
``` nix
{
  inputs.nix-github-actions.url = "github:nix-community/nix-github-actions";
  inputs.nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nix-github-actions }: {
    githubActions = nix-github-actions.lib.mkGithubMatrix { checks = self.packages; };
    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
  };
}
```

#### Using Flake attribute checks

- `flake.nix`
``` nix
{
  inputs.nix-github-actions.url = "github:nix-community/nix-github-actions";
  inputs.nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nix-github-actions }: {
    githubActions = nix-github-actions.lib.mkGithubMatrix { inherit (self) checks; };
    checks.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    checks.x86_64-linux.default = self.packages.x86_64-linux.hello;
  };
}
```
