#!/usr/bin/env python3
"""Map an accent hex colour to the closest papirus-folders colour name.

Usage: papirus_color.py '#a7cda8'  ->  green
Compares hue in OKLCh (perceptual), so pastel Material You accents still
land on the right family. Very low-chroma accents map to grey/bluegrey.
"""
import math
import sys

PAPIRUS = {
    "red": "#e53935", "carmine": "#a30002", "deeporange": "#f4511e",
    "orange": "#fb8c00", "yellow": "#ffca28", "green": "#66bb6a",
    "teal": "#16a085", "cyan": "#00bcd4", "darkcyan": "#45abb7",
    "blue": "#5294e2", "indigo": "#5c6bc0", "violet": "#7e57c2",
    "magenta": "#ca71df", "pink": "#f06292",
}


def _lin(c):
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def oklch(hex_):
    h = hex_.lstrip("#")
    r, g, b = (_lin(int(h[i:i + 2], 16)) for i in (0, 2, 4))
    l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    l, m, s = (x ** (1 / 3) for x in (l, m, s))
    L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
    a = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
    bb = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
    return L, math.hypot(a, bb), math.degrees(math.atan2(bb, a)) % 360


def closest(accent):
    L, C, H = oklch(accent)
    if C < 0.03:                       # essentially grey
        return "bluegrey" if 200 < H < 280 else "grey"
    best, best_d = None, 1e9
    for name, ref in PAPIRUS.items():
        rl, rc, rh = oklch(ref)
        dh = min(abs(H - rh), 360 - abs(H - rh))
        d = dh + 60 * abs(C - rc) + 20 * abs(L - rl)
        if d < best_d:
            best, best_d = name, d
    return best


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: papirus_color.py '#rrggbb'")
    print(closest(sys.argv[1]))
