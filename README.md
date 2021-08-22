# daffy
A notebook/coding environment for the Fennel programming language which runs
from within the Warcraft client.

## Goals
1. Everything is fennel: if you use the tool, you should be able to hack on it.
1. Self hosted. Code for the ui lives in WoW and is modifiable. The actual
   addon only provides what is absolutely necessary to run code.
1. No lua support. There is already tooling supporting lua (Hack forks, Wowlua)
1. Modular. Other addons should be able to use pieces of daffy independantly
1. Multiuser. Users should be able to easily share and remix scripts. Weakauras
   is a good example of what we are chasing here.
1. Stable communicatiion protocols. Code for communication protocols is _not_ available
   from within the UI, and is only hackable by modifying the addon.
1. Embrace the Lua ecosystem over the WoW when needed. We are going to need to
   use packages from the Lua ecosystem. Our lives will be easier if we embrace
   lua idioms instead of WoW idioms. One example is lua packages vs LibStub. We
   aren't going to rewrite fennel to use LibStub, we will just use the lua
   idioms for loading packages.
1. You should be able to run the build from Linux, Windows Subsystem for Linux,
   or Mac OS X

## Why didn't you fork an existing tool?
Sadly I haven't found a tool like this with an open license.
Hack claims public domain, but that claim is not from the original author.
Wowlua seems to have no license whatsoever, so it is closed source.
I haven't that isn't one of these, or a fork of one of these.

## Setting up your dev environment
Setup your environment: `cp .env.example .env` and then modify `.env` according
to your system.

Install the tools for managing the dev environment:
* nix
** direnv
** lorri

These tools work on Macs, Linux, and WSL. You can roll without these, but
you are on your own in that case.

## Building
`make install`
