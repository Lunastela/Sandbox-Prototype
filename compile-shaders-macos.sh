#!/bin/bash

# compile shaders

mkdir -p shader/build

# simple shader
./lib/build/bin/shaderc \
-f shader/v_simple.sc -o shader/build/v_simple.bin \
--platform osx --type vertex --verbose -i ./ -p metal

./lib/build/bin/shaderc \
-f shader/f_simple.sc -o shader/build/f_simple.bin \
--platform osx --type fragment --verbose -i ./ -p metal
