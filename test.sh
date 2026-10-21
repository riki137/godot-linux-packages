#!/bin/sh
# Installs every amd64 package in dist/ in clean Ubuntu and Fedora containers, runs each command, removes them again.
set -eu
cd "$(dirname "$0")"
run=$(command -v podman || command -v docker)
check='
for c in /usr/bin/godot-*; do $c --headless --version; done
godot --headless --version | grep -q mono # the godot alternative prefers .NET
ls /opt/godot-engine-dotnet*/GodotSharp > /dev/null'
apt_repo='/etc/apt/sources.list.d/godot-linux-packages.sources /etc/apt/keyrings/godot-linux-packages.asc'
dnf_repo=/etc/yum.repos.d/godot-linux-packages.repo
# Godot, the godot command and the repo files all go away with the last package
gone='for f in /opt/godot-engine* /usr/bin/godot '"$apt_repo $dnf_repo"'; do [ ! -e $f ]; done'

$run run --rm -v "$PWD/dist:/dist:ro,z" ubuntu:26.04 sh -euxc "
	apt-get update -qq
	apt-get install -y -qq --no-install-recommends /dist/*/*_amd64.deb > /dev/null
	$check
	for f in $apt_repo; do test -s \$f; done
	apt-get remove -y -qq 'godot-engine*' > /dev/null
	$gone"

$run run --rm -v "$PWD/dist:/dist:ro,z" fedora:latest sh -euxc "
	dnf install -y -q --setopt=install_weak_deps=False /dist/*/*.x86_64.rpm
	$check
	test -s $dnf_repo
	dnf remove -y -q 'godot-engine*'
	$gone"
echo all packages install, run and uninstall cleanly
