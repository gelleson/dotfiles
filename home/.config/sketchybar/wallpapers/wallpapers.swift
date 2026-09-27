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

// Kick75: LEGO studs on the Obsidian Black case, the flag cells as 1x1 bricks.
render("kick") { ctx in
  ctx.setFillColor(rgb(0x1c1c1e)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
  let s = 80
  for gy in 0..<(H / s) { for gx in 0..<(W / s) { dot(ctx, gx * s + s / 2, gy * s + s / 2, 24, rgb(0x232326)) } }
  for (col, base, stud) in flagCells {
    let x = (W / s - col) * s, y = 3 * s
    ctx.setFillColor(rgb(base)); ctx.fill(CGRect(x: x + 2, y: y + 2, width: s - 4, height: s - 4))
    dot(ctx, x + s / 2, y + s / 2, 24, rgb(stud))
  }
}

// Node75 Ink Gray: the dotted texture over graphite, the flag cells as larger
// dots, and its 5x2 LED matrix lit in the one orange accent.
render("node") { ctx in
  ctx.setFillColor(rgb(0x2b2c2f)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
  let s = 40
  for gy in 0..<(H / s) { for gx in 0..<(W / s) { dot(ctx, gx * s + s / 2, gy * s + s / 2, 4, rgb(0x35373b)) } }
  for (col, base, _) in flagCells { dot(ctx, (W / s - col) * s + s / 2, 6 * s + s / 2, 12, rgb(base)) }
  let lit: Set<Int> = [0, 1, 2, 5, 6]
  for i in 0..<10 {
    let x = 7 * s + (i % 5) * 2 * s, y = H - 9 * s + (i / 5) * 2 * s
    dot(ctx, x, y, 14, lit.contains(i) ? rgb(0xe0672a) : rgb(0x3d3f44))
  }
}

// Built-in keyboard only: a plain dark gradient, out of the way.
render("builtin") { ctx in
  let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                     colors: [rgb(0x1d1e22), rgb(0x0f1012)] as CFArray, locations: [0, 1])!
  ctx.drawLinearGradient(g, start: .zero, end: CGPoint(x: 0, y: H), options: [])
}
