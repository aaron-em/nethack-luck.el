nethack-luck.el
===============

Nethack's luck messages, for your convenience (and in your Eshell banner)

Copyright (C) 2013 Aaron Miller. All rights reversed.
Share and Enjoy!

Last revision: Wednesday, December 18, 2013, ca. 23:00.

This release of nethack-luck.el, and every future release, is
dedicated to the memory of Izchak Miller (1935-1994).

Author: Aaron Miller <me@aaron-miller.me>

This file is not part of Emacs.

This file is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation; either version 2, or (at your
option) any later version.

This file is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see `http://www.gnu.org/licenses`.

Commentary
----------

I thought it would be nifty to have my eshell buffers' banner
message show the same luck-modifier messages as Nethack does, so I
wrote this library which does that, using Nethack's own phase-of-moon
algorithm for maximum veracity.

This library also provides a function, `nethack-luck-message`,
which returns the message Nethack would include in its banner for
the given time, or for right now if no time is given; a function,
`nethack-luck-phase-of-moon`, which returns the current phase of
moon, calculated by Nethack's algorithm, as an integer; a function,
`nethack-luck-phase-name`, which returns the name corresponding to
an integer which `nethack-luck-phase-of-moon` might return; and a
few ancillary functions, which you might also find useful.

To use this code, drop this file into your Emacs load path, then
(require 'nethack-luck). This suffices to modify your default
Eshell banner with the Nethack luck message, if any.

The Eshell banner modification is made by means of advice around
`eshell-buffer-initialize`, so the value of `eshell-banner-message`
is not changed. (The advice obtains the Eshell banner, before
modifying it, via (eval eshell-banner-message), so it will behave
properly no matter what value you have assigned to
`eshell-banner-message`.)  If you wish to disable the Eshell banner
modification, and simply have `nethack-luck-message` and friends
available for your own purposes, set `nethack-luck-modify-banner`
to nil.

Bugs/TODO
---------

Currently, while the effect of the new moon on your luck is
identical to that in Nethack, there is no effect on your chance,
when you hear a cockatrice's or chickatrice's hissing, of
starting to turn to stone.

Miscellany
----------

The canonical version of this file is hosted in [my Github
repository][1]. If you didn't get it from there, great! I'm happy
to hear my humble efforts have achieved wide enough interest to
result in a fork hosted somewhere else. I'd be obliged if you'd
drop me a line to let me know about it.

[1]: https://github.com/aaron-em/nethack-luck.el
