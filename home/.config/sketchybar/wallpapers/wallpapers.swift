import AppKit
// Wallpapers matching the bar's palettes, one per keyboard state.
// Regenerate: swift wallpapers.swift   (writes kick.png, node.png, builtin.png)
// The built-in's own size. The 16:9 Studio Display crops ~150px off the top
// and bottom instead, so nothing important sits near those edges.
let W = 3456, H = 2234

func rgb(_ hex: UInt32) -> CGColor {
  CGColor(red: CGFloat(hex >> 16 & 0xff) / 255, green: CGFloat(hex >> 8 & 0xff) / 255,
          blue: CGFloat(hex & 0xff) / 255, alpha: 1)
}
func render(_ name: String, _ draw: (CGContext) -> Void) {
  let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0,
                      space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.translateBy(x: 0, y: CGFloat(H)); ctx.scaleBy(x: 1, y: -1)   // top-left origin
  draw(ctx)
  let png = NSBitmapImageRep(cgImage: ctx.makeImage()!).representation(using: .png, properties: [:])!
  try! png.write(to: URL(fileURLWithPath: "\(name).png"))
}
func dot(_ ctx: CGContext, _ x: Int, _ y: Int, _ r: Int, _ c: CGColor) {
  ctx.setFillColor(c); ctx.fillEllipse(in: CGRect(x: x - r, y: y - r, width: 2 * r, height: 2 * r))
}

// Top right on each: four Kazakh sky-blue cells, a gap, four Australian navy.
// Below the bar and inside the Studio Display's crop. Returns the grid column
// for each cell, counted from the right edge, with its (base, highlight).
let flagCells: [(Int, UInt32, UInt32)] =
  (0..<4).map { (12 - $0, 0x00afca, 0x3cc6db) } + (0..<4).map { (6 - $0, 0x012169, 0x2a4f9e) }

// The keyboard's name in the center, in a 3x5 pixel font laid on the grid.
let glyphs: [Character: [String]] = [
  "K": ["101", "101", "110", "101", "101"], "I": ["111", "010", "010", "010", "111"],
  "C": ["111", "100", "100", "100", "111"], "N": ["110", "101", "101", "101", "101"],
  "O": ["111", "101", "101", "101", "111"], "D": ["110", "101", "101", "101", "110"],
  "E": ["111", "100", "110", "100", "111"], "7": ["111", "001", "010", "010", "010"],
  "5": ["111", "100", "111", "001", "111"],
]
// Grid cells (column, row, letter index) lit by `text`, centered on a grid of
// `cols` x `rows`. The index lets each letter take the next accent color.
func pixels(_ text: String, _ cols: Int, _ rows: Int) -> [(Int, Int, Int)] {
  let x0 = (cols - (4 * text.count - 1)) / 2, y0 = (rows - 5) / 2
  var out: [(Int, Int, Int)] = []
  for (i, ch) in text.enumerated() {
    for (r, line) in glyphs[ch]!.enumerated() {
      for (c, bit) in line.enumerated() where bit == "1" { out.append((x0 + 4 * i + c, y0 + r, i)) }
    }
  }
  return out
}

// Kick75: LEGO studs on the Obsidian Black case, KICK75 in bricks of its accents, four 2x2 bricks bottom left
// in the keyboard's accents, and the flag cells as 1x2
// bricks, the same height as those.
render("kick") { ctx in
  ctx.setFillColor(rgb(0x1c1c1e)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
  let s = 80
  for gy in 0..<(H / s) { for gx in 0..<(W / s) { dot(ctx, gx * s + s / 2, gy * s + s / 2, 24, rgb(0x232326)) } }
  let bricks: [(UInt32, UInt32)] = [(0x4b9f4a, 0x5cb35b), (0xf2cd37, 0xf7dc6a), (0x0055bf, 0x1f6fd6), (0xc91a09, 0xdd3522)]
  for (i, (base, stud)) in bricks.enumerated() {
    let bx = (2 + 3 * i) * s, by = (H / s - 5) * s
    ctx.setFillColor(rgb(base)); ctx.fill(CGRect(x: bx + 2, y: by + 2, width: 2 * s - 4, height: 2 * s - 4))
    for j in 0..<4 { dot(ctx, bx + s / 2 + (j % 2) * s, by + s / 2 + (j / 2) * s, 24, rgb(stud)) }
  }
  for (gx, gy, i) in pixels("KICK75", W / s, H / s) {
    let (base, stud) = bricks[i % bricks.count]
    ctx.setFillColor(rgb(base)); ctx.fill(CGRect(x: gx * s + 2, y: gy * s + 2, width: s - 4, height: s - 4))
    dot(ctx, gx * s + s / 2, gy * s + s / 2, 24, rgb(stud))
  }
  for (col, base, stud) in flagCells {
    let x = (W / s - col) * s, y = 3 * s
    ctx.setFillColor(rgb(base)); ctx.fill(CGRect(x: x + 2, y: y + 2, width: s - 4, height: 2 * s - 4))
    for j in 0..<2 { dot(ctx, x + s / 2, y + s / 2 + j * s, 24, rgb(stud)) }
  }
}

// Node75 Ink Gray: the perforated texture over the near-black case, NODE75 in
// dot-matrix dots of its accents, the flag
// cells as larger dots, and a 5x2 LED matrix lit in the mint Esc green.
render("node") { ctx in
  ctx.setFillColor(rgb(0x161617)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
  let s = 40
  for gy in 0..<(H / s) { for gx in 0..<(W / s) { dot(ctx, gx * s + s / 2, gy * s + s / 2, 4, rgb(0x242527)) } }
  let accents: [UInt32] = [0x3fbf8a, 0xe8b423, 0xe24a3b]   // mint, yellow, red
  for (px, py, i) in pixels("NODE75", W / s / 2, H / s / 2) {   // each font pixel is 2x2 dots
    for j in 0..<4 { dot(ctx, (2 * px + j % 2) * s + s / 2, (2 * py + j / 2) * s + s / 2, 12, rgb(accents[i % accents.count])) }
  }
  for (col, base, _) in flagCells { dot(ctx, (W / s - col) * s + s / 2, 6 * s + s / 2, 12, rgb(base)) }
  let lit: Set<Int> = [0, 1, 2, 5, 6]
  for i in 0..<10 {
    let x = 7 * s + (i % 5) * 2 * s, y = H - 9 * s + (i / 5) * 2 * s
    dot(ctx, x, y, 14, lit.contains(i) ? rgb(0x3fbf8a) : rgb(0x2e2f32))
  }
}

// Built-in keyboard only: a plain dark gradient, out of the way.
render("builtin") { ctx in
  let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                     colors: [rgb(0x1d1e22), rgb(0x0f1012)] as CFArray, locations: [0, 1])!
  ctx.drawLinearGradient(g, start: .zero, end: CGPoint(x: 0, y: H), options: [])
}
