//
//  DeviceFrame.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 15/01/2026.
//  Mis à jour le 06/02/2026 — Couleurs d'appareil, positions, export, badges
//

import SwiftUI

// MARK: - Device Type

enum DeviceType: String, CaseIterable, Identifiable, Codable {
    case iPhone15Pro = "iPhone 15 Pro"
    case iPhone15 = "iPhone 15"
    case iPadPro = "iPad Pro"
    case macBookPro = "MacBook Pro"
    
    var id: String { rawValue }
    
    var aspectRatio: CGFloat {
        switch self {
        case .iPhone15Pro, .iPhone15:
            return 19.5 / 9
        case .iPadPro:
            return 4.3 / 3
        case .macBookPro:
            return 16 / 10
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .iPhone15Pro, .iPhone15:
            return 55
        case .iPadPro:
            return 20
        case .macBookPro:
            return 10
        }
    }
    
    var bezelWidth: CGFloat {
        switch self {
        case .iPhone15Pro:
            return 18
        case .iPhone15:
            return 20
        case .iPadPro:
            return 20
        case .macBookPro:
            return 15
        }
    }
    
    var frameColor: Color {
        switch self {
        case .iPhone15Pro:
            return Color(red: 0.2, green: 0.2, blue: 0.25)
        case .iPhone15:
            return Color(red: 0.1, green: 0.1, blue: 0.1)
        case .iPadPro:
            return Color(red: 0.15, green: 0.15, blue: 0.15)
        case .macBookPro:
            return Color(red: 0.75, green: 0.75, blue: 0.78)
        }
    }
    
    var icon: String {
        switch self {
        case .iPhone15Pro, .iPhone15:
            return "iphone"
        case .iPadPro:
            return "ipad"
        case .macBookPro:
            return "laptopcomputer"
        }
    }
    
    /// Couleurs disponibles pour ce type d'appareil
    var availableColors: [DeviceColor] {
        switch self {
        case .iPhone15Pro:
            return [.naturalTitanium, .blueTitanium, .whiteTitanium, .blackTitanium]
        case .iPhone15:
            return [.black, .blue, .green, .yellow, .pink]
        case .iPadPro:
            return [.silver, .spaceGray]
        case .macBookPro:
            return [.silver, .spaceGray]
        }
    }
}

// MARK: - Device Color

enum DeviceColor: String, CaseIterable, Identifiable, Codable {
    // iPhone 15 Pro — Titane
    case naturalTitanium = "Titane Naturel"
    case blueTitanium = "Titane Bleu"
    case whiteTitanium = "Titane Blanc"
    case blackTitanium = "Titane Noir"
    // iPhone 15 — Aluminium
    case black = "Noir"
    case blue = "Bleu"
    case green = "Vert"
    case yellow = "Jaune"
    case pink = "Rose"
    // iPad / Mac
    case silver = "Argent"
    case spaceGray = "Gris Sidéral"
    
    var id: String { rawValue }
    
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
    
    /// Dégradé multi-stops pour le contour métallique
    var frameGradientStops: [Gradient.Stop] {
        switch self {
        case .naturalTitanium:
            return [
                .init(color: Color(white: 0.62), location: 0),
                .init(color: Color(white: 0.42), location: 0.15),
                .init(color: Color(white: 0.52), location: 0.3),
                .init(color: Color(white: 0.38), location: 0.5),
                .init(color: Color(white: 0.48), location: 0.7),
                .init(color: Color(white: 0.35), location: 0.85),
                .init(color: Color(white: 0.55), location: 1),
            ]
        case .blueTitanium:
            return [
                .init(color: Color(red: 0.42, green: 0.45, blue: 0.55), location: 0),
                .init(color: Color(red: 0.30, green: 0.33, blue: 0.42), location: 0.2),
                .init(color: Color(red: 0.38, green: 0.40, blue: 0.50), location: 0.5),
                .init(color: Color(red: 0.28, green: 0.30, blue: 0.40), location: 0.8),
                .init(color: Color(red: 0.35, green: 0.38, blue: 0.48), location: 1),
            ]
        case .whiteTitanium:
            return [
                .init(color: Color(white: 0.82), location: 0),
                .init(color: Color(white: 0.72), location: 0.2),
                .init(color: Color(white: 0.78), location: 0.5),
                .init(color: Color(white: 0.68), location: 0.8),
                .init(color: Color(white: 0.75), location: 1),
            ]
        case .blackTitanium:
            return [
                .init(color: Color(white: 0.28), location: 0),
                .init(color: Color(white: 0.15), location: 0.2),
                .init(color: Color(white: 0.22), location: 0.5),
                .init(color: Color(white: 0.12), location: 0.8),
                .init(color: Color(white: 0.20), location: 1),
            ]
        case .black:
            return [
                .init(color: Color(white: 0.18), location: 0),
                .init(color: Color(white: 0.10), location: 0.3),
                .init(color: Color(white: 0.15), location: 0.6),
                .init(color: Color(white: 0.08), location: 1),
            ]
        case .blue:
            return [
                .init(color: Color(red: 0.35, green: 0.50, blue: 0.65), location: 0),
                .init(color: Color(red: 0.25, green: 0.40, blue: 0.55), location: 0.3),
                .init(color: Color(red: 0.30, green: 0.45, blue: 0.60), location: 0.6),
                .init(color: Color(red: 0.20, green: 0.35, blue: 0.50), location: 1),
            ]
        case .green:
            return [
                .init(color: Color(red: 0.42, green: 0.52, blue: 0.42), location: 0),
                .init(color: Color(red: 0.32, green: 0.42, blue: 0.32), location: 0.3),
                .init(color: Color(red: 0.38, green: 0.48, blue: 0.38), location: 0.6),
                .init(color: Color(red: 0.28, green: 0.38, blue: 0.28), location: 1),
            ]
        case .yellow:
            return [
                .init(color: Color(red: 0.65, green: 0.60, blue: 0.40), location: 0),
                .init(color: Color(red: 0.55, green: 0.50, blue: 0.30), location: 0.3),
                .init(color: Color(red: 0.60, green: 0.55, blue: 0.35), location: 0.6),
                .init(color: Color(red: 0.50, green: 0.45, blue: 0.28), location: 1),
            ]
        case .pink:
            return [
                .init(color: Color(red: 0.62, green: 0.48, blue: 0.50), location: 0),
                .init(color: Color(red: 0.52, green: 0.38, blue: 0.40), location: 0.3),
                .init(color: Color(red: 0.58, green: 0.44, blue: 0.46), location: 0.6),
                .init(color: Color(red: 0.48, green: 0.35, blue: 0.38), location: 1),
            ]
        case .silver:
            return [
                .init(color: Color(red: 0.78, green: 0.78, blue: 0.80), location: 0),
                .init(color: Color(red: 0.68, green: 0.68, blue: 0.72), location: 0.3),
                .init(color: Color(red: 0.74, green: 0.74, blue: 0.76), location: 0.6),
                .init(color: Color(red: 0.65, green: 0.65, blue: 0.70), location: 1),
            ]
        case .spaceGray:
            return [
                .init(color: Color(white: 0.38), location: 0),
                .init(color: Color(white: 0.22), location: 0.3),
                .init(color: Color(white: 0.30), location: 0.6),
                .init(color: Color(white: 0.20), location: 1),
            ]
        }
    }
    
    /// Couleur de swatch pour l'UI de sélection
    var swatchColor: Color {
        switch self {
        case .naturalTitanium: return Color(white: 0.52)
        case .blueTitanium: return Color(red: 0.35, green: 0.38, blue: 0.48)
        case .whiteTitanium: return Color(white: 0.78)
        case .blackTitanium: return Color(white: 0.18)
        case .black: return Color(white: 0.10)
        case .blue: return Color(red: 0.30, green: 0.45, blue: 0.60)
        case .green: return Color(red: 0.38, green: 0.48, blue: 0.38)
        case .yellow: return Color(red: 0.60, green: 0.55, blue: 0.35)
        case .pink: return Color(red: 0.58, green: 0.44, blue: 0.46)
        case .silver: return Color(red: 0.74, green: 0.74, blue: 0.76)
        case .spaceGray: return Color(white: 0.30)
        }
    }
    
    /// Couleur des boutons latéraux
    var buttonGradientColors: [Color] {
        let stops = frameGradientStops
        return [stops.first?.color ?? .gray, stops.last?.color ?? .gray]
    }
}

// MARK: - Caption Position

enum CaptionPosition: String, CaseIterable, Identifiable, Codable {
    case top = "Haut"
    case center = "Centre"
    case bottom = "Bas"
    
    var id: String { rawValue }
    
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
    
    var icon: String {
        switch self {
        case .top: return "arrow.up.to.line"
        case .center: return "arrow.up.and.down"
        case .bottom: return "arrow.down.to.line"
        }
    }
}

// MARK: - Export Size Preset

enum ExportSizePreset: String, CaseIterable, Identifiable, Codable {
    case iphone69 = "iPhone 6,9 pouces"
    case iphone67 = "iPhone 6,7 pouces"
    case iphone61 = "iPhone 6,1 pouces"
    case ipad129 = "iPad Pro 13 pouces"
    case landscape169 = "Bandeau paysage"
    case custom1080 = "Standard vertical"

    var id: String { rawValue }

    var localizedName: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }

    var size: CGSize {
        switch self {
        case .iphone69: return CGSize(width: 1320, height: 2868)
        case .iphone67: return CGSize(width: 1290, height: 2796)
        case .iphone61: return CGSize(width: 1179, height: 2556)
        case .ipad129: return CGSize(width: 2064, height: 2752)
        case .landscape169: return CGSize(width: 1600, height: 900)
        case .custom1080: return CGSize(width: 1080, height: 1920)
        }
    }

    /// La cote, telle qu'un imprimeur l'écrirait.
    var dimensionLabel: String {
        "\(Int(size.width)) × \(Int(size.height))"
    }

    var displayLabel: String { dimensionLabel }

    var isLandscape: Bool { size.width > size.height }

    var icon: String {
        switch self {
        case .iphone69, .iphone67, .iphone61: return "iphone"
        case .ipad129: return "ipad"
        case .landscape169: return "rectangle"
        case .custom1080: return "rectangle.portrait"
        }
    }

    /// Les formats effectivement exigés au dépôt, pour le tirage en lot.
    static let batchSet: [ExportSizePreset] = [.iphone69, .iphone67, .iphone61, .ipad129]
}

// MARK: - Badge

struct MockupBadge: Identifiable, Equatable, Codable {
    let id: UUID
    var text: String
    var style: BadgeStyle
    var position: BadgePosition
    
    init(text: String, style: BadgeStyle, position: BadgePosition) {
        self.id = UUID()
        self.text = text
        self.style = style
        self.position = position
    }
    
    static func == (lhs: MockupBadge, rhs: MockupBadge) -> Bool {
        lhs.id == rhs.id
    }
}

enum BadgeStyle: String, CaseIterable, Identifiable, Codable {
    case red = "Rouge"
    case blue = "Bleu"
    case green = "Vert"
    case orange = "Orange"
    case purple = "Violet"
    case black = "Noir"
    case white = "Blanc"
    
    var id: String { rawValue }
    
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
    
    var backgroundColor: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .black: return .black
        case .white: return .white
        }
    }
    
    /// Couleurs plus vives pour l'interface du panneau de contrôle
    var vibrantColor: Color {
        switch self {
        case .red: return Color(red: 1.0, green: 0.2, blue: 0.25)
        case .blue: return Color(red: 0.2, green: 0.45, blue: 1.0)
        case .green: return Color(red: 0.15, green: 0.75, blue: 0.35)
        case .orange: return Color(red: 1.0, green: 0.55, blue: 0.1)
        case .purple: return Color(red: 0.65, green: 0.3, blue: 1.0)
        case .black: return Color(red: 0.25, green: 0.25, blue: 0.3)
        case .white: return Color(red: 0.95, green: 0.95, blue: 0.97)
        }
    }
    
    var textColor: Color {
        switch self {
        case .white: return .black
        default: return .white
        }
    }
}

enum BadgePosition: String, CaseIterable, Identifiable, Codable {
    case topLeading = "Haut gauche"
    case topTrailing = "Haut droit"
    case bottomLeading = "Bas gauche"
    case bottomTrailing = "Bas droit"
    
    var id: String { rawValue }
    
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
    
    /// Libellé court, pour tenir dans un segmenté à quatre positions.
    var shortLabel: String {
        switch self {
        case .topLeading: return "Haut G."
        case .topTrailing: return "Haut D."
        case .bottomLeading: return "Bas G."
        case .bottomTrailing: return "Bas D."
        }
    }
    
    var alignment: Alignment {
        switch self {
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        }
    }
}

// MARK: - Badge Presets

extension MockupBadge {
    static let presets: [MockupBadge] = [
        MockupBadge(text: "NOUVEAU", style: .red, position: .topTrailing),
        MockupBadge(text: "v2.0", style: .blue, position: .topTrailing),
        MockupBadge(text: "GRATUIT", style: .green, position: .topLeading),
        MockupBadge(text: "N°1 APP STORE", style: .orange, position: .topLeading),
        MockupBadge(text: "CHOIX DE LA RÉDACTION", style: .white, position: .topTrailing),
        MockupBadge(text: "PROMO", style: .black, position: .bottomTrailing),
    ]
}
