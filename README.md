Quik
====

![screenshot](https://img.itch.zone/aW1hZ2UvMTMxMDUvNDUzNTkucG5n/347x500/VV6Njs.png)

The source and assets for [Quik: Gravity Flip Platformer](https://irrationalidiom.com/quik).

**This is the develop branch, updated to use Flixel 4.**

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

### Known Working Versions of Dependencies

 * Haxe 4.5.2
 * HxCPP 4.2.1
 * Flixel 5.0.2
 * Lime 8.0.0
 * OpenFL 9.2.0
 * polygonal-core 1.0.4
 * polygonal-ds 1.4.1 (this may require a fix to the code in `de/polygonal/ds/Bits.hx`)
 * polygonal-printf 1.0.2-beta

### Then

```
    lime -Drelease build mac -64
```

You can also use `build.sh` to create something similar to the actual
released binaries:

```
    ./build.sh mac_publish_release
```


## Code Tour

NOTE: It helps to first know the basic structure of a HaxeFlixel game.
If unsure, have a look at the HaxeFlixel tutorials and demos first.

The entry point is `source/Main.hx`, but as you can see it pretty much brings up...

...the code in `source/Game.hx`, which is mostly glue around play states, saving, scores, etc.

Most of the gameplay guts are in `source/PlayState.hx`, which is the main "game state".

Loading levels (created using _Tiled_) is handled via `source/LevelLoader.hx` which delegates
things back to `PlayState`.

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
