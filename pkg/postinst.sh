#!/bin/sh
# Downloads the official Godot build this package pins, checks its SHA-512 and unpacks it to /opt/@PKG@.
# Runs as the deb postinst ("configure") and the rpm %post (1 = install, 2 = upgrade).
set -eu
case "${1:-}" in configure|[0-9]*) ;; *) exit 0 ;; esac

dir=/opt/@PKG@
url=@URL@
sha512=@SHA512@

if [ "$(cat "$dir/.sha512" 2>/dev/null)" != "$sha512" ]; then
	tmp=$(mktemp -d /var/tmp/@PKG@.XXXXXX)
	trap 'rm -rf "$tmp"' EXIT
	echo "Downloading Godot @VERSION@ from $url"
	curl --proto '=https' --tlsv1.2 -fsSL --retry 3 -o "$tmp/godot.zip" "$url"
	echo "$sha512  $tmp/godot.zip" | sha512sum -c --quiet -
	unzip -q "$tmp/godot.zip" -d "$tmp/x"
	# the .NET zip wraps the binary and GodotSharp/ in a folder, the plain zip is just the binary
	root=$tmp/x
	[ "$(ls "$root" | wc -l)" = 1 ] && [ -d "$root"/* ] && root=$(echo "$root"/*)
	mv "$root"/Godot_v* "$root/godot"
	chmod 755 "$root/godot"
	echo "$sha512" > "$root/.sha512"
	rm -rf "$dir.new" "$dir.old"
	mv "$root" "$dir.new"
	[ ! -e "$dir" ] || mv "$dir" "$dir.old"
	mv "$dir.new" "$dir"
	rm -rf "$dir.old"
fi

if command -v update-alternatives >/dev/null; then alt=update-alternatives; else alt=alternatives; fi
$alt --install /usr/bin/godot godot /usr/bin/@CMD@ @PRIO@
