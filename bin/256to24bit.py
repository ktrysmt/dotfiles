#! /usr/bin/python

# CC0

from __future__ import print_function


# 16 -> 231
red = 0
while red < 6:
  green = 0
  while green < 6:
    blue = 0
    while blue < 6:
      print ('{0:3d}:#{1:02x}{2:02x}{3:02x}'.format (16 + (red * 36) + (green * 6) + (blue * 1),
                                                     (red * 40 + 55) if red > 0 else 0,
                                                     (green * 40 + 55) if green > 0 else 0,
                                                     (blue * 40 + 55) if blue > 0 else 0))
      blue += 1
    green += 1
  red += 1

# 232 -> 255
gray = 0
while gray < 24:
  level = gray * 10 + 8
  print ('{0:3d}:#{1:02x}{2:02x}{3:02x}'.format (232 + gray, level, level, level))
  gray += 1