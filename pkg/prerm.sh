#!/bin/sh
# Undoes postinst on removal, not on upgrade. Runs as the deb prerm ("remove") and the rpm %preun (0 = erase).
set -eu
case "${1:-}" in remove|0) ;; *) exit 0 ;; esac
if command -v update-alternatives >/dev/null; then alt=update-alternatives; else alt=alternatives; fi
$alt --remove godot /usr/bin/@CMD@ || true
rm -rf /opt/@PKG@ /opt/@PKG@.new /opt/@PKG@.old
# the last godot-engine package out takes the repo with it
ls -d /opt/godot-engine* > /dev/null 2>&1 ||
	rm -f /etc/apt/sources.list.d/godot-linux-packages.sources /etc/apt/keyrings/godot-linux-packages.asc /etc/yum.repos.d/godot-linux-packages.repo
