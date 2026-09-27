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
  flags(ctx)
  let png = NSBitmapImageRep(cgImage: ctx.makeImage()!).representation(using: .png, properties: [:])!
  try! png.write(to: URL(fileURLWithPath: "\(name).png"))
}
func dot(_ ctx: CGContext, _ x: Int, _ y: Int, _ r: Int, _ c: CGColor) {
  ctx.setFillColor(c); ctx.fillEllipse(in: CGRect(x: x - r, y: y - r, width: 2 * r, height: 2 * r))
}

func star(_ ctx: CGContext, _ cx: Double, _ cy: Double, _ r: Double, _ points: Int, _ c: CGColor) {
  ctx.setFillColor(c); ctx.beginPath()
  for i in 0..<(points * 2) {
    let rad = i % 2 == 0 ? r : r * (points == 7 ? 0.44 : 0.4)
    let a = Double(i) * .pi / Double(points) - .pi / 2
    let p = CGPoint(x: cx + rad * cos(a), y: cy + rad * sin(a))
    i == 0 ? ctx.move(to: p) : ctx.addLine(to: p)
  }
  ctx.closePath(); ctx.fillPath()
}

// Kazakhstan and Australia (no Union Jack, as on the bar's key), top right.
// Kept inside the strip the built-in display crops off, and below the bar.
func flags(_ ctx: CGContext) {
  let h = 200.0, w = 400.0, gap = 60.0, top = 220.0
  let au = CGRect(x: Double(W) - 480 - w, y: top, width: w, height: h)
  let kz = au.offsetBy(dx: -(w + gap), dy: 0)
  let gold = rgb(0xfec50c), white = rgb(0xffffff)

  func field(_ r: CGRect, _ c: CGColor) {
    ctx.saveGState(); ctx.addPath(CGPath(roundedRect: r, cornerWidth: 10, cornerHeight: 10, transform: nil))
    ctx.clip(); ctx.setFillColor(c); ctx.fill(r)
  }

  // Kazakhstan: sky blue, a 32-ray sun over a steppe eagle, ornament at the hoist.
  field(kz, rgb(0x00afca))
  let sx = kz.midX + 10, sy = kz.minY + h * 0.4
  ctx.setFillColor(gold)
  for i in 0..<32 {
    let a = Double(i) * .pi / 16, b = a + .pi / 32
    ctx.beginPath()
    ctx.move(to: CGPoint(x: sx + 38 * cos(a - .pi / 32), y: sy + 38 * sin(a - .pi / 32)))
    ctx.addLine(to: CGPoint(x: sx + 62 * cos(a), y: sy + 62 * sin(a)))
    ctx.addLine(to: CGPoint(x: sx + 38 * cos(b), y: sy + 38 * sin(b)))
    ctx.fillPath()
  }
  ctx.fillEllipse(in: CGRect(x: sx - 32, y: sy - 32, width: 64, height: 64))
  ctx.beginPath()   // eagle: two swept wings meeting under the sun
  ctx.move(to: CGPoint(x: sx - 110, y: sy + 70))
  ctx.addQuadCurve(to: CGPoint(x: sx, y: sy + 100), control: CGPoint(x: sx - 50, y: sy + 110))
  ctx.addQuadCurve(to: CGPoint(x: sx + 110, y: sy + 70), control: CGPoint(x: sx + 50, y: sy + 110))
  ctx.addQuadCurve(to: CGPoint(x: sx, y: sy + 116), control: CGPoint(x: sx + 50, y: sy + 128))
  ctx.addQuadCurve(to: CGPoint(x: sx - 110, y: sy + 70), control: CGPoint(x: sx - 50, y: sy + 128))
  ctx.fillPath()
  for i in 0..<7 {   // ornament column
    let cy = kz.minY + 18 + Double(i) * 27.3, cx = kz.minX + 30
    ctx.beginPath()
    ctx.move(to: CGPoint(x: cx, y: cy - 11)); ctx.addLine(to: CGPoint(x: cx + 11, y: cy))
    ctx.addLine(to: CGPoint(x: cx, y: cy + 11)); ctx.addLine(to: CGPoint(x: cx - 11, y: cy))
    ctx.fillPath()
  }
  ctx.restoreGState()

  // Australia: Commonwealth Star at the hoist, Southern Cross on the fly.
  field(au, rgb(0x012169))
  star(ctx, au.minX + w * 0.25, au.minY + h * 0.62, h * 0.15, 7, white)
  star(ctx, au.minX + w * 0.75, au.minY + h * 0.17, h * 0.07, 7, white)
  star(ctx, au.minX + w * 0.62, au.minY + h * 0.45, h * 0.07, 7, white)
  star(ctx, au.minX + w * 0.87, au.minY + h * 0.38, h * 0.07, 7, white)
  star(ctx, au.minX + w * 0.75, au.minY + h * 0.83, h * 0.07, 7, white)
  star(ctx, au.minX + w * 0.81, au.minY + h * 0.57, h * 0.04, 5, white)
  ctx.restoreGState()
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
