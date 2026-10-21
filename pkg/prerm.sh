#!/bin/sh
# Undoes postinst on removal, not on upgrade. Runs as the deb prerm ("remove") and the rpm %preun (0 = erase).
set -eu
case "${1:-}" in remove|0) ;; *) exit 0 ;; esac
if command -v update-alternatives >/dev/null; then alt=update-alternatives; else alt=alternatives; fi
$alt --remove godot /usr/bin/@CMD@ || true
rm -rf /opt/@PKG@ /opt/@PKG@.new /opt/@PKG@.old
