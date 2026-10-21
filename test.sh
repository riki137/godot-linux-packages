#!/bin/sh
# Installs every amd64 package in dist/ in clean Ubuntu and Fedora containers, runs each command, removes them again.
set -eu
cd "$(dirname "$0")"
run=$(command -v podman || command -v docker)
check='
for c in /usr/bin/godot-*; do $c --headless --version; done
godot --headless --version | grep -q mono # the godot alternative prefers .NET
ls /opt/godot-engine-dotnet*/GodotSharp > /dev/null'
gone='! ls -d /opt/godot-engine* 2> /dev/null && ! [ -e /usr/bin/godot ]'

$run run --rm -v "$PWD/dist:/dist:ro,z" ubuntu:26.04 sh -euxc "
	apt-get update -qq
	apt-get install -y -qq --no-install-recommends /dist/*/*_amd64.deb > /dev/null
	$check
	apt-get remove -y -qq 'godot-engine*' > /dev/null
	$gone"

$run run --rm -v "$PWD/dist:/dist:ro,z" fedora:latest sh -euxc "
	dnf install -y -q --setopt=install_weak_deps=False /dist/*/*.x86_64.rpm
	$check
	dnf remove -y -q 'godot-engine*'
	$gone"
echo all packages install, run and uninstall cleanly
