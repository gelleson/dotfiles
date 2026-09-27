import AppKit
// Australian flag stretched to a keycap, @2x. Union Jack canton on the left,
// Southern Cross on the right, navy field in between for the label.
let W = 448.0, H = 44.0
let ctx = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.translateBy(x: 0, y: H); ctx.scaleBy(x: 1, y: -1)   // top-left origin
let navy = CGColor(red: 1/255, green: 33/255, blue: 105/255, alpha: 1)
let red = CGColor(red: 228/255, green: 0, blue: 43/255, alpha: 1)
let white = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
ctx.setFillColor(navy); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))

// Union Jack, 2:1, full key height.
let cw = H * 2, ch = H
ctx.saveGState(); ctx.clip(to: CGRect(x: 0, y: 0, width: cw, height: ch))
func line(_ c: CGColor, _ w: Double, _ a: CGPoint, _ b: CGPoint) {
  ctx.setStrokeColor(c); ctx.setLineWidth(w); ctx.move(to: a); ctx.addLine(to: b); ctx.strokePath()
}
line(white, 9, .init(x: 0, y: 0), .init(x: cw, y: ch)); line(white, 9, .init(x: cw, y: 0), .init(x: 0, y: ch))
line(red, 3, .init(x: 0, y: 0), .init(x: cw, y: ch)); line(red, 3, .init(x: cw, y: 0), .init(x: 0, y: ch))
line(white, 14, .init(x: cw/2, y: 0), .init(x: cw/2, y: ch)); line(white, 14, .init(x: 0, y: ch/2), .init(x: cw, y: ch/2))
line(red, 8, .init(x: cw/2, y: 0), .init(x: cw/2, y: ch)); line(red, 8, .init(x: 0, y: ch/2), .init(x: cw, y: ch/2))
ctx.restoreGState()

func star(_ cx: Double, _ cy: Double, _ r: Double, _ points: Int) {
  let inner = points == 7 ? r * 0.44 : r * 0.4
  ctx.setFillColor(white); ctx.beginPath()
  for i in 0..<(points * 2) {
    let rad = i % 2 == 0 ? r : inner
    let a = Double(i) * .pi / Double(points) - .pi / 2
    let p = CGPoint(x: cx + rad * cos(a), y: cy + rad * sin(a))
    i == 0 ? ctx.move(to: p) : ctx.addLine(to: p)
  }
  ctx.closePath(); ctx.fillPath()
}
// Southern Cross: gamma top, beta left, delta right, alpha bottom, small epsilon.
let x0 = W - 58.0
star(x0 + 22, 8, 5.5, 7); star(x0 + 6, 21, 5.5, 7); star(x0 + 40, 17, 5, 7)
star(x0 + 23, 36, 6, 7); star(x0 + 31, 26, 3, 5)

let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
