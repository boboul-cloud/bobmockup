//
//  CreationLayout.swift
//  Bobmockup
//
//  Modes de création. Chaque mode décrit une disposition réelle
//  d'appareils dans le cadre, pas un simple préréglage de couleur.
//  Le diagramme est monoline et montre l'agencement obtenu :
//  une vignette doit annoncer le résultat, pas se contenter d'être jolie.
//

import SwiftUI

enum CreationLayout: String, CaseIterable, Identifiable, Codable {
    case single   = "Épreuve"
    case duo      = "Duo"
    case series   = "Série App Store"
    case banner   = "Bande"

    var id: String { rawValue }

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }

    var detail: LocalizedStringKey { LocalizedStringKey(detailText) }

    var detailText: String {
        switch self {
        case .single:  "1 appareil"
        case .duo:     "2 appareils"
        case .series:  "5 écrans liés"
        case .banner:  "Paysage 16:9"
        }
    }

    /// Nombre d'images produites par un tirage dans ce mode.
    var frameCount: Int {
        switch self {
        case .single, .banner: 1
        case .duo: 1
        case .series: 5
        }
    }

    /// Format de sortie imposé par la disposition, s'il y en a un.
    var forcedExportSize: ExportSizePreset? {
        switch self {
        case .banner: .landscape169
        default: nil
        }
    }

    var requiresPremium: Bool {
        switch self {
        case .single, .duo: false
        case .series, .banner: true
        }
    }
}

// MARK: - Diagramme

/// Le diagramme d'un mode : des cadres monoline disposés exactement
/// comme ils le seront dans le tirage.
struct CreationLayoutDiagram: View {
    let layout: CreationLayout
    var side: CGFloat = 44

    var body: some View {
        Canvas { context, size in
            let stroke = GraphicsContext.Shading.color(.primary)
            for rect in frames(in: size) {
                let path = Path(roundedRect: rect, cornerRadius: min(3, rect.width / 4))
                context.stroke(path, with: stroke, lineWidth: 1.4)
            }
        }
        .frame(width: side, height: side)
        .accessibilityHidden(true)
    }

    private func frames(in size: CGSize) -> [CGRect] {
        let w = size.width, h = size.height
        switch layout {
        case .single:
            let fw = w * 0.30, fh = h * 0.70
            return [CGRect(x: (w - fw) / 2, y: (h - fh) / 2, width: fw, height: fh),
                    CGRect(x: (w - fw * 0.55) / 2, y: (h - fh * 0.45) / 2,
                           width: fw * 0.55, height: fh * 0.45)]
        case .duo:
            let fh = h * 0.62
            return [CGRect(x: w * 0.14, y: (h - fh) / 2 + h * 0.06, width: w * 0.27, height: fh),
                    CGRect(x: w * 0.51, y: (h - fh * 1.14) / 2, width: w * 0.32, height: fh * 1.14)]
        case .series:
            let fw = w * 0.15, fh = h * 0.48, gap = w * 0.04
            let total = fw * 5 + gap * 4
            return (0..<5).map { i in
                CGRect(x: (w - total) / 2 + CGFloat(i) * (fw + gap),
                       y: (h - fh) / 2, width: fw, height: fh)
            }
        case .banner:
            let bw = w * 0.88, bh = h * 0.40
            let outer = CGRect(x: (w - bw) / 2, y: (h - bh) / 2, width: bw, height: bh)
            let dh = bh * 0.86
            return [outer,
                    CGRect(x: outer.maxX - bw * 0.30, y: outer.midY - dh / 2,
                           width: bw * 0.13, height: dh)]
        }
    }
}
