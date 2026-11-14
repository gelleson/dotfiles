import AppKit
// Deterministic cutting mats matching the bar's three keyboard palettes.
// Regenerate here: swift wallpapers.swift   (kick-mat.png, node-mat.png, builtin-mat.png)
let W = 3456, H = 2234
let mat = CGRect(x: 128, y: 288, width: 3200, height: 1664)
let unit: CGFloat = 64

func rgb(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
  CGColor(red: CGFloat(hex >> 16 & 0xff) / 255, green: CGFloat(hex >> 8 & 0xff) / 255,
          blue: CGFloat(hex & 0xff) / 255, alpha: alpha)
}
func render(_ name: String, _ draw: (CGContext) -> Void) {
  let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0,
                      space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.translateBy(x: 0, y: CGFloat(H)); ctx.scaleBy(x: 1, y: -1)
  let previous = NSGraphicsContext.current
  NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: true)
  defer { NSGraphicsContext.current = previous }
  draw(ctx)
  let png = NSBitmapImageRep(cgImage: ctx.makeImage()!).representation(using: .png, properties: [:])!
  try! png.write(to: URL(fileURLWithPath: "\(name)-mat.png"))
}
func line(_ ctx: CGContext, _ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) {
  ctx.move(to: CGPoint(x: x1, y: y1)); ctx.addLine(to: CGPoint(x: x2, y: y2)); ctx.strokePath()
}
func dot(_ ctx: CGContext, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ color: CGColor) {
  ctx.setFillColor(color); ctx.fillEllipse(in: CGRect(x: x - r, y: y - r, width: 2 * r, height: 2 * r))
}
func label(_ text: String, _ x: CGFloat, _ y: CGFloat, _ color: UInt32) {
  let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.monospacedSystemFont(ofSize: 20, weight: .regular),
    .foregroundColor: NSColor(cgColor: rgb(color, 0.65))!,
  ]
  let size = (text as NSString).size(withAttributes: attributes)
  (text as NSString).draw(at: CGPoint(x: x - size.width / 2, y: y - size.height / 2), withAttributes: attributes)
}

let glyphs: [Character: [String]] = [
  "K": ["101", "101", "110", "101", "101"], "I": ["111", "010", "010", "010", "111"],
  "C": ["111", "100", "100", "100", "111"], "N": ["110", "101", "101", "101", "101"],
  "O": ["111", "101", "101", "101", "111"], "D": ["110", "101", "101", "101", "110"],
  "E": ["111", "100", "110", "100", "111"], "7": ["111", "001", "010", "010", "010"],
  "5": ["111", "100", "111", "001", "111"], "M": ["101", "111", "111", "101", "101"],
  "A": ["010", "101", "111", "101", "101"], "B": ["110", "101", "110", "101", "110"],
]
func pixels(_ text: String) -> [(Int, Int, Int)] {
  var out: [(Int, Int, Int)] = []
  for (i, ch) in text.enumerated() {
    for (r, row) in glyphs[ch]!.enumerated() {
      for (c, bit) in row.enumerated() where bit == "1" { out.append((4 * i + c, r, i)) }
    }
  }
  return out
}

let palettes: [(String, String, UInt32, UInt32, [UInt32])] = [
  ("kick", "KICK75", 0x1c1c1e, 0xa0a5a9, [0x4b9f4a, 0xf2cd37, 0x0055bf, 0xc91a09]),
  ("node", "NODE75", 0x161617, 0xa8a9ab, [0x3fbf8a, 0xe8b423, 0xe24a3b]),
  ("builtin", "MACBOOK", 0x111214, 0xe8e8e6, [0x0a84ff]),
]
for (name, title, base, ink, accents) in palettes {
  render(name) { ctx in
    ctx.setFillColor(rgb(base)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))

    // Half-unit subdivisions, with a heavier line every five units.
    for vertical in [true, false] {
      let count = Int((vertical ? mat.width : mat.height) / (unit / 2))
      for i in 0...count {
        let major = i % 10 == 0, whole = i % 2 == 0
        ctx.setStrokeColor(rgb(ink, major ? 0.32 : whole ? 0.16 : 0.07))
        ctx.setLineWidth(major ? 1.5 : 1)
        let offset = CGFloat(i) * unit / 2
        if vertical {
          line(ctx, mat.minX + offset, mat.minY, mat.minX + offset, mat.maxY)
        } else {
          line(ctx, mat.minX, mat.minY + offset, mat.maxX, mat.minY + offset)
        }
      }
    }
    ctx.setStrokeColor(rgb(ink, 0.45)); ctx.setLineWidth(2); ctx.stroke(mat)

    // Rulers remain inside the 16:9 crop, including their labels.
    for i in 0...50 {
      let x = mat.minX + CGFloat(i) * unit, tick: CGFloat = i % 5 == 0 ? 20 : 10
      line(ctx, x, mat.minY, x, mat.minY - tick)
      line(ctx, x, mat.maxY, x, mat.maxY + tick)
      if i % 5 == 0 {
        label(String(i), x, mat.minY - 40, ink); label(String(i), x, mat.maxY + 40, ink)
      }
    }
    for i in 0...26 {
      let y = mat.minY + CGFloat(i) * unit, tick: CGFloat = i % 5 == 0 ? 20 : 10
      line(ctx, mat.minX, y, mat.minX - tick, y)
      line(ctx, mat.maxX, y, mat.maxX + tick, y)
      if i % 5 == 0 { label(String(i), mat.minX - 44, y, ink) }
    }

    // A quarter protractor and the usual cutting angles, away from the title.
    let cx = mat.minX + 5 * unit, cy = mat.maxY - 4 * unit
    ctx.setStrokeColor(rgb(ink, 0.26)); ctx.setLineWidth(1.5)
    for radius in [2 * unit, 3 * unit, 4 * unit] {
      ctx.addArc(center: CGPoint(x: cx, y: cy), radius: radius, startAngle: -.pi / 2, endAngle: 0, clockwise: false)
      ctx.strokePath()
    }
    for degrees in stride(from: 0, through: 90, by: 5) {
      let angle = CGFloat(degrees) * .pi / 180
      let inner = 4 * unit - (degrees % 15 == 0 ? 18 : 8)
      line(ctx, cx + inner * cos(angle), cy - inner * sin(angle), cx + 4 * unit * cos(angle), cy - 4 * unit * sin(angle))
    }
    for degrees in [30, 45, 60] {
      let angle = CGFloat(degrees) * .pi / 180, length = 8 * unit
      line(ctx, cx, cy, cx + length * cos(angle), cy - length * sin(angle))
      label("\(degrees)°", cx + (length + 36) * cos(angle), cy - (length + 36) * sin(angle), ink)
    }
    dot(ctx, cx, cy, 5, rgb(accents[0], 0.8))

    let corners = [(mat.minX, mat.minY, 1.0, 1.0), (mat.maxX, mat.minY, -1.0, 1.0),
                   (mat.maxX, mat.maxY, -1.0, -1.0), (mat.minX, mat.maxY, 1.0, -1.0)]
    for (i, (x, y, dx, dy)) in corners.enumerated() {
      ctx.setStrokeColor(rgb(accents[i % accents.count], 0.8)); ctx.setLineWidth(4)
      ctx.move(to: CGPoint(x: x + dx * 32, y: y)); ctx.addLine(to: CGPoint(x: x, y: y))
      ctx.addLine(to: CGPoint(x: x, y: y + dy * 32)); ctx.strokePath()
    }

    let plate = CGRect(x: mat.maxX - 640, y: mat.minY, width: 640, height: 224)
    let titleFrame = CGRect(x: plate.maxX - 32 - CGFloat(4 * title.count - 1) * 20,
                            y: plate.minY + 40, width: CGFloat(4 * title.count - 1) * 20, height: 100)
    // Protect the name from the Studio Display crop and the 32pt status bar.
    let crop = (CGFloat(H) - CGFloat(W) * 9 / 16) / 2
    assert(CGRect(x: 0, y: crop + 64, width: CGFloat(W), height: CGFloat(H) - 2 * crop - 64).contains(plate))
    assert(plate.insetBy(dx: 24, dy: 24).contains(titleFrame))
    ctx.setFillColor(rgb(base)); ctx.fill(plate)
    ctx.setStrokeColor(rgb(ink, 0.32)); ctx.setLineWidth(1.5); ctx.stroke(plate)
    for (gx, gy, i) in pixels(title) {
      let x = titleFrame.minX + CGFloat(gx) * 20, y = titleFrame.minY + CGFloat(gy) * 20
      let color = name == "builtin" ? ink : accents[i % accents.count]
      if name == "node" {
        for j in 0..<4 { dot(ctx, x + 5 + CGFloat(j % 2) * 10, y + 5 + CGFloat(j / 2) * 10, 3.5, rgb(color)) }
      } else {
        ctx.setFillColor(rgb(color)); ctx.fill(CGRect(x: x + 1, y: y + 1, width: 18, height: 18))
        if name == "kick" { dot(ctx, x + 10, y + 10, 5, rgb(0xffffff, 0.18)) }
      }
    }
    for (i, color) in accents.enumerated() {
      ctx.setFillColor(rgb(color)); ctx.fill(CGRect(x: plate.minX + 32 + CGFloat(i) * 40, y: plate.minY + 176, width: 24, height: 16))
    }
    if name != "builtin" {
      // Four Kazakh sky-blue cells, a gap, four Australian navy cells.
      for i in 0..<8 {
        let x = plate.maxX - 32 - CGFloat(8 - i + (i < 4 ? 1 : 0)) * 16
        let y = plate.minY + 184, color: UInt32 = i < 4 ? 0x00afca : 0x012169
        if name == "node" {
          dot(ctx, x + 6, y, 5, rgb(color))
        } else {
          ctx.setFillColor(rgb(color)); ctx.fill(CGRect(x: x, y: y - 8, width: 12, height: 16))
          dot(ctx, x + 6, y, 3, rgb(0xffffff, 0.18))
        }
      }
    }
  }
}
