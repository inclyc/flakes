#!/usr/bin/env nix-shell
#!nix-shell -i python -p python3

from dataclasses import dataclass
import os.path
import os
import subprocess
import re
import json
import requests


@dataclass
class Platform:
    arch: str
    os: str


def get_nix_platform(p: Platform):
    nix_archname = {
        "x64": "x86_64",
        "arm64": "aarch64",
    }[p.arch]

    return f"{nix_archname}-{p.os}"


@dataclass
class VSCodiumMetadata:
    asset: str
    platform: Platform
    version: str
    archive_fmt: str


def vscodium_url(meta: VSCodiumMetadata):
    base = "https://github.com/VSCodium/vscodium/releases/download"
    vscodium_url = f"{base}/{meta.version}/{meta.asset}-{meta.platform.os}-{meta.platform.arch}-{meta.version}.{meta.archive_fmt}"
    return vscodium_url


def prefetch(meta: VSCodiumMetadata):
    url = vscodium_url(meta)
    vscodium_sha256 = subprocess.check_output(
        ["nix-prefetch-url", url], text=True
    ).strip()

    return {
        "url": url,
        "sha256": vscodium_sha256,
    }


def fetch_version_github(owner, repo):
    response = requests.get(
        f"https://github.com/{owner}/{repo}/releases/latest",
        allow_redirects=False,
    )
    return response.headers["Location"].rstrip("/").split("/")[-1]


def main():
    ROOT = os.path.dirname(os.path.realpath(__file__))
    nix_path = os.path.join(ROOT, "default.nix")

    if not os.path.isfile(nix_path):
        print(f"ERROR: cannot find vscodium.nix in {ROOT}")
        exit(1)

    # Get the latest VSCodium version
    vscodium_ver = os.environ.get(
        "VSCODIUM_VERSION",
        fetch_version_github("VSCodium", "vscodium"),
    )

    # Update the version in vscodium.nix
    with open(nix_path, "r") as file:
        content = file.read()

    updated_content = re.sub(
        r"version = \".*\"", f'version = "{vscodium_ver}"', content
    )

    with open(nix_path, "w") as file:
        file.write(updated_content)

    # Update hashes for various architectures
    output = {}
    for asset in ("vscodium-reh",):
        output[asset] = {}
        for osname in ("linux", "darwin"):
            for arch in ("x64", "arm64"):
                platform = get_nix_platform(Platform(arch=arch, os=osname))
                output[asset][platform] = prefetch(
                    VSCodiumMetadata(
                        asset=asset,
                        archive_fmt="tar.gz",
                        platform=Platform(os=osname, arch=arch),
                        version=vscodium_ver,
                    ),
                )
    with open(os.path.join(ROOT, "sources.json"), "w") as f:
        json.dump(output, f, indent=4)


if __name__ == "__main__":
    main()
