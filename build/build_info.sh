#!/bin/sh

echo "" >> build.info || true
echo "Build-Info ${1}:" >> build.info || true
echo "==============================" >> build.info || true
cat "/etc/os-release" >> build.info || true
echo "git ${2}" >> build.info || true
echo "node $(node -v)" >> build.info || true
echo "npm $(npm -v)" >> build.info || true
