#!/bin/sh
# Adds the packages in dist/ to the published repo and re-signs its metadata, and refreshes the landing page.
# usage: ./publish.sh [published-dir]   (default: site-out). Signs with gpg's default key; needs apt-ftparchive, createrepo_c and appstreamcli.
set -eu
cd "$(dirname "$0")"
out=$(realpath "${1:-site-out}")
mkdir -p "$out/deb" "$out/rpm"
cp -r site/. "$out/"
cp pkg/godot.svg "$out/"
touch "$out/.nojekyll"
ls dist/*/*.deb > /dev/null 2>&1 || exit 0
cp dist/*/*.deb "$out/deb/"
cp dist/*/*.rpm "$out/rpm/"
# for the README badges: {"stable": "4.7.2", "beta": "4.8-beta1"}
latest() { ls "$out/deb/$1"_*_amd64.deb | sort -V | tail -1; }
newest() { latest "$1" | sed -E "s/.*\/$1_(.+)-[0-9]+_amd64\.deb$/\1/" | sed 's/~~*/-/'; }
printf '{"stable": "%s", "beta": "%s"}\n' "$(newest godot-engine)" "$(newest godot-engine-beta)" > "$out/versions.json"
# versionless copies for the README's download buttons: godot-engine_amd64.deb, godot-engine.x86_64.rpm
mkdir -p "$out/download"
for f in dist/*/*.deb dist/*/*.rpm; do
	cp "$f" "$out/download/$(basename "$f" | sed -E -e 's/_[^_]+_/_/' -e 's/-[^-]+-[0-9]+(\.[a-z0-9_]+\.rpm)$/\1/')"
done

# AppStream catalog: software centers list the packages with their name, icon, screenshots and license
{
	echo '<?xml version="1.0" encoding="UTF-8"?>'
	echo '<components version="1.0" origin="godot-linux-packages">'
	for p in godot-engine godot-engine-dotnet godot-engine-beta godot-engine-dotnet-beta; do
		dpkg-deb --fsys-tarfile "$(latest $p)" | tar -xO --wildcards './usr/share/metainfo/*' | sed -e '/<?xml/d' -e "s|</component>|\
  <pkgname>$p</pkgname>\
  <icon type=\"stock\">$p</icon>\
  <icon type=\"remote\">https://riki137.github.io/godot-linux-packages/godot.svg</icon>\
</component>|"
	done
	echo '</components>'
} > "$out/appstream.xml"

cd "$out/deb"
sign() {
	gpg --batch --yes --clearsign -o "$1/InRelease" "$1/Release"
	gpg --batch --yes -abs -o "$1/Release.gpg" "$1/Release"
}
release() { apt-ftparchive -o APT::FTPArchive::Release::Origin=godot-linux-packages -o APT::FTPArchive::Release::Label="Godot Engine" "$@"; }
# apt only fetches AppStream (DEP-11) data from a dists/<suite>/<component> layout
d=dists/stable/main
for a in amd64 arm64; do
	mkdir -p $d/binary-$a $d/dep11
	apt-ftparchive --arch $a packages . > $d/binary-$a/Packages
	gzip -9kf $d/binary-$a/Packages
	# Ubuntu's App Center only reads the older DeveloperName key
	appstreamcli convert --format=yaml "$out/appstream.xml" $d/dep11/Components-$a.yml
	sed -i '/^Developer:$/i DeveloperName:\n  C: The Godot Engine Community' $d/dep11/Components-$a.yml
	gzip -9kf $d/dep11/Components-$a.yml
done
release -o APT::FTPArchive::Release::Suite=stable -o APT::FTPArchive::Release::Codename=stable \
	-o APT::FTPArchive::Release::Components=main -o APT::FTPArchive::Release::Architectures="amd64 arm64" \
	release dists/stable > Release.tmp
mv Release.tmp dists/stable/Release
sign dists/stable
# the flat repo (Suites: ./) of installs from before dists/stable; their next upgrade switches them over
rm -f Release InRelease Release.gpg
apt-ftparchive packages . > Packages
gzip -9kf Packages
release release . > ../Release.tmp
mv ../Release.tmp Release
sign .

cd "$out/rpm"
createrepo_c -q --update .
modifyrepo_c --mdtype=appstream --compress-type=gz "$out/appstream.xml" repodata > /dev/null
gpg --batch --yes -abs -o repodata/repomd.xml.asc repodata/repomd.xml
