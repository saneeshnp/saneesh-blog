// Run locally: swift scripts/prepare-photos.swift
// Uses only macOS frameworks. Output stays in ignored staging until selected manually.
import AppKit
import ImageIO
import UniformTypeIdentifiers
import CryptoKit

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let source = root.appendingPathComponent("Photos Original")
let output = root.appendingPathComponent("Photos Prepared")
let manager = FileManager.default
try manager.createDirectory(at: output, withIntermediateDirectories: true)
let datePattern = try NSRegularExpression(pattern: "(?:19|20)[0-9]{6}(?:_[0-9]{6})?")
let files = try manager.contentsOfDirectory(at: source, includingPropertiesForKeys: nil)
    .filter { ["jpg", "jpeg"].contains($0.pathExtension.lowercased()) }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
var preparedCount = 0
var originalBytes = 0
var webBytes = 0

for file in files {
    let name = file.deletingPathExtension().lastPathComponent
    let range = NSRange(name.startIndex..., in: name)
    guard let match = datePattern.firstMatch(in: name, range: range),
          let dateRange = Range(match.range, in: name) else {
        fatalError("Missing capture year in \(file.lastPathComponent)")
    }
    let year = String(name[dateRange].prefix(4))
    let digest = SHA256.hash(data: try Data(contentsOf: file)).prefix(6).map { String(format: "%02x", $0) }.joined()
    let filename = "photo-\(year)-\(digest).jpg"
    let destination = output.appendingPathComponent(filename)
    guard let imageSource = CGImageSourceCreateWithURL(file as CFURL, nil),
          let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
          let originalWidth = properties[kCGImagePropertyPixelWidth] as? Int,
          let originalHeight = properties[kCGImagePropertyPixelHeight] as? Int,
          let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: min(2400, max(originalWidth, originalHeight))
          ] as CFDictionary) else { fatalError("Cannot read \(file.lastPathComponent)") }
    // Render into a fresh sRGB bitmap: no source EXIF, GPS, IPTC or XMP survives.
    let width = thumbnail.width, height = thumbnail.height
    guard let context = CGContext(data: nil, width: width, height: height,
        bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fatalError("Bitmap failed") }
    context.interpolationQuality = .high
    context.draw(thumbnail, in: CGRect(x: 0, y: 0, width: width, height: height))
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    let fontSize = max(18, CGFloat(max(width, height)) * 0.015)
    let padding = max(16, CGFloat(min(width, height)) * 0.025)
    let text = "saneesh.net" as NSString
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: .regular),
        .foregroundColor: NSColor(calibratedWhite: 0.23, alpha: 0.85),
        .strokeColor: NSColor(calibratedWhite: 1, alpha: 0.6),
        .strokeWidth: -2
    ]
    let size = text.size(withAttributes: attributes)
    text.draw(at: NSPoint(x: CGFloat(width) - padding - size.width, y: padding), withAttributes: attributes)
    NSGraphicsContext.restoreGraphicsState()
    guard let finished = context.makeImage(),
          let writer = CGImageDestinationCreateWithURL(destination as CFURL, UTType.jpeg.identifier as CFString, 1, nil)
          else { fatalError("Cannot write \(filename)") }
    CGImageDestinationAddImage(writer, finished, [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary)
    guard CGImageDestinationFinalize(writer) else { fatalError("JPEG encoding failed") }
    originalBytes += (try manager.attributesOfItem(atPath: file.path)[.size] as! NSNumber).intValue
    webBytes += (try manager.attributesOfItem(atPath: destination.path)[.size] as! NSNumber).intValue
    preparedCount += 1
}
print("Prepared \(preparedCount) photos in Photos Prepared/. Originals: \(originalBytes) bytes; web copies: \(webBytes) bytes.")
print("Copy only selected JPEGs to content/photos/ and add their year, location, alt and optional note to index.md.")
