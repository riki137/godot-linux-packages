#!/bin/sh
if [ ! -x /opt/@PKG@/godot ]; then
	echo "@CMD@: Godot was never downloaded. Retry with: sudo apt install --reinstall @PKG@  (Fedora: sudo dnf reinstall @PKG@)" >&2
	exit 1
fi
exec /opt/@PKG@/godot "$@"
