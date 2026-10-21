#!/bin/sh
# Adds the packages in dist/ to the published repo and re-signs its metadata, and refreshes the landing page.
# usage: ./publish.sh [published-dir]   (default: site-out). Signs with gpg's default key; needs apt-ftparchive and createrepo_c.
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
newest() { ls "$out/deb/$1"_*_amd64.deb | sed -E "s/.*\/$1_(.+)-[0-9]+_amd64\.deb$/\1/" | sort -V | tail -1 | sed 's/~~*/-/'; }
printf '{"stable": "%s", "beta": "%s"}\n' "$(newest godot-engine)" "$(newest godot-engine-beta)" > "$out/versions.json"
# versionless copies for the README's download buttons: godot-engine_amd64.deb, godot-engine.x86_64.rpm
mkdir -p "$out/download"
for f in dist/*/*.deb dist/*/*.rpm; do
	cp "$f" "$out/download/$(basename "$f" | sed -E -e 's/_[^_]+_/_/' -e 's/-[^-]+-[0-9]+(\.[a-z0-9_]+\.rpm)$/\1/')"
done

cd "$out/deb"
rm -f Release InRelease Release.gpg
apt-ftparchive packages . > Packages
gzip -9kf Packages
apt-ftparchive -o APT::FTPArchive::Release::Origin=godot-linux-packages \
	-o APT::FTPArchive::Release::Label="Godot Engine" release . > ../Release.tmp
mv ../Release.tmp Release
gpg --batch --yes --clearsign -o InRelease Release
gpg --batch --yes -abs -o Release.gpg Release

cd "$out/rpm"
createrepo_c -q --update .
gpg --batch --yes -abs -o repodata/repomd.xml.asc repodata/repomd.xml
