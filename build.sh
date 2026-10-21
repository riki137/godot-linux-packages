#!/bin/sh
# Builds installer packages for the newest Godot stable and prerelease that aren't published yet.
# usage: ./build.sh [published-dir]   (default: site-out)
# Output: dist/<upstream tag>-<REV>/*.deb *.rpm, one directory per new release. Needs gh, curl and nfpm.
# rpms are signed when SIGNING_KEY_FILE points to an armored private key.
set -eu
REV=2 # bump to rebuild the current versions after changing pkg/
cd "$(dirname "$0")"
published=${1:-site-out}
dl=https://github.com/godotengine/godot-builds/releases/download
rm -rf dist build
mkdir -p dist build

# 4.8-dev7 -> 4.8~~dev7, 4.8-beta1 -> 4.8~beta1, 4.8-stable -> 4.8, so dev < beta < rc < stable for dpkg, rpm and sort -V
debver() { echo "$1" | sed -e 's/-stable$//' -e 's/-dev/~~dev/' -e 's/-\(beta\|rc\)/~\1/'; }
newest() { while read -r t; do echo "$(debver "$t") $t"; done | sort -V | tail -1 | cut -d' ' -f2; }

tags=$(gh api --paginate 'repos/godotengine/godot-builds/releases?per_page=100' --jq '.[].tag_name' |
	grep -E '^([4-9]|[1-9][0-9])\.[0-9]+(\.[0-9]+)*-(stable|rc[0-9]+|beta[0-9]+|dev[0-9]+)$')

# package <pkg> <cmd> <alternatives priority> <menu name> <zip name, ARCH = x86_64|arm64>
package() {
	for arch in amd64 arm64; do
		a=x86_64
		[ $arch = amd64 ] || a=arm64
		zip=$(echo "$5" | sed "s/ARCH/$a/")
		sha=$(echo "$sums" | awk -v z="$zip" '$2 == z { print $1 }')
		b=build/$1-$arch
		mkdir -p "$b"
		for f in postinst.sh prerm.sh launcher.sh godot.desktop; do
			sed -e "s|@PKG@|$1|g" -e "s|@CMD@|$2|g" -e "s|@PRIO@|$3|g" -e "s|@NAME@|$4|g" \
				-e "s|@VERSION@|$tag|g" -e "s|@URL@|$dl/$tag/$zip|g" -e "s|@SHA512@|$sha|g" "pkg/$f" > "$b/$f"
		done
		{
			cat <<-EOF
				name: $1
				arch: $arch
				platform: linux
				version: "$ver"
				version_schema: none
				release: "$REV"
				section: devel
				maintainer: riki137 <riki137@users.noreply.github.com>
				homepage: https://github.com/riki137/godot-linux-packages
				license: MIT
				description: |-
				  $4 - multi-platform 2D and 3D game engine (official build)
				  Downloads the official Godot $tag build for $a from godotengine/godot-builds
				  at install time, verifies its SHA-512 and installs it as the $2 command,
				  with a menu entry and an alternative for the godot command. Adds the
				  godot-linux-packages apt/dnf repo for updates.
				depends: [curl, unzip, ca-certificates]
				contents:
				  - {src: $b/launcher.sh, dst: /usr/bin/$2, file_info: {mode: 0755}}
				  - {src: $b/godot.desktop, dst: /usr/share/applications/$1.desktop}
				  - {src: pkg/godot.svg, dst: /usr/share/icons/hicolor/scalable/apps/$1.svg}
				  - {src: pkg/godot-mime.xml, dst: /usr/share/mime/packages/$1.xml}
				  - {src: site/godot-linux-packages.asc, dst: /usr/share/$1/godot-linux-packages.asc}
				  - {src: site/godot-linux-packages.sources, dst: /usr/share/$1/godot-linux-packages.sources}
				  - {src: site/godot-linux-packages.repo, dst: /usr/share/$1/godot-linux-packages.repo}
				scripts: {postinstall: $b/postinst.sh, preremove: $b/prerm.sh}
			EOF
			case $1 in *dotnet*)
				cat <<-EOF
					overrides:
					  deb: {recommends: ["dotnet-sdk-10.0 | dotnet-sdk-9.0 | dotnet-sdk-8.0"]}
					  rpm: {recommends: ["(dotnet-sdk-10.0 or dotnet-sdk-9.0 or dotnet-sdk-8.0)"]}
				EOF
			esac
			[ -z "${SIGNING_KEY_FILE:-}" ] || echo "rpm: {signature: {key_file: $SIGNING_KEY_FILE}}"
		} > "$b/nfpm.yaml"
		for p in deb rpm; do nfpm pkg -f "$b/nfpm.yaml" -p $p -t "$out/" > /dev/null; done
	done
}

# channel <package suffix> <upstream tag>
channel() {
	tag=$2
	ver=$(debver "$tag")
	if [ -e "$published/deb/godot-engine$1_$ver-${REV}_amd64.deb" ]; then
		echo "godot-engine$1 $ver-$REV is already published"
		return
	fi
	if ! sums=$(curl -fsSL "$dl/$tag/SHA512-SUMS.txt"); then
		echo "$tag has no SHA512-SUMS.txt yet"
		return
	fi
	for zip in linux.x86_64 linux.arm64 mono_linux_x86_64 mono_linux_arm64; do
		echo "$sums" | grep -q " Godot_v${tag}_$zip.zip\$" || { echo "$tag: Godot_v${tag}_$zip.zip isn't uploaded yet"; return; }
	done
	out=dist/$tag-$REV
	mkdir -p "$out"
	# the godot alternative prefers .NET over plain, and stable over beta
	if [ "$1" ]; then
		package godot-engine-beta godot-beta 10 "Godot Engine Beta" "Godot_v${tag}_linux.ARCH.zip"
		package godot-engine-dotnet-beta godot-dotnet-beta 20 "Godot Engine Beta (.NET)" "Godot_v${tag}_mono_linux_ARCH.zip"
	else
		package godot-engine godot-stable 30 "Godot Engine" "Godot_v${tag}_linux.ARCH.zip"
		package godot-engine-dotnet godot-dotnet 40 "Godot Engine (.NET)" "Godot_v${tag}_mono_linux_ARCH.zip"
	fi
	echo "built godot-engine$1 $ver-$REV into $out"
}

channel "" "$(echo "$tags" | grep -- '-stable$' | newest)"
channel -beta "$(echo "$tags" | newest)"
