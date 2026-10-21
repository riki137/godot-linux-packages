#!/bin/sh
# Adds the packages in dist/ to the published repo and re-signs its metadata, and refreshes the landing page.
# usage: ./publish.sh [published-dir]   (default: site-out). Signs with gpg's default key; needs apt-ftparchive and createrepo_c.
set -eu
cd "$(dirname "$0")"
out=$(realpath "${1:-site-out}")
mkdir -p "$out/deb" "$out/rpm"
cp -r site/. "$out/"
touch "$out/.nojekyll"
ls dist/*/*.deb > /dev/null 2>&1 || exit 0
cp dist/*/*.deb "$out/deb/"
cp dist/*/*.rpm "$out/rpm/"

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
