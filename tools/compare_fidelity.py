#!/usr/bin/env python3
"""Pixel comparison: Godot capture vs Enduro daytime reference (160×192, nearest)."""

from __future__ import annotations

import argparse
import struct
import zlib
from pathlib import Path


def read_png(path: Path):
    data = path.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    i = 8
    w = h = None
    idat = b""
    ct = 6
    while i < len(data):
        ln = struct.unpack(">I", data[i : i + 4])[0]
        tag = data[i + 4 : i + 8]
        chunk = data[i + 8 : i + 8 + ln]
        i += 12 + ln
        if tag == b"IHDR":
            w, h = struct.unpack(">II", chunk[:8])
            ct = chunk[9]
        elif tag == b"IDAT":
            idat += chunk
        elif tag == b"IEND":
            break
    raw = zlib.decompress(idat)
    ch = 4 if ct == 6 else 3 if ct == 2 else 1
    rows = []
    p = 0
    for _y in range(h):
        filt = raw[p]
        p += 1
        row = bytearray(raw[p : p + w * ch])
        p += w * ch
        if filt == 1:
            for x in range(ch, len(row)):
                row[x] = (row[x] + row[x - ch]) & 255
        elif filt == 2 and rows:
            prev = rows[-1]
            for x in range(len(row)):
                row[x] = (row[x] + prev[x]) & 255
        elif filt == 3:
            prev = rows[-1] if rows else bytes(len(row))
            for x in range(len(row)):
                left = row[x - ch] if x >= ch else 0
                row[x] = (row[x] + ((left + prev[x]) // 2)) & 255
        elif filt == 4:
            prev = rows[-1] if rows else bytes(len(row))

            def paeth(a, b, c):
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                return a if pa <= pb and pa <= pc else (b if pb <= pc else c)

            for x in range(len(row)):
                a = row[x - ch] if x >= ch else 0
                b = prev[x]
                c = prev[x - ch] if x >= ch else 0
                row[x] = (row[x] + paeth(a, b, c)) & 255
        rows.append(bytes(row))
    pix = []
    for y in range(h):
        r = rows[y]
        for x in range(w):
            o = x * ch
            pix.append((r[o], r[o + 1], r[o + 2]))
    return w, h, pix


def write_png(path: Path, w: int, h: int, rgb):
    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

    raw = b""
    for y in range(h):
        raw += b"\x00"
        for x in range(w):
            r, g, b = rgb[y * w + x]
            raw += bytes((r, g, b, 255))
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
    )


REGIONS = {
    "sky": (0, 0, 160, 64),
    "playfield": (0, 64, 160, 87),
    "panel": (0, 151, 160, 41),
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ref", type=Path, required=True)
    ap.add_argument("--godot", type=Path, required=True)
    ap.add_argument("--out-dir", type=Path, required=True)
    args = ap.parse_args()
    args.out_dir.mkdir(parents=True, exist_ok=True)

    rw, rh, rp = read_png(args.ref)
    gw, gh, gp = read_png(args.godot)
    assert (rw, rh) == (160, 192), (rw, rh)
    assert (gw, gh) == (160, 192), (gw, gh)

    diff = []
    abs_err = 0
    mismatch = 0
    for i in range(160 * 192):
        a, b = rp[i], gp[i]
        dr, dg, db = abs(a[0] - b[0]), abs(a[1] - b[1]), abs(a[2] - b[2])
        e = dr + dg + db
        abs_err += e
        if e > 30:
            mismatch += 1
            diff.append((min(255, dr * 3), min(255, dg * 3), min(255, db * 3)))
        else:
            diff.append((0, 0, 0))

    # Side-by-side and overlay (average)
    side = []
    for y in range(192):
        for x in range(160):
            side.append(rp[y * 160 + x])
        for x in range(160):
            side.append(gp[y * 160 + x])
    overlay = []
    for i in range(160 * 192):
        a, b = rp[i], gp[i]
        overlay.append(((a[0] + b[0]) // 2, (a[1] + b[1]) // 2, (a[2] + b[2]) // 2))

    write_png(args.out_dir / "diff_map.png", 160, 192, diff)
    write_png(args.out_dir / "side_by_side.png", 320, 192, side)
    write_png(args.out_dir / "overlay.png", 160, 192, overlay)

    report = []
    report.append(f"ref={args.ref}")
    report.append(f"godot={args.godot}")
    report.append(f"mean_abs_channel_error={abs_err / (160 * 192 * 3):.4f}")
    report.append(f"pixels_mismatch_gt30={mismatch} ({100.0 * mismatch / (160 * 192):.2f}%)")
    for name, (x, y, w, h) in REGIONS.items():
        e = 0
        n = 0
        m = 0
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                i = yy * 160 + xx
                a, b = rp[i], gp[i]
                de = abs(a[0] - b[0]) + abs(a[1] - b[1]) + abs(a[2] - b[2])
                e += de
                n += 1
                if de > 30:
                    m += 1
        report.append(f"region[{name}] mean_abs={e / (n * 3):.4f} mismatch_gt30={m}/{n}")

    report.append("")
    report.append("NOTE: Exact pixel identity is not claimed. JPEG source reference,")
    report.append("approximated TIA fonts, and scaled opponent masks prevent bit-identical")
    report.append("frames. Use images + regions as diagnostic; owner approval is final.")
    text = "\n".join(report) + "\n"
    (args.out_dir / "report.txt").write_text(text)
    print(text)


if __name__ == "__main__":
    main()
