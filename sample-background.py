#!/usr/bin/env python
"""Sample the wallpaper strip using the primary monitor's fill crop."""
import json, subprocess, sys
from pathlib import Path
from PIL import Image, ImageOps
try:
    monitors = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"]))
    m = monitors[0]
    w, h = m["width"], m["height"]
    size = max(1, round(float(sys.argv[2]) * m.get("scale", 1)))
    path = Path.home() / ".local/state/omarchy/current/background"
    im = ImageOps.fit(ImageOps.exif_transpose(Image.open(path)).convert("RGB"), (w, h))
    position = sys.argv[1]
    boxes = {"top": (0,0,w,size), "bottom": (0,h-size,w,h), "left": (0,0,size,h), "right": (w-size,0,w,h)}
    rgb = im.crop(boxes[position]).resize((1,1), Image.Resampling.BOX).getpixel((0,0))
    print("#%02x%02x%02x" % rgb)
except Exception:
    print("#202020")
