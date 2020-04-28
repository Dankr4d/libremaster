import os, streams, strutils # Required for laapatch
import winim # Required for resolutions

proc laapatch(path: cstring): cstring {.cdecl, exportc, dynlib.} =
  var fs: FileStream = newFileStream($path, fmReadWriteExisting)
  fs.setPosition(parseHexInt("00000146"))
  fs.write(byte(0x2E))
  fs.close()

# This should be outsourced later (have a look at the resolutions module in BF2142Unlocker project)
proc getAvailableResolutions(): seq[tuple[width, height: uint]] =
  var dm: DEVMODE # = [0]
  dm.dmSize = cast[WORD](sizeof((dm)))
  var iModeNum: cint = 0
  var lastResolution: tuple[width, height: uint] = (cast[uint](0), cast[uint](0))
  while EnumDisplaySettings(nil, iModeNum, addr(dm)) != 0:
    if dm.dmDisplayFixedOutput == 0:
      if lastResolution != (cast[uint](dm.dmPelsWidth), cast[uint](dm.dmPelsHeight)):
        result.add((cast[uint](dm.dmPelsWidth), cast[uint](dm.dmPelsHeight)))
      lastResolution = (cast[uint](dm.dmPelsWidth), cast[uint](dm.dmPelsHeight))
    inc(iModeNum)

proc resolutions(): cstring {.cdecl, exportc, dynlib.} =
  var str: string
  let resolutions: seq[tuple[width, height: uint]] = getAvailableResolutions()
  for idx, resolution in resolutions:
    str.add($resolution.width & "x" & $resolution.height)
    if idx < resolutions.high:
      str.add(";")
  return cstring(str)
