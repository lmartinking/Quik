Quik
====

![screenshot](https://img.itch.zone/aW1hZ2UvMTMxMDUvNDUzNTkucG5n/347x500/VV6Njs.png)

The source and assets for [Quik: Gravity Flip Platformer](https://irrationalidiom.com/quik).

**This is the develop branch, updated to use Flixel 4**

It is inspired by two games I love: _Cannabalt_ and _VVVVVV_.

You can still get a copy of the published version for:

* [Mac / Windows / Linux](https://irrationalidiom.itch.io/quik)
* [Android](https://play.google.com/store/apps/details?id=com.irrationalidiom.quik_release)

This game was created back in 2014, using Haxe and HaxeFlixel.

Most of the time was spent on level design, and code was fairly quick
to write (there are some scruffy parts across the code-base), but my
goal was to get a game released in a few months.

I am releasing the code now because I think this could help others
discover how fantastic the Haxe/HaxeFlixel platform is for making
cross-platform games! Not to mention, a nice resource for those 
learning to make their own games.

## Build

You will need Haxe, OpenFL/Lime and HaxeFlixel set up.

Then:

```
    lime -Drelease build mac -64
```

You can also use `build.sh` to create something similar to the actual
released binaries:

```
    ./build.sh mac_publish_release
```


## Code Tour

Most of the guts are in `source/Game.hx`, which is the main "game state".

Customised UI widgets are in `source/ui/`.

Of interest: There are some simple macros in `source/misc/MacroStuff.hx`
which are used to embed the compilation date, extract and return
the version from `Project.xml`, and obfuscate secrets used for HMAC in the code!

The secrets in this source have been changed so you can't fake high scores :-)

## Licence

The code is licenced under LGPLv3. See `LICENSE` and `COPYING.LESSER`.

The assets (graphics, sounds, music, levels) are Freeware, and cannot be 
distributed as part of a published work without permission.

Copyright (c) 2014 Lucas Martin-King.
