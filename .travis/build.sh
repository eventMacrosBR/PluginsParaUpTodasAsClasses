#!/bin/bash

git fetch --unshallow
git checkout -b master
git submodule update --init --recursive

mkdir dist
zip -r dist/plugins.zip plugins/

