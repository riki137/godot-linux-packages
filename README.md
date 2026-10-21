<img src="pkg/godot.svg" width="96" align="right" alt="Godot Engine logo">

# Godot Engine for Ubuntu, Debian and Fedora (.deb/.rpm, with .NET/C#)

[![stable](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Friki137.github.io%2Fgodot-linux-packages%2Fversions.json&query=%24.stable&label=stable&color=478cbf)](https://github.com/riki137/godot-linux-packages/releases/latest)
[![beta](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Friki137.github.io%2Fgodot-linux-packages%2Fversions.json&query=%24.beta&label=beta&color=orange)](https://github.com/riki137/godot-linux-packages/releases)
[![update](https://github.com/riki137/godot-linux-packages/actions/workflows/update.yml/badge.svg)](https://github.com/riki137/godot-linux-packages/actions/workflows/update.yml)

Official Godot 4 builds as `.deb` and `.rpm` packages, the .NET (C#) version included. Install once, and every new Godot release arrives with your normal system updates.

## Download

|                                 | Ubuntu, Debian, Mint | Fedora | arm64 |
|---------------------------------|----------------------|--------|-------|
| Godot .NET (C# and GDScript)    | [![.deb](https://img.shields.io/badge/download-.deb-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://riki137.github.io/godot-linux-packages/download/godot-engine-dotnet_amd64.deb) | [![.rpm](https://img.shields.io/badge/download-.rpm-51A2DA?style=for-the-badge&logo=fedora&logoColor=white)](https://riki137.github.io/godot-linux-packages/download/godot-engine-dotnet.x86_64.rpm) | [deb](https://riki137.github.io/godot-linux-packages/download/godot-engine-dotnet_arm64.deb), [rpm](https://riki137.github.io/godot-linux-packages/download/godot-engine-dotnet.aarch64.rpm) |
| Godot (GDScript)                | [![.deb](https://img.shields.io/badge/download-.deb-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://riki137.github.io/godot-linux-packages/download/godot-engine_amd64.deb) | [![.rpm](https://img.shields.io/badge/download-.rpm-51A2DA?style=for-the-badge&logo=fedora&logoColor=white)](https://riki137.github.io/godot-linux-packages/download/godot-engine.x86_64.rpm) | [deb](https://riki137.github.io/godot-linux-packages/download/godot-engine_arm64.deb), [rpm](https://riki137.github.io/godot-linux-packages/download/godot-engine.aarch64.rpm) |
| Godot .NET beta (dev, beta, rc) | [.deb](https://riki137.github.io/godot-linux-packages/download/godot-engine-dotnet-beta_amd64.deb) | [.rpm](https://riki137.github.io/godot-linux-packages/download/godot-engine-dotnet-beta.x86_64.rpm) | [deb](https://riki137.github.io/godot-linux-packages/download/godot-engine-dotnet-beta_arm64.deb), [rpm](https://riki137.github.io/godot-linux-packages/download/godot-engine-dotnet-beta.aarch64.rpm) |
| Godot beta (dev, beta, rc)      | [.deb](https://riki137.github.io/godot-linux-packages/download/godot-engine-beta_amd64.deb) | [.rpm](https://riki137.github.io/godot-linux-packages/download/godot-engine-beta.x86_64.rpm) | [deb](https://riki137.github.io/godot-linux-packages/download/godot-engine-beta_arm64.deb), [rpm](https://riki137.github.io/godot-linux-packages/download/godot-engine-beta.aarch64.rpm) |

Open the file to install it, or run `sudo apt install ./godot-engine-dotnet_amd64.deb` (Fedora: `sudo dnf install ./godot-engine-dotnet.x86_64.rpm`). The package also adds this repo, so `apt upgrade` and `dnf upgrade` keep Godot current. Install as many variants as you like.

## Why

|                                     | this repo | official zip | Flathub             | distro package          |
|-------------------------------------|-----------|--------------|---------------------|-------------------------|
| Godot .NET (C#)                     | ✅        | ✅           | ⚠️ stuck on 4.3     | ❌                      |
| newest Godot 4                      | ✅        | ✅           | ✅                  | ⚠️ Ubuntu 26.04 has 3.6 |
| official upstream binaries          | ✅        | ✅           | ❌ rebuilt          | ❌ rebuilt              |
| updates with the system             | ✅        | ❌           | ✅                  | ✅                      |
| uses your `dotnet` SDK and IDE      | ✅        | ✅           | ❌ sandboxed .NET 8 | -                       |
| `godot` command on PATH             | ✅        | ❌           | ❌ `flatpak run`    | ✅                      |
| menu icon, `project.godot` opens it | ✅        | ❌           | ✅                  | ✅                      |
| stable and beta side by side        | ✅        | ✅ by hand   | ⚠️                  | ❌                      |

New Godot releases are picked up by a [GitHub Action](.github/workflows/update.yml) that checks every 3 hours, tests the packages in Ubuntu and Fedora containers and publishes them. Nobody has to remember to bump a version.

## Commands

| package                    | command             |
|----------------------------|---------------------|
| `godot-engine`             | `godot-stable`      |
| `godot-engine-dotnet`      | `godot-dotnet`      |
| `godot-engine-beta`        | `godot-beta`        |
| `godot-engine-dotnet-beta` | `godot-dotnet-beta` |

`godot` runs one of them (.NET over plain, stable over beta). Switch with `sudo update-alternatives --config godot`.

<details>
<summary>Add the repo from the terminal instead</summary>

Ubuntu, Debian, Mint:

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

</details>

## How it works

Each package is under 10 KB. It holds the download URL, the SHA-512 and a [short install script](pkg/postinst.sh) that downloads the official zip from [godotengine/godot-builds](https://github.com/godotengine/godot-builds/releases), refuses it if the hash doesn't match and unpacks it to `/opt`. Removing the last package removes Godot and the repo again. Export templates still install from the editor.

Unofficial, not affiliated with the Godot Foundation. Godot is MIT licensed, the Godot logo is CC BY 4.0 by Andrea Calabró. The packaging scripts are MIT too.

Godot maintainers: if any of this is useful for official Linux packages, take it. Fork it, move it under godotengine, rewrite it, no credit needed. I'd be happy to see it go upstream in whatever shape works for you.
