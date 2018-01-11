#!/bin/bash

set -e

[[ -f "$HOME/Haxe/environment" ]] && source $HOME/Haxe/environment

set -x

LIME="haxelib run lime"

VERSION=$(./build/get_version.py Project.xml)
[[ -z "$VERSION" ]] && exit 1

echo "*** Version: $VERSION ***"

function android_publish_testing ()
{
	CERT_PATH="$HOME/.keys/irrational_testing.keystore"
	CERT_ALIAS="testing"

	stamp=$( date "+%Y-%m-%d" )
	rm -f export/android/bin/bin/*.apk
	${LIME} -Dtesting build android --certificate-path=${CERT_PATH} --certificate-alias=${CERT_ALIAS}
	cp export/android/bin/bin/quik-release.apk "publish/android/quik-testing-${stamp}.apk"
}

function android_publish()
{
	local type="$1"

	CERT_PATH="$HOME/.keys/irrational_release.keystore"
	CERT_ALIAS="release"

	stamp=$( date "+%Y-%m-%d" )
	rm -Rf export/android/
	${LIME} -D${type} build android --certificate-path=${CERT_PATH} --certificate-alias=${CERT_ALIAS}
	cp export/android/bin/bin/quik-release.apk "publish/android/quik-${type}-${stamp}.apk"
}

function android_publish_release ()
{
	android_publish release
}

function android_publish_demo ()
{
	android_publish demo
}

function linux_publish()
{
	local type="$1"

	stamp=$( date "+%Y-%m-%d" )
	local buildarchs="x86 x64"
	local origin=$(pwd)

	for arch in $buildarchs ; do
		local bits=""
		local buildbits="-32"
		[[ "$arch" == "x64" ]] && bits="64"
		[[ "$arch" == "x64" ]] && buildbits="-64"

		local buildlog="linux-${arch}.log"

		cd $origin
		rm -Rf "export/linux${bits}/"
		${LIME} -D${type} build linux ${buildbits} > $buildlog

		local appdir="quik-${arch}"
		local apparchive="quik-${VERSION}-${arch}-${stamp}.tar.bz2"

		if [[ "$type" == "demo" ]] ; then
			apparchive="quik-${VERSION}-demo-${arch}-${stamp}.tar.bz2"
		fi
		
		cd export/linux${bits}/cpp/
		mv bin "${appdir}"

		# strip syms
		strip -s ${appdir}/quik

		# move original binary
		mv ${appdir}/quik ${appdir}/quik.bin

		# launch script
		cp ${origin}/platform/linux/quik ${appdir}/quik
		chmod 755 ${appdir}/quik

		# package
		tar -cjvf "${apparchive}" "${appdir}" --owner=65534 --group=100

		# publish
		echo "*** archive: ${apparchive}"
		cp "${apparchive}" "${origin}/publish/linux/"
	done

}

function linux_publish_release ()
{
	linux_publish release
}

function linux_publish_demo()
{
	linux_publish demo
}

function mac_publish()
{
	local type="$1"

	stamp=$( date "+%Y-%m-%d" )
	local origin=$(pwd)

	rm -Rf export/mac64
	lime -D${type} build mac -64

	cd export/mac64/cpp/bin

	local bundlename="Quik.app"
	[[ "$type" == "demo" ]] && bundlename="Quik (Demo).app"

	local appname=$( echo "$bundlename" | sed -e 's/.app//' )

	local dmgvolname="Quik"
	[[ "$type" == "demo" ]] && dmgvolname="Quik (Demo)"

	local dmgsize=15
	local dmgtmp=/tmp/quik.tmp.dmg
	local dmgmnt=/tmp/quik
	local dmg=/tmp/quik-${type}-${stamp}.dmg

	hdiutil create -ov -megabytes ${dmgsize} -fs HFS+ -nospotlight -volname "${dmgvolname}" ${dmgtmp}
	mkdir -p ${dmgmnt}
	hdiutil attach -mountpoint ${dmgmnt} ${dmgtmp}

	cp -pR "quik.app" "${dmgmnt}/${bundlename}"

	pushd "${dmgmnt}"
	ln -s /Applications .
	popd

	hdiutil detach "${dmgmnt}"

	hdiutil convert "${dmgtmp}" -format UDBZ -o "${dmg}"
	rm "${dmgtmp}"

	mv "${dmg}" "${origin}/publish/mac/"

	cd "$origin"
}

function mac_publish_demo()
{
	mac_publish demo
}

function mac_publish_release()
{
	mac_publish release
}

"$@"
