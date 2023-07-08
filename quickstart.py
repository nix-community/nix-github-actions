#!/usr/bin/env python
from os.path import join as path_join
from textwrap import dedent
from os.path import (
    abspath,
    dirname,
    basename,
)
import sys
import os


SCRIPT_DIR = dirname(abspath(__file__))


if __name__ == "__main__":
    workflow_dir = path_join(SCRIPT_DIR, ".github/workflows")
    files = sorted([
        path_join(workflow_dir, f)
        for f in os.listdir(workflow_dir)
        if f.endswith(".yml") and f != "dependabot.yml"
    ])

    print(
        dedent(
            """
    nix-github-actions quickstart

    This interactive tool helps you to:
    - Select & install a Github CI template into your repository
    - Outputs a code snippet for you to copy & paste into your flake.lock
    """
        )
    )

    # Select CI template
    while True:
        print("Templates:")
        for i, filename in enumerate(files):
            print(f"{i}. {basename(filename)}")

        print("")
        print("Your choice:")

        try:
            choice = files[int(input())]
            print("")
        except (ValueError, IndexError) as e:
            print("Invalid choice: " + str(e), file=sys.stderr)
            continue
        else:
            break

    # Install template into repository
    print("Creating .github/workflows")
    os.makedirs(".github/workflows", exist_ok=True)

    print("Installing template into .github/workflows/nix-github-actions.yml")
    with open(choice) as f:
        template = f.read()
    with open(".github/workflows/nix-github-actions.yml", "w") as f:
        f.write(template)

    print("")
    print("Template installed, now add a githubActions output to your flake:")
    with open(path_join(SCRIPT_DIR, "README.md")) as f:
        print(f.read().split("Integrate into your project")[-1])
