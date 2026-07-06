#!/usr/bin/env python3
import sys
from PIL import Image, ImageDraw

if len(sys.argv) != 3:
    print("Usage: make_avatar.py <input> <output>")
    sys.exit(1)

face_path = sys.argv[1]
out_path = sys.argv[2]

img = Image.open(face_path).convert('RGBA').resize((256, 256), Image.LANCZOS)
mask = Image.new('L', (256, 256), 0)
ImageDraw.Draw(mask).ellipse((0, 0, 255, 255), fill=255)
out = Image.new('RGBA', (256, 256), (0, 0, 0, 0))
out.paste(img, mask=mask)
out.save(out_path)
print("Avatar generated")
