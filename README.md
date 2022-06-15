# UAS_Ardupilot_Scripts (Work In Progress)

Competition Failsafe script for AUVSI SUAS



# Setup

## Hardware:

-Can be run on SITL through MAVProxy or Mission Planner

-Can be run on the SD card of a flight controller

- Note: Flight Controller must have 2MB of flash and 70kB of memory for lua scripting

## Ardupilot Parameters:
- SCR_ENABLE = 1

## For SITL:

-Scripts must be located in a folder called 'scripts'

- eg. C:\Users\username\Documents\Mission Planner\sitl\plane\scripts\COMP_FS.lua

## For Flight Contoller:

-Scripts must be located in a folder on the SD card called 'scripts'

- eg. F:\APM\scripts\COMP_FS.lua
