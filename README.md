# Godot Engine for Ubuntu, Debian and Fedora (apt/dnf, with .NET/C#)

[![stable](https://img.shields.io/github/v/release/riki137/godot-linux-packages?label=stable)](https://github.com/riki137/godot-linux-packages/releases/latest)
[![beta](https://img.shields.io/github/v/release/riki137/godot-linux-packages?include_prereleases&label=beta)](https://github.com/riki137/godot-linux-packages/releases)
[![update](https://github.com/riki137/godot-linux-packages/actions/workflows/update.yml/badge.svg)](https://github.com/riki137/godot-linux-packages/actions/workflows/update.yml)

Official Godot 4 builds as `apt` and `dnf` packages, the .NET (C#) version included. A GitHub Action checks for new Godot releases every 3 hours and publishes them, no human involved.

## Install

Ubuntu, Debian, Linux Mint, Pop!_OS:

```sh
sudo wget -qO /etc/apt/keyrings/godot-linux-packages.asc https://riki137.github.io/godot-linux-packages/godot-linux-packages.asc
sudo wget -qO /etc/apt/sources.list.d/godot-linux-packages.sources https://riki137.github.io/godot-linux-packages/godot-linux-packages.sources
sudo apt update && sudo apt install godot-engine-dotnet
```

Fedora:

```sh
sudo curl -fsSLo /etc/yum.repos.d/godot-linux-packages.repo https://riki137.github.io/godot-linux-packages/godot-linux-packages.repo
sudo dnf install godot-engine-dotnet
```

| package                    | command             | what                         |
|----------------------------|---------------------|------------------------------|
| `godot-engine`             | `godot-stable`      | Godot (GDScript)             |
| `godot-engine-dotnet`      | `godot-dotnet`      | Godot .NET (C# and GDScript) |
| `godot-engine-beta`        | `godot-beta`        | newest dev, beta or rc       |
| `godot-engine-dotnet-beta` | `godot-dotnet-beta` | newest dev, beta or rc, .NET |

Install any combination. `godot` runs one of them (.NET over plain, stable over beta), switch with `sudo update-alternatives --config godot`. x86_64 and arm64.

## Why

1. Distros don't have it. Ubuntu 26.04 only ships Godot 3, Debian is a version behind and none of them has the .NET build.
2. These are the official builds, byte for byte. Each package pins the SHA-512 of the upstream zip and checks it on install.
3. `apt upgrade` gets you a new Godot a few hours after its release. Nobody has to remember to bump a version.
4. C# works with your normal `dotnet` SDK (installed as a recommended package). No Flatpak sandbox between Godot, the SDK and your IDE.
5. `godot` is on your PATH, every variant gets a menu entry with an icon and `project.godot` files open in Godot.
6. Stable and beta live side by side, so trying a beta doesn't cost you your stable editor.

## How it works

Each package is about 4 KB. It holds the download URL, the SHA-512 and a [30-line install script](pkg/postinst.sh) that downloads the zip from [godotengine/godot-builds](https://github.com/godotengine/godot-builds/releases), verifies it and unpacks it to `/opt`. Removing the package removes Godot from `/opt` too. Everything that builds and publishes the repo is here: [build.sh](build.sh) and [the workflow](.github/workflows/update.yml).

Export templates still install from the editor (Editor > Manage Export Templates).

Unofficial, not affiliated with the Godot Foundation. Godot is MIT licensed, the Godot logo is CC BY 4.0 by Andrea Calabró. The packaging scripts are MIT too.
