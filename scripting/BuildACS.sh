#!/bin/bash

# compile ACS
./spcomp acs.sp -v:0

# Copy the new smx file into the test server
# *** Replace path with your servers SourceMod plugins folder location ***
cp ./acs.smx /home/steam/l4d2testing/left4dead2/addons/sourcemod/plugins/

# Print the timestamp of the build completion
timestamp=$(date +%Y-%m-%d\ %H:%M:%S)
echo "                                     COMPILED: " $timestamp