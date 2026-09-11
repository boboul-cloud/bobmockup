//
//  ExportService.swift
//  Bobmockup
//
//  Toute la chaîne de tirage. Le rendu ne dépend que du mode ; la
//  destination n'intervient qu'à la toute fin, une fois les images prêtes.
//  N'importe quel mode peut donc aller dans la photothèque ou dans Fichiers.
//

import SwiftUI
import Photos
import ImageIO
import UniformTypeIdentifiers

struct ExportResult {
    var mode: ExportMode
    var destination: ExportDestination?
    var images: [UIImage] = []
    /// Fichiers à remettre à l'utilisateur via la feuille de partage —
    /// c'est le chemin vers Fichiers, iCloud Drive, AirDrop ou Mail.
    var fileURLs: [URL] = []
    /// Détail affiché sur l'écran de réussite.
    var detail: String
}

enum ExportError: LocalizedError {
    case renderFailed
    case photoAccessDenied
    case writeFailed

    var errorDescription: String? {
        switch self {
        case .renderFailed:
            "Le tirage n'a pas pu être rendu. Réduisez la taille d'export et réessayez."
        case .photoAccessDenied:
            "Bobmockup n'a pas accès à votre photothèque. Autorisez l'ajout de photos dans Réglages, ou choisissez Fichiers comme destination."
        case .writeFailed:
            "Le fichier n'a pas pu être écrit."
        }
    }
}

@MainActor
enum ExportService {

    // MARK: - Entrée principale

    /// Exécute un tirage complet. `progress` est appelé entre 0 et 1 pour que
    /// l'écran de tirage affiche une vraie avancée, pas une animation
    /// décorative. Le rappel est synchrone et sur l'acteur principal :
    /// différé, sa dernière valeur écraserait l'état final.
    static func run(mode: ExportMode,
                    destination: ExportDestination,
                    composition: CompositionSpec,
                    includeAlpha: Bool,
                    progress: @MainActor (Double) -> Void) async throws -> ExportResult {

        // Le presse-papiers ne produit pas de fichier : cas à part.
        if mode == .clipboard {
            let image = try render(composition, size: composition.exportSize)
            UIPasteboard.general.image = image
            progress(1)
            return ExportResult(mode: mode, images: [image], detail: "Presse-papiers · PNG")
        }

        // Le PDF n'est pas une image : il va toujours dans Fichiers.
        if mode == .pdf {
            let url = try renderPDF(composition)
            progress(1)
            return ExportResult(mode: mode, destination: .files, fileURLs: [url],
                                detail: "Vectoriel · 1 page · Fichiers")
        }

        // 1. Rendu — identique quelle que soit la destination.
        let renders = try await render(mode: mode, composition: composition) { value in
            progress(value * 0.8)
        }

        // 2. Remise.
        switch destination {
        case .photos:
            try await saveToPhotoLibrary(renders.map { try $0.pngData(includeAlpha: includeAlpha) })
            progress(1)
            return ExportResult(mode: mode, destination: .photos, images: renders.map(\.image),
                                detail: detailLine(renders, destination: .photos))

        case .files:
            var urls: [URL] = []
            for render in renders {
                urls.append(try writeTemporaryPNG(render.pngData(includeAlpha: includeAlpha),
                                                  named: render.name))
            }
            progress(1)
            return ExportResult(mode: mode, destination: .files, images: renders.map(\.image),
                                fileURLs: urls, detail: detailLine(renders, destination: .files))
        }
    }

    // MARK: - Rendu

    private struct Render {
        let image: UIImage
        /// Nom de fichier lisible — c'est lui qu'on retrouve dans Fichiers.
        let name: String

        /// Les octets PNG effectivement remis, quelle que soit la destination.
        /// Le choix d'alpha est appliqué une seule fois, à l'encodage : aucun
        /// cas de rendu ne peut l'oublier ni le contredire.
        func pngData(includeAlpha: Bool) throws -> Data {
            let data = includeAlpha ? image.pngData() : ExportService.opaquePNGData(image)
            guard let data else { throw ExportError.writeFailed }
            return data
        }
    }

    private static func render(mode: ExportMode,
                               composition rawComposition: CompositionSpec,
                               progress: @MainActor (Double) -> Void) async throws -> [Render] {

        // Un mode qui impose sa cote l'emporte sur le format de l'éditeur.
        var composition = rawComposition
        if let forced = mode.forcedExportSize { composition.exportSize = forced }

        switch mode {
        case .single:
            let image = try render(composition, size: composition.exportSize)
            progress(1)
            return [Render(image: image, name: name(composition.exportSize))]

        case .transparent:
            var spec = composition
            spec.transparentBackground = true
            let image = try render(spec, size: composition.exportSize)
            progress(1)
            return [Render(image: image, name: name(composition.exportSize, suffix: "detoure"))]

        case .appStore65:
            let image = try render(composition, size: composition.exportSize)
            progress(1)
            return [Render(image: image, name: name(composition.exportSize, suffix: "6-5"))]

        case .series:
            var renders: [Render] = []
            let frames = max(1, composition.screenshots.count)
            for index in 0..<frames {
                var spec = composition
                spec.activeScreenshotIndex = index
                renders.append(Render(image: try render(spec, size: composition.exportSize),
                                      name: name(composition.exportSize,
                                                 suffix: String(format: "%02d", index + 1))))
                progress(Double(index + 1) / Double(frames))
                await Task.yield()
            }
            return renders

        case .batch:
            var renders: [Render] = []
            let presets = ExportSizePreset.batchSet
            for (index, preset) in presets.enumerated() {
                var spec = composition
                spec.exportSize = preset
                renders.append(Render(image: try render(spec, size: preset), name: name(preset)))
                progress(Double(index + 1) / Double(presets.count))
                await Task.yield()
            }
            return renders

        case .pdf, .clipboard:
            return []
        }
    }

    static func render(_ spec: CompositionSpec, size: ExportSizePreset) throws -> UIImage {
        let renderer = ImageRenderer(content: ExportComposition(spec: spec))
        renderer.scale = 1
        renderer.isOpaque = !spec.transparentBackground
        renderer.proposedSize = ProposedViewSize(width: size.size.width, height: size.size.height)
        guard let image = renderer.uiImage else { throw ExportError.renderFailed }
        return image
    }

    static func renderPDF(_ spec: CompositionSpec) throws -> URL {
        let size = spec.exportSize.size
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Bobmockup-\(stamp()).pdf")

        let renderer = ImageRenderer(content: ExportComposition(spec: spec))
        renderer.proposedSize = ProposedViewSize(width: size.width, height: size.height)

        var didWrite = false
        renderer.render { _, drawInContext in
            var box = CGRect(origin: .zero, size: size)
            guard let consumer = CGDataConsumer(url: url as CFURL),
                  let context = CGContext(consumer: consumer, mediaBox: &box, nil)
            else { return }
            context.beginPDFPage(nil)
            drawInContext(context)
            context.endPDFPage()
            context.closePDF()
            didWrite = true
        }
        guard didWrite else { throw ExportError.writeFailed }
        return url
    }

    // MARK: - Destinations

    /// Aplatit le tirage et l'encode en PNG **sans canal alpha**.
    ///
    /// `pngData()` conserve la composante alpha du CGImage rendu, même quand
    /// toutes ses valeurs valent 255 : App Store Connect refuse alors la
    /// capture. On redessine donc sur un contexte dépourvu d'alpha
    /// (`noneSkipLast`), puis on encode par ImageIO, qui écrit un PNG
    /// truecolor à trois canaux.
    ///
    /// Le fond de secours ne couvre que les pixels qu'un rendu opaque
    /// n'aurait pas peints — il n'y en a pas en pratique.
    static func opaquePNGData(_ image: UIImage, background: UIColor = .black) -> Data? {
        guard let source = image.cgImage, source.width > 0, source.height > 0 else { return nil }

        guard let context = CGContext(data: nil,
                                      width: source.width,
                                      height: source.height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        else { return nil }

        let frame = CGRect(x: 0, y: 0, width: source.width, height: source.height)
        context.setFillColor(background.cgColor)
        context.fill(frame)
        context.draw(source, in: frame)

        guard let flattened = context.makeImage() else { return nil }

        let buffer = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            buffer, UTType.png.identifier as CFString, 1, nil
        ) else { return nil }
        CGImageDestinationAddImage(destination, flattened, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return buffer as Data
    }

    /// Écrit les données PNG, pas l'UIImage : `creationRequestForAsset(from:)`
    /// réencode en JPEG, ce qui recompresse le tirage et détruit la couche
    /// alpha du mode « appareil détouré ».
    static func saveToPhotoLibrary(_ payloads: [Data]) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else { throw ExportError.photoAccessDenied }

        try await PHPhotoLibrary.shared().performChanges {
            for data in payloads {
                let request = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                options.uniformTypeIdentifier = UTType.png.identifier
                request.addResource(with: .photo, data: data, options: options)
            }
        }
    }

    static func writeTemporaryPNG(_ data: Data, named name: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try? FileManager.default.removeItem(at: url)
        try data.write(to: url, options: .atomic)
        return url
    }

    // MARK: - Nommage et libellés

    private static func stamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter.string(from: .now)
    }

    private static func name(_ size: ExportSizePreset, suffix: String? = nil) -> String {
        let dimensions = "\(Int(size.size.width))x\(Int(size.size.height))"
        let tail = suffix.map { "-\($0)" } ?? ""
        return "Bobmockup-\(dimensions)\(tail)-\(stamp()).png"
    }

    private static func detailLine(_ renders: [Render], destination: ExportDestination) -> String {
        let count = renders.count
        let unit = count > 1 ? "fichiers" : "fichier"
        return "\(count) \(unit) · \(destination.pastTense)"
    }
}
