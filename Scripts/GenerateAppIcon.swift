import AppKit
import Foundation

let size = 1024
let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: size,
    pixelsHigh: size,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)!
let context = NSGraphicsContext(bitmapImageRep: bitmap)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
context.imageInterpolation = .high
context.shouldAntialias = true

func color(_ hex: UInt32, alpha: CGFloat = 1) -> NSColor {
    NSColor(
        calibratedRed: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: alpha
    )
}

func centeredPath(width: CGFloat, height: CGFloat, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: NSRect(x: -width / 2, y: -height / 2, width: width, height: height), xRadius: radius, yRadius: radius)
}

func transform(_ path: NSBezierPath, x: CGFloat, y: CGFloat, angle: CGFloat) -> NSBezierPath {
    let affine = NSAffineTransform()
    affine.translateX(by: x, yBy: y)
    affine.rotate(byDegrees: angle)
    return affine.transform(path)
}

func drawCard(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, angle: CGFloat, top: UInt32, bottom: UInt32, border: NSColor, shadowColor: NSColor) {
    let shape = transform(centeredPath(width: width, height: height, radius: 58), x: x, y: y, angle: angle)
    let shadow = NSShadow()
    shadow.shadowColor = shadowColor
    shadow.shadowBlurRadius = 34
    shadow.shadowOffset = NSSize(width: 0, height: -19)
    NSGraphicsContext.saveGraphicsState()
    shadow.set()
    NSGradient(colors: [color(top), color(bottom)])!.draw(in: shape, angle: 90)
    NSGraphicsContext.restoreGraphicsState()
    border.setStroke()
    shape.lineWidth = 3
    shape.stroke()
}

NSColor.clear.setFill()
NSRect(x: 0, y: 0, width: size, height: size).fill()

let iconShape = NSBezierPath(roundedRect: NSRect(x: 24, y: 24, width: 976, height: 976), xRadius: 218, yRadius: 218)
NSGraphicsContext.saveGraphicsState()
iconShape.addClip()
NSGradient(colors: [color(0x10162F), color(0x2A3976), color(0x5268B4)])!.draw(in: NSRect(x: 0, y: 0, width: size, height: size), angle: 42)

let glow = NSBezierPath(ovalIn: NSRect(x: 170, y: 575, width: 680, height: 530))
color(0x6279D6, alpha: 0.14).setFill()
glow.fill()

// A quiet glass-like rim gives the background depth without reducing the note's contrast.
let innerRim = NSBezierPath(roundedRect: NSRect(x: 40, y: 40, width: 944, height: 944), xRadius: 204, yRadius: 204)
color(0xDCE5FF, alpha: 0.15).setStroke()
innerRim.lineWidth = 3
innerRim.stroke()

// The offset sheets suggest multiple notes hovering in a small stack.
drawCard(x: 566, y: 526, width: 430, height: 516, angle: 14, top: 0xC7D5FF, bottom: 0x879BE0, border: color(0xFFFFFF, alpha: 0.32), shadowColor: color(0x080D23, alpha: 0.34))
drawCard(x: 528, y: 514, width: 452, height: 544, angle: 7, top: 0xF0F4FF, bottom: 0xC6D2F5, border: color(0xFFFFFF, alpha: 0.70), shadowColor: color(0x080D23, alpha: 0.28))

// Main warm paper note.
let paper = transform(centeredPath(width: 500, height: 596, radius: 62), x: 469, y: 490, angle: -7)
let paperShadow = NSShadow()
paperShadow.shadowColor = color(0x080D23, alpha: 0.46)
paperShadow.shadowBlurRadius = 39
paperShadow.shadowOffset = NSSize(width: 0, height: -23)
NSGraphicsContext.saveGraphicsState()
paperShadow.set()
NSGradient(colors: [color(0xFFFEF7), color(0xF9EFCF)])!.draw(in: paper, angle: 90)
NSGraphicsContext.restoreGraphicsState()
color(0xFFFFFF, alpha: 0.86).setStroke()
paper.lineWidth = 4
paper.stroke()

// Folded upper-right corner with a fine crease.
let fold = NSBezierPath()
fold.move(to: NSPoint(x: 0, y: 0))
// Draw in a rotated local coordinate system matching the front sheet.
NSGraphicsContext.saveGraphicsState()
let frontTransform = NSAffineTransform()
frontTransform.translateX(by: 469, yBy: 490)
frontTransform.rotate(byDegrees: -7)
frontTransform.concat()
let localFold = NSBezierPath()
localFold.move(to: NSPoint(x: 250, y: 298))
localFold.line(to: NSPoint(x: 154, y: 298))
localFold.line(to: NSPoint(x: 250, y: 202))
localFold.close()
color(0xE9DDAF).setFill()
localFold.fill()
color(0xD5C89A, alpha: 0.9).setStroke()
let crease = NSBezierPath()
crease.move(to: NSPoint(x: 154, y: 298))
crease.line(to: NSPoint(x: 250, y: 202))
crease.lineWidth = 3
crease.stroke()

// Three clear, rounded writing lines remain legible at small icon sizes.
let lineColor = color(0x53617D, alpha: 0.63)
for (index, width) in [CGFloat(232), CGFloat(287), CGFloat(198)].enumerated() {
    let line = NSBezierPath()
    let y = CGFloat(112 - index * 72)
    line.move(to: NSPoint(x: -157, y: y))
    line.line(to: NSPoint(x: -157 + width, y: y))
    line.lineWidth = 15
    line.lineCapStyle = .round
    lineColor.setStroke()
    line.stroke()
}
NSGraphicsContext.restoreGraphicsState()

// A small aqua glint communicates lift and motion.
let sparkle = NSBezierPath()
sparkle.move(to: NSPoint(x: 797, y: 821))
sparkle.curve(to: NSPoint(x: 818, y: 842), controlPoint1: NSPoint(x: 805, y: 822), controlPoint2: NSPoint(x: 810, y: 835))
sparkle.curve(to: NSPoint(x: 797, y: 863), controlPoint1: NSPoint(x: 826, y: 849), controlPoint2: NSPoint(x: 806, y: 857))
sparkle.curve(to: NSPoint(x: 776, y: 842), controlPoint1: NSPoint(x: 793, y: 858), controlPoint2: NSPoint(x: 784, y: 850))
sparkle.curve(to: NSPoint(x: 797, y: 821), controlPoint1: NSPoint(x: 768, y: 835), controlPoint2: NSPoint(x: 787, y: 827))
sparkle.close()
color(0x8DF2E1).setFill()
sparkle.fill()

NSGraphicsContext.restoreGraphicsState()
NSGraphicsContext.restoreGraphicsState()

let output = URL(fileURLWithPath: CommandLine.arguments[1])
let png = bitmap.representation(using: .png, properties: [:])!
try png.write(to: output)
print("Wrote \(output.path) (\(bitmap.pixelsWide)x\(bitmap.pixelsHigh))")
