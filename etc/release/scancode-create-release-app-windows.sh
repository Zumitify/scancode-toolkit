#!/bin/bash
#
# Copyright (c) nexB Inc. and others. All rights reserved.
# ScanCode is a trademark of nexB Inc.
# SPDX-License-Identifier: Apache-2.0
# See http://www.apache.org/licenses/LICENSE-2.0 for the license text.
# See https://github.com/nexB/scancode-toolkit for support or download.
# See https://aboutcode.org for more information about nexB OSS projects.
#

################################################################################
# ScanCode release build script for a macOS app archive
################################################################################

set -e
# Un-comment to trace execution
#set -x

operating_system=windows
python_dot_version=3.8
python_version=38
python_exe="py -$python_dot_version"
release_dir=scancode-toolkit-$(git describe --tags)

rm -rf $release_dir
mkdir -p $release_dir
echo -n "$python_exe" > $release_dir/PYTHON_EXECUTABLE
git describe --tags > $release_dir/SCANCODE_VERSION
thirdparty_dir=$release_dir/thirdparty
mkdir -p $thirdparty_dir

venv/bin/python etc/scripts/fetch_thirdparty.py \
  --requirements=requirements.txt \
  --dest $thirdparty_dir \
  --operating-system=$operating_system \
  --python-version=$python_version \
  --wheels --use-cached-index

venv/bin/python etc/scripts/fetch_thirdparty.py \
  --requirements=requirements-native.txt \
  --wheel-only extractcode \
  --wheel-only extractcode-7z \
  --wheel-only extractcode-libarchive \
  --wheel-only typecode-libmagic \
  --wheel-only packagedcode-msitools \
  --wheel-only rpm-inspector-rpm \
  --dest $thirdparty_dir \
  --sdists --use-cached-index

cp dist/scancode_*.whl $release_dir
mkdir -p $release_dir/etc
cp -r etc/thirdparty $release_dir/etc
cp -r \
  scancode.bat extractcode.bat configure.bat \
  *.rst \
  samples \
  *NOTICE *LICENSE *ABOUT \
  $release_dir

zipball=scancode-toolkit-$(git describe --tags)_py$python_dot_version-$operating_system.zip
mkdir -p release
zip -r release/$zipball $release_dir

set +e
set +x
