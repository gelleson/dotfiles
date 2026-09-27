import AppKit
// Wallpapers matching the bar's palettes, one per keyboard state.
// Regenerate: swift wallpapers.swift   (writes kick.png, node.png, builtin.png)
let W = 5120, H = 2880   // Studio Display; the built-in crops to fill

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

// Kick75: LEGO studs on the Obsidian Black case, four bricks in the accents.
render("kick") { ctx in
  ctx.setFillColor(rgb(0x1c1c1e)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
  let s = 80
  for gy in 0..<(H / s) { for gx in 0..<(W / s) { dot(ctx, gx * s + s / 2, gy * s + s / 2, 24, rgb(0x232326)) } }
  let bricks: [(UInt32, UInt32)] = [(0x4b9f4a, 0x5cb35b), (0xf2cd37, 0xf7dc6a), (0x0055bf, 0x1f6fd6), (0xc91a09, 0xdd3522)]
  for (i, (base, stud)) in bricks.enumerated() {
    let bx = W - s * (2 + 3 * (bricks.count - i)), by = H - s * 5
    ctx.setFillColor(rgb(base)); ctx.fill(CGRect(x: bx, y: by, width: 2 * s, height: 2 * s))
    for j in 0..<4 { dot(ctx, bx + s / 2 + (j % 2) * s, by + s / 2 + (j / 2) * s, 24, rgb(stud)) }
  }
}

// Node75 Ink Gray: the dotted texture over graphite, and its 5x2 LED matrix
// lit in the one orange accent.
render("node") { ctx in
  ctx.setFillColor(rgb(0x2b2c2f)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
  let s = 40
  for gy in 0..<(H / s) { for gx in 0..<(W / s) { dot(ctx, gx * s + s / 2, gy * s + s / 2, 4, rgb(0x35373b)) } }
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
